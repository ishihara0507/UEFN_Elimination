using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Fortnite.com/Teams }

round_ui_device := class(creative_device):
    
    @editable
    GameManagerDevice:game_manager_device = game_manager_device{}

    # ラウンドの進行結果を表示するUI用---------------------------------------------------------------------------------
    var TeamPlayerNum:int = 0

    var TeamWidgets:[]widget = array{canvas{}, canvas{}}

    # ウィジェット
    var MyTeamTextures:[][]texture_block = array{}
    var EnemyTeamTextures:[][]texture_block = array{}

    var MyPointTexts:[]text_block = array{}
    var EnemyPointTexts:[]text_block = array{}

    var TimeText:text_block = text_block{}
    # --------------------------------------------------------------------------------------------------------------

    # ラウンド結果を表示するUI用 --------------------------------------------------------------------------------------
    @editable
    DisplayTime:float = 4.0

    @editable
    SideSwitchDisplayTime:float = 3.0

    @editable
    WinMTHudDevices:[]hud_message_device = array{} # 自分のチームが勝利したときの、自分のチーム側のウィジェット
    @editable
    WinETHudDevices:[]hud_message_device = array{} # 自分のチームが勝利したときの、敵のチーム側のウィジェット
    
    @editable
    LoseMTHudDevices:[]hud_message_device = array{} # 自分のチームが敗北したときの、自分のチーム側のウィジェット
    @editable
    LoseETHudDevices:[]hud_message_device = array{} # 自分のチームが敗北したときの、敵のチーム側のウィジェット

    @editable
    RoundCountHudDevice:hud_message_device = hud_message_device{}
    
    @editable
    BackgroundHudDevice:hud_message_device = hud_message_device{}

    @editable
    SideSwitchHudDevice:hud_message_device = hud_message_device{}

    @editable
    AttackersHudDevice:hud_message_device = hud_message_device{}
    
    @editable
    DefendersHudDevice:hud_message_device = hud_message_device{}
    #  -------------------------------------------------------------------------------------------------------------

    OnBegin<override>()<suspends>:void=
        # ラウンドの進行結果を表示するUI用 --------------------------------------------------
        if(Num := Quotient[GameManagerDevice.MatchPlayerNum, 2]):
            set TeamPlayerNum = Num
            
        # ウィジェットの初期化

        set MyTeamTextures = for(Index := 0 .. 1):
            for(Index2 := 0 .. TeamPlayerNum - 1):
                texture_block{DefaultImage := Textures.Human_Blue, DefaultDesiredSize := vector2{X := 54.0, Y := 54.0}}

        set EnemyTeamTextures = for(Index := 0 .. 1):
            for(Index2 := 0 .. TeamPlayerNum - 1):
                texture_block{DefaultImage := Textures.Human_Red, DefaultDesiredSize := vector2{X := 54.0, Y := 54.0}}

        set MyPointTexts = for(Index := 0 .. 1):
            text_block{DefaultText:=S2M("0")}
        
        set EnemyPointTexts = for(Index := 0 .. 1):
            text_block{DefaultText:=S2M("0")}

        set TimeText = text_block{DefaultText:=S2M("00:00")}
        
        # ラウンド結果を表示するUI用 -------------------------------------------------------
        for(HudDevice:WinMTHudDevices):
            HudDevice.SetDisplayTime(DisplayTime)

        for(HudDevice:WinETHudDevices):
            HudDevice.SetDisplayTime(DisplayTime)

        for(HudDevice:LoseMTHudDevices):
            HudDevice.SetDisplayTime(DisplayTime)

        for(HudDevice:LoseMTHudDevices):
            HudDevice.SetDisplayTime(DisplayTime)

        RoundCountHudDevice.SetDisplayTime(DisplayTime)

    # ラウンドの進行状況を表すUIを全プレイヤーに付与する関数
    AddRoundStateUI():void=
        CreateRoundStateUI()

        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        for(Index := 0 .. 1):
            for(Agent:TeamCollection.GetAgents[TeamArray[Index]], PlayerUI := GetPlayerUI[player[Agent]]):
                if(Widget := TeamWidgets[Index]):
                    PlayerUI.AddWidget(Widget)

    # ラウンドの進行状況を表すUIを全プレイヤーから削除する関数
    DeleteRoundStateUI():void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        for(Index := 0 .. 1):
            for(Agent:TeamCollection.GetAgents[TeamArray[Index]], PlayerUI := GetPlayerUI[player[Agent]]):
                if(Widget := TeamWidgets[Index]):
                    PlayerUI.RemoveWidget(Widget)
                    
    # ラウンドの進行状況を表すUIを作成する関数
    CreateRoundStateUI():void=
        for(Index := 0 .. 1):
            var NewSlots:[]canvas_slot = array{}

            # 制限時間を表示するウィジェットを追加
            set NewSlots += array:
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}}
                    Offsets := margin{Left := 0.0, Top := 60.0, Right := -0.0, Bottom := -0.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                    Widget := color_block{DefaultColor := color{R := 1.0, G := 1.0, B := 1.0}, DefaultDesiredSize := vector2{X := 128.0, Y := 54.0}}
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}}
                    Offsets := margin{Left := 0.0, Top := 60.0, Right := -0.0, Bottom := -0.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                    Widget := TimeText

            # ラウンド勝利数を追加
            if(MyPointText := MyPointTexts[Index], EnemyPointText := EnemyPointTexts[Index]):
                set NewSlots += array:
                    canvas_slot:
                        Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}}
                        Offsets := margin{Left := -100.0, Top := 60.0, Right := -0.0, Bottom := -0.0}
                        Alignment := vector2{X:=0.5,Y:=0.5}
                        SizeToContent := true
                        Widget := MyPointText
                    canvas_slot:
                        Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}}
                        Offsets := margin{Left := 100.0, Top := 60.0, Right := -0.0, Bottom := -0.0}
                        Alignment := vector2{X:=0.5,Y:=0.5}
                        SizeToContent := true
                        Widget := EnemyPointText

            # 味方チームのプレイヤーアイコンを追加
            if(MyTeamTexture := MyTeamTextures[Index]):
                set NewSlots += array:
                    canvas_slot:
                        Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}}
                        Offsets := margin{Left := -216.0, Top := 60.0, Right := -0.0, Bottom := -0.0}
                        Alignment := vector2{X:=0.5,Y:=0.5}
                        SizeToContent := true
                        Widget := stack_box:
                            Orientation := orientation.Horizontal
                            Slots := for(Index2 := 0 .. TeamPlayerNum - 1):
                                var PaddingLeft:float = -10.0
                                var Texture:texture_block = texture_block{DefaultImage := Textures.Human_Blue}
                                if(Index2 = 0):
                                    set PaddingLeft = 0.0
                                if(T := MyTeamTexture[Index2]):
                                    set Texture = T
                                
                                stack_box_slot:
                                    Padding := margin{Left := PaddingLeft}
                                    HorizontalAlignment := horizontal_alignment.Fill
                                    VerticalAlignment := vertical_alignment.Fill
                                    Widget := Texture

            # 敵チームのプレイヤーアイコンを追加
            if(EnemyTeamTexture := EnemyTeamTextures[Index]):
                set NewSlots += array:
                    canvas_slot:
                        Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}}
                        Offsets := margin{Left := 216.0, Top := 60.0, Right := -0.0, Bottom := -0.0}
                        Alignment := vector2{X:=0.5,Y:=0.5}
                        SizeToContent := true
                        Widget := stack_box:
                            Orientation := orientation.Horizontal
                            Slots := for(Index2 := 0 .. TeamPlayerNum - 1):
                                var PaddingLeft:float = -10.0
                                var Texture:texture_block = texture_block{DefaultImage := Textures.Human_Red}
                                if(Index2 = 0):
                                    set PaddingLeft = 0.0
                                if(T := EnemyTeamTexture[Index2]):
                                    set Texture = T
                                
                                stack_box_slot:
                                    Padding := margin{Left := PaddingLeft}
                                    HorizontalAlignment := horizontal_alignment.Fill
                                    VerticalAlignment := vertical_alignment.Fill
                                    Widget := Texture

            if. set TeamWidgets[Index] = canvas{Slots := NewSlots}

        UpdateRoundStateUI() # 表示・非表示を設定する

    # ラウンドの進行状況を表すUIを更新する関数（制限時間部分のみ）
    # 制限時間は頻繁に更新するので別関数として用意
    UpdateRoundStateUITimeText(Message:message):void=
        TimeText.SetText(Message)

    # ラウンドの進行状況を表すUIを更新する関数（制限時間部分は除く）
    UpdateRoundStateUI():void=
        TeamWinsMap := GameManagerDevice.TeamWinsMap
        TeamRemainingMap := GameManagerDevice.TeamRemainingMap

        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        # 味方チームのラウンド勝利数を更新
        for(Index->Team:TeamArray):
            if(MyPointText := MyPointTexts[Index], Point := TeamWinsMap[Team]):
                MyPointText.SetText(S2M("{Point}"))

        # 敵チームのラウンド勝利数を更新
        for(Index->Team:TeamArray):
            for(Index2 := 0 .. 1):
                if(not Index = Index2, EnemyPointText := EnemyPointTexts[Index2], Point := TeamWinsMap[Team]):
                    EnemyPointText.SetText(S2M("{Point}"))

        # 味方チームの生存者リストを更新
        for(Index->MyTeamTexture:MyTeamTextures):
            var PlayerNum:int = 0

            # プレイヤーのテクスチャ自体を表示するかしないかを設定
            if(Num := TeamCollection.GetAgents[TeamArray[Index]].Length):
                set PlayerNum = Num
                var HiddenNum:int = TeamPlayerNum - PlayerNum
                for(Texture:MyTeamTexture):
                    if(HiddenNum > 0):
                        Texture.SetVisibility(widget_visibility.Hidden)
                        set HiddenNum -= 1
                    else:
                        Texture.SetVisibility(widget_visibility.Visible)

            # プレイヤーがキルされているかいなかを設定
            var DeathPlayerNum:int = 0
            if(RemainingNum := TeamRemainingMap[TeamArray[Index]]):
                set DeathPlayerNum = PlayerNum - RemainingNum
                for(Texture:MyTeamTexture):
                    if(DeathPlayerNum > 0):
                        Texture.SetImage(Textures.Human_Dark)
                        set DeathPlayerNum -= 1
                    else:
                        Texture.SetImage(Textures.Human_Blue)

        # 敵チームの生存者リストを更新
        for(Index->EnemyTeamTexture:EnemyTeamTextures):
            for(Index2 := 0 .. 1):
                # プレイヤーのテクスチャ自体を表示するかしないかを設定
                var PlayerNum:int = 0
                if(not Index = Index2, Num := TeamCollection.GetAgents[TeamArray[Index2]].Length):
                    set PlayerNum = Num
                    for(Texture:EnemyTeamTexture):
                        if(PlayerNum > 0):
                            Texture.SetVisibility(widget_visibility.Visible)
                            set PlayerNum -= 1
                        else:
                            Texture.SetVisibility(widget_visibility.Hidden)

                # プレイヤーがキルされているかいかなを設定
                var RemainingNum:int = 0
                if(not Index = Index2, Num := TeamRemainingMap[TeamArray[Index2]]):
                    set RemainingNum = Num
                    for(Texture:EnemyTeamTexture):
                        if(RemainingNum > 0):
                            Texture.SetImage(Textures.Human_Red)
                            set RemainingNum -= 1
                        else:
                            Texture.SetImage(Textures.Human_Dark)

    # ラウンド結果を表示するUIを全プレイヤーに付与する関数
    ShowRoundResult(RoundCount:int, ORoundWinTeam:?team)<suspends>:void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        TeamWinsMap := GameManagerDevice.TeamWinsMap

        if(RoundWinTeam := ORoundWinTeam?):
            for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
                # 使用するHUDデバイスの配列を決定する
                MTHudDevices := if(Team = RoundWinTeam). WinMTHudDevices else. LoseMTHudDevices
                ETHudDevices := if(Team = RoundWinTeam). WinETHudDevices else. LoseETHudDevices

                # 上で決定した配列の中から、使用するHUDデバイスを決定する
                var MTIndex:int = -1
                var ETIndex:int = -1
                for(Team2:TeamArray, Wins := TeamWinsMap[Team2]):
                    if(Team2 = Team):
                        set MTIndex = if(Team2 = RoundWinTeam). Wins - 1 else. Wins
                    else:
                        set ETIndex = if(Team2 = RoundWinTeam). Wins - 1 else. Wins

                # 表示する
                if(MTHudDevice := MTHudDevices[MTIndex], ETHudDevice := ETHudDevices[ETIndex]):
                    for(Agent:Agents):
                        RoundCountHudDevice.Show(Agent, S2M("Round {RoundCount}"))
                        MTHudDevice.Show(Agent)
                        ETHudDevice.Show(Agent)
        Sleep(DisplayTime)

    # 黒半透明の背景を全プレイヤーに表示する関数
    ShowBackground():void=
        for(Player:GameManagerDevice.GamePlayers):
            BackgroundHudDevice.Show(Player)

    HideBackground():void=
        for(Player:GameManagerDevice.GamePlayers):
            BackgroundHudDevice.Hide(Player)

    ShowHideSideSwitch()<suspends>:void=
        for(Player:GameManagerDevice.GamePlayers):
            SideSwitchHudDevice.Show(Player)

        Sleep(SideSwitchDisplayTime)

        for(Player:GameManagerDevice.GamePlayers):
            SideSwitchHudDevice.Hide(Player)

    # ラウンド開始前に各プレイヤーに今何陣営かを表示する関数
    ShowHideSide(OAttackTeam:?team, ODefenseTeam:?team)<suspends>:void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        if(AttackTeam := OAttackTeam?, DefenceTeam := ODefenseTeam?):
            for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
                if(Team = AttackTeam):
                    for(Agent:Agents):
                        AttackersHudDevice.Show(Agent)
                else:
                    for(Agent:Agents):
                        DefendersHudDevice.Show(Agent)

        Sleep(SideSwitchDisplayTime)

        for(Player:GameManagerDevice.GamePlayers):
            AttackersHudDevice.Hide(Player)
            DefendersHudDevice.Hide(Player)
