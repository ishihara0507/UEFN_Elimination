using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Fortnite.com/Teams }

####################################################
### ラウンドの進行状況を表すUIを管理するためのクラス ###
####################################################

round_state_ui := class():

    GameManagerDevice:game_manager_device
    TeamCollection:fort_team_collection
    
    var TeamPlayerNum:int = 4

    var TeamWidgets:[]widget = array{}

    # ウィジェット
    var MyTeamTextures:[][]texture_block = array{}
    var EnemyTeamTextures:[][]texture_block = array{}

    var MyPointTexts:[]text_block = array{}
    var EnemyPointTexts:[]text_block = array{}

    var TimeText:text_block = text_block{}

    Init()<suspends>:void=
        # ウィジェットの初期化
        if(Num := Quotient[GameManagerDevice.MatchPlayerNum, 2]):
            set TeamPlayerNum = Num

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
        
        # UIの付与
        CreateUI()

        TeamArray := TeamCollection.GetTeams()
        for(Index := 0 .. 1):
            for(Agent:TeamCollection.GetAgents[TeamArray[Index]], PlayerUI := GetPlayerUI[player[Agent]]):
                if(Widget := TeamWidgets[Index]):
                    PlayerUI.AddWidget(Widget)

    DeleteAllUI():void=
        TeamArray := TeamCollection.GetTeams()
        for(Index := 0 .. 1):
            for(Agent:TeamCollection.GetAgents[TeamArray[Index]], PlayerUI := GetPlayerUI[player[Agent]]):
                if(Widget := TeamWidgets[Index]):
                    PlayerUI.RemoveWidget(Widget)

    CreateUI():void=
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
                                if(Index = 0):
                                    set PaddingLeft = 0.0
                                if(T := EnemyTeamTexture[Index2]):
                                    set Texture = T
                                
                                stack_box_slot:
                                    Padding := margin{Left := PaddingLeft}
                                    HorizontalAlignment := horizontal_alignment.Fill
                                    VerticalAlignment := vertical_alignment.Fill
                                    Widget := Texture

            if. set TeamWidgets[Index] = canvas{Slots := NewSlots}

        UpdateUI() # 表示・非表示を設定する

    UpdateUI():void=
        TeamWinsMap := GameManagerDevice.TeamWinsMap
        TeamRemainingMap := GameManagerDevice.TeamRemainingMap

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
            # プレイヤーのテクスチャ自体を表示するかしないかを設定
            var PlayerNum:int = 0
            if(Num := TeamCollection.GetAgents[TeamArray[Index]].Length):
                set PlayerNum = Num
                for(Texture:MyTeamTexture, PlayerNum <= 0):
                    Texture.SetVisibility(widget_visibility.Hidden)
                    set PlayerNum -= 1

            # プレイヤーがキルされているかいかなを設定
            var DeathPlayerNum:int = 0
            if(RemainingNum := TeamRemainingMap[TeamArray[Index]]):
                set DeathPlayerNum = PlayerNum - RemainingNum
                for(Texture:MyTeamTexture):
                    if(DeathPlayerNum > 0):
                        Texture.SetImage(Textures.Human_Red)
                        set DeathPlayerNum -= 1
                    else:
                        Texture.SetImage(Textures.Human_Blue)

        # 敵チームの生存者リストを更新
        for(Index->MyTeamTexture:MyTeamTextures):
            for(Index2 := 0 .. 1):
                # プレイヤーのテクスチャ自体を表示するかしないかを設定
                var PlayerNum:int = 0
                if(not Index = Index2, Num := TeamCollection.GetAgents[TeamArray[Index2]].Length):
                    set PlayerNum = Num
                    for(Texture:MyTeamTexture, PlayerNum <= 0):
                        Texture.SetVisibility(widget_visibility.Hidden)
                        set PlayerNum -= 1

                # プレイヤーがキルされているかいかなを設定
                var RemainingNum:int = 0
                if(not Index = Index2, Num := TeamRemainingMap[TeamArray[Index2]]):
                    set RemainingNum = Num
                    for(Texture:MyTeamTexture):
                        if(RemainingNum > 0):
                            Texture.SetImage(Textures.Human_Blue)
                            set RemainingNum -= 1
                        else:
                            Texture.SetImage(Textures.Human_Red)

    # 制限時間は頻繁に更新するので別関数として用意
    UpdateTimeText(Message:message):void=
        TimeText.SetText(Message)