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

stage_data := struct<concrete>:
    @editable
    TeleportersRed:[]teleporter_device = array{}
    @editable
    TeleportersBlue:[]teleporter_device = array{}
    @editable
    FlagPos:vector3 = vector3{}

respawn_data := struct:
    Pos:vector3
    Rot:rotation

game_manager_device := class(creative_device):

    ### @editable --------------------------------------------------
    @editable
    MatchPlayerNum:int = 2 # 偶数にする

    @editable
    SideSwitchNum:int = 3 # 陣営変更するラウンド数

    @editable
    WinningPoints:int = 3

    @editable
    RoundTime:int = 300

    @editable
    Stages:[]stage_data = array{}

    @editable
    PlayerSpawners:[]player_spawner_device = array{}

    @editable
    WeaponGranter:item_granter_device = item_granter_device{} # 選択した武器を付与するデバイス

    @editable
    ItemRemover:item_remover_device = item_remover_device{}

    @editable
    FinishEriaPositions:[]vector3 = array{} # 試合終了後にリスポーンさせる場所。一応8人分用意する
    @editable
    FinishEriaRotation:rotation = rotation{} # 試合終了後エリアでのリスポーン時の向き
    
    # 自作デバイス
    @editable
    SavePresetDevice:save_preset_device = save_preset_device{}

    @editable
    SelectPresetDevice:select_preset_device = select_preset_device{}

    @editable
    RoundUIDevice:round_ui_device = round_ui_device{}

    # 爆弾系
    @editable
    ExplosiveDevicesA:[]explosive_device = array{}
    @editable
    ExplosiveDevicesB:[]explosive_device = array{}
    @editable
    LimitDevicesA:[]timed_objective_device = array{} # 0:チーム１が起動する側, 1:チーム２が起動する側
    @editable
    LimitDevicesB:[]timed_objective_device = array{} # 0:チーム１が起動する側, 1:チーム２が起動する側

    # HUD
    @editable
    MessageHud:hud_message_device = hud_message_device{}
    @editable
    CountDownHud:hud_message_device = hud_message_device{}
    @editable
    StartDelayHud:hud_message_device = hud_message_device{} # 試合開始直前のカウントダウンを表示するHUD（数字を大きめにしたいから別で用意）
    # @editable
    # FlagHud:hud_message_device = hud_message_device{} # ラウンド制限時間が終了して、フラッグが発生したことを知らせるHUD
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

    var UseStage:stage_data = stage_data{}

    var ResDataRed:[]respawn_data = array{} # 赤チームのリスポーン位置の配列
    var ResDataBlue:[]respawn_data = array{} # 青チームのリスポーン位置の配列

    var PlayerKillsMap:[player]int = map{} # 各プレイヤーのキル数を保持
    var PlayerDeathsMap:[player]int = map{} # 各プレイヤーのデス数を保持
    var PlayerBombsMap:[player]int = map{} # 各プレイヤーの爆弾起動数を保持
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
        
        for(LimitDevice:LimitDevicesA):
            LimitDevice.BeganEvent.Subscribe(OnLimitDeviceAStart)
            LimitDevice.PausedEvent.Subscribe(OnLimitDeviceStop)
            LimitDevice.CompletedEvent.Subscribe(OnLimitDeviceATimeOut)
        for(LimitDevice:LimitDevicesB):
            LimitDevice.BeganEvent.Subscribe(OnLimitDeviceBStart)
            LimitDevice.PausedEvent.Subscribe(OnLimitDeviceStop)
            LimitDevice.CompletedEvent.Subscribe(OnLimitDeviceBTimeOut)

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

                # すべてのプレイヤーをダメージを受けない状態にする
                for(Player:GamePlayers):
                    if(FortCharacter := Player.GetFortCharacter[]):
                        FortCharacter.SetVulnerability(false)

                # 今回のセッションで使用するステージをランダムで選択する
                if(RandomStage := Shuffle(Stages)[0]):
                    set UseStage = RandomStage

                SplitPlayersToTeams() # チーム分けをする
                StartGameFlow() # ゲームを開始する
                break
            NeedPlayerNum:int = MatchPlayerNum - Players.Length
            MessageHud.Show(S2M("Waiting for {NeedPlayerNum} more players to join.")) # プレイヤー全員にHUDを表示
            Sleep(1.0)

    # 時限式爆破オブジェクトが起動されたら実行される関数
    OnLimitDeviceAStart(Agent:agent):void=
        BombStartEvent.Signal()
        set IsBombActivated = true
        for(LimitDevice:LimitDevicesB):
            for(Player:GamePlayers):
                LimitDevice.Disable(Player)

        if(Player := player[Agent]):
            if. set PlayerBombsMap[Player] += 1
        
    OnLimitDeviceBStart(Agent:agent):void=
        BombStartEvent.Signal()
        set IsBombActivated = true
        for(LimitDevice:LimitDevicesA):
            for(Player:GamePlayers):
                LimitDevice.Disable(Player)
                
        if(Player := player[Agent]):
            if. set PlayerBombsMap[Player] += 1

    # 時限式爆破オブジェクトが解除されたら実行される関数
    OnLimitDeviceStop(Agent:agent):void=
        BombStopEvent.Signal()
            
    # 時限式爆破オブジェクトのカウントが０になったら実行される関数
    OnLimitDeviceATimeOut(Agent:agent):void=
        for(ExplosiveDevice:ExplosiveDevicesA):
            ExplosiveDevice.Explode(Agent)
        BombEndEvent.Signal()
    OnLimitDeviceBTimeOut(Agent:agent):void=
        for(ExplosiveDevice:ExplosiveDevicesB):
            ExplosiveDevice.Explode(Agent)
        BombEndEvent.Signal()

    # 爆発したボムを復活させる関数
    ResetBombs():void=
        for(ExplosiveDevice:ExplosiveDevicesA):
            ExplosiveDevice.Reset()
        for(ExplosiveDevice:ExplosiveDevicesB):
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
                set TeamStageTelepotersMap[TeamArray[0]] = UseStage.TeleportersRed
                set TeamStageTelepotersMap[TeamArray[1]] = UseStage.TeleportersBlue

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
                set PlayerBombsMap[Player] = 0

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

        RoundUIDevice.AddRoundStateUI(Self) # ラウンドUIを表示

        loop:
            set RoundCount += 1

            var RoundWinTeam:?team = false

            Print("ラウンド{RoundCount}!!")

            if(RoundCount = 1): # 最初のラウンドだけリスポーン位置を記録する
                for(Agent:TeamCollection.GetAgents[TeamArray[0]]):
                    if(FortCharacter := Agent.GetFortCharacter[]):
                        set ResDataRed += array{
                            respawn_data{
                                Pos := FortCharacter.GetTransform().Translation,
                                Rot := FortCharacter.GetTransform().Rotation
                            }
                        }
                for(Agent:TeamCollection.GetAgents[TeamArray[1]]):
                    if(FortCharacter := Agent.GetFortCharacter[]):
                        set ResDataBlue += array{
                            respawn_data{
                                Pos := FortCharacter.GetTransform().Translation,
                                Rot := FortCharacter.GetTransform().Rotation
                            }
                        }
            else: # 2ラウンド以降はプレイヤーを強制リスポーンすることで陣営変更を実現する
            # 第1ラウンドはテレポーターでTeam0はRedにTeam1はBlueにワープしている
                if(Mod[RoundCount, 2] = 0): # 偶数ラウンドの場合（2, 4, 6, ...）
                    for(Index->Agent:TeamCollection.GetAgents[TeamArray[0]]):
                        if. Agent.Respawn(ResDataBlue[Index].Pos, ResDataBlue[Index].Rot)
                        else:
                            Print("リスポーン関連のエラーが発生")
                    for(Index->Agent:TeamCollection.GetAgents[TeamArray[1]]):
                        if. Agent.Respawn(ResDataRed[Index].Pos, ResDataRed[Index].Rot)
                        else:
                            Print("リスポーン関連のエラーが発生")
                else: # 奇数ラウンドの場合（3, 5, 7, ...）
                    for(Index->Agent:TeamCollection.GetAgents[TeamArray[1]]):
                        if. Agent.Respawn(ResDataBlue[Index].Pos, ResDataBlue[Index].Rot)
                        else:
                            Print("リスポーン関連のエラーが発生")
                    for(Index->Agent:TeamCollection.GetAgents[TeamArray[0]]):
                        if. Agent.Respawn(ResDataRed[Index].Pos, ResDataRed[Index].Rot)
                        else:
                            Print("リスポーン関連のエラーが発生")

            # キルによってラウンドが終了した場合に、なぜかプレイヤーの静止が聞かなかった。
            # 次のように一瞬の待機を設けたら直った。
            # 多分リスポーン終了判定より先に静止処理が動いていたのだと思う。（静止中にリスポーンしたら静止は解除される）
            Sleep(0.0)

            RoundUIDevice.UpdateRoundStateUI(Self)

            # プレイヤーを静止させる＋プレイヤーの体力・シールドを全回復する
            for(Player:GamePlayers):
                if(FortCharacter := Player.GetFortCharacter[]):
                    FortCharacter.PutInStasis(stasis_args{AllowTurning := true, AllowFalling := true, AllowEmotes := true})
                    FortCharacter.SetHealth(PlayerMaxHealth)
                    FortCharacter.SetShield(PlayerMaxShield)

            # ラウンド１は、チーム１を攻撃チームに、チーム２を守備チームに設定する
            if(RoundCount = 1, Team1 := TeamArray[0], Team2 := TeamArray[1]):
                set OAttackTeam = option{Team1}
                set ODefenseTeam = option{Team2}
                
            # ３ラウンドごとに攻守を入れ替える
            if(Mod[RoundCount, SideSwitchNum] = 1):
                Tmp := OAttackTeam
                set OAttackTeam = ODefenseTeam
                set ODefenseTeam = Tmp
            RoundUIDevice.ShowHideSide(Self, OAttackTeam, ODefenseTeam) # 陣営を表示する

            # 有効にする時限式爆破オブジェクトを切り替える
            set IsBombActivated = false # 爆弾起動保持変数リセット
            for(LimitDevice:LimitDevicesA + LimitDevicesB): # 一旦全部無効化する
                LimitDevice.Hide()
                for(Player:GamePlayers):
                    LimitDevice.Disable(Player)
            for(Index->Team:TeamArray): # 攻撃側に合わせて有効化する時限式を決める
                if(AttackTeam := OAttackTeam?, Team = AttackTeam):
                    if(LimitDeviceA := LimitDevicesA[Index], LimitDeviceB := LimitDevicesB[Index]):
                        LimitDeviceA.Show()
                        LimitDeviceB.Show()
                        for(Player:GamePlayers):
                            LimitDeviceA.Enable(Player)
                            LimitDeviceB.Enable(Player)
        
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

            # そのラウンドの目標をHUDで表示する
            if(AttackTeam := OAttackTeam?, Agents := TeamCollection.GetAgents[AttackTeam]):
                for(Agent:Agents):
                    MessageHud.Show(Agent, S2M("あなたは攻撃チームです。\n制限時間以内に爆弾を設置して爆破すると勝利です。"))
            if(DefenseTeam := ODefenseTeam?, Agents := TeamCollection.GetAgents[DefenseTeam]):
                for(Agent:Agents):
                    MessageHud.Show(Agent, S2M("あなたは守備チームです。\n敵を全滅させるか、制限時間内に爆破されなかったら勝利です。"))
            
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

            # ラウンドの目標HUDを非表示にする
            MessageHud.Hide()

            # プレイヤーの静止を解除する
            for(Player:GamePlayers):
                if(FortCharacter := Player.GetFortCharacter[]):
                    FortCharacter.SetVulnerability(true) # ダメージを受けるようにする
                    FortCharacter.ReleaseFromStasis()

            race:
                loop: # プレイヤー退出待ち
                    LeavingPlayer:player = GetPlayspace().PlayerRemovedEvent().Await()
                    if. (Team := PlayerTeamMap[LeavingPlayer], set TeamRemainingMap[Team] -= 1)
                    RoundUIDevice.UpdateRoundStateUI(Self)
                    # ラウンド終了判定
                    OWinTeam := CheckRoundEnd()
                    if(WinTeam := OWinTeam?):
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
                        if(IsBombActivated?, DefenseTeam := ODefenseTeam?, WinTeam = DefenseTeam):
                            Print("爆弾が解除されるまで負けではない")
                            Sleep(1000.0) # キル待ちをなくす（おそらくキルは発生しないが）
                        else:
                            if. set TeamWinsMap[WinTeam] += 1
                            set RoundWinTeam = OWinTeam
                            break
                block: # 制限時間終了（守備チームの勝利）
                    set Count = RoundTime
                    RoundUIDevice.UpdateRoundStateUITimeText(S2M("{CalcElapsedTime(Count)}"))

                    race:
                        loop:
                            Sleep(1.0)
                            set Count -= 1
                            RoundUIDevice.UpdateRoundStateUITimeText(S2M("{CalcElapsedTime(Count)}"))
                            if(Count <= 0):
                                break
                        block:
                            BombStartEvent.Await()
                            
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
            if(Mod[RoundCount, SideSwitchNum] = 1): # 3ラウンドごとに「SideSwitch」と表示する
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
        for(Index->Player:GamePlayers, RespawnPos := FinishEriaPositions[Index]):
            Player.Respawn(RespawnPos, FinishEriaRotation)
            ThankYouHudDevice.Show(Player)
