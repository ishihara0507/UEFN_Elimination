using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Fortnite.com/Teams }

round_ui_device := class(creative_device):

    # ラウンドの進行結果を表示するUI用---------------------------------------------------------------------------------
    @editable
    RoundTimeHudDevice:hud_message_device = hud_message_device{} # ラウンドの制限時間を表示するようにテキスト
    @editable
    BallisticTimeHudDevice:hud_message_device = hud_message_device{} # 爆弾が設置された後のテキスト

    var TeamPlayerNum:int = 0

    var TeamWidgets:[]widget = array{canvas{}, canvas{}}

    var PlayerRoundStatusUIMap:[player]round_status_ui = map{}

    # ウィジェット
    var MyTeamTextures:[][]texture_block = array{}
    var EnemyTeamTextures:[][]texture_block = array{}

    var MyPointTexts:[]text_block = array{}
    var EnemyPointTexts:[]text_block = array{}
    # --------------------------------------------------------------------------------------------------------------

    # ラウンド結果を表示するUI用 --------------------------------------------------------------------------------------

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

    # ラウンドの進行状況を表すUIを全プレイヤーに付与する関数
    AddRoundStatusUI(TeamRemainingMap:[team]int, TeamWinsMap:[team]int):void=
        RemoveRoundStatusUI() # 一応前回のラウンド進行状況UIを削除しておく（一度のラウンド中に複数回付与することはないはずだけど）

        if(Num := Quotient[MatchPlayerNum, 2]):
            set TeamPlayerNum = Num

        TeamCollection := GetPlayspace().GetTeamCollection()
        for(Team:TeamCollection.GetTeams(), Agents := TeamCollection.GetAgents[Team]):
            for(Agent:Agents, Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                RoundStatusUI := round_status_ui:
                    Players := GetPlayspace().GetPlayers()
                    PlayerTeam := Team
                    TeamCollection := TeamCollection
                    TeamPlayerNum := TeamPlayerNum
                RoundStatusUI.Init(TeamRemainingMap, TeamWinsMap)
                PlayerUI.AddWidget(RoundStatusUI.Widget)
                if. set PlayerRoundStatusUIMap[Player] = RoundStatusUI

        RoundTimeHudDevice.Show(S2M(""))

    # ラウンドの進行状況を表すUIを更新する関数（制限時間部分は除く）
    UpdateRoundStatusUI(TeamRemainingMap:[team]int, TeamWinsMap:[team]int):void=
        ###
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        for(Index->Team:TeamArray, R := TeamRemainingMap[Team], W := TeamWinsMap[Team]):
            Print("チーム{Index + 1},  残り人数: {R}, 勝利数: {W}")
        ###

        for(RoundStatusUI:PlayerRoundStatusUIMap):
            RoundStatusUI.UpdateUI(TeamRemainingMap, TeamWinsMap)

    # ラウンドの進行状況を表すUIを全プレイヤーから削除する関数
    RemoveRoundStatusUI():void=
        for(Player->RoundStatusUI:PlayerRoundStatusUIMap, PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(RoundStatusUI.Widget)

        RoundTimeHudDevice.Hide()
        BallisticTimeHudDevice.Hide()
                    
    # ラウンドの進行状況を表すUIを更新する関数（制限時間部分のみ）
    # 制限時間は頻繁に更新するので別関数として用意
    UpdateRoundTimeText(Message:message):void=
        RoundTimeHudDevice.SetText(Message)

    # 制限時間のテキストを非表示にする関数
    HideRoundTimeText():void=
        RoundTimeHudDevice.Hide()
        
    ShowBallisticTime(Message:message):void=
        RoundTimeHudDevice.Hide()
        BallisticTimeHudDevice.Show(Message)

    UpdateBallisticTimeText(Message:message):void=
        BallisticTimeHudDevice.SetText(Message)

    HideBallisticTime():void=
        BallisticTimeHudDevice.Hide()

    # ラウンド結果を表示するUIを全プレイヤーに付与する関数
    ShowRoundResult(TeamWinsMap:[team]int, RoundCount:int, ORoundWinTeam:?team):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        if(RoundWinTeam := ORoundWinTeam?):
            for(Index->Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
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

    HideRoundResult(GamePlayers:[]player):void=
        HudDevices := array{RoundCountHudDevice} + WinMTHudDevices + LoseMTHudDevices + WinETHudDevices + LoseETHudDevices
        for(Player:GamePlayers):
            for(HudDevice:HudDevices):
                HudDevice.Hide(Player)

    # 黒半透明の背景を全プレイヤーに表示する関数
    ShowBackground(GamePlayers:[]player):void=
        for(Player:GamePlayers):
            BackgroundHudDevice.Show(Player)

    HideBackground(GamePlayers:[]player):void=
        for(Player:GamePlayers):
            BackgroundHudDevice.Hide(Player)

    ShowSideSwitch(GamePlayers:[]player):void=
        for(Player:GamePlayers):
            SideSwitchHudDevice.Show(Player)

    HideSideSwitch(GamePlayers:[]player):void=
        for(Player:GamePlayers):
            SideSwitchHudDevice.Hide(Player)

    # ラウンド開始前に各プレイヤーに今何陣営かを表示する関数
    ShowSide(GamePlayers:[]player):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        for(Index->Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
            if(Index = 0):
                for(Agent:Agents):
                    AttackersHudDevice.Show(Agent)
            else:
                for(Agent:Agents):
                    DefendersHudDevice.Show(Agent)

    HideSide(GamePlayers:[]player):void=
        for(Player:GamePlayers):
            AttackersHudDevice.Hide(Player)
            DefendersHudDevice.Hide(Player)


round_status_ui := class:
    Players:[]player
    PlayerTeam:team
    TeamCollection:fort_team_collection
    TeamPlayerNum:int

    var Widget:widget = canvas{}

    # ウィジェット
    var MyTeamTextures:[]texture_block = array{}
    var EnemyTeamTextures:[]texture_block = array{}

    var MyPointText:text_block = text_block{}
    var EnemyPointText:text_block = text_block{}

    var TimeText:text_block = text_block{}

    Init(TeamRemainingMap:[team]int, TeamWinsMap:[team]int):void=
        # ウィジェットの初期化
        set MyTeamTextures = for(Index2 := 0 .. TeamPlayerNum - 1):
            texture_block{DefaultImage := Textures.Human_Blue, DefaultDesiredSize := vector2{X := 54.0, Y := 54.0}}

        set EnemyTeamTextures = for(Index2 := 0 .. TeamPlayerNum - 1):
                texture_block{DefaultImage := Textures.Human_Red, DefaultDesiredSize := vector2{X := 54.0, Y := 54.0}}

        set MyPointText = text_block{DefaultText:=S2M("0")}
        
        set EnemyPointText = text_block{DefaultText:=S2M("0")}

        CreateUI()
        UpdateUI(TeamRemainingMap, TeamWinsMap)

    # ラウンドの進行状況を表すUIを作成する関数
    CreateUI():void=
        var NewSlots:[]canvas_slot = array{}

        # 制限時間を表示するウィジェットを追加
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}}
                Offsets := margin{Left := 0.0, Top := 60.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                ZOrder := 0
                Widget := texture_block{DefaultImage := Textures.RoundTimeBack, DefaultDesiredSize := vector2{X := 130.0, Y := 70.0}}

        # ラウンド勝利数を追加
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
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}}
                Offsets := margin{Left := -216.0, Top := 60.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := stack_box:
                    Orientation := orientation.Horizontal
                    Slots := for(Index := 0 .. TeamPlayerNum - 1):
                        var PaddingLeft:float = -10.0
                        var Texture:texture_block = texture_block{DefaultImage := Textures.Human_Blue}
                        if(Index = 0):
                            set PaddingLeft = 0.0
                        if(T := MyTeamTextures[Index]):
                            set Texture = T
                        
                        stack_box_slot:
                            Padding := margin{Left := PaddingLeft}
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Fill
                            Widget := Texture

        # 敵チームのプレイヤーアイコンを追加
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}}
                Offsets := margin{Left := 216.0, Top := 60.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := stack_box:
                    Orientation := orientation.Horizontal
                    Slots := for(Index := 0 .. TeamPlayerNum - 1):
                        var PaddingLeft:float = -10.0
                        var Texture:texture_block = texture_block{DefaultImage := Textures.Human_Red}
                        if(Index = 0):
                            set PaddingLeft = 0.0
                        if(T := EnemyTeamTextures[Index]):
                            set Texture = T
                        
                        stack_box_slot:
                            Padding := margin{Left := PaddingLeft}
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Fill
                            Widget := Texture

        set Widget = canvas{Slots := NewSlots}

    # ラウンドの進行状況を表すUIを更新する関数（制限時間部分は除く）
    UpdateUI(TeamRemainingMap:[team]int, TeamWinsMap:[team]int):void=
        TeamArray := TeamCollection.GetTeams()
        var OEnemyTeam:?team = false

        for(Team:TeamArray, Team <> PlayerTeam):
            set OEnemyTeam = option{Team}

        # 味方チームのラウンド勝利数を更新 --------------------------------------------
        if(Point := TeamWinsMap[PlayerTeam]):
            MyPointText.SetText(S2M("{Point}"))

        # 敵チームのラウンド勝利数を更新 --------------------------------------------
        if(EnemyTeam := OEnemyTeam?, Point := TeamWinsMap[EnemyTeam]):
            EnemyPointText.SetText(S2M("{Point}"))

        # 味方チームの生存者リストを更新 --------------------------------------------
        var MTPlayerNum:int = 0
        for(Agent:TeamCollection.GetAgents[PlayerTeam], Players.Find[player[Agent]]):
            set MTPlayerNum += 1

        # プレイヤーのテクスチャ自体を表示するかしないかを設定
        var MTHiddenNum:int = TeamPlayerNum - MTPlayerNum
        for(Texture:MyTeamTextures):
            if(MTHiddenNum > 0):
                Texture.SetVisibility(widget_visibility.Hidden)
                set MTHiddenNum -= 1
            else:
                Texture.SetVisibility(widget_visibility.Visible)

        # プレイヤーがキルされているかいないかを設定
        var MTDeathPlayerNum:int = 0
        if(RemainingNum := TeamRemainingMap[PlayerTeam]):
            set MTDeathPlayerNum = MTPlayerNum - RemainingNum
            for(Texture:MyTeamTextures):
                if(MTDeathPlayerNum > 0):
                    Texture.SetImage(Textures.Human_Dark)
                    set MTDeathPlayerNum -= 1
                else:
                    Texture.SetImage(Textures.Human_Blue)

        # 敵チームの生存者リストを更新 --------------------------------------------
        var ETPlayerNum:int = 0
        if(EnemyTeam := OEnemyTeam?):
            for(Agent:TeamCollection.GetAgents[EnemyTeam], Players.Find[player[Agent]]):
                set ETPlayerNum += 1

        # プレイヤーのテクスチャ自体を表示するかしないかを設定
        for(Texture:EnemyTeamTextures):
            if(ETPlayerNum > 0):
                Texture.SetVisibility(widget_visibility.Visible)
                set ETPlayerNum -= 1
            else:
                Texture.SetVisibility(widget_visibility.Hidden)

        # プレイヤーがキルされているかいないかを設定
        var ETRemainingNum:int = 0
        if(EnemyTeam := OEnemyTeam?, Num := TeamRemainingMap[EnemyTeam]):
            set ETRemainingNum = Num
            for(Texture:EnemyTeamTextures):
                if(ETRemainingNum > 0):
                    Texture.SetImage(Textures.Human_Red)
                    set ETRemainingNum -= 1
                else:
                    Texture.SetImage(Textures.Human_Dark)
