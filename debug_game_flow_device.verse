using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/UI }

debug_game_flow_device := class(creative_device):

    ### @editable系 ---------------------------------------------------------------------
    # 自作デバイス
    @editable
    SavePresetDevice:save_preset_device = save_preset_device{}
    
    @editable
    SelectPresetDevice:select_preset_device = select_preset_device{}
    
    @editable
    RoundUIDevice:round_ui_device = round_ui_device{}

    @editable
    BallisticTrackingDevice:ballistic_tracking_device = ballistic_tracking_device{}

    # いろいろ
    @editable
    ClassDesigners:[]class_designer_device = array{} # 要素１をクラス２のやつに、要素２をクラス３のやつに設定する必要がある
    @editable
    ClassSelectors:[]class_and_team_selector_device = array{}
    @editable
    NoneClassSelector:class_and_team_selector_device = class_and_team_selector_device{} # 試合終了時にクラスなしに設定する用

    @editable
    BarrierZones:[]barrier_device = array{} # ラウンド開始前の待機する場所

    @editable
    RiftPointVolumes:[]rift_point_volume_device = array{}

    @editable
    RoundSettingDevice:round_settings_device = round_settings_device{}

    # ゲーム終了後に有効化する系
    @editable
    GameEndMutator:mutator_zone_device = mutator_zone_device{}

    @editable
    BillBoard:billboard_device = billboard_device{}

    @editable
    MatchMakingDevice:matchmaking_portal_device = matchmaking_portal_device{}

    # HUD
    @editable
    MessageHud:hud_message_device = hud_message_device{}

    @editable
    CountDownHud:hud_message_device = hud_message_device{}

    @editable
    StartDelayHud:hud_message_device = hud_message_device{} # 試合開始直前のカウントダウンを表示するHUD（数字を大きめにしたいから別で用意）
    
    @editable
    VsMTHudDevice:hud_message_device = hud_message_device{}

    @editable
    VsETHudDevice:hud_message_device = hud_message_device{}

    @editable
    VictoryHudDevice:hud_message_device = hud_message_device{}

    @editable
    DefeatHudDevice:hud_message_device = hud_message_device{}

    @editable
    WinLoseHudDevice:hud_message_device = hud_message_device{}

    @editable
    LoseWinHudDevice:hud_message_device = hud_message_device{}

    # ムービーシーケンス
    @editable
    StageCinemaDevice:cinematic_sequence_device = cinematic_sequence_device{}
    ### ----------------------------------------------------------------------------------


    ### 変数 -----------------------------------------------------------------------------
    var GamePlayers:[]player = array{}

    var GameStarted:logic = false
    
    var IsBombActivated:logic = false # 爆弾が起動しているのかを記憶する（攻撃側が全員キルされても終わらないように）
    ### ----------------------------------------------------------------------------------


    ### 定数 -----------------------------------------------------------------------------
    WinningPoints:int = 3 # 先に何ラウンド取ったら勝利となるか

    SideSwitchNum:int = 2 # 何ラウンドごとに陣営を変更するか
    
    StartDelay:int = 3 # ラウンド開始前などに設ける時間

    RoundTime:int = 300

    VictoryAndDefeatTime:float = 5.0 # 勝利、敗北UIを表示する秒数

    PlayerStatsManager:player_stat_manager = player_stat_manager{}
    ### ----------------------------------------------------------------------------------


    ### イベント --------------------------------------------------------------------------
    KillEvent:event(agent) = event(agent){}
    
    BombStartEvent:event() = event(){} # 爆弾を起動したときに発火するイベント
    BombStopEvent:event() = event(){} # 爆弾を停止したときに発火するイベント
    BombEndEvent:event() = event(){} # 爆弾が爆発したときに発火するイベント
    ### ----------------------------------------------------------------------------------

    OnBegin<override>()<suspends>:void=
        # バリアを有効化
        for(BarrierZone:BarrierZones):
            BarrierZone.Enable()

        # バリスティックの仕掛けにイベントを登録する
        for(RiftPointVolume:RiftPointVolumes):
            RiftPointVolume.PlantEvent.Subscribe(RiftPlant)
            RiftPointVolume.DefuseEvent.Subscribe(RiftDefuse)
            RiftPointVolume.DetonateEvent.Subscribe(RiftDetonate)

        GameEndMutator.Disable()
        BillBoard.HideText()
        MatchMakingDevice.Disable()

        loop:
            if(GameStarted?):
                spawn{RoundStart()} # ラウンドスタート
                break
            else:
                Sleep(1.0)

    # ラウンドの処理を実行する関数
    RoundStart()<suspends>:void=
        var Count:int = 0
        var TeamRemainingMap:[team]int = map{}
        var TeamWinsMap:[team]int = map{}
        var PlayerTeamMap:[player]team = map{} # 退出したプレイヤーがどのチームに所属していたかを判定する用

        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        # 試合が終了していたらここで処理を終える
        for(Team:TeamArray, Agent := TeamCollection.GetAgents[Team][0]):
            OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
            if(PlayerStats := OPlayerStats?, PlayerStats.RoundWins >= WinningPoints):
                GameEndMutator.Enable()
                BillBoard.ShowText()
                MatchMakingDevice.Enable()
                EndGame() # 試合終了処理
                return

        Print("ラウンド開始")

        set GamePlayers = GetPlayspace().GetPlayers()

        # 現在のラウンド数を取得
        RoundCount := CalcRoundCount()

        # 陣営変更
        if(not RoundCount = 1 and Mod[RoundCount, SideSwitchNum] = 1):
            for(Index->ClassDesigner:ClassDesigners):
                for(Index2->ClassSelector:ClassSelectors, not Index = Index2):
                    for(Agent:ClassDesigner.GetClassMembers()):
                        ClassSelector.ChangeClass(Agent)
                
        # クラスに合わせてチームを設定する
        for(Index->ClassDesigner:ClassDesigners, Team := TeamArray[Index]):
            Agents := ClassDesigner.GetClassMembers()
            for(Agent:Agents):
                if. TeamCollection.AddToTeam[Agent, Team]
                if. set PlayerTeamMap[player[Agent]] = Team

        # 最初のラウンドだったら、ムービーを流す
        if(RoundCount = 1):
            SavePresetDevice.KillAllPresetsUI() # プリセット登録UIを全プレイヤーから削除する
            ShowVsUI() # 対戦相手を表示するUIを付与して、一定時間後に削除
            StageCinemaDevice.Play()
            StageCinemaDevice.StoppedEvent.Await()
            # プレイヤーの静止状態を解除する
            for(Player:GamePlayers, Fort := Player.GetFortCharacter[]):
                Fort.ReleaseFromStasis()

        # 陣営を表示
        RoundUIDevice.ShowHideSide(GamePlayers)

        # キルイベントを設定する
        for(Player:GamePlayers):
            if(FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)

        # TeamRemainingMap と TeamWinsMap を初期化する
        for(Team:TeamArray, RemainingNum := TeamCollection.GetAgents[Team].Length):
            if. set TeamRemainingMap[Team] = RemainingNum
        for(Team:TeamArray, Agent := TeamCollection.GetAgents[Team][0]):
            OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
            if(PlayerStats := OPlayerStats?, Wins := PlayerStats.RoundWins):
                if. set TeamWinsMap[Team] = Wins

        # ラウンドUIを初期化して表示
        RoundUIDevice.AddRoundStateUI(TeamRemainingMap, TeamWinsMap)

        # 武器を付与する（自作デバイスを使って実装した）
        for(Player:GamePlayers):
            SelectPresetDevice.MakePresetsUI(Player)
        spawn{DeleteSelectPresetUIs(30.0)} # 30秒たったら自動的に消えるようにする

        # ラウンド開始前に数秒カウントダウンする
        set Count = StartDelay
        StartDelayHud.Show(S2M("{Count}"))
        loop:
            Sleep(1.0)
            set Count -= 1
            if(Count <= 0):
                break
            StartDelayHud.SetText(S2M("{Count}"))
        StartDelayHud.Hide()

        # マップインジケーターを有効化する
        BallisticTrackingDevice.EnableMapIndicator()

        # バリアを無効化
        for(BarrierZone:BarrierZones):
            BarrierZone.Disable()
            
        # ラウンド終了待ち
        var ORoundWinTeam:?team = false
        race:
            loop: # プレイヤー退出待ち
                LeavingPlayer:player = GetPlayspace().PlayerRemovedEvent().Await()
                if. (Team := PlayerTeamMap[LeavingPlayer], set TeamRemainingMap[Team] -= 1)
                RoundUIDevice.UpdateRoundStateUI(TeamRemainingMap, TeamWinsMap)
                # ラウンド終了判定
                OWinTeam := CheckRoundEnd(TeamRemainingMap)
                if(WinTeam := OWinTeam?):
                    if(IsBombActivated?, WinTeam = TeamArray[1]):
                        Print("爆弾が解除されるまで負けではない")
                        Sleep(1000.0) # キル待ちをなくす（おそらくキルは発生しないが）
                    else:
                        set ORoundWinTeam = OWinTeam
                        break

            loop: # 一方のチームの全滅待ち
                EliminatedAgent := KillEvent.Await() # キルされたプレイヤー
                if. (Team := TeamCollection.GetTeam[EliminatedAgent], set TeamRemainingMap[Team] -= 1)
                RoundUIDevice.UpdateRoundStateUI(TeamRemainingMap, TeamWinsMap)
                # ラウンド終了判定
                OWinTeam := CheckRoundEnd(TeamRemainingMap)
                if(WinTeam := OWinTeam?):
                    if(IsBombActivated?, WinTeam = TeamArray[1]):
                        Print("爆弾が解除されるまで負けではない")
                        Sleep(1000.0) # キル待ちをなくす（おそらくキルは発生しないが）
                    else:
                        set ORoundWinTeam = OWinTeam
                        break

            block: # 制限時間終了（守備チームの勝利）
                set Count = RoundTime
                RoundUIDevice.UpdateRoundStateUITimeText(S2M("{CalcElapsedTime(Count)}"))

                loop:
                    Sleep(1.0)
                    set Count -= 1
                    RoundUIDevice.UpdateRoundStateUITimeText(S2M("{CalcElapsedTime(Count)}"))
                    if(Count <= 0, IsBombActivated?):
                        break
                        
                if(IsBombActivated?):
                    Sleep(1000.0) # 制限時間処理はなくす（45秒より長く停止させればいい）
                else:
                    set ORoundWinTeam = option{TeamArray[1]}

            block: # 爆弾設置
                BombStartEvent.Await()
                race:
                    block:
                        BombStopEvent.Await()
                        set ORoundWinTeam = option{TeamArray[1]} # 守備側の勝ち
                        Print("爆弾が解除されました")
                    block:
                        BombEndEvent.Await()
                        set ORoundWinTeam = option{TeamArray[0]} # 攻撃側の勝ち
                        Print("爆弾が爆発しました")

        ### ラウンド終了処理
        var OWinAgent:?agent = false
        if(RoundWinTeam := ORoundWinTeam?):
            # 持続データのラウンド勝利数の更新
            for(Agent:TeamCollection.GetAgents[RoundWinTeam]):
                PlayerStatsManager.UpdateRoundWinsStat(Agent)
                if(not OWinAgent?):
                    set OWinAgent = option{Agent}

            if. set TeamWinsMap[RoundWinTeam] += 1

            # ラウンド結果UIの表示
            RoundUIDevice.ShowBackground(GamePlayers)
            RoundUIDevice.ShowRoundResult(TeamWinsMap, RoundCount, ORoundWinTeam)
            if(Mod[RoundCount, SideSwitchNum] = 1): # 陣営を切り替える際に「SideSwitch」と表示する
                RoundUIDevice.ShowHideSideSwitch(GamePlayers)
            RoundUIDevice.HideBackground(GamePlayers)

        # ゲーム終了判定
        var OGameWinTeam:?team = false
        for(Team->Wins:TeamWinsMap):
            if(Wins >= WinningPoints):
                set OGameWinTeam = option{Team}

        if(GameWinTeam := OGameWinTeam?): # 勝者チームが存在していたら
            # 勝利、敗北UIを表示する
            for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
                if(Team = GameWinTeam):
                    for(Agent:Agents):
                        VictoryHudDevice.Show(Agent)
                else:
                    for(Agent:Agents):
                        DefeatHudDevice.Show(Agent)
            Sleep(VictoryAndDefeatTime)

            # 全プレイヤーをクラスなしに設定する
            for(Player:GamePlayers):
                NoneClassSelector.ChangeClass(Player)
            
        # ラウンドを終える
        if(WinAgent := OWinAgent?):
            RoundSettingDevice.EndRound(WinAgent)
                    


    # バリスティックの仕掛けを起動したときに実行する関数
    RiftPlant(Agent:agent):void=
        BombStartEvent.Signal()
        set IsBombActivated = true
        for(RiftPointVolume:RiftPointVolumes):
            RiftPointVolume.Disable()

        RoundUIDevice.HideRoundStateUITimeText() # 制限時間のテキストを非表示にする
        RoundUIDevice.UpdateRoundStateUIBallistic(true) # バリスティックの仕掛けの画像を表示

        PlayerStatsManager.UpdateCurrentStartBombsStat(Agent)
        
    # バリスティックの仕掛けを解除したときに実行する関数
    RiftDefuse(Agent:agent):void=
        BombStopEvent.Signal()

        PlayerStatsManager.UpdateCurrentStopBombsStat(Agent)

    # バリスティックの仕掛けを爆破したときに実行する関数
    RiftDetonate(Agent:agent):void=
        BombEndEvent.Signal()
    
    # 現在のラウンド数を算出する関数
    CalcRoundCount():int=
        var RoundCounts:[]int = array{0, 0}

        # 各チームのラウンド勝利数を取得
        for(Index->ClassDesigner:ClassDesigners, Agent := ClassDesigner.GetClassMembers()[0]):
            OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
            if:
                PlayerStats := OPlayerStats?
                Wins := PlayerStats.RoundWins
                set RoundCounts[Index] = Wins

        RoundCount := if(N := RoundCounts[0], N2 := RoundCounts[1]). N + N2 + 1 else. 1

        # 各チームでプレイヤーのラウンド勝利数が一致しているかを確認
        var SameFlag:logic = true
        for(ClassDesigner:ClassDesigners, SameFlag?):
            var Wins:int = 0
            for(Index->Agent:ClassDesigner.GetClassMembers(), SameFlag?):
                OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
                if(PlayerStats := OPlayerStats?):
                    if(Index = 0):
                        set Wins = PlayerStats.RoundWins
                    else if(not Wins = PlayerStats.RoundWins):
                        set SameFlag = false
                
        # 一致していなかったらバグってるので、ゲームを１ラウンドから始める
        if(SameFlag = false):
            for(Player:GamePlayers):
                PlayerStatsManager.SetGameStats(Player)

        return if(SameFlag = false). 1 else. RoundCount

    # messageを結合する関数（間に改行を挟む）
    CombineMsg<localizes>(Msg:message, Msg2:message):message="{Msg}\n{Msg2}"

    # 各チームのプレイヤーネームテキストを作成する関数
    GenPlayerNamesMsg():[team]message=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        var TeamMsgMap:[team]message = map{}

        for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
            for(Index->Agent:Agents):
                PlayerName := GetAgentName(Agent)
                if(Index = 0):
                    if. set TeamMsgMap[Team] = PlayerName
                else if(DeforeMsg := TeamMsgMap[Team]):
                    AfterMsg := CombineMsg(DeforeMsg, PlayerName)
                    if. set TeamMsgMap[Team] = AfterMsg

        return TeamMsgMap

    # 試合開始前に各チームのプレイヤーの名前を表示するUIを付与する関数
    ShowVsUI()<suspends>:void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        TeamMsgMap := GenPlayerNamesMsg()

        for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
            for(Agent:Agents):
                for(Team2->Msg:TeamMsgMap):
                    if(Team2 = Team):
                        VsMTHudDevice.Show(Agent, Msg)
                    else:
                        VsETHudDevice.Show(Agent, Msg)

        Sleep(5.0)

        for(Player:GamePlayers):
            VsMTHudDevice.Hide(Player)
            VsETHudDevice.Hide(Player)

    OnPlayerEliminated(Result:elimination_result):void=
        Print("キル発生!!")
        EliminatedFort:fort_character = Result.EliminatedCharacter # デスしたプレイヤー
        OEliminatorFort:?fort_character = Result.EliminatingCharacter # キルしたプレイヤー

        if(EliminatorFort := OEliminatorFort?, EliminatorAgent := EliminatorFort.GetAgent[]):
            PlayerStatsManager.UpdateCurrentKillsStat(EliminatorAgent)

        if(EliminatedAgent := EliminatedFort.GetAgent[]):
            PlayerStatsManager.UpdateCurrentDeathsStat(EliminatedAgent)
            KillEvent.Signal(EliminatedAgent)

    # 引数秒たったら、プリセット選択UIを削除する関数
    DeleteSelectPresetUIs(Limit:float)<suspends>:void=
        Sleep(Limit)
        SelectPresetDevice.KillAllPresetsUI()

    # ラウンド終了判定を行う関数
    CheckRoundEnd(TeamRemainingMap:[team]int):?team=
        var WinTeam:?team = false

        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        if(TeamRemainingMap[TeamArray[0]] <= 0):
            set WinTeam = option{TeamArray[1]}
        else if(TeamRemainingMap[TeamArray[1]] <= 0):
            set WinTeam = option{TeamArray[0]}

        return WinTeam

    # 引数で与えられた時間(s)を00:00の形にして返す関数
    CalcElapsedTime(StormRemainingTime:int):string=
        # 各値を算出
        var Seconds : int = 0 # 秒
        var Minutes : int = 0 # 分
        if:
            # 秒
            tmp_sec := Mod[StormRemainingTime, 60] 
            set Seconds = tmp_sec
            # 分
            tmp_min := Int[(StormRemainingTime - Seconds)*1.0 / 60.0]
            set Minutes = tmp_min

        # 文字列に変換するための準備
        var Minutes_zero : string = ""
        var Seconds_zero : string = ""
        if(Minutes < 10):
            set Minutes_zero = "0"
        if(Seconds < 10):
            set Seconds_zero = "0"

        return "{Minutes_zero}{Minutes}:{Seconds_zero}{Seconds}"

    # 試合が終了したラウンドの１つ後のラウンドで実行する関数
    EndGame():void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        var TeamWinsMap:[team]int = map{}
        var OWinningTeam:?team = false

        # TeamWinsMap と OWinningTeam を設定
        for(Team:TeamArray, Agent := TeamCollection.GetAgents[Team][0]):
            OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
            if:
                PlayerStats := OPlayerStats?
                set TeamWinsMap[Team] = PlayerStats.RoundWins
        for(Team->Wins:TeamWinsMap, Wins >= WinningPoints):
            set OWinningTeam = option{Team}

        # 試合結果の表示と、持続データへの反映
        if(WinningTeam := OWinningTeam?):
            GameResult := game_result:
                GamePlayers := GamePlayers
                TeamWinsMap := TeamWinsMap
                WinningTeam := WinningTeam
                TeamCollection := GetPlayspace().GetTeamCollection()
                WinLoseHudDevice := WinLoseHudDevice
                LoseWinHudDevice := LoseWinHudDevice
            GameResult.AddGameResultUI() # 試合結果を表示
            GameResult.SavePlayersResult() # 持続データを更新