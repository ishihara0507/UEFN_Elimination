using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Fortnite.com/Teams }

#########################################################
### 試合結果のUIの表示や、結果の反映を行うためのプログラム ###
#########################################################

# 持続データへの登録処理とかもここに記述する

# 試合結果に応じた、UIの付与や持続データの更新を行うクラス
game_result := class:

    GameManagerDevice:game_manager_device
    TeamCollection:fort_team_collection
    PlayerKillMap:[player]int # 各プレイヤーのキル数を保持
    PlayerDeathMap:[player]int # 各プレイヤーのデス数を保持
    PlayerBombMap:[player]int # 各プレイヤーの爆弾起動数を保持

    AddGameResultUI():void=
        # １チームの人数を算出
        var TeamPlayerNum:int = 0
        if(Num := Quotient[GameManagerDevice.MatchPlayerNum, 2]):
            set TeamPlayerNum = Num

        # PlayerResultMap の初期化（ソートをするならここ）
        var PlayerResultMap:[player][string]int = map{}
        for(Player:GameManagerDevice.GamePlayers):
            var ValueMap:[string]int = map{} # １人のプレイヤーのキル・デス・ボムの値を保持
            
            if(Kill := PlayerKillMap[Player]):
                if. set ValueMap["Kill"] = Kill
            if(Death := PlayerDeathMap[Player]):
                if. set ValueMap["Death"] = Death
            if(Bomb := PlayerBombMap[Player]):
                if. set ValueMap["Bomb"] = Bomb

            if. set PlayerResultMap[Player] = ValueMap

        TeamArray := TeamCollection.GetTeams()
        for(Team:TeamArray):
            for(Agent:TeamCollection.GetAgents[Team], PlayerUI := GetPlayerUI[player[Agent]]):
                GameResultUI := game_result_ui:
                    PlayerUI := PlayerUI
                    PlayerTeam := Team
                    TeamCollection := TeamCollection
                    TeamPlayerNum := TeamPlayerNum
                    PlayerResultMap := PlayerResultMap
                spawn{GameResultUI.Init()}

# 試合結果を表示するUI関連の処理をまとめたクラス（UIの見た目は W_GameResult を元に作っている）
game_result_ui := class:

    PlayerUI:player_ui # UIを付与するプレイヤー
    PlayerTeam:team # UIを付与するプレイヤーが参加しているチーム
    TeamCollection:fort_team_collection
    TeamPlayerNum:int
    PlayerResultMap:[player][string]int

    var TeamWidgets:[]widget = array{canvas{}, canvas{}}

    var Widget:widget = canvas{}

    var TeamPlayers:[][]player = array{}

    var CloseBtn:button_loud = button_loud{}

    Init()<suspends>:void=
        set CloseBtn = button_loud{DefaultText:=S2M("CLOSE")}

        CreateUI()
        PlayerUI.AddWidget(Widget)
        CloseBtn.OnClick().Await()
        PlayerUI.RemoveWidget(Widget)

    CreateUI():void=
        # 各チームのメンバーを取得
        TeamArray := TeamCollection.GetTeams()
        set TeamPlayers = for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
            for(Agent:Agents, Player := player[Agent]):
                Player
            
        for(Index := 0 .. 1):
            var NewSlots:[]canvas_slot = array{}
            var StackBoxSlots:[][]stack_box_slot = array{}

            # 透明のアイコン領域を定義
            ClearBox:stack_box_slot = stack_box_slot: 
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

            # 味方と敵の表の部分をループで作成する
            set StackBoxSlots = for(StackIndex := 0 .. 1):
                # スタックボックスの表に見出しの行を追加
                # （実際には見出しの行の部分は、HUDデバイスで表示するが、位置を合わせるために透明の見出し行を追加する。）
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := color_block{DefaultColor := color{R := 1.0, G := 1.0, B := 1.0}, DefaultDesiredSize := vector2{X := -0.0, Y := -0.0}}
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
                                        ClearBox
                                        # デスアイコンの領域
                                        ClearBox
                                        # ボムアイコンの領域
                                        ClearBox

                # スタックボックスに表のデータ部分を追加
                TeamOrder := if(Index = 0). array{0, 1} else. array{1, 0}

                var Color:color = color{R := 0.0, G := 0.15, B := 0.25} # 青色
                if(StackIndex = 1):
                    set Color = color{R := 0.57, G := 0.0, B := 0.08} # 赤色

                var PlayerName:message = S2M("----------")
                var Kill:string = "--"
                var Death:string = "--"
                var Bomb:string = "--"
                for(Index2 := 0 .. TeamPlayerNum - 1):
                    if:
                        Player := TeamPlayers[TeamOrder[StackIndex]][Index2]
                        K := PlayerResultMap[Player][Kill]
                        D := PlayerResultMap[Player][Death]
                        B := PlayerResultMap[Player][Bomb]
                    then:
                        set PlayerName = GetAgentName(Player)
                        set Kill = "{K}"
                        set Death = "{D}"
                        set Bomb = "{B}"  # text_block{DefaultText := PlayerName, DefaultTextOpacity := 0.0}
                        
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
                                                            Widget := text_block{DefaultText := PlayerName}
                                            # キル数の追加
                                            CreateStackBoxSlot(Kill)
                                            # デス数の追加
                                            CreateStackBoxSlot(Death)
                                            # ボム数の追加
                                            CreateStackBoxSlot(Bomb)

                                    
            # キャンバスに味方と敵の表を横に並べるスタックボックスを追加
            set NewSlots = array:
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets := margin{Left := 0.0, Top := 0.0, Right := -0.0, Bottom := -0.0}
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
                    Offsets := margin{Left := 0.0, Top := 200.0, Right := -0.0, Bottom := -0.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                    Widget := CloseBtn

            if. set TeamWidgets[Index] = canvas{Slots := NewSlots}

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
                        Widget := text_block{DefaultText := S2M(Str)}