using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }

# グローバル変数
MatchPlayerNum:int = 8 # 偶数にする

waiting_players_device := class(creative_device):

    @editable
    GameFlowDevice:game_flow_device = game_flow_device{}

    @editable
    PlayerSpawners:[]player_spawner_device = array{} # マップに入ったときにスポーンするやつ

    @editable
    RoundSettingDevice:round_settings_device = round_settings_device{}

    @editable
    AttackerTeleporters:[]teleporter_device = array{}
    @editable
    DefenderTeleporters:[]teleporter_device = array{}

    @editable
    ClassDesigners:[]class_designer_device = array{} # 要素１をクラス２のやつに、要素２をクラス３のやつに設定する必要がある
    @editable
    ClassSelectors:[]class_and_team_selector_device = array{}

    @editable
    MessageHud:hud_message_device = hud_message_device{}
    @editable
    CountDownHud:hud_message_device = hud_message_device{}

    @editable
    PopupDialogDevice:popup_dialog_device = popup_dialog_device{} # 人数が揃っていない状態で試合を始めていいかを確認するためのデバイス

    var GamePlayers:[]player = array{}

    var TeleportersArray:[][]teleporter_device = array{}

    var VoteYesCount:int = 0
    var VoteNoCount:int = 0
    var ThisMatchPlayerNum:int = MatchPlayerNum # 今回の試合に参加するプレイヤー人数（8人未満の場合もあるため用意）


    StartDelay:int = 5 # プレイヤーがそろってから試合を開始するまでの秒数

    DisplayPopupTime:float = 10.0 # ポップアップを表示する時間

    CompleteVoteEvent:event() = event(){}

    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    OnBegin<override>()<suspends>:void=
        for(PlayerSpawner:PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)
        PopupDialogDevice.RespondingButtonEvent.Subscribe(ClickPopupBtn)

        set TeleportersArray = array{AttackerTeleporters, DefenderTeleporters}

        # プレイヤー待ちループは、試合開始前のみ実行させるようにする
        var NotGameStarted:logic = false
        var CheckedPlayerCount:int = 0
        loop:
            Print("プレイヤーを確認")
            Players := GetPlayspace().GetPlayers()
            if(Players.Length >= 2):
                for(Player:Players):
                    OPlayerStats := PlayerStatsManager.GetPlayerStats(Player)
                    if(PlayerStats := OPlayerStats?, PlayerStats.RoundWins = -1):
                        set CheckedPlayerCount += 1
                        set NotGameStarted = true
                    else:
                        Print("プレイヤーを正常に確認できなかった")
            if(CheckedPlayerCount >= 2):
                Print("プレイヤーを正常に確認できた")
                break
            else:
                Print("CheckedPlayerCount: {CheckedPlayerCount}")
                Sleep(1.0)
            
        var WaitedTime:float = 0.0
        if(NotGameStarted?):
            loop:
                # 3分経過して8人に達していなかったら、試合を始めてるかの投票を行う
                if(WaitedTime >= 180.0): 
                    DisplayVoteStarting() # 投票を行う
                    CompleteVoteEvent.Await() # 投票が完了するまで待機
                    set WaitedTime = 0.0

                # 人数が揃っているかを確認
                Players := GetPlayspace().GetPlayers()
                if(Players.Length >= ThisMatchPlayerNum):
                    Print("プレイヤーが揃ったのでゲームを開始する")

                    RoundSettingDevice.DisableMatchmaking() # 新しくマップにマッチングできないようにする

                    var Count:int = StartDelay
                    CountDownHud.Show(S2M("ゲーム開始まで: {Count}\nGame starts in: {Count}"))
                    loop:
                        Sleep(1.0)
                        set Count -= 1
                        if(Count <= 0):
                            break
                        CountDownHud.SetText(S2M("ゲーム開始まで: {Count}\nGame starts in: {Count}"))
                    CountDownHud.Hide()
                    
                    set GamePlayers = Players
                    SplitPlayersToTeams() # チーム分けを行う
                    
                    # 試合ごとの持続データを全部０に設定する
                    for(Player:GamePlayers):
                        PlayerStatsManager.InitializePlayerStat(Player) # 念のため初期化処理
                        PlayerStatsManager.SetGameStats(Player)

                    TeleportToStage() # 全プレイヤーをステージに送る

                    set GameFlowDevice.GameStarted = true # 試合開始の合図
                    break

                NeedPlayerNum:int = MatchPlayerNum - Players.Length
                MessageHud.Show(S2M("あと {NeedPlayerNum} 人のプレイヤーの参加を待っています。\nWaiting for {NeedPlayerNum} more players to join.")) # プレイヤー全員にHUDを表示
                Sleep(1.0)
                set WaitedTime += 1.0
        else:
            set GameFlowDevice.GameStarted = true # ラウンド開始の合図
            Print("試合は始まっている")

    OnPlayerSpawn(Agent:agent):void=
        PlayerStatsManager.InitializePlayerStat(Agent) # 持続データをプレイヤーに割り当てる
        PlayerStatsManager.ResetGameStats(Agent) # 試合ごとに-1にするデータを初期化する

    # チーム分けを行う関数。実際にはここではクラスを設定することでチームを分ける
    SplitPlayersToTeams():void=
        Players := Shuffle(GamePlayers)
        PlayersNum := Players.Length
        if:
            TeamPlayerNum := Ceil[PlayersNum * 1.0 / 2.0]
            T1 := Players.Slice[0, TeamPlayerNum] # 0 番目から TeamPlayerNum - 1 番目までの配列
            T2 := Players.Slice[TeamPlayerNum] # TeamPlayerNum 番目から最後までの配列
            ClassSelector1 := ClassSelectors[0]
            ClassSelector2 := ClassSelectors[1]
        then:
            for(Player:T1):
                ClassSelector1.ChangeClass(Player)
            for(Player:T2):
                ClassSelector2.ChangeClass(Player)

    # すべてのプレイヤーを静止させてから、ステージにテレポートさせる関数
    TeleportToStage():void=
        for(Index->ClassDesigner:ClassDesigners, Teleporters := TeleportersArray[Index]):
            for(Index2->Agent:ClassDesigner.GetClassMembers(), Teleporter := Teleporters[Index2]):
                # 静止処理
                if(Fort := player[Agent].GetFortCharacter[]):
                    Fort.PutInStasis(stasis_args{AllowTurning := false, AllowFalling := true, AllowEmotes := true})
                
                # ステージにテレポート
                Teleporter.Teleport(Agent)

    # 8人揃っていない状態で試合を始めてもいいかをプレイヤーに確認するポップアップを表示する関数
    DisplayVoteStarting()<suspends>:void=
        PlayersNum := GetPlayspace().GetPlayers().Length
        PopupDialogDevice.SetTitleText(S2M("{PlayersNum}/{MatchPlayerNum}"))
        PopupDialogDevice.Show() # すべてのプレイヤーにポップアップを表示する
        Sleep(DisplayPopupTime + 1.0)
        
        Print("VoteYesCount: {VoteYesCount}, VoteNoCount: {VoteNoCount}")
        if(VoteYesCount >= VoteNoCount):
            Print("必要な人数を{PlayersNum}人に変更します")
            set ThisMatchPlayerNum = PlayersNum
        else:
            set VoteNoCount = 0
            set VoteYesCount = 0

        CompleteVoteEvent.Signal()

    # ポップアップのボタンが押されたときに実行される関数
    ClickPopupBtn(Agent:agent, BtnNum:int):void=
        if(BtnNum = 0):
            set VoteNoCount += 1
        else if(BtnNum = 1):
            set VoteYesCount += 1
