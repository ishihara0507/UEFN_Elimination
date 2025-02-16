using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

test_stage_data := struct<concrete>:
    @editable
    TeleportersRed:[]teleporter_device = array{}
    @editable
    TeleportersBlue:[]teleporter_device = array{}
    @editable
    FlagPos:vector3 = vector3{}

test_res_data := struct:
    Pos:vector3
    Rot:rotation

test_game_manager_device := class(creative_device):
    ### テスト用 -------------------------------------------------------
    @editable
    Trigger0:trigger_device = trigger_device{}
    @editable
    Trigger1:trigger_device = trigger_device{}

    @editable
    HudGameData:hud_message_device = hud_message_device{}

    var RobbyAgents:[]agent = array{}

    var GameAgents:[]agent = array{}

    @editable
    Delay:float = 0.0
    ### -------------------------------------------------------------------



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
    Stages:[]test_stage_data = array{}
    
    @editable
    PlayerMaxHealth:float = 100.0

    @editable
    PlayerMaxShield:float = 100.0

    # 武器エリアのテレポーターは、一応１チームの人数分用意しておく
    @editable
    WeaponEreaTeleportersRed:[]teleporter_device = array{} # チーム赤の武器エリアに設置するテレポーター
    @editable
    WeaponEreaTeleportersBlue:[]teleporter_device = array{} # チーム青の武器エリアに設置するテレポーター
    
    @editable
    MessageHud:hud_message_device = hud_message_device{} # 基本的なメッセージを表示するHUD
    @editable
    CountDownHud:hud_message_device = hud_message_device{} # 人数がそろった時のカウントダウンと、武器選択の残り時間を表示するHUD
    @editable
    StartDelayHud:hud_message_device = hud_message_device{} # 試合開始直前のカウントダウンを表示するHUD（数字を大きめにしたいから別で用意）
    @editable
    RoundCoundDownHud:hud_message_device = hud_message_device{} # ラウンドの残り時間を表示するHUD
    @editable
    FlagHud:hud_message_device = hud_message_device{} # ラウンド制限時間が終了して、フラッグが発生したことを知らせるHUD

    @editable
    ToStageTeleporters:[]teleporter_device = array{} # 武器選択フェーズにおけるステージへのテレポーター

    @editable
    RemoconGranter:item_granter_device = item_granter_device{} # リモコンを付与するデバイス
    @editable
    SignalRemoteManager:signal_remote_manager_device = signal_remote_manager_device{}

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

    var TeamWeaponTelepotersMap:[team][]teleporter_device = map{}
    
    var TeamStageTelepotersMap:[team][]teleporter_device = map{}

    var UseStage:test_stage_data = test_stage_data{}

    var WeaponPlayerMap:[player][]int = map{}

    var ResDataRed:[]test_res_data = array{} # 赤チームのリスポーン位置の配列
    var ResDataBlue:[]test_res_data = array{} # 青チームのリスポーン位置の配列
    ### ------------------------------------------------------------

    ### event() ----------------------------------------------------
    KillEvent:event(agent) = event(agent){} # キルの発生を管理するイベント

    FlagCaptured:event(agent) = event(agent){} # フラッグの取得を管理するイベント
    ### ------------------------------------------------------------

    # プレイヤーが揃うまで待機する関数
    OnBegin<override>()<suspends>:void=
        Trigger0.TriggeredEvent.Subscribe(OnTriggered0) ###
        Trigger1.TriggeredEvent.Subscribe(OnTriggered1) ###

        spawn{DisplayGameData()} ###

        
        for(Teleporter:ToStageTeleporters):
            Teleporter.EnterEvent.Subscribe(OnTeleportToStage)
        SignalRemoteManager.PrimarySignalEvent.Subscribe(OnRemoconBoot)
        SignalRemoteManager.SecondarySignalEvent.Subscribe(OnRemoconBoot)

        Sleep(5.0)
        Players := GetPlayspace().GetPlayers()
        if. set RobbyAgents += array{Players[0]}

        loop:
            ### Players := GetPlayspace().GetPlayers()
            if(RobbyAgents.Length >= MatchPlayerNum): ### if(Players.Length >= MatchPlayerNum):
                MessageHud.Hide()
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

                set GameAgents = RobbyAgents ### set GamePlayers = Players
                set GamePlayers = GetPlayspace().GetPlayers() ### テスト用に追加

                # すべてのプレイヤーをダメージを受けない状態にする
                for(Agent:GameAgents): ###for(Player:GamePlayers):
                    if(FortCharacter := Agent.GetFortCharacter[]): ### if(FortCharacter := Player.GetFortCharacter[]):
                        FortCharacter.SetVulnerability(false)

                # 今回のセッションで使用するステージをランダムで選択する
                if(RandomStage := Shuffle(Stages)[0]):
                    set UseStage = RandomStage

                SplitPlayersToTeams() # チーム分けをする
                TeleportAllPlayersToWeaponErea() # すべてのプレイヤーを武器選択エリアにテレポートする
                StartGameFlow() # ゲームを開始する

                break
            NeedPlayerNum:int = MatchPlayerNum - RobbyAgents.Length ### NeedPlayerNum:int = MatchPlayerNum - Players.Length
            MessageHud.Show(S2M("Waiting for {NeedPlayerNum} more players to join.")) # プレイヤー全員にHUDを表示
            Sleep(1.0)

    # ステージをランダムで選択する関数
    # チーム分けもする
    SplitPlayersToTeams():void=
        Agents := Shuffle(GameAgents) ### Players := Shuffle(GamePlayers)
        Print("シャッフルAgents.Length: {Agents.Length}") ### 
        if:
            TeamPlayerNum := Int[MatchPlayerNum * 1.0 / 2.0]
            Print("チームの人数を{TeamPlayerNum} 人に設定") ###
            T1 := Agents.Slice[0, TeamPlayerNum] ### T1 := Players.Slice[0, TeamPlayerNum - 1]
            Print("T1 := Agents.Slice[0, {TeamPlayerNum - 1}]") ### 
            T2 := Agents.Slice[TeamPlayerNum] ### T2 := Players.Slice[TeamPlayerNum]
            Print("T2 := Agents.Slice[{TeamPlayerNum}]") ###
        then:
            Print("T1: {T1.Length}, T2: {T2.Length}") ###
            # 同じチーム同士はダメージを受けないようにするために、島設定のチーム機能を使う
            TeamCollection := GetPlayspace().GetTeamCollection()
            TeamArray := TeamCollection.GetTeams()
            for(Agent:T1): ### for(Player:T1):
                if. TeamCollection.AddToTeam[Agent, TeamArray[0]] ### if. TeamCollection.AddToTeam[Player, TeamArray[0]]
            for(Agent:T2): ### for(Player:T2):
                if. TeamCollection.AddToTeam[Agent, TeamArray[1]] ### if. TeamCollection.AddToTeam[Player, TeamArray[1]]

            if:
                # TeamWinsMapを初期化
                set TeamWinsMap[TeamArray[0]] = 0
                set TeamWinsMap[TeamArray[1]] = 0
                
                # TeamWeaponTelepotersMapを初期化
                set TeamWeaponTelepotersMap[TeamArray[0]] = WeaponEreaTeleportersRed
                set TeamWeaponTelepotersMap[TeamArray[1]] = WeaponEreaTeleportersBlue

                # TeamStageTelepotersMapを初期化する
                set TeamStageTelepotersMap[TeamArray[0]] = UseStage.TeleportersRed
                set TeamStageTelepotersMap[TeamArray[1]] = UseStage.TeleportersBlue

    # 全員をチームごとに別の武器選択エリア上にテレポートする
    TeleportAllPlayersToWeaponErea():void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        for(Team:TeamArray):
            if(Members := TeamCollection.GetAgents[Team], WeaponTeleporters := TeamWeaponTelepotersMap[Team]):
                for(Index->Member:Members):
                    if(WeaponTeleporter := WeaponTeleporters[Index]):
                        WeaponTeleporter.Teleport(Member)

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

    # 武器選択フェーズ中に、ステージにテレポートした際に実行する関数
    OnTeleportToStage(Agent:agent):void=
        if(Player := player[Agent]):
            ItemRemover.Remove(Player) # 所持アイテムの削除
            RemoconGranter.GrantItem(Player)

    OnRemoconBoot(Agent:agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        if(Player := player[Agent]):
            # リモコンを起動したプレイヤーが所属しているチームに合わせて、テレポート先を変更する
            if(Team := TeamCollection.GetTeam[Agent], Members := TeamCollection.GetAgents[Team], WeaponTeleporters := TeamWeaponTelepotersMap[Team]): # リモコンを起動したプレイヤーが所属しているチームを取得
                for(Index->Member:Members):
                    if(Player = Member, WeaponTeleporter := WeaponTeleporters[Index]):
                        WeaponTeleporter.Teleport(Player)

            ItemRemover.Remove(Player) # 所持アイテムの削除
            for(WeaponIndex:WeaponPlayerMap[Player]):
                WeaponGranter.GrantItemIndex(Player, WeaponIndex)

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

        ### ステージ見学＋武器を選択するフェーズ -----------------------------------------------------------
        # 武器選択フェーズのカウントダウン開始
        var Count:int = RoundReadyTime
        CountDownHud.Show(S2M("Round starts in: {Count}"))
        loop:
            Sleep(1.0)
            set Count -= 1
            if(Count <= 0):
                break
            CountDownHud.SetText(S2M("Round starts in: {Count}"))
        CountDownHud.Hide()

        for(Player:GamePlayers):
            if(FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)

        ### テスト用に追加 --------------------
        for(Agent:GameAgents):
            if(FortCharacter := Agent.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)
        ### --------------------

        ### 試合をするフェーズ ----------------------------------------------------------------------------------
        var RoundCount:int = 0

        TeleportAllPlayersToStage()

        loop:
            set RoundCount += 1

            Print("ラウンド{RoundCount}!!")

            if(RoundCount = 1): # 最初のラウンドだけリスポーン位置を記録する
                for(Agent:TeamCollection.GetAgents[TeamArray[0]]):
                    if(FortCharacter := Agent.GetFortCharacter[]):
                        set ResDataRed += array{
                            test_res_data{
                                Pos := FortCharacter.GetTransform().Translation,
                                Rot := FortCharacter.GetTransform().Rotation
                            }
                        }
                for(Agent:TeamCollection.GetAgents[TeamArray[1]]):
                    if(FortCharacter := Agent.GetFortCharacter[]):
                        set ResDataBlue += array{
                            test_res_data{
                                Pos := FortCharacter.GetTransform().Translation,
                                Rot := FortCharacter.GetTransform().Rotation
                            }
                        }
            else: # 2ラウンド以降はプレイヤーを強制リスポーンすることで陣営変更を実現する（第1ラウンドはテレポーターでTeam0はRedにTeam1はBlueにワープしている）
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

            # プレイヤーを静止させる
            for(Agent:GameAgents): ### for(Player:GamePlayers):
                if(FortCharacter := Agent.GetFortCharacter[]): ### if(FortCharacter := Player.GetFortCharacter[]):
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
                ### for(WeaponIndex:WeaponPlayerMap[Player]):
                    ### WeaponGranter.GrantItemIndex(Player, WeaponIndex)
                WeaponGranter.GrantItemIndex(Player, 0) ### テスト用に追加
            
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
            for(Agent:GameAgents): ### for(Player:GamePlayers):
                if(FortCharacter := Agent.GetFortCharacter[]): ### if(FortCharacter := Player.GetFortCharacter[]):
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
                    Print("タイムアップ")
                    # FlagHud.Show(S2M("Flag!!!"))
                    # FlagCapturedAgent := FlagCaptured.Await()
                    # if(RoundWinTeam := TeamCollection.GetTeam[FlagCapturedAgent]):
                    #     if. set TeamWinsMap[RoundWinTeam] += 1 
                    # else:
                    #     Print("フラッグに関するエラーが発生した。")
                    # FlagHud.Hide()
            
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


    ### テスト用 --------------------------------------------
    OnTriggered0(OAgent:?agent):void=
        if(Agent := OAgent?):
            set RobbyAgents += array{Agent}
            if(Fort := Agent.GetFortCharacter[]):
                Print("NPCからもfort_characterはとれる！！！！！！！")

    OnTriggered1(OAgent:?agent):void=
        if(Agent := OAgent?):
            set RobbyAgents += array{Agent}

    DisplayGameData()<suspends>:void=
        HudGameData.Show(S2M(""))
        
        loop:
            var Str:string = ""

            # 各チームの人数を追加
            TeamCollection := GetPlayspace().GetTeamCollection()
            TeamArray := TeamCollection.GetTeams()
            for(Index->Team:TeamArray):
                if(Num := TeamCollection.GetAgents[Team].Length):
                    set Str += "チーム{Index}の人数: {Num}人\n"

            # ラウンド毎の残りプレイヤー数を追加
            for(Team->Num:TeamRemainingMap):
                for(Index->T:TeamArray):
                    if(Team = T):
                        set Str += "チーム{Index}の残りプレイヤー数: {Num}\n"

            # 各チームの勝利数を追加
            for(Team->Wins:TeamWinsMap):
                for(Index->T:TeamArray):
                    if(Team = T):
                        set Str += "チーム{Index}の勝利数: {Wins}\n"

            Sleep(0.0)
            HudGameData.SetText(S2M(Str))

# OnTriggered0(OAgent:?agent):void=
#     TeamCollection := GetPlayspace().GetTeamCollection()
#     TeamArray := TeamCollection.GetTeams()

#     if(Agent := OAgent?):
#         if. TeamCollection.AddToTeam[Agent, TeamArray[0]]

#     for(Index->Team:TeamArray):
#         if(Num := TeamCollection.GetAgents[Team].Length):
#             Print("チーム{Index}の人数: {Num}人")

# OnTriggered1(OAgent:?agent):void=
#     TeamCollection := GetPlayspace().GetTeamCollection()
#     TeamArray := TeamCollection.GetTeams()

#     if(Agent := OAgent?):
#         if. TeamCollection.AddToTeam[Agent, TeamArray[1]]
    
#     for(Index->Team:TeamArray):
#         if(Num := TeamCollection.GetAgents[Team].Length):
#             Print("チーム{Index}の人数: {Num}人")