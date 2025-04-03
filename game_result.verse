using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Teams }

#########################################################
### 試合結果のUIの表示や、結果の反映を行うためのプログラム ###
#########################################################

# 持続データへの登録処理とかもここに記述する

# 試合結果に応じた、UIの付与や持続データの更新を行うクラス
game_result := class:
    GamePlayers:[]player
    TeamWinsMap:[team]int
    WinningTeam:team
    TeamCollection:fort_team_collection
    WinLoseHudDevice:hud_message_device
    LoseWinHudDevice:hud_message_device

    var PlayerResultMap:[player][string]int = map{}

    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    # 全プレイヤーに試合結果のUIを表示する関数
    AddGameResultUI():void=
        # データの作成（PlayerResultMap の初期化、ソート処理を行うならここ）
        for(Player:GamePlayers):
            var ValueMap:[string]int = map{} # １人のプレイヤーのキル・デス・ボムの値を保持
            OPlayerStats := PlayerStatsManager.GetPlayerStats(Player)
            
            if:
                PlayerStats := OPlayerStats?
                set ValueMap["Kills"] = PlayerStats.CurrentKills
                set ValueMap["Deaths"] = PlayerStats.CurrentDeaths
                set ValueMap["StartBombs"] = PlayerStats.CurrentStartBombs
                set ValueMap["StopBombs"] = PlayerStats.CurrentStopBombs
                set PlayerResultMap[Player] = ValueMap

        # 試合結果を持続データへの反映
        SavePlayersResult() 

        # UIの付与
        TeamArray := TeamCollection.GetTeams()
        for(Team:TeamArray):
            for(Agent:TeamCollection.GetAgents[Team], Player := player[Agent]):
                GameResultUI := game_result_ui:
                    TeamWinsMap := TeamWinsMap
                    WinningTeam := WinningTeam
                    WinLoseHudDevice := WinLoseHudDevice
                    LoseWinHudDevice := LoseWinHudDevice
                    AddPlayer := Player
                    PlayerTeam := Team
                    PlayerResultMap := PlayerResultMap
                    TeamCollection := TeamCollection
                spawn{GameResultUI.Init()}
                PlayerStatsManager.ResetGameStats(Player) # 試合ごとに初期化するデータをリセット

    # 全プレイヤーの試合結果を持続データに反映する関数
    SavePlayersResult():void=
        # キル・デス・ボム設置を更新
        for(Player->ResultMap:PlayerResultMap):
            if(AddKills := ResultMap["Kills"]):
                PlayerStatsManager.UpdateTotalKillsStat(Player, AddKills)
            if(AddDeaths := ResultMap["Deaths"]):
                PlayerStatsManager.UpdateTotalDeathsStat(Player, AddDeaths)
            if(AddStartBombs := ResultMap["StartBombs"]):
                PlayerStatsManager.UpdateTotalStartBombsStat(Player, AddStartBombs)
            if(AddStopBombs := ResultMap["StopBombs"]):
                PlayerStatsManager.UpdateTotalStopBombsStat(Player, AddStopBombs)

        # ガチャの結果を更新
        for(Player:GamePlayers):
            PlayerStatsManager.UpdateTotalRarityPullsArrayStat(Player)

        # 勝利数または敗北数を更新
        for(Index->Team:TeamCollection.GetTeams(), Agents := TeamCollection.GetAgents[Team]):
            if(Team = WinningTeam):
                for(Agent:Agents):
                    PlayerStatsManager.UpdateTotalWinsStat(Agent)
            else:
                for(Agent:Agents):
                    PlayerStatsManager.UpdateTotalLossesStat(Agent)
                    

# 試合結果を表示するUI関連の処理をまとめたクラス（UIの見た目は W_GameResult を元に作っている）
game_result_ui := class:

    TeamWinsMap:[team]int
    WinningTeam:team
    WinLoseHudDevice:hud_message_device
    LoseWinHudDevice:hud_message_device
    AddPlayer:player # UIを付与するプレイヤー
    PlayerTeam:team # UIを付与するプレイヤーが参加しているチーム
    PlayerResultMap:[player][string]int
    TeamCollection:fort_team_collection

    var Widget:widget = canvas{}
    
    var TeamPlayers:[][]player = array{} # 各チームごとにメンバーを保持

    var CloseBtn:button_loud = button_loud{}

    TeamPlayerNum:int = 4 # プレイヤーを2列4行分を表示する

    Init()<suspends>:void=
        set CloseBtn = button_loud{DefaultText:=S2M("CLOSE")}

        # 自分チームと敵チームのラウンド勝利数を決める
        var MyTeamPoint:int = 0
        var EnemyTeamPoint:int = 0
        for(Team->Point:TeamWinsMap):
            if(Team = PlayerTeam):
                set MyTeamPoint = Point
            else:
                set EnemyTeamPoint = Point

        # 使うHUDデバイスを決める
        var UseHudDevice:hud_message_device = hud_message_device{}
        if(PlayerTeam = WinningTeam):
            set UseHudDevice = WinLoseHudDevice
        else:
            set UseHudDevice = LoseWinHudDevice

        if(PlayerUI := GetPlayerUI[AddPlayer]):
            CreateUI()
            UseHudDevice.Show(AddPlayer, S2M("{MyTeamPoint}  {EnemyTeamPoint}"))
            PlayerUI.AddWidget(Widget, player_ui_slot{InputMode := ui_input_mode.All})
            CloseBtn.OnClick().Await()
            PlayerUI.RemoveWidget(Widget)
            UseHudDevice.Hide(AddPlayer)

    CreateUI():void=
        # 各チームのメンバーを取得
        TeamArray := TeamCollection.GetTeams()
        set TeamPlayers = for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
            for(Agent:Agents, Player := player[Agent]):
                Player
            
        var NewSlots:[]canvas_slot = array{}
        var StackBoxSlots:[][]stack_box_slot = array{array{}, array{}}

        # スタックボックスの表に見出しの行を追加
        # （実際には見出しの行の部分は、HUDデバイスで表示するが、位置を合わせるために透明の見出し行を追加する。）
        for(StackIndex := 0 .. 1):
            # スタックボックスの表に見出しの行を追加
            # （実際には見出しの行の部分は、HUDデバイスで表示するが、位置を合わせるために透明の見出し行を追加する。）
            TranparentStackBox := stack_box_slot:
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
                Widget := overlay:
                    Slots := array:
                        overlay_slot:
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Fill
                            Widget := color_block{DefaultDesiredSize := vector2{X := -0.0, Y := -0.0}, DefaultOpacity := 0.0}
                        overlay_slot:
                            Padding := margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Fill
                            Widget := stack_box:
                                Orientation := orientation.Horizontal
                                Slots := array:
                                    # プレイヤー名の領域
                                    stack_box_slot:
                                        HorizontalAlignment := horizontal_alignment.Fill
                                        VerticalAlignment := vertical_alignment.Fill
                                        Widget := overlay:
                                            Slots := array:
                                                overlay_slot:
                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                    VerticalAlignment := vertical_alignment.Fill
                                                    Widget := color_block{DefaultDesiredSize := vector2{X := 365.0, Y := -0.0}, DefaultOpacity := 0.0}
                                                overlay_slot:
                                                    HorizontalAlignment := horizontal_alignment.Left
                                                    VerticalAlignment := vertical_alignment.Center
                                                    Widget := text_block{DefaultText := S2M("PlayerName"), DefaultTextOpacity := 0.0}
                                    # キルアイコンの領域
                                    CreateTranparentStackBoxSlot()
                                    # デスアイコンの領域
                                    CreateTranparentStackBoxSlot()
                                    # ボムアイコンの領域
                                    CreateTranparentStackBoxSlot()
 
            if. set StackBoxSlots[StackIndex] = array{TranparentStackBox}
            else. Print("見出し失敗")

        for(StackIndex := 0 .. 1):
            # スタックボックスに表のデータ部分を追加
            TeamOrder := if(PlayerTeam = TeamArray[0]). array{0, 1} else. array{1, 0}

            var Color:color = color{R := 0.0, G := 0.15, B := 0.25} # 青色
            if(StackIndex = 1):
                set Color = color{R := 0.57, G := 0.0, B := 0.08} # 赤色

            PlayerStackBoxes := for(Index2 := 0 .. TeamPlayerNum - 1):
                var PlayerName:message = S2M("----------")
                var Kill:string = "--"
                var Death:string = "--"
                var StartBomb:string = "--"
                var StopBomb:string = "--"

                if:
                    Player := TeamPlayers[TeamOrder[StackIndex]][Index2]
                    K := PlayerResultMap[Player]["Kills"]
                    D := PlayerResultMap[Player]["Deaths"]
                    StartB := PlayerResultMap[Player]["StartBombs"]
                    StopB := PlayerResultMap[Player]["StopBombs"]
                then:
                    set PlayerName = GetAgentName(Player)
                    set Kill = "{K}"
                    set Death = "{D}"
                    set StartBomb = "{StartB}"
                    set StopBomb = "{StopB}"
                    
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := color_block{DefaultColor := Color, DefaultDesiredSize := vector2{X := -0.0, Y := -0.0}}
                            overlay_slot:
                                Padding := margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                                HorizontalAlignment := horizontal_alignment.Left
                                VerticalAlignment := vertical_alignment.Center
                                Widget := stack_box:
                                    Orientation := orientation.Horizontal
                                    Slots := array:
                                        # プレイヤー名の追加
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Fill
                                            VerticalAlignment := vertical_alignment.Fill
                                            Widget := overlay:
                                                Slots := array:
                                                    overlay_slot:
                                                        HorizontalAlignment := horizontal_alignment.Fill
                                                        VerticalAlignment := vertical_alignment.Fill
                                                        Widget := color_block{DefaultDesiredSize := vector2{X := 365.0, Y := -0.0}, DefaultOpacity := 0.0}
                                                    overlay_slot:
                                                        HorizontalAlignment := horizontal_alignment.Left
                                                        VerticalAlignment := vertical_alignment.Center
                                                        Widget := text_block{DefaultText := PlayerName, DefaultTextColor := Black}
                                        # キル数の追加
                                        CreateStackBoxSlot(Kill)
                                        # デス数の追加
                                        CreateStackBoxSlot(Death)
                                        # ボム数の追加
                                        CreateStackBoxSlot(StartBomb)
                                        # ボム数の追加
                                        CreateStackBoxSlot(StopBomb)

            if. set StackBoxSlots[StackIndex] += PlayerStackBoxes
            else. Print("データ失敗")
                                
        # キャンバスに味方と敵の表を横に並べるスタックボックスを追加
        set NewSlots = array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := -5.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := stack_box:
                    Orientation := orientation.Horizontal
                    Slots := for(Index2 := 0 .. 1, StackBoxSlot := StackBoxSlots[Index2]):
                        stack_box_slot:
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Fill
                            Widget := stack_box:
                                Orientation := orientation.Vertical
                                Slots := StackBoxSlot
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 250.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := CloseBtn

        set Widget = canvas{Slots := NewSlots}

    # 透明のキル・デス・ボムを表示するstack_box_slotを作成する関数
    CreateTranparentStackBoxSlot():stack_box_slot=
        stack_box_slot: 
            HorizontalAlignment := horizontal_alignment.Fill
            VerticalAlignment := vertical_alignment.Fill
            Widget := overlay:
                Slots := array:
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment := vertical_alignment.Fill
                        Widget := color_block{DefaultDesiredSize := vector2{X := 100.0, Y := -0.0}, DefaultOpacity := 0.0}
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Center
                        Widget := color_block{DefaultDesiredSize := vector2{X := 52.0, Y := 52.0}, DefaultOpacity := 0.0}

    # キル・デス・ボムを表示するstack_box_slotを作成する関数（コードの重複をなくすために作成した）
    CreateStackBoxSlot(Str:string):stack_box_slot=
        stack_box_slot:
            HorizontalAlignment := horizontal_alignment.Fill
            VerticalAlignment := vertical_alignment.Fill
            Widget := overlay:
                Slots := array:
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment := vertical_alignment.Fill
                        Widget := color_block{DefaultDesiredSize := vector2{X := 100.0, Y := -0.0}, DefaultOpacity := 0.0}
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Center
                        Widget := text_block{DefaultText := S2M(Str), DefaultTextColor := Black}
