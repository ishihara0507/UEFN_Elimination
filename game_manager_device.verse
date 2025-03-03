using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/UI }

S2M<localizes>(S:string):message = "{S}"
GetAgentName<localizes>(Agent:agent):message="{Agent}"

respawn_data := struct:
    Pos:vector3
    Rot:rotation

game_manager_device := class(creative_device):

    ### @editable --------------------------------------------------
    # 自作デバイス
    @editable
    SavePresetDevice:save_preset_device = save_preset_device{}

    @editable
    SelectPresetDevice:select_preset_device = select_preset_device{}

    @editable
    RoundUIDevice:round_ui_device = round_ui_device{}

    # いろいろ
    @editable
    MatchPlayerNum:int = 2 # 偶数にする

    @editable
    SideSwitchNum:int = 2 # 陣営変更するラウンド数

    @editable
    WinningPoints:int = 3

    @editable
    RoundTime:int = 300

    @editable
    PlayerSpawners:[]player_spawner_device = array{} # 持続データの初期化とペナルティ用に使う

    @editable
    AttackTeamTeleporters:[]teleporter_device = array{}
    @editable
    DefenceTeamTeleporters:[]teleporter_device = array{}

    @editable
    AttackClassSelector:class_and_team_selector_device = class_and_team_selector_device{} # 攻撃側のクラス（バリスティックの仕掛けを使用できる）
    @editable
    DefenceClassSelector:class_and_team_selector_device = class_and_team_selector_device{} # 守備側のクラス（バリスティックの仕掛けは使用できない）
    
    @editable
    BarrierZones:[]barrier_device = array{} # ラウンド開始前の待機する場所

    @editable
    RiftPointVolumes:[]rift_point_volume_device = array{}

    @editable
    ExplosiveDevices:[]explosive_device = array{}

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

    @editable
    ThankYouHudDevice:hud_message_device = hud_message_device{}
    ### ------------------------------------------------------------


    ### 定数 -------------------------------------------------------
    AddPenaltyTime:float = 600.0 # 試合中に退出した場合に付与されるペナルティ時間（秒）
    
    # プレイヤーの初期ステータス
    PlayerMaxHealth:float = 100.0
    PlayerMaxShield:float = 100.0
    
    StartDelay:int = 3 # テレポート前やゲーム直前などに設ける時間

    PlayerStatsManager:player_stat_manager = player_stat_manager{} # 持続データを更新するときに使うクラス
    ### ------------------------------------------------------------
    

    ### ゲーム中に変動する変数 -------------------------------------
    var GamePlayers:[]player = array{} # ゲームに参加するプレイヤー

    var TeamRemainingMap:[team]int = map{} # ラウンドごとの残りプレイヤーの数を保持するマップ
    
    var IsBombActivated:logic = false # 爆弾が起動しているのかを記憶する（攻撃側が全員キルされても終わらないように）

    var TeamWinsMap:[team]int = map{} # ラウンドの勝利回数を保持

    var WinningTeam:?team = false # ゲームに勝利したチーム
    
    var TeamStageTelepotersMap:[team][]teleporter_device = map{}

    var Team0ResDatas:[]respawn_data = array{} # 赤チームのリスポーン位置の配列
    var Team1ResDatas:[]respawn_data = array{} # 青チームのリスポーン位置の配列

    var PlayerKillsMap:[player]int = map{} # 各プレイヤーのキル数を保持
    var PlayerDeathsMap:[player]int = map{} # 各プレイヤーのデス数を保持
    var PlayerStartBombsMap:[player]int = map{} # 各プレイヤーの爆弾起動回数を保持
    var PlayerStopBombsMap:[player]int = map{} # 各プレイヤーの爆弾解除回数を保持
    ### ------------------------------------------------------------


    ### event() ----------------------------------------------------
    KillEvent:event(agent) = event(agent){} # キルの発生を管理するイベント

    BombStartEvent:event() = event(){} # 爆弾を起動したときに発火するイベント
    BombStopEvent:event() = event(){} # 爆弾を停止したときに発火するイベント
    BombEndEvent:event() = event(){} # 爆弾が爆発したときに発火するイベント

    KillRoundUIEvent:event() = event(){} # ラウンドUIを削除するイベント
    ### ------------------------------------------------------------

    OnBegin<override>()<suspends>:void=
        # デバイスにイベントを登録する
        for(PlayerSpawner:PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)

        # バリスティックの仕掛けにイベントを登録する
        for(RiftPointVolume : RiftPointVolumes):
            RiftPointVolume.PlantEvent.Subscribe(RiftPlant)
            RiftPointVolume.DefuseEvent.Subscribe(RiftDefuse)
            RiftPointVolume.DetonateEvent.Subscribe(RiftDetonate)

        # プレイヤーが揃うまで待機する
        loop:
            Players := GetPlayspace().GetPlayers()
            if(Players.Length >= MatchPlayerNum):
                Print("プレイヤーが揃ったのでゲームを開始する")
                var Count:int = StartDelay
                CountDownHud.Show(S2M("Game starts in: {Count}"))
                loop:
                    Sleep(1.0)
                    set Count -= 1
                    if(Count <= 0):
                        break
                    CountDownHud.SetText(S2M("Game starts in: {Count}"))
                CountDownHud.Hide()

                set GamePlayers = Players

                SplitPlayersToTeams() # チーム分けをする
                StartGameFlow() # ゲームを開始する
                break
            NeedPlayerNum:int = MatchPlayerNum - Players.Length
            MessageHud.Show(S2M("Waiting for {NeedPlayerNum} more players to join.")) # プレイヤー全員にHUDを表示
            Sleep(1.0)

    # バリスティックの仕掛けを起動したときに実行する関数
    RiftPlant(Agent:agent):void=
        BombStartEvent.Signal()
        set IsBombActivated = true
        for(RiftPointVolume:RiftPointVolumes):
            RiftPointVolume.Disable()
        if(Player := player[Agent]):
            if. set PlayerStartBombsMap[Player] += 1
        
    # バリスティックの仕掛けを解除したときに実行する関数
    RiftDefuse(Agent:agent):void=
        BombStopEvent.Signal()
        if(Player := player[Agent]):
            if. set PlayerStopBombsMap[Player] += 1

    # バリスティックの仕掛けを爆破したときに実行する関数
    RiftDetonate(Agent:agent):void=
        BombEndEvent.Signal()
        
    # 爆発したボムを復活させる関数
    ResetBombs():void=
        for(ExplosiveDevice:ExplosiveDevices):
            ExplosiveDevice.Reset()

    # プレイヤースポナーに対して設定する関数
    OnPlayerSpawn(Agent:agent):void=
        # 持続データの初期化（初めてのプレイだったら持続データをプレイヤーと結びつける）
        PlayerStatsManager.InitializePlayerStat(Agent)

        # ペナルティ関連の処理
        # ペナルティ付与
        OPlayerStat := PlayerStatsManager.GetPlayerStats(Agent)
        if(PlayerStat := OPlayerStat?, PlayerStat.InMatch = true):
            Print("ペナルティ付与対象のプレイヤーが参加しました。")
            CurrentUnixTime := GetSecondsSinceEpoch()
            PlayerStatsManager.UpdatePenaltyEndTimeStat(Agent, CurrentUnixTime + AddPenaltyTime)
            PlayerStatsManager.UpdateInMatchStat(Agent, false)

        # ペナルティが与えられているかを確認と、キックの実行
        OPlayerStat2 := PlayerStatsManager.GetPlayerStats(Agent) # 直前の処理でペナルティが付与されたかもしれないから、取得しなおす
        if(PlayerStat := OPlayerStat2?):
            PenaltyPeriod := PlayerStat.PenaltyEndTime - GetSecondsSinceEpoch()
            if(PenaltyPeriod <= 0.0):
                Print("ペナルティ終了済み")
                PlayerStatsManager.UpdatePenaltyEndTimeStat(Agent, -1.0) # ペナルティを初期値に設定
            else:
                Print("ペナルティ期間中")
                spawn{KickPenaltyPlayer(Agent, PenaltyPeriod)}

    # プレイヤーをキックする関数
    KickPenaltyPlayer(Agent:agent, PenaltyPeriod:float)<suspends>:void=
        var Minutes:int = 0 # ペナルティが解除されるまでの時間（分）。秒は切り上げ
        if(S := Int[PenaltyPeriod], M := Ceil(S / 60)):
            set Minutes = M

        if(Player := player[Agent]):
            MessageHud.Show(Agent, S2M("前回のプレイが正常に終了しなかったので、\n{Minutes}分後にもう一度お試しください。"))
            Sleep(5.0)
            MessageHud.Hide(Agent)
            Player.SendToLobby() # 強制的にロビーに戻す

    # チーム分けをする関数
    SplitPlayersToTeams():void=
        Players := Shuffle(GamePlayers)
        if:
            TeamPlayerNum := Quotient[MatchPlayerNum, 2]
            T1 := Players.Slice[0, TeamPlayerNum]
            T2 := Players.Slice[TeamPlayerNum]
        then:
            # 同じチーム同士はダメージを受けないようにするために、島設定のチーム機能を使う
            TeamCollection := GetPlayspace().GetTeamCollection()
            TeamArray := TeamCollection.GetTeams()
            for(Player:T1):
                if. TeamCollection.AddToTeam[Player, TeamArray[0]]
            for(Player:T2):
                if. TeamCollection.AddToTeam[Player, TeamArray[1]]

            if:
                # TeamWinsMapを初期化
                set TeamWinsMap[TeamArray[0]] = 0
                set TeamWinsMap[TeamArray[1]] = 0

                # TeamStageTelepotersMapを初期化する
                set TeamStageTelepotersMap[TeamArray[0]] = AttackTeamTeleporters
                set TeamStageTelepotersMap[TeamArray[1]] = DefenceTeamTeleporters

    # 全員をチームごとにステージにテレポートする関数
    TeleportAllPlayersToStage():void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        for(Team:TeamArray):
            if(Members := TeamCollection.GetAgents[Team], StageTeleporters := TeamStageTelepotersMap[Team]):
                for(Index->Member:Members):
                    if(StageTeleporter := StageTeleporters[Index]):
                        StageTeleporter.Teleport(Member)

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

    OnPlayerEliminated(Result:elimination_result):void=
        Print("キル発生!!")
        EliminatedFort:fort_character = Result.EliminatedCharacter # デスしたプレイヤー
        OEliminatorFort:?fort_character = Result.EliminatingCharacter # キルしたプレイヤー

        if(EliminatorFort := OEliminatorFort?, EliminatorPlayer := player[EliminatorFort.GetAgent[]]):
            if. set PlayerKillsMap[EliminatorPlayer] += 1

        if(EliminatedAgent := EliminatedFort.GetAgent[], EliminatedPlayer := player[EliminatedAgent]):
            if. set PlayerDeathsMap[EliminatedPlayer] += 1
            KillEvent.Signal(EliminatedAgent)

    # 引数秒たったら、プリセット選択UIを削除する関数
    DeleteSelectPresetUIs(Limit:float)<suspends>:void=
        Sleep(Limit)
        SelectPresetDevice.KillAllPresetsUI()

    # 各チームの残りプレイヤー数を確認して、ラウンドが終了するか否かを判定し、そのラウンドの勝利チームを決定する
    CheckRoundEnd():?team=
        var WinTeam:?team = false

        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        if(TeamRemainingMap[TeamArray[0]] <= 0):
            set WinTeam = option{TeamArray[1]}
        else if(TeamRemainingMap[TeamArray[1]] <= 0):
            set WinTeam = option{TeamArray[0]}

        return WinTeam
    
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
                
    # ゲーム全体の流れを実行する関数
    StartGameFlow()<suspends>:void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        var Count:int = 0
        var RoundCount:int = 0
        
        var OAttackTeam:?team = false
        var ODefenseTeam:?team = false

        # キル・デス・ボム設置マップを初期化
        for(Player:GamePlayers):
            if:
                set PlayerKillsMap[Player] = 0
                set PlayerDeathsMap[Player] = 0
                set PlayerStartBombsMap[Player] = 0
                set PlayerStopBombsMap[Player] = 0

        # 持続データの初期化（プレイヤースポナーでも行ってるけど、念のためもう一度行う）
        PlayerStatsManager.InitializeAllPlayers(GamePlayers)

        # 持続データのプレイヤーが試合に参加したという情報を true にする
        for(Player:GamePlayers):
            PlayerStatsManager.UpdateInMatchStat(Player, true)

        for(Player:GamePlayers):
            if(FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)

        SavePresetDevice.KillAllPresetsUI() # プリセット登録UIを全プレイヤーから削除する
        
        TeleportAllPlayersToStage()

        Sleep(1.0) # 一応ちょっと待つ

        ShowVsUI() # 対戦相手を表示するUIを付与して、一定時間後に削除

        RoundUIDevice.AddRoundStateUI(Self) # ラウンドUIを初期化して表示

        loop:
            set RoundCount += 1

            var RoundWinTeam:?team = false

            Print("ラウンド{RoundCount}!!")

            # バリアを有効化
            for(BarrierZone:BarrierZones):
                BarrierZone.Enable()

            if(RoundCount = 1): # 最初のラウンドだけリスポーン位置を記録する
                for(Agent:TeamCollection.GetAgents[TeamArray[0]]):
                    if(FortCharacter := Agent.GetFortCharacter[]):
                        set Team0ResDatas += array{
                            respawn_data{
                                Pos := FortCharacter.GetTransform().Translation,
                                Rot := FortCharacter.GetTransform().Rotation
                            }
                        }
                for(Agent:TeamCollection.GetAgents[TeamArray[1]]):
                    if(FortCharacter := Agent.GetFortCharacter[]):
                        set Team1ResDatas += array{
                            respawn_data{
                                Pos := FortCharacter.GetTransform().Translation,
                                Rot := FortCharacter.GetTransform().Rotation
                            }
                        }
            else: # 2ラウンド以降はプレイヤーを強制リスポーンすることで陣営変更を実現する
            # 第1ラウンドはテレポーターでTeam0はRedにTeam1はBlueにワープしている
                if(Mod[RoundCount, 2] = 0): # 偶数ラウンドの場合（2, 4, 6, ...）
                    for(Index->Agent:TeamCollection.GetAgents[TeamArray[0]]):
                        if. Agent.Respawn(Team1ResDatas[Index].Pos, Team1ResDatas[Index].Rot)
                        else:
                            Print("リスポーン関連のエラーが発生")
                    for(Index->Agent:TeamCollection.GetAgents[TeamArray[1]]):
                        if. Agent.Respawn(Team0ResDatas[Index].Pos, Team0ResDatas[Index].Rot)
                        else:
                            Print("リスポーン関連のエラーが発生")
                else: # 奇数ラウンドの場合（3, 5, 7, ...）
                    for(Index->Agent:TeamCollection.GetAgents[TeamArray[1]]):
                        if. Agent.Respawn(Team1ResDatas[Index].Pos, Team1ResDatas[Index].Rot)
                        else:
                            Print("リスポーン関連のエラーが発生")
                    for(Index->Agent:TeamCollection.GetAgents[TeamArray[0]]):
                        if. Agent.Respawn(Team0ResDatas[Index].Pos, Team0ResDatas[Index].Rot)
                        else:
                            Print("リスポーン関連のエラーが発生")

            # キルによってラウンドが終了した場合に、なぜかプレイヤーの静止が聞かなかった。
            # 次のように一瞬の待機を設けたら直った。
            # 多分リスポーン終了判定より先に静止処理が動いていたのだと思う。（静止中にリスポーンしたら静止は解除される）
            Sleep(0.0)

            RoundUIDevice.UpdateRoundStateUI(Self)

            # プレイヤーの体力・シールドを全回復する
            for(Player:GamePlayers, FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.SetHealth(PlayerMaxHealth)
                FortCharacter.SetShield(PlayerMaxShield)

            # 攻撃チームと守備チームの設定を行う
            if(RoundCount = 1 or Mod[RoundCount, SideSwitchNum] = 1):
                if(RoundCount = 1): # ラウンド１は、チーム１を攻撃チームに、チーム２を守備チームに設定する
                    if(Team1 := TeamArray[0], Team2 := TeamArray[1]):
                        set OAttackTeam = option{Team1}
                        set ODefenseTeam = option{Team2}
                else if(Mod[RoundCount, SideSwitchNum] = 1): # ３ラウンドごとに攻守を入れ替える
                    Tmp := OAttackTeam
                    set OAttackTeam = ODefenseTeam
                    set ODefenseTeam = Tmp

                # クラスを切り替える＋陣営をHUDで表示する
                if(AttackTeam := OAttackTeam?, Agents := TeamCollection.GetAgents[AttackTeam]):
                    for(Agent:Agents):
                        AttackClassSelector.ChangeClass(Agent)
                if(DefenseTeam := ODefenseTeam?, Agents := TeamCollection.GetAgents[DefenseTeam]):
                    for(Agent:Agents):
                        DefenceClassSelector.ChangeClass(Agent)

            # そのラウンドの陣営を表示する
            RoundUIDevice.ShowHideSide(Self, OAttackTeam, ODefenseTeam)

            # バリスティックの仕掛けを有効化する
            for(RiftPointVolume:RiftPointVolumes):
                RiftPointVolume.Enable()
                
            set IsBombActivated = false # 爆弾の起動判定をオフにする
        
            # 爆発したボムを復活させる
            ResetBombs()

            # ラウンド開始時の各チームの初期人数を設定＋プレイヤーとチームのMapを初期化する（プレイヤーが退出したとき用に作成してる）
            var PlayerTeamMap:[player]team = map{} # 退出したプレイヤーがどのチームに所属していたかを判定する用
            for(Team:TeamArray):
                if(TeamAgents := TeamCollection.GetAgents[Team], set TeamRemainingMap[Team] = TeamAgents.Length):
                    for(Agent:TeamAgents):
                        if. (Player := player[Agent], set PlayerTeamMap[Player] = Team)

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
            
            # バリアを無効化
            for(BarrierZone:BarrierZones):
                BarrierZone.Disable()

            race:
                loop: # プレイヤー退出待ち
                    LeavingPlayer:player = GetPlayspace().PlayerRemovedEvent().Await()
                    if. (Team := PlayerTeamMap[LeavingPlayer], set TeamRemainingMap[Team] -= 1)
                    RoundUIDevice.UpdateRoundStateUI(Self)
                    # ラウンド終了判定
                    OWinTeam := CheckRoundEnd()
                    if(WinTeam := OWinTeam?):
                        if(IsBombActivated?, DefenseTeam := ODefenseTeam?, WinTeam = DefenseTeam):
                            Print("爆弾が解除されるまで負けではない")
                            Sleep(1000.0) # キル待ちをなくす（おそらくキルは発生しないが）
                        else:
                            if. set TeamWinsMap[WinTeam] += 1
                            set RoundWinTeam = OWinTeam
                            break
                loop: # 一方のチームの全滅待ち
                    EliminatedAgent := KillEvent.Await() # キルされたプレイヤー
                    if. (Team := TeamCollection.GetTeam[EliminatedAgent], set TeamRemainingMap[Team] -= 1)
                    RoundUIDevice.UpdateRoundStateUI(Self)
                    # ラウンド終了判定
                    OWinTeam := CheckRoundEnd()
                    if(WinTeam := OWinTeam?):
                        if. set TeamWinsMap[WinTeam] += 1
                        set RoundWinTeam = OWinTeam
                        break
                block: # 制限時間終了（守備チームの勝利）
                    set Count = RoundTime
                    RoundUIDevice.UpdateRoundStateUITimeText(S2M("{CalcElapsedTime(Count)}"))

                    loop:
                        Sleep(1.0)
                        set Count -= 1
                        RoundUIDevice.UpdateRoundStateUITimeText(S2M("{CalcElapsedTime(Count)}"))
                        if(Count <= 0):
                            break
                            
                    if(IsBombActivated?):
                        Sleep(1000.0) # 制限時間処理はなくす（30秒より長く停止させればいい）
                    else:
                        OWinTeam := ODefenseTeam
                        if(WinTeam := OWinTeam?):
                            if. set TeamWinsMap[WinTeam] += 1
                            set RoundWinTeam = OWinTeam
                block: # 爆弾設置
                    BombStartEvent.Await()
                    var OWinTeam:?team = false
                    race:
                        block:
                            BombStopEvent.Await()
                            set OWinTeam = ODefenseTeam
                            Print("爆弾が解除されました")
                        block:
                            BombEndEvent.Await()
                            set OWinTeam = OAttackTeam
                            Print("爆弾が爆発しました")
                    if(WinTeam := OWinTeam?):
                        if. set TeamWinsMap[WinTeam] += 1
                        set RoundWinTeam = OWinTeam
            
            ### ラウンド終了処理
            # ラウンド結果UIの表示
            RoundUIDevice.ShowBackground(Self)
            RoundUIDevice.ShowRoundResult(Self, RoundCount, RoundWinTeam) # 4.0秒くらいここで処理が止まる
            if(Mod[RoundCount, SideSwitchNum] = 1): # 陣営を切り替える際に「SideSwitch」と表示する
                RoundUIDevice.ShowHideSideSwitch(Self)
            RoundUIDevice.HideBackground(Self)

            # ゲーム終了判定
            for(Team->TeamWins:TeamWinsMap):
                if(TeamWins >= WinningPoints):
                    set WinningTeam = option{Team}
                    break
        
        # ゲームを終了するフェーズ ------------------------------------------------------------------------
        RoundUIDevice.DeleteRoundStateUI() # ラウンドUIを削除

        # 持続データのプレイヤーが試合に参加したという情報を false にする
        for(Player:GamePlayers):
            PlayerStatsManager.UpdateInMatchStat(Player, false)
            
        if(TrueWinningTeam := WinningTeam?):
            for(Index->Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
                if(Team = WinningTeam):
                    Print("チーム{Index}が勝った")
                    for(Agent:Agents):
                        VictoryHudDevice.Show(Agent)
                else:
                    Print("チーム{Index}が負けた")
                    for(Agent:Agents):
                        DefeatHudDevice.Show(Agent)
        Sleep(5.0)

        # 試合結果の表示と、持続データへの反映
        GameResult := game_result{GameManagerDevice := Self, WinLoseHudDevice := WinLoseHudDevice, LoseWinHudDevice := LoseWinHudDevice}
        GameResult.AddGameResultUI()
        GameResult.SavePlayersResult()

        # 試合終了後エリアへワープさせる
        ThankYouHudDevice.SetDisplayTime(6.0)
        for(Index->Player:GamePlayers):
            ThankYouHudDevice.Show(Player)
