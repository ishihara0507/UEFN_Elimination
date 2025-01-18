using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }

stage_data := struct<concrete>:
    TeleportersRed:[]teleporter_device = array{}
    TeleportersBlue:[]teleporter_device = array{}
    FlagPos:vector3 = vector3{}

team_data := struct:
    Team:team = team{}
    Wins:int = 0
    Members:[]player = array{}

game_manager_device := class(creative_device):

    ### @editable --------------------------------------------------
    @editable
    MatchPlayerNum:int = 2

    @editable
    StartDelay:int = 3 # テレポート前やゲーム直前などに設ける時間

    @editable
    RoundReadyTime:int = 180 # 武器を選んだり、ステージを見学したりする時間

    @editable
    RoundTime:int = 300

    @editable
    Stages:[]stage_data = array{}
    
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
    StageTeleporter:[]teleporter_device = teleporter_device{} # 武器選択フェーズにおけるステージへのテレポーター

    @editable
    RemoconGranter:item_granter_device = item_granter_device{} # リモコンを付与するデバイス
    @editable
    Remocon:signal_remote_manager_device = signal_remote_manager_device{}

    @editable
    WeaponGranter:item_granter_device = item_granter_device{} # 選択した武器を付与するデバイス

    @editable
    ItemRemover:item_remover_device = item_remover_device{}
    # 武器を選択しなかった場合に与えられる武器

    ### ------------------------------------------------------------

    ### ゲーム中に変動する変数 -------------------------------------
    var GamePlayers:[]player = array{} # ゲームに参加するプレイヤー

    var TeamDatas:team_data = array{}

    # var TeamRed:[]player = array{}
    # var TeamBlue:[]player = array{}

    # var TeamWinsMap:[team]int = map{} # 各チームの勝利回数を保持する

    var WeaponPlayerMap:[player][]int = map{} # これはできるか？

    var FlagCapturedPlayer:?player = false
    ### ------------------------------------------------------------

    ### event() ----------------------------------------------------
    KillEvent:event() = event(){} # キルの発生を管理するイベント

    FlagCaptured:event() = event(){} # フラッグの取得を管理するイベント
    ### ------------------------------------------------------------

    S2M<localizes>(S:string):message = "{S}"

    # プレイヤーが揃うまで待機する関数
    OnBegin<override>()<suspends>:void=
        StageTeleporter.EnterEvent.Subscribe(OnTeleportToStage)
        Remocon.PrimarySignalEvent.Subscribe(OnRemoconBoot)
        Remocon.SecondarySignalEvent.Subscribe(OnRemoconBoot)

        loop:
            Players := GetPlayspace().GetPlayers()
            if(Players.Length >= MatchPlayerNum):
                Print("プレイヤーが揃ったのでゲームを開始する")
                var Count:int = StartDelay
                loop:
                    CountDownHud.Show(S2M("Game starts in: {Count}"))
                    Sleep(1.0)
                    set Count -= 1
                CountDownHud.Hide()

                set GamePlayers = Players

                # すべてのプレイヤーをダメージを受けない状態にする
                for(Player := GamePlayers):
                    if(FortCharacter := Player.GetFortCharacter[]):
                        FortCharacter.SetVulnerability(false)

                StageSelect()
                break
            NeedPlayerNum:int = MatchPlayerNum - Players.Length
            MessageHud.Show(S2M("Waiting for {NeedPlayerNum} more players to join.")) # プレイヤー全員にHUDを表示
            Sleep(1.0)

    # ステージをランダムで選択して、その場所にプレイヤーをテレポートさせる関数
    # チーム分けもする
    StageSelect():void=
        if(S := Shuffle(Stages)[0]):
            Players := Shuffle(GamePlayers)
            if:
                TeamPlayerNum := Int[MatchPlayerNum * 1.0 / 2.0]
                T1 := Players.Slice[0, TeamPlayerNum - 1]
                T2 := Players.Slice[TeamPlayerNum]
            then:
                set TeamRed = T1
                set TeamBlue = T2

                Team

                # 同じチーム同士はダメージを受けないようにするために、島設定のチーム機能を使う
                TeamCollection := GetPlayspace().GetTeamCollection()
                TeamArray := TeamCollection.GetTeams()

                for(Team:TeamArray):
                    if. TeamWinsMap[Team] = 0 # チームごとの処理数を保持するマップの初期化

                for(Player:TeamRed):
                    if. TeamCollection.AddToTeam[Player, TeamArray[0]]
                for(Player:TeamBlue):
                    if. TeamCollection.AddToTeam[Player, TeamArray[1]]

                TeleportAllPlayersToStage()
        else:
            Print("ステージ選択の際にエラーが発生しました。")

    TeleportAllPlayersToStage():void=
        for(Index := 0..TeamRed.Length-1):
            if(Player := TeamRed[Index], Teleporter := S.TeleportersRed[Index]):
                Teleporter.Teleport(Player)
        for(Index := 0..TeamBlue.Length-1):
            if(Player := TeamBlue[Index], Teleporter := S.TeleportersRed[Index]):
                Teleporter.Teleport(Player)

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
        if(Player := player[Agent]):
            for(Index := 0..TeamRed.Length-1):
                if(Player = TeamRed[Index], Teleporter := S.TeleportersRed[Index]):
                    Teleporter.Teleport(Player)
            for(Index := 0..TeamBlue.Length-1):
                if(Player = TeamBlue[Index], Teleporter := S.TeleportersRed[Index]):
                    Teleporter.Teleport(Player)
            ItemRemover.Remove(Player) # 所持アイテムの削除
            for(Index := 0..WeaponPlayerMap[Player].Length-1):
                WeaponGranter.GrantItemIndex(Player, WeaponPlayerMap[Player][Index])

    OnPlayerEliminated(Result:elimination_result):void=
        Print("キル発生!!")
        EliminatorFort:?fort_character = Result.EliminatingCharacter

        if(FortCharacter := EliminatorFort?, EliminatorAgent := FortCharacter.GetAgent[]):
            TeamCollection := GetPlayspace().GetTeamCollection()
            TeamArray := TeamCollection.GetTeams()
            RoundWinTeam := TeamCollection.GetTeam(EliminatorAgent)
            for(Team->Wins:TeamWinsMap):
                if. (Team = RoundWinTeam, set TeamWinsMap[Team] += 1)
        else:
            Print("キルに関するエラーが発生した。")
        
        KillEvent.Signal()

    OnFlagCaptured(FlagCapturedAgent:agent):void=
        if(Player := player[FlagCapturedAgent]):
            set FlagCapturedPlayer = option{Player}
        else:
            Print("フラッグ関連のエラーが発生しました。")
        FlagCaptured.Signal()

    # ゲーム全体の流れを実行する関数
    StartGameFlow()<suspends>:void=
        ### ステージ見学＋武器を選択するフェーズ -----------------------------------------------------------
        # 武器選択フェーズのカウントダウン開始
        var Count:int = RoundReadyTime
        loop:
            CountDownHud.Show(S2M("Round starts in: {Count}"))
            Sleep(1.0)
            set Count -= 1
        CountDownHud.Hide()

        ### 試合をするフェーズ ----------------------------------------------------------------------------------
        # プレイヤーを静止させる
        for(Player:GamePlayers):
            if(FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.PutInStasis(stasis_args{AllowTurning := false, AllowFalling := false, AllowEmotes := true})
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)
        
        TeleportAllPlayersToStage()

        # 武器を付与する
        for(Player:TeamRed):
            ItemRemover.Remove(Player)
            for(Index := 0..WeaponPlayerMap[Player].Length-1):
                WeaponGranter.GrantItemIndex(Player, WeaponPlayerMap[Player][Index])
        for(Player:TeamBlue):
            ItemRemover.Remove(Player)
            for(Index := 0..WeaponPlayerMap[Player].Length-1):
                WeaponGranter.GrantItemIndex(Player, WeaponPlayerMap[Player][Index])
        
        # ラウンド開始前に数秒カウントダウンする
        var Count:int = StartDelay
        loop:
            StartDelayHud.Show(S2M("{Count}"))
            Sleep(1.0)
            set Count -= 1
        StartDelayHud.Hide()

        # プレイヤーの静止を解除する
        for(Player:GamePlayers):
            if(FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.SetVulnerability(true) # ダメージを受けるようにする
                FortCharacter.ReleaseFromStasis()

        race:
            loop: # プレイヤー退出待ち
                LeavingAgent := GetPlayspace().PlayerRemovedEvent().Await()
                if(LeavingPlayer := player[LeavingAgent]):
                    TeamCollection := GetPlayspace().GetTeamCollection()
                    TeamArray := TeamCollection.GetTeams()
                then:
                    for(Player : Players):
                        if(not(LeavingPlayer = Player)):

        # ラウンドタイマーを開始する
        var Count:int = RoundTime
        loop:
            RoundCoundDownHud.Show(S2M("{CalcElapsedTime(Count)}"))
            Sleep(1.0)
            set Count -= 1
        RoundCoundDownHud.Hide()

        FlagHud.Show()
        FlagCaptured.Await()
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        if(FCPlayer := FlagCapturedPlayer?):
            RoundWinTeam := TeamCollection.GetTeam(FCPlayer)
            for(Team->Wins:TeamWinsMap):
                if. (Team = RoundWinTeam, set TeamWinsMap[Team] += 1)
            set FlagCapturedPlayer = false
        else:
            Print("フラッグに関するエラーが発生した。")
        
        # ゲームを終了するフェーズ ------------------------------------------------------------------------