using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }

##################################################
### 選択したプリセットを手持ちに反映するプログラム ###
##################################################

select_preset_device := class(creative_device):
    
    @editable
    WeaponGranter:item_granter_device = item_granter_device{} # 選択した武器を付与するデバイス

    @editable
    ItemRemover:item_remover_device = item_remover_device{} # 手持ちアイテムを削除するためのデバイス

    @editable
    PresetTrigger:trigger_device = trigger_device{} # このトリガーを起動したらプリセット選択が行える

    var PlayerUIMap:[]select_preset_ui = array{}

    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?, Player := player[Agent]):
            spawn{MakePresetsUI(Player)}

    OnBegin<override>()<suspends>:void=
        PresetTrigger.TriggeredEvent.Subscribe(OnTriggered)

    # プリセット選択UIを作成する関数        
    MakePresetsUI(Player:player)<suspends>:void=
        Print("UI作成")
        OPlayerStat := PlayerStatsManager.GetPlayerStats(Player)
        if(PlayerStat := OPlayerStat?):
            var Presets:[][]weapon_enum = array:
                PlayerStat.Preset0
                PlayerStat.Preset1
                PlayerStat.Preset2
                PlayerStat.Preset3
                PlayerStat.Preset4
                
            NewSelectPresetUI := select_preset_ui{Presets := Presets}
            NewSelectPresetUI.Init()

            if(set PlayerUIMap += array{NewSelectPresetUI}, PlayerUI := GetPlayerUI[Player]):
                PlayerUI.AddWidget(NewSelectPresetUI.Widget, player_ui_slot{InputMode := ui_input_mode.All})
                SelectNum := NewSelectPresetUI.KillEvent.Await()
                PlayerUI.RemoveWidget(NewSelectPresetUI.Widget)
                if(Preset := Presets[SelectNum]):
                    GrantPreset(Player, Preset)
                else:
                    Print("選択が強制的に終了された")

    # 選択したプリセットと同じ武器をプレイヤーの手持ちに与える関数
    GrantPreset(Player:player, Preset:[]weapon_enum):void=
        Print("武器を与える")
        ItemRemover.Remove(Player) # 所持アイテムの削除
        for(Weapon:Preset):
            WeaponGranter.GrantItemIndex(Player, Weapon.ToIndex())

    # すべてのプレイヤーからプリセット選択UIを削除する関数
    KillAllPresetsUI():void=
        for(PlayerUI:PlayerUIMap):
            PlayerUI.KillEvent.Signal(100) # わざと失敗になるインデックスを返す

select_preset_ui := class:

    var Widget:widget = canvas{}

    Presets:[][]weapon_enum # 持続データに登録されているプリセットを保持する

    var PageNum:int = 0 # 最初のページを０ページ目と考える

    var MaxPage:int = 0
    WeaponSlotsNum:int = 5

    UpValue:float = 100.0 # ウィジェット全体を中央からどれだけ上に移動させるか（0.0にすると武器画像の列が上下左右中央に配置される）

    # ウィジェット
    var BackBtn:button_loud = button_loud{}
    var SelectBtn:button_loud = button_loud{}
    var NextBtn:button_loud = button_loud{}

    var PagiNationBlocks:[]color_block = array{}
    var PagiNationBorders:[]color_block = array{}

    var PresetWeaponTextures:[]texture_block = array{}

    # イベント
    KillEvent:event(int) = event(int){} # 選択したプリセットのインデックスを返せるようにする
    UpdateEvent:event() = event(){}

    Init():void=
        set MaxPage = Presets.Length

        # 各ウィジェットの設定
        set BackBtn = button_loud{DefaultText:=S2M("<")}
        set SelectBtn = button_loud{DefaultText:=S2M("Select")}
        set NextBtn = button_loud{DefaultText:=S2M(">")}
        for(Index := 0 .. MaxPage - 1):
            set PagiNationBorders += array{color_block{DefaultColor := color{R := 0.8, G := 0.0, B := 0.0}, DefaultDesiredSize := vector2{X := 50.0, Y := 50.0}}} # 赤
            set PagiNationBlocks += array{color_block{DefaultColor := color{R := 1.0, G := 1.0, B := 1.0}, DefaultDesiredSize := vector2{X := 38.0, Y := 38.0}}} # 白 

        for(Index := 0 .. WeaponSlotsNum - 1):
            set PresetWeaponTextures += array{texture_block{DefaultImage := weapon_enum.PumpShotgun_L1.ToTexture(), DefaultDesiredSize := vector2{X := 150.0, Y := 150.0}}}

        CreateUI()
        spawn{HandleBtn()}

    # UIを作成する関数
    CreateUI():void=
        var NewSlots:[]canvas_slot = array{}
        
        # ボタン系を追加
        set NewSlots += array:
            canvas_slot:
                Widget := BackBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := -150.0, Top := 250.0 - UpValue, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
            canvas_slot:
                Widget := SelectBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 250.0 - UpValue, Right := 200.0, Bottom := 80.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := false
            canvas_slot:
                Widget := NextBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 150.0, Top := 250.0 - UpValue, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
            
        # ページネーションを追加
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 150.0 - UpValue, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := stack_box:
                    Orientation := orientation.Horizontal
                    Slots := for(Index := 0 .. MaxPage - 1):
                        var PagiNationBorder:color_block = color_block{}
                        var PagiNationBlock:color_block = color_block{}
                        var PaddingLeft:float = 0.0

                        if(not Index = 0):
                            set PaddingLeft = 20.0
                        if(Border := PagiNationBorders[Index], Block := PagiNationBlocks[Index]):
                            set PagiNationBorder = Border
                            set PagiNationBlock = Block

                        stack_box_slot:
                            Padding := margin{Left := PaddingLeft}
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Fill
                            Widget := overlay:
                                Slots := array:
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Center
                                        VerticalAlignment := vertical_alignment.Center
                                        Widget := PagiNationBorder
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Center
                                        VerticalAlignment := vertical_alignment.Center
                                        Widget := PagiNationBlock
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Center
                                        VerticalAlignment := vertical_alignment.Center
                                        Widget := text_block{DefaultText := S2M("{Index + 1}")}

        # 具体的な武器なUpdateUI()で設定する（ここではとりあえずデフォルト画像を設定）
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 0.0 - UpValue, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := overlay:
                    Slots := array:
                        overlay_slot:
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Fill
                            Widget := color_block{DefaultColor := color{R := 1.0, G := 0.3, B := 0.0}}
                        overlay_slot:
                            Padding := margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment := vertical_alignment.Center
                            Widget := stack_box:
                                Orientation := orientation.Horizontal
                                Slots := for(Index := 0 .. WeaponSlotsNum - 1):
                                    var WeaponTexture:texture_block = texture_block{DefaultImage := weapon_enum.PumpShotgun_L1.ToTexture()}
                                    var PaddingLeft:float = 0.0

                                    if(Texture := PresetWeaponTextures[Index]):
                                        set WeaponTexture = Texture
                                    if(not Index = 0):
                                        set PaddingLeft = 10.0

                                    stack_box_slot:
                                        Padding := margin{Left := PaddingLeft}
                                        HorizontalAlignment := horizontal_alignment.Fill
                                        VerticalAlignment := vertical_alignment.Fill
                                        Widget := overlay:
                                            Slots := array:
                                                overlay_slot:
                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                    VerticalAlignment := vertical_alignment.Fill
                                                    Widget := color_block{DefaultColor := color{R := 1.0, G := 1.0, B := 1.0}}
                                                overlay_slot:
                                                    Padding := margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                    VerticalAlignment := vertical_alignment.Fill
                                                    Widget := WeaponTexture

        set Widget = canvas{Slots := NewSlots}

        UpdateUI() # 表示・非表示を設定する

    # UIを更新する関数
    UpdateUI():void=
        # ページネーションの更新
        for(Index->PagiNationBorder:PagiNationBorders):
            if(Index = PageNum):
                PagiNationBorder.SetVisibility(widget_visibility.Visible)
            else:
                PagiNationBorder.SetVisibility(widget_visibility.Hidden)

        # そのページに登録しているプリセットの画像を更新
        for(Index->PresetWeaponTexture:PresetWeaponTextures):
            if(Weapon := Presets[PageNum][Index]):
                PresetWeaponTexture.SetImage(Weapon.ToTexture())
                PresetWeaponTexture.SetVisibility(widget_visibility.Visible)
            else:
                PresetWeaponTexture.SetVisibility(widget_visibility.Hidden)

    # ボタン入力を管理する関数
    HandleBtn()<suspends>:void=
        var SelectedBtn:string = ""

        race:
            block:
                KillEvent.Await()
            loop:
                race:
                    block:
                        BackBtn.OnClick().Await()
                        set SelectedBtn = "Back"
                    block:
                        SelectBtn.OnClick().Await()
                        set SelectedBtn = "Select"
                    block:
                        NextBtn.OnClick().Await()
                        set SelectedBtn = "Next"

                if(SelectedBtn = "Back"):
                    Print("Backボタンが押された")
                    if(PageNum = 0):
                        set PageNum = MaxPage - 1
                    else:
                        set PageNum -= 1
                else if(SelectedBtn = "Select"):
                    Print("Selectボタンが押された")
                    KillEvent.Signal(PageNum)
                else if(SelectedBtn = "Next"):
                    Print("Nextボタンが押された")
                    if(PageNum = MaxPage - 1):
                        set PageNum = 0
                    else:
                        set PageNum += 1

                UpdateUI()

        Print("ボタン待ち処理終了")