using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }

Stage := struct<concrete>:
    TeleportersRed:[]teleporter_device = array{}
    TeleportersBlue:[]teleporter_device = array{}

game_manager_device := class(creative_device):

    ### @editable --------------------------------------------------
    @editable
    MatchPlayerNum:int = 2

    @editable
    StartDelay:int = 3 # テレポート前やゲーム直前などに設ける時間

    @editable
    RoundReadyTime:int = 180 # 武器を選んだり、ステージを見学したりする時間

    @editable
    Stages:[]Stage = array{}
    
    @editable
    MessageHud:hud_message_device = hud_message_device{}
    @editable
    CountDownHud:hud_message_device = hud_message_device{}
    @editable
    RoundCoundDownHud:hud_message_device = hud_message_device{} # 試合開始直前のカウントダウンを表示するHUD（数字を大きめにしたいから別で用意）

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

    var TeamRed:[]player = array{}
    var TeamBlue:[]player = array{}

    var WeaponPlayerMap:[player][]int = map{} # これはできるか？
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
                CountFunc := spawn{CountDown("Game starts in", StartDelay)}
                CountFunc.Await() # これできるのか？
                set GamePlayers = Player
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

    CountDown(Str:string, TimeLimit:int)<suspends>:void=
        var Count:int = TimeLimit
        loop:
            CountDownHud.Show(S2M("{Str}: {Count}"))
            Sleep(1.0)
            set Count -= 1
        CountDownHud.Hide()

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

    # ゲーム全体の流れを実行する関数
    StartGameFlow()<suspends>:void=
        # ステージ見学＋武器を選択するフェーズ
            # 前回の武器選択を統計データで保持できるようにしたい。
            # ステージではリモコンだけ持ってて、武器選択エリアに瞬間移動できる。
            # 武器選択エリアでは、テレポーターに入ることでステージに移動できる。
            # ステージと武器選択エリアを自由に行き来できる。武器選択エリアはチームごとに作る。
            # 移動はリモコンで行える。
            # 全部で2分か3分くらい設ける。
            # 武器選択エリアには、武器練習用のやつも用意しておく。
        CountFunc := spawn{CountDown("Round starts in", RoundReadyTime)}
        CountFunc.Await()

        # プレイヤーを静止させる
        for(GamePlayers):
            if(FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.PutInStasis(stasis_args{AllowTurning := false, AllowFalling := false, AllowEmotes := true})
        
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
        

        # 試合をするフェーズ
            # ラウンド
            # 勝敗判定
        var Count:int = StartDelay
        loop:
            RoundCoundDownHud.Show(S2M("{Count}"))
            Sleep(1.0)
            set Count -= 1
            
        # プレイヤーの静止を解除する
        for(GamePlayers):
            if(FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.ReleaseFromStasis()

        
        
        
        # ゲームを終了するフェーズ