using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

stage_data := struct<concrete>:
    @editable
    TeleportersRed:[]teleporter_device = array{}
    @editable
    TeleportersBlue:[]teleporter_device = array{}
    @editable
    FlagPos:vector3 = vector3{}

res_data := struct:
    Pos:vector3
    Rot:rotation

game_manager_device := class(creative_device):

    ### @editable --------------------------------------------------
    @editable
    MatchPlayerNum:int = 2 # 偶数にする

    @editable
    WinningPoints:int = 3

    @editable
    StartDelay:int = 3 # テレポート前やゲーム直前などに設ける時間

    @editable
    RoundReadyTime:int = 180 # 武器を選んだり、ステージを見学したりする時間

    @editable
    RoundTime:int = 300

    @editable
    Stages:[]stage_data = array{}

    @editable
    PlayerMaxHealth:float = 100.0

    @editable
    PlayerMaxShield:float = 100.0
    
    @editable
    MessageHud:hud_message_device = hud_message_device{}
    @editable
    CountDownHud:hud_message_device = hud_message_device{}
    @editable
    StartDelayHud:hud_message_device = hud_message_device{} # 試合開始直前のカウントダウンを表示するHUD（数字を大きめにしたいから別で用意）
    @editable
    RoundCoundDownHud:hud_message_device = hud_message_device{}
    @editable
    FlagHud:hud_message_device = hud_message_device{} # ラウンド制限時間が終了して、フラッグが発生したことを知らせるHUD

    @editable
    WeaponGranter:item_granter_device = item_granter_device{} # 選択した武器を付与するデバイス

    @editable
    ItemRemover:item_remover_device = item_remover_device{}
    # 武器を選択しなかった場合に与えられる武器

    ### ------------------------------------------------------------

    ### ゲーム中に変動する変数 -------------------------------------
    var GamePlayers:[]player = array{} # ゲームに参加するプレイヤー

    var TeamRemainingMap:[team]int = map{} # ラウンドごとの残りプレイヤーの数を保持するマップ

    var TeamWinsMap:[team]int = map{}

    var WinningTeam:?team = false # ゲームに勝利したチーム
    
    var TeamStageTelepotersMap:[team][]teleporter_device = map{}

    var UseStage:stage_data = stage_data{}

    var WeaponPlayerMap:[player][]int = map{}

    var ResDataRed:[]res_data = array{} # 赤チームのリスポーン位置の配列
    var ResDataBlue:[]res_data = array{} # 青チームのリスポーン位置の配列
    ### ------------------------------------------------------------

    ### event() ----------------------------------------------------
    KillEvent:event(agent) = event(agent){} # キルの発生を管理するイベント

    FlagCaptured:event(agent) = event(agent){} # フラッグの取得を管理するイベント
    ### ------------------------------------------------------------

    S2M<localizes>(S:string):message = "{S}"

    # プレイヤーが揃うまで待機する関数
    OnBegin<override>()<suspends>:void=

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

    # チーム分けをする関数
    SplitPlayersToTeams():void=
        Players := Shuffle(GamePlayers)
        if:
            TeamPlayerNum := Int[MatchPlayerNum * 1.0 / 2.0]
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
        EliminatedFort:fort_character = Result.EliminatedCharacter
        if:
            EliminatedAgent := EliminatedFort.GetAgent[]
        then:
            KillEvent.Signal(EliminatedAgent)
        else:
            Print("キルに関するエラーが発生した。")

    OnFlagCaptured(FlagCapturedAgent:agent):void=
        FlagCaptured.Signal(FlagCapturedAgent)

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
        var Count:int = RoundReadyTime
        var RoundCount:int = 0

        for(Player:GamePlayers):
            if(FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)

        TeleportAllPlayersToStage()

        loop:
            set RoundCount += 1

            Print("ラウンド{RoundCount}!!")

            if(RoundCount = 1): # 最初のラウンドだけリスポーン位置を記録する
                for(Agent:TeamCollection.GetAgents[TeamArray[0]]):
                    if(FortCharacter := Agent.GetFortCharacter[]):
                        set ResDataRed += array{
                            res_data{
                                Pos := FortCharacter.GetTransform().Translation,
                                Rot := FortCharacter.GetTransform().Rotation
                            }
                        }
                for(Agent:TeamCollection.GetAgents[TeamArray[1]]):
                    if(FortCharacter := Agent.GetFortCharacter[]):
                        set ResDataBlue += array{
                            res_data{
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

            # プレイヤーを静止させる＋プレイヤーの体力・シールドを全回復する
            for(Player:GamePlayers):
                if(FortCharacter := Player.GetFortCharacter[]):
                    FortCharacter.PutInStasis(stasis_args{AllowTurning := true, AllowFalling := true, AllowEmotes := true})
                    FortCharacter.SetHealth(PlayerMaxHealth)
                    FortCharacter.SetShield(PlayerMaxShield)

            for(Team:TeamArray):
                if(RemainingCount := TeamCollection.GetAgents[Team].Length):
                    if. set TeamRemainingMap[Team] = RemainingCount

            # ラウンド開始時の各チームの初期人数を設定＋プレイヤーとチームのMapを初期化する（プレイヤーが退出したとき用に作成してる）
            var PlayerTeamMap:[player]team = map{}
            for(Team:TeamArray):
                if(TeamAgents := TeamCollection.GetAgents[Team], set TeamRemainingMap[Team] = TeamAgents.Length):
                    for(Agent:TeamAgents):
                        if. (Player := player[Agent], set PlayerTeamMap[Player] = Team)

            # 武器を付与する
            for(Player:GamePlayers):
                ItemRemover.Remove(Player) # 所持アイテムの削除
                for(WeaponIndex:WeaponPlayerMap[Player]):
                    WeaponGranter.GrantItemIndex(Player, WeaponIndex)
            
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

            # プレイヤーの静止を解除する
            for(Player:GamePlayers):
                if(FortCharacter := Player.GetFortCharacter[]):
                    FortCharacter.SetVulnerability(true) # ダメージを受けるようにする
                    FortCharacter.ReleaseFromStasis()

            race:
                loop: # プレイヤー退出待ち
                    LeavingPlayer:player = GetPlayspace().PlayerRemovedEvent().Await()
                    if. (Team := PlayerTeamMap[LeavingPlayer], set TeamRemainingMap[Team] -= 1)
                    # ラウンド終了判定
                    WinTeam := CheckRoundEnd()
                    if(TrueWinTeam := WinTeam?):
                        if. set TeamWinsMap[TrueWinTeam] += 1
                        RoundCoundDownHud.Hide()
                        break
                loop: # 一方のチームの全滅待ち
                    EliminatedAgent := KillEvent.Await() # キルされたプレイヤー
                    if. (Team := TeamCollection.GetTeam[EliminatedAgent], set TeamRemainingMap[Team] -= 1)
                    # ラウンド終了判定
                    WinTeam := CheckRoundEnd()
                    if(TrueWinTeam := WinTeam?):
                        if. set TeamWinsMap[TrueWinTeam] += 1
                        RoundCoundDownHud.Hide()
                        break
                block: # 制限時間終了し、旗が取られるの待ち
                    ### 旗の生成はキャプチャーエリアの仕掛けを使う
                    set Count = RoundTime
                    RoundCoundDownHud.Show(S2M("{CalcElapsedTime(Count)}"))
                    loop:
                        Sleep(1.0)
                        set Count -= 1
                        if(Count <= 0):
                            break
                        RoundCoundDownHud.SetText(S2M("{CalcElapsedTime(Count)}"))
                    RoundCoundDownHud.Hide()
                    FlagHud.Show()
                    FlagCapturedAgent := FlagCaptured.Await()
                    if(RoundWinTeam := TeamCollection.GetTeam[FlagCapturedAgent]):
                        if. set TeamWinsMap[RoundWinTeam] += 1 
                    else:
                        Print("フラッグに関するエラーが発生した。")
            
            ### ラウンド終了処理
            # ゲーム終了判定
            for(Team->TeamWins:TeamWinsMap):
                if(TeamWins >= WinningPoints):
                    set WinningTeam = option{Team}
                    break
        
        # ゲームを終了するフェーズ ------------------------------------------------------------------------
        if(TrueWinningTeam := WinningTeam?):
            for(Index->Team:TeamArray):
                if(Team = WinningTeam):
                    Print("チーム{Index}の勝利！！！！！！")