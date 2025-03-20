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

    # デバッグ用で新規に追加
    @editable
    EliminationDevice:elimination_manager_device = elimination_manager_device{}

    ### @editable系 ---------------------------------------------------------------------
    # 自作デバイス
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

    @editable # 試合後に変更されるクラス
    GameEndClassSelector:class_and_team_selector_device = class_and_team_selector_device{} 

    @editable
    BarrierZones:[]barrier_device = array{} # ラウンド開始前の待機する場所

    @editable
    ItemRemover:item_remover_device = item_remover_device{}

    @editable
    RiftPointVolumes:[]rift_point_volume_device = array{}

    @editable
    RoundSettingDevice:round_settings_device = round_settings_device{}

    @editable
    EliminationXPDevice:accolades_device = accolades_device{}
    @editable
    MatchPlayedXPDevice:accolades_device = accolades_device{}
    @editable
    VictoryXPDevice:accolades_device = accolades_device{}

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
    VictoryHudDevice:hud_message_device = hud_message_device{}

    @editable
    DefeatHudDevice:hud_message_device = hud_message_device{}

    @editable
    WinLoseHudDevice:hud_message_device = hud_message_device{}

    @editable
    LoseWinHudDevice:hud_message_device = hud_message_device{}

    @editable
    GoldHudDevice:hud_message_device = hud_message_device{}

    # ムービーシーケンス
    @editable
    StageCinemaDevice:cinematic_sequence_device = cinematic_sequence_device{}
    ### ----------------------------------------------------------------------------------


    ### 変数 -----------------------------------------------------------------------------
    var GamePlayers:[]player = array{}

    var GameAgents:[]agent = array{} ### 追加

    var GameStarted:logic = false
    
    var IsBombActivated:logic = false # 爆弾が起動しているのかを記憶する（攻撃側が全員キルされても終わらないように）
    ### ----------------------------------------------------------------------------------


    ### 定数 -----------------------------------------------------------------------------
    WinningPoints:int = 3 # 先に何ラウンド取ったら勝利となるか

    SideSwitchNum:int = 2 # 何ラウンドごとに陣営を変更するか
    
    StartDelay:int = 3 # ラウンド開始前などに設ける時間

    RoundTime:int = 180

    BallisticTime:int = 45 # バリスティックの仕掛けを起動してから爆発するまでの時間

    RoundResultDisplayTime:float = 4.0
    SideSwitchDisplayTime:float = 3.0
    VictoryAndDefeatTime:float = 5.0 # 勝利、敗北UIを表示する秒数

    PlayerStatsManager:player_stat_manager = player_stat_manager{}
    ### ----------------------------------------------------------------------------------


    ### イベント --------------------------------------------------------------------------
    KillEvent:event(agent) = event(agent){}
    
    BombStartEvent:event() = event(){} # 爆弾を起動したときに発火するイベント
    BombStopEvent:event() = event(){} # 爆弾を停止したときに発火するイベント
    BombEndEvent:event() = event(){} # 爆弾が爆発したときに発火するイベント
    BombCountStopEvent:event() = event(){} # 爆弾のカウントを停止するイベント
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
        var KilledPlayers:[]player = array{} # そのラウンドでキルされたプレイヤー（退出でReamingMapの値を減らす判定のために用意）
        var TeamRemainingMap:[team]int = map{}
        var TeamWinsMap:[team]int = map{}
        var AgentTeamMap:[agent]team = map{} ### var PlayerTeamMap:[player]team = map{} # 退出したプレイヤーがどのチームに所属していたかを判定する用

        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        Print("ラウンド開始")

        set GameAgents = GetPlayspace().GetParticipants() ### set GamePlayers = GetPlayspace().GetPlayers()
        
        for(Agent:GameAgents, Player := player[Agent]): ### 追加
            set GamePlayers += array{Player} ### 追加
            
        for(Player:GamePlayers, Fort := Player.GetFortCharacter[]):
            GoldHudDevice.Hide(Player)
            ItemRemover.Remove(Player)
            PlayerStatsManager.UpdateRoundCountStat(Player) # ラウンドカウント１増やす
            Fort.SetVulnerability(false) # ダメージ受けないようにする

        # 現在のラウンド数を取得
        RoundCount := CalcRoundCount()

        Print("現在のラウンド数: {RoundCount}")
                
        # クラスに合わせてチームを設定する
        for(Index->ClassDesigner:ClassDesigners, Team := TeamArray[Index]):
            Agents := ClassDesigner.GetClassMembers()
            for(Agent:Agents):
                if:
                    TeamCollection.AddToTeam[Agent, Team]
                    set AgentTeamMap[Agent] = Team
                then:
                    Print("チーム変更成功")

        # TeamRemainingMap と TeamWinsMap を初期化する
        for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team], set TeamRemainingMap[Team] = 0):
            Print("チームの長さ: {Agents.Length}")
            for(Agent:Agents, GameAgents.Find[Agent]):
                if. set TeamRemainingMap[Team] += 1
                then. Print("TeamReaminingMapに加算")
        for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]): ### for(Team:TeamArray, Agent := TeamCollection.GetAgents[Team][0]):
            for(Agent:Agents): ### 追加
                OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
                if(PlayerStats := OPlayerStats?, Wins := PlayerStats.RoundWins):
                    if. set TeamWinsMap[Team] = Wins
        for(Team:TeamArray, not TeamWinsMap[Team]): # プレイヤーが１人もいない状況の対策
            for(Team2:TeamArray, not Team = Team2):
                if(ETWins := TeamWinsMap[Team2]):
                    if. set TeamWinsMap[Team] = (RoundCount - 1) - ETWins
                    else. Print("失敗チームの設定に失敗")
                else:
                    Print("成功チームの取得に失敗")

        # 試合が終了していたらここで処理を終える
        for(Team->Wins:TeamWinsMap):
            if(Wins >= WinningPoints):
                Print("ゲーム終了！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！")
                GameEndMutator.Enable()
                BillBoard.ShowText()
                MatchMakingDevice.Enable()

                EndGame() # 試合終了処理
                return

        # 最初のラウンドだったら、ムービーを流す
        if(RoundCount = 1):
            StageCinemaDevice.Play()
            StageCinemaDevice.StoppedEvent.Await()
            # プレイヤーの静止状態を解除する
            for(Player:GamePlayers, Fort := Player.GetFortCharacter[]):
                Fort.ReleaseFromStasis()

        # 陣営を表示
        RoundUIDevice.ShowSide(GamePlayers)
        Sleep(SideSwitchDisplayTime)
        RoundUIDevice.HideSide(GamePlayers)

        # キルイベントを設定する
        EliminationDevice.EliminatedEvent.Subscribe(OnEliminatedEvent) ### 追加
        EliminationDevice.EliminationEvent.Subscribe(OnEliminationEvent) ### 追加
        # for(Player:GamePlayers):
        #     if(FortCharacter := Player.GetFortCharacter[]):
        #         FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)

        ### 追加
        Print("ラウンド開始時ーーーーーーーーーー")
        for(Index->Team:TeamArray, Wins := TeamWinsMap[Team]):
            Print("TeamWinsMap[{Index}] = {Wins}")
        Print("ーーーーーーーーーーーーーーーー")
        ###

        # ラウンドUIを初期化して表示
        RoundUIDevice.AddRoundStatusUI(TeamRemainingMap, TeamWinsMap)
        RoundUIDevice.UpdateRoundTimeText(S2M("{CalcElapsedTime(RoundTime)}"))

        # 武器を付与する（自作デバイスを使って実装した）
        for(Player:GamePlayers):
            spawn{SelectPresetDevice.MakePresetsUI(Player)}

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
        BallisticTrackingDevice.InitializeMapIndicators()

        # バリアを無効化
        for(BarrierZone:BarrierZones):
            Print("バリア無効化")
            BarrierZone.Disable()
        
        for(Player:GamePlayers, Fort := Player.GetFortCharacter[]):
            Fort.SetVulnerability(true) # ダメージ受けるようにする
            
        # ラウンド終了待ち
        Print("ラウンド開始！！！！！！！！！")
        var ORoundWinTeam:?team = false
        race:
            # block: # ラウンド開始時点で一方のチームが０人だったら、もう一方のチームを勝者として即座にラウンドを終了させるための処理
            #     Sleep(0.1)
            #     OWinTeam := CheckRoundEnd(TeamRemainingMap)
            #     if(WinTeam := OWinTeam?):
            #         set ORoundWinTeam = OWinTeam
            #     else:
            #         Sleep(1000.0) # ラウンドの最長時間より長ければ何秒でもいい

            loop: # プレイヤー退出待ち
                LeavingPlayer:player = GetPlayspace().PlayerRemovedEvent().Await()
                if:
                    not KilledPlayers.Find[LeavingPlayer] # 退出したプレイヤーがキルされていなかったら
                    Team := AgentTeamMap[LeavingPlayer] ### Team := PlayerTeamMap[LeavingPlayer] 
                    set TeamRemainingMap[Team] -= 1
                RoundUIDevice.UpdateRoundStatusUI(TeamRemainingMap, TeamWinsMap)
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
                if(EliminatedPlayer := player[EliminatedAgent], EliminatedPlayer.IsActive[]):
                    Print("キルされたプレイヤーアクティブ")
                else. Print("キルされたプレイヤー非アクティブ")

                if:
                    EliminatedPlayer := player[EliminatedAgent]
                    EliminatedPlayer.IsActive[]
                    set KilledPlayers += array{EliminatedPlayer}
                if: ### 
                    Team := TeamCollection.GetTeam[EliminatedAgent]
                    set TeamRemainingMap[Team] -= 1
                RoundUIDevice.UpdateRoundStatusUI(TeamRemainingMap, TeamWinsMap)
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
                RoundUIDevice.UpdateRoundTimeText(S2M("{CalcElapsedTime(Count)}"))

                loop:
                    Sleep(1.0)
                    set Count -= 1
                    RoundUIDevice.UpdateRoundTimeText(S2M("{CalcElapsedTime(Count)}"))
                    if(Count <= 0 or IsBombActivated?):
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

        # 爆弾を置けないようにする
        for(RiftPointVolume:RiftPointVolumes):
            RiftPointVolume.Disable()
        BombCountStopEvent.Signal()

        # セレクトウェポンUIを削除する
        SelectPresetDevice.KillAllPresetsUI()

        # プレイヤーがダメージを受けないようにする
        for(Player:GamePlayers, Fort := Player.GetFortCharacter[]):
            Fort.SetVulnerability(false)

        ### ラウンド終了処理
        var OWinAgent:?agent = false
        if(RoundWinTeam := ORoundWinTeam?):
            # もし一方のチームが０人だったら、もう一方のチームを勝利状態にする
            var NoneTeamFlag:logic = false
            for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
                var PlayerNum:int = 0
                for(Agent:Agents, GamePlayers.Find[Agent]):
                    set PlayerNum += 1
                if(PlayerNum < 1):
                    Print("人数が０人です")
                    set NoneTeamFlag = true
                    for(Team2:TeamArray, Team2 <> Team, Agents2 := TeamCollection.GetAgents[Team2]):
                        for(Agent:Agents2):
                            PlayerStatsManager.UpdateRoundWinsStat(Agent, WinningPoints)
                        if. set TeamWinsMap[Team2] = WinningPoints

            # 持続データのラウンド勝利数の更新
            for(Agent:TeamCollection.GetAgents[RoundWinTeam]):
                PlayerStatsManager.UpdateRoundWinsStat(Agent, 1)
                if(not OWinAgent?):
                    set OWinAgent = option{Agent}
            
            # ラウンド勝者チームからAgentが取れなかったら（勝者チームが全員退出した場合とか）
            # 基本実行されないはず
            if(not OWinAgent?): 
                for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
                    for(Agent:Agents, not OWinAgent?):
                        set OWinAgent = option{Agent}

            if. set TeamWinsMap[RoundWinTeam] += 1

            RoundUIDevice.ShowBackground(GamePlayers) # 暗転

            ### 追加
            Print("ラウンド終了時ーーーーーーーーーー")
            for(Index->Team:TeamArray, Wins := TeamWinsMap[Team]):
                Print("TeamWinsMap[{Index}] = {Wins}")
            Print("ーーーーーーーーーーーーーーーー")

            if(not NoneTeamFlag?):
                RoundUIDevice.ShowRoundResult(TeamWinsMap, RoundCount, ORoundWinTeam) # ラウンド結果UIの表示
                Sleep(RoundResultDisplayTime)
                RoundUIDevice.HideRoundResult(GamePlayers)
        else:
            Print("ラウンド勝利チームが取れなかった")

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
            for(Player:GamePlayers):
                VictoryHudDevice.Hide(Player)
                DefeatHudDevice.Hide(Player)

            # 全プレイヤーをクラスなしに設定する
            for(Agent:GameAgents):                   ### for(Player:GamePlayers):
                GameEndClassSelector.ChangeClass(Agent) ###     GameEndClassSelector.ChangeClass(Player)
            
        # ラウンドを終える
        if(WinAgent := OWinAgent?):
            # 陣営変更
            if(Mod[RoundCount, SideSwitchNum] = 0, not OGameWinTeam?):
                Print("陣営変更")
                var ATKMembers:[]agent = array{}
                var DEFMembers:[]agent = array{}

                RoundUIDevice.ShowSideSwitch(GamePlayers)
                for(Index->ClassDesigner:ClassDesigners):
                    if(Index = 0):
                        set ATKMembers = ClassDesigner.GetClassMembers()
                    else:
                        set DEFMembers = ClassDesigner.GetClassMembers()

                for(Index->ClassSelector:ClassSelectors):
                    if(Index = 0):
                        for(Agent:DEFMembers):
                            ClassSelector.ChangeClass(Agent)
                            Print(GetAgentName(Agent))
                            Print("クラスを攻撃側に変更")
                    else:
                        for(Agent:ATKMembers):
                            ClassSelector.ChangeClass(Agent)
                            Print(GetAgentName(Agent))
                            Print("クラスを守備側に変更")
                Sleep(SideSwitchDisplayTime)
                RoundUIDevice.HideSideSwitch(GamePlayers)

            RoundUIDevice.HideBackground(GamePlayers) # 暗転解除
            RoundUIDevice.HideRoundTimeText()
            RoundUIDevice.HideBallisticTime()
            RoundUIDevice.RemoveRoundStatusUI() # ラウンド進行状況UIを削除する

            # ラウンドを更新
            Print("ラウンドを更新")
            RoundSettingDevice.EndRound(WinAgent)
    

    # バリスティックの仕掛けが爆発するまでの制限時間を表示・更新する関数
    ShowBallisticTime()<suspends>:void=
        RoundUIDevice.ShowBallisticTime(S2M("{CalcElapsedTime(BallisticTime)}"))

        var Count:int = BallisticTime
        race:
            loop:
                Sleep(1.0)
                set Count -= 1
                RoundUIDevice.UpdateBallisticTimeText(S2M("{CalcElapsedTime(Count)}"))
                if(Count <= 0):
                    break
            block:
                BombEndEvent.Await()
                RoundUIDevice.UpdateBallisticTimeText(S2M("00:00"))
            block:
                BombCountStopEvent.Await()

    # バリスティックの仕掛けを起動したときに実行する関数
    RiftPlant(Agent:agent):void=
        BombStartEvent.Signal()

        RoundUIDevice.HideRoundTimeText() # 制限時間のテキストを非表示にする

        spawn{ShowBallisticTime()}

        set IsBombActivated = true
        for(RiftPointVolume:RiftPointVolumes):
            RiftPointVolume.Disable()

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
        var TrueCoundCount:int = 0
        var RoundCountSameFlag:logic = true
        var RoundWinSameFlag:logic = true

        # 全員のラウンドカウントが一致しているかを判定
        var OBeforeRoundCount:?int = false
        for(Player:GamePlayers):
            OPlayerStats := PlayerStatsManager.GetPlayerStats(Player)
            if(PlayerStats := OPlayerStats?, RoundCount := PlayerStats.RoundCount):
                if(BeforeRoundCount := OBeforeRoundCount?):
                    if(not RoundCount = BeforeRoundCount):
                        set RoundCountSameFlag = false
                else:
                    set OBeforeRoundCount = option{RoundCount}
                    set TrueCoundCount = RoundCount

        # 各チームのラウンド勝利数が一致しているかを判定
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
            var OBeforeRoundWins:?int = false
            for(Agent:Agents):
                OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
                if(PlayerStats := OPlayerStats?, RoundWins := PlayerStats.RoundWins):
                    if(BeforeRoundWins := OBeforeRoundWins?):
                        if(not RoundWins = BeforeRoundWins):
                            set RoundWinSameFlag = false
                    else:
                        set OBeforeRoundWins = option{RoundWins}

        # 異なっていたら、試合状況をリセットする（試合が1ラウンドから始まる）
        if(not RoundCountSameFlag? or not RoundWinSameFlag?):
            for(Player:GamePlayers):
                PlayerStatsManager.SetGameStats(Player)
            set TrueCoundCount = 1
        
        return TrueCoundCount

    OnPlayerEliminated(Result:elimination_result):void=
        Print("キル発生!!")
        EliminatedFort:fort_character = Result.EliminatedCharacter # デスしたプレイヤー
        OEliminatorFort:?fort_character = Result.EliminatingCharacter # キルしたプレイヤー

        if(EliminatorFort := OEliminatorFort?, EliminatorAgent := EliminatorFort.GetAgent[]):
            Print("キルしたやつがいた！！")
            EliminationXPDevice.Award(EliminatorAgent) # XPを与える
            PlayerStatsManager.UpdateCurrentKillsStat(EliminatorAgent)

        if(EliminatedAgent := EliminatedFort.GetAgent[]):
            Print("キルされたやつがいた！！")
            PlayerStatsManager.UpdateCurrentDeathsStat(EliminatedAgent)
            KillEvent.Signal(EliminatedAgent)

    ### 追加 Agentがキルされたときに実行される関数
    OnEliminatedEvent(Agent:agent):void=
        Print("キル発生！")
        PlayerStatsManager.UpdateCurrentDeathsStat(Agent)
        KillEvent.Signal(Agent)
    
    ### 追加 Agentがキルしたときに実行される関数
    OnEliminationEvent(OAgent:?agent):void=
        if(Agent := OAgent?):
            PlayerStatsManager.UpdateCurrentKillsStat(Agent)

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

        # TeamWinsMap を作成
        for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]): ### for(Team:TeamArray, Agent := TeamCollection.GetAgents[Team][0]):
            for(Agent:Agents, Player := player[Agent], GamePlayers.Find[Player]): ### 追加
                OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
                if:
                    PlayerStats := OPlayerStats?
                    set TeamWinsMap[Team] = PlayerStats.RoundWins
        RoundCount := CalcRoundCount()
        Print("ゲーム終了時のラウンドカウント: {RoundCount}")
        for(Team:TeamArray, not TeamWinsMap[Team]): # プレイヤーが１人もいない状況の対策
            for(Team2:TeamArray, not Team = Team2, ETWins := TeamWinsMap[Team2]):
                if. set TeamWinsMap[Team] = (RoundCount - 1) - ETWins
                if:
                    TeamWinsMap[Team] < 0
                    set TeamWinsMap[Team] = 0

        # OWinningTeam 作成
        for(Team->Wins:TeamWinsMap):
            Print("勝利数: {Wins}")
            if(Wins >= WinningPoints):
                Print("勝利チーム！！！")
                set OWinningTeam = option{Team}
            else:
                Print("勝利チームではない")

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
        else:
            Print("勝利チームが取得できなかった")

        # XPを与える
        for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team], WinningTeam := OWinningTeam?):
            for(Agent:Agents):
                MatchPlayedXPDevice.Award(Agent)
                if(Team = WinningTeam):
                    VictoryXPDevice.Award(Agent)
