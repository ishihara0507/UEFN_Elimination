using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Fortnite.com/Teams }

test_device := class(creative_device):

    @editable
    UITringger:trigger_device = trigger_device{}

    @editable
    HudDevice:hud_message_device = hud_message_device{}

    @editable
    Trigger:trigger_device = trigger_device{}
    @editable
    Trigger2:trigger_device = trigger_device{}
    @editable
    Trigger3:trigger_device = trigger_device{}
    @editable
    Trigger4:trigger_device = trigger_device{}
    @editable
    Trigger5:trigger_device = trigger_device{}
    @editable
    Trigger6:trigger_device = trigger_device{}

    Event:event() = event(){}
    Event2:event() = event(){}
    Event3:event() = event(){}
    Event4:event() = event(){}
    Event5:event() = event(){}

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)
        Trigger2.TriggeredEvent.Subscribe(OnTriggered2)
        Trigger3.TriggeredEvent.Subscribe(OnTriggered3)
        Trigger4.TriggeredEvent.Subscribe(OnTriggered4)
        Trigger5.TriggeredEvent.Subscribe(OnTriggered5)
        Trigger6.TriggeredEvent.Subscribe(OnTriggered6)

        Print("5秒待機。この間にチームを切り替えて")
        Sleep(5.0)

        TeamCollection := GetPlayspace().GetTeamCollection()
        TestRoundStateUI := test_round_state_ui{TeamCollection := TeamCollection}
        TestRoundStateUI.Init()
        spawn{Time(TestRoundStateUI)}

        Print("操作待ち")
        race:
            loop:
                Event.Await()
                UpdateWinsMap(TestRoundStateUI, TeamCollection, 0)
            loop:
                Event2.Await()
                UpdateRemainingMap(TestRoundStateUI, TeamCollection, 0)
            loop:
                Event3.Await()
                UpdateWinsMap(TestRoundStateUI, TeamCollection, 1)
            loop:
                Event4.Await()
                UpdateRemainingMap(TestRoundStateUI, TeamCollection, 1)
            loop:
                Event5.Await()
                TestRoundStateUI.DeleteAllUI()
                break

        
    OnTriggered(OAgent:?agent):void=
        Event.Signal()

    OnTriggered2(OAgent:?agent):void=
        Event2.Signal()

    OnTriggered3(OAgent:?agent):void=
        Event3.Signal()

    OnTriggered4(OAgent:?agent):void=
        Event4.Signal()
    
    OnTriggered6(OAgent:?agent):void=
        Event5.Signal()
    
    UpdateWinsMap(TestRoundStateUI:test_round_state_ui, TeamCollection:fort_team_collection, Index:int):void=
        TeamArray := TeamCollection.GetTeams()
        for(Index2->Team:TeamArray, Index = Index2):
            if. set TestRoundStateUI.TeamWinsMap[Team] += 1
        TestRoundStateUI.UpdateUI()

    UpdateRemainingMap(TestRoundStateUI:test_round_state_ui, TeamCollection:fort_team_collection, Index:int):void=
        TeamArray := TeamCollection.GetTeams()
        for(Index2->Team:TeamArray, Index = Index2):
            if. set TestRoundStateUI.TeamRemainingMap[Team] -= 1
        TestRoundStateUI.UpdateUI()

    Time(TestRoundStateUI:test_round_state_ui)<suspends>:void=
        var Count:int = 10
        TestRoundStateUI.UpdateTimeText(S2M("{CalcElapsedTime(Count)}"))

        loop:
            Sleep(1.0)
            set Count -= 1
            TestRoundStateUI.UpdateTimeText(S2M("{CalcElapsedTime(Count)}"))
            if(Count <= 0):
                break

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

    OnTriggered5(OAgent:?agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        if:
            Agent := OAgent?
            Player := player[Agent]
            CurrentTeam := TeamCollection.GetTeam[Player]
        then:
            for(Index->Team:TeamArray):
                if(not Team = CurrentTeam):
                    if(TeamCollection.AddToTeam[Player, Team]):
                        Print("チーム{Index}に切り替えました")
                

test_round_state_ui := class():

    TeamCollection:fort_team_collection

    MatchPlayerNum:int = 8

    var TeamWinsMap:[team]int = map{}
    var TeamRemainingMap:[team]int = map{}
    
    var TeamPlayerNum:int = 4

    var TeamWidgets:[]widget = array{canvas{}, canvas{}}

    # ウィジェット
    var MyTeamTextures:[][]texture_block = array{}
    var EnemyTeamTextures:[][]texture_block = array{}

    var MyPointTexts:[]text_block = array{}
    var EnemyPointTexts:[]text_block = array{}

    var TimeText:text_block = text_block{}

    Init()<suspends>:void=
        TeamArray := TeamCollection.GetTeams()
        for(Index->Team:TeamArray):
            Print("チーム{Index}を初期化")
            if. set TeamWinsMap[Team] = 0
            if. set TeamRemainingMap[Team] = 4

        # ウィジェットの初期化
        if(Num := Quotient[MatchPlayerNum, 2]):
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

        UpdateUI() # 表示・非表示を設定する

    UpdateUI():void=
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
                set PlayerNum = 2
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
                    set PlayerNum = 1
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

    # 制限時間は頻繁に更新するので別関数として用意
    UpdateTimeText(Message:message):void=
        TimeText.SetText(Message)
