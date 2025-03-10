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
    AttackerTeleporters:[]teleporter_device = array{}
    @editable
    DefenderTeleporters:[]teleporter_device = array{}

    @editable
    ClassDesigners:[]class_designer_device = array{} # 要素１をクラス２のやつに、要素２をクラス３のやつに設定する必要がある
    @editable
    ClassSelectors:[]class_and_team_selector_device = array{}

    @editable
    CountDownHud:hud_message_device = hud_message_device{}
    @editable
    MessageHud:hud_message_device = hud_message_device{}

    var GamePlayers:[]player = array{}

    var TeleportersArray:[][]teleporter_device = array{}

    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    StartDelay:int = 5 # プレイヤーがそろってから試合を開始するまでの秒数

    OnBegin<override>()<suspends>:void=
        for(PlayerSpawner:PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)

        set TeleportersArray = array{AttackerTeleporters, DefenderTeleporters}

        # プレイヤー待ちループは、試合開始前のみ実行させるようにする
        var NotGameStarted:logic = false
        loop:
            Players := GetPlayspace().GetPlayers()
            if(Players.Length >= 2):
                for(Player:Players):
                    OPlayerStats := PlayerStatsManager.GetPlayerStats(Player)
                    if(PlayerStats := OPlayerStats?, PlayerStats.RoundWins = -1):
                        set NotGameStarted = true
                break
            else:
                Sleep(1.0)
            
        if(NotGameStarted?):
            loop:
                Players := GetPlayspace().GetPlayers()
                if(Players.Length >= MatchPlayerNum):
                    Print("プレイヤーが揃ったのでゲームを開始する")
                    set GamePlayers = Players

                    var Count:int = StartDelay
                    CountDownHud.Show(S2M("ゲーム開始まで {Count}\nGame starts in: {Count}"))
                    loop:
                        Sleep(1.0)
                        set Count -= 1
                        if(Count <= 0):
                            break
                        CountDownHud.SetText(S2M("ゲーム開始まで {Count}\nGame starts in: {Count}"))
                    CountDownHud.Hide()
                    
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
        else:
            set GameFlowDevice.GameStarted = true # ラウンド開始の合図

    OnPlayerSpawn(Agent:agent):void=
        PlayerStatsManager.InitializePlayerStat(Agent) # 持続データをプレイヤーに割り当てる
        PlayerStatsManager.ResetGameStats(Agent) # 試合ごとに-1にするデータを初期化する

    # チーム分けを行う関数。実際にはここではクラスを設定することでチームを分ける
    SplitPlayersToTeams():void=
        Players := Shuffle(GamePlayers)
        if:
            TeamPlayerNum := Quotient[MatchPlayerNum, 2]
            T1 := Players.Slice[0, TeamPlayerNum]
            T2 := Players.Slice[TeamPlayerNum]
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