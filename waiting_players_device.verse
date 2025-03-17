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
    SavePresetDevice:save_preset_device = save_preset_device{}

    @editable
    PlayerSpawners:[]player_spawner_device = array{} # マップに入ったときにスポーンするやつ

    @editable
    EnterMutator:mutator_zone_device = mutator_zone_device{}

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
    NoneClassSelector:class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    MessageHud:hud_message_device = hud_message_device{}
    @editable
    CountDownHud:hud_message_device = hud_message_device{}
    
    @editable
    VsMTHudDevice:hud_message_device = hud_message_device{}
    @editable
    VsETHudDevice:hud_message_device = hud_message_device{}

    @editable
    VoteStartPopupDevice:popup_dialog_device = popup_dialog_device{} # 人数が揃っていない状態で試合を始めていいかを確認するためのデバイス
    @editable
    VoteResultPopupDevice:popup_dialog_device = popup_dialog_device{} # 投票の結果を表示するためのデバイス

    var GamePlayers:[]player = array{}

    var TeleportersArray:[][]teleporter_device = array{}

    var VoteYesCount:int = 0
    var VoteNoCount:int = 0
    var ThisMatchPlayerNum:int = MatchPlayerNum # 今回の試合に参加するプレイヤー人数（8人未満の場合もあるため用意）


    StartDelay:int = 5 # プレイヤーがそろってから試合を開始するまでの秒数

    DisplayPopupTime:float = 10.0 # ポップアップを表示する時間
    VsPlayerNameDisplayTime:float = 5.0

    CompleteVoteEvent:event() = event(){}
    VoteResultEvent:event() = event(){}

    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    OnBegin<override>()<suspends>:void=
        for(PlayerSpawner:PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)
        VoteStartPopupDevice.RespondingButtonEvent.Subscribe(ClickPopupBtn)
        EnterMutator.AgentEntersEvent.Subscribe(OnEnterMutator)

        set TeleportersArray = array{AttackerTeleporters, DefenderTeleporters}

        spawn{OnPlayerLeaved()} # 退出待ちループ関数を実行する

        Sleep(0.0) # スポーン時の処理を先に実行させるために必要
        # プレイヤー待ちループは、試合開始前のみ実行させるようにする
        var NotGameStarted:logic = false
        loop:
            var CheckedPlayerCount:int = 0
            Print("プレイヤーを確認")
            for(Player:GetPlayspace().GetPlayers()):
                OPlayerStats := PlayerStatsManager.GetPlayerStats(Player)
                if(PlayerStats := OPlayerStats?):
                    set CheckedPlayerCount += 1
                    if(PlayerStats.RoundWins = -1):
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
            loop: # プレイヤー待ちループ
                # 3分経過して8人に達していなかったら、試合を始めてるかの投票を行う
                PlayerNum := GetPlayspace().GetPlayers().Length
                if(WaitedTime >= 180.0, PlayerNum < MatchPlayerNum): 
                    spawn{DisplayVoteStarting(PlayerNum)} # 投票を行う
                    CompleteVoteEvent.Await() # 投票が完了するまで待機

                    spawn{DisplayVoteResult(PlayerNum)} # 投票結果を表示
                    VoteResultEvent.Await()

                    set VoteYesCount = 0
                    set VoteNoCount = 0
                    set WaitedTime = 0.0

                # 人数が揃っているかを確認
                Players := GetPlayspace().GetPlayers()
                if(Players.Length >= ThisMatchPlayerNum):
                    Print("プレイヤーが揃ったのでゲームを開始する")
                    RoundSettingDevice.DisableMatchmaking() # 新しくマップにマッチングできないようにする
                    MessageHud.Hide()

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

                    SavePresetDevice.KillAllPresetsUI() # プリセット登録UIを全プレイヤーから削除する
                    ShowVsUIAndTeleportToStage() # 参加するプレイヤーの名前を見せて、ステージへのテレポートも行う

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

    # プレイヤーが退出したら、そのプレイヤーのクラスをクラスなしに変更する関数
    OnPlayerLeaved()<suspends>:void=
        loop:
            LeavingPlayer := GetPlayspace().PlayerRemovedEvent().Await()
            PlayerStatsManager.ResetGameStats(LeavingPlayer) # 試合ごとに-1にするデータを初期化する
            NoneClassSelector.ChangeClass(LeavingPlayer) # クラスをクラスなしに設定する

    OnEnterMutator(Agent:agent):void=
        PlayerStatsManager.InitializePlayerStat(Agent) # 持続データをプレイヤーに割り当てる
        PlayerStatsManager.ResetGameStats(Agent) # 試合ごとに-1にするデータを初期化する
        NoneClassSelector.ChangeClass(Agent) # クラスをクラスなしに設定する

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

    # messageを結合する関数（間に改行を挟む）
    CombineMsg<localizes>(Msg:message, Msg2:message):message="{Msg}\n{Msg2}"

    # 各チームのプレイヤーネームテキストを作成する関数
    GenPlayerNamesMsg():[team]message=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        var TeamMsgMap:[team]message = map{}

        for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
            if(Agents.Length > 0):
                for(Index->Agent:Agents, Player := player[Agent]):
                    PlayerName := GetAgentName(Player)
                    if(Index = 0):
                        if. set TeamMsgMap[Team] = PlayerName
                    else if(DeforeMsg := TeamMsgMap[Team]):
                        AfterMsg := CombineMsg(DeforeMsg, PlayerName)
                        if. set TeamMsgMap[Team] = AfterMsg
            else:
                EmptyMsg := S2M("")
                if. set TeamMsgMap[Team] = EmptyMsg

        return TeamMsgMap
    
    # 試合開始前に各チームのプレイヤーの名前を表示するUIを付与する関数
    ShowVsUIAndTeleportToStage()<suspends>:void=
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

        Sleep(VsPlayerNameDisplayTime / 2.0)
        TeleportToStage()
        Sleep(VsPlayerNameDisplayTime / 2.0)

        for(Player:GamePlayers):
            VsMTHudDevice.Hide(Player)
            VsETHudDevice.Hide(Player)

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
    DisplayVoteStarting(PlayerNum:int)<suspends>:void=
        VoteStartPopupDevice.SetTitleText(S2M("{PlayerNum}/{MatchPlayerNum} players"))
        VoteStartPopupDevice.SetDescriptionText(S2M("現在の人数で試合を始めてもよろしいですか？\nIs it okay to start the game with the current number of people?"))

        VoteStartPopupDevice.Show() # すべてのプレイヤーにポップアップを表示する
        Sleep(DisplayPopupTime + 0.5)
        VoteStartPopupDevice.Hide()
        
        Print("VoteYesCount: {VoteYesCount}, VoteNoCount: {VoteNoCount}")
        if(VoteYesCount >= VoteNoCount, not (VoteYesCount = 0 and VoteNoCount = 0)):
            Print("必要な人数を{PlayerNum}人に変更します")
            set ThisMatchPlayerNum = PlayerNum
            MessageHud.Hide()

        CompleteVoteEvent.Signal()

    # ポップアップのボタンが押されたときに実行される関数
    ClickPopupBtn(Agent:agent, BtnNum:int):void=
        if(BtnNum = 0):
            set VoteNoCount += 1
        else if(BtnNum = 1):
            set VoteYesCount += 1

    # 投票の結果をポップアップで表示する関数
    DisplayVoteResult(PlayerNum:int)<suspends>:void=
        TitleText := "投票結果 Voting results"
        TimedOutNum := PlayerNum - (VoteYesCount + VoteNoCount)
        var DescriptionText:string = ""

        if(not ThisMatchPlayerNum = MatchPlayerNum): # Yes >= No だったら
            set DescriptionText += "Yes: {VoteYesCount}人, No: {VoteNoCount}人, 時間切れ: {TimedOutNum}人 だったので、試合を開始します。\n"
            set DescriptionText += "\n"
            set DescriptionText += "Yes: {VoteYesCount}, No: {VoteNoCount}, Timed out: {TimedOutNum}. Therefore, we will start the game."
        else:
            set DescriptionText += "Yes: {VoteYesCount}人, No: {VoteNoCount}人, 時間切れ: {TimedOutNum}人 だったので、他のプレイヤーの参加を待ちます。\n"
            set DescriptionText += "さらに3分経過してもまだ8人に達していない場合は、再度投票を行います。\n"
            set DescriptionText += "\n"
            set DescriptionText += "Yes: {VoteYesCount}, No: {VoteNoCount}, Timed out: {TimedOutNum}. Therefore, we will wait for more players to join.\n"
            set DescriptionText += "If the number of players still does not reach 8 after an additional 3 minutes, we will hold another vote."

        VoteResultPopupDevice.SetTitleText(S2M(TitleText))
        VoteResultPopupDevice.SetDescriptionText(S2M(DescriptionText))

        VoteResultPopupDevice.Show()
        Sleep(DisplayPopupTime)
        VoteResultPopupDevice.Hide()

        VoteResultEvent.Signal()