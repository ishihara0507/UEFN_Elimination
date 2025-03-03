using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Assets }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }

#####################################
### プリセットの登録を行うプログラム ###
#####################################

save_preset_device := class(creative_device):

    @editable
    WeaponsSelectDevice:weapons_select_device = weapons_select_device{}

    @editable
    SaveTrigger:trigger_device = trigger_device{} # プリセット登録を行うUIを付与するトリガー

    @editable
    DebugTrigger:trigger_device = trigger_device{} # デバッグ用

    var PlayerPresetsUIMap:[player]presets_ui = map{}

    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    OnBegin<override>()<suspends>:void=
        SaveTrigger.TriggeredEvent.Subscribe(OnTriggered)
        DebugTrigger.TriggeredEvent.Subscribe(PlayerStatsManager.ShowPresets) # デバッグ用

    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?, Player := player[Agent]):
            spawn{MakePresetsUI(Player)}

    # プリセットUIを作成する関数        
    MakePresetsUI(Player:player)<suspends>:void=
        Print("UI作成")
        if(HoldingWeapons := WeaponsSelectDevice.WeaponsPlayerMap[Player]):
            NewPresetsUI := presets_ui{Player := Player, HoldingWeapons := HoldingWeapons, PlayerStatsManager := PlayerStatsManager}
            NewPresetsUI.Init()

            if(set PlayerPresetsUIMap[Player] = NewPresetsUI, PlayerUI := GetPlayerUI[Player]):
                PlayerUI.AddWidget(NewPresetsUI.Widget, player_ui_slot{InputMode := ui_input_mode.All})
                NewPresetsUI.KillEvent.Await()
                PlayerUI.RemoveWidget(NewPresetsUI.Widget)
        else:
            Print("連携エラー")

    # すべてのプレイヤーからプリセット登録UIを削除する関数
    KillAllPresetsUI():void=
        for(PlayerPresetsUI:PlayerPresetsUIMap):
            PlayerPresetsUI.KillEvent.Signal()

presets_ui := class:

    var Widget:widget = canvas{}

    # インスタンス作成時に設定する
    Player:player
    HoldingWeapons:[]weapon_enum
    PlayerStatsManager:player_stat_manager
    
    var MaxPage:int = 3 # プリセット登録できる最大値
    var PageNum:int = 0 # 最初のページを０ページ目と考える

    WeaponSlotsNum:int = 5
    var Presets:[][]weapon_enum = array{} # 持続データに登録されているプリセットを保持する

    # ウィジェット
    var BackBtn:button_loud = button_loud{}
    var SaveBtn:button_loud = button_loud{}
    var NextBtn:button_loud = button_loud{}
    var ExitBtn:button_loud = button_loud{}

    var PagiNationBlocks:[]color_block = array{}
    var PagiNationBorders:[]color_block = array{}

    var HoldingWeaponTextures:[]texture_block = array{}
    var PresetWeaponTextures:[]texture_block = array{}

    # イベント
    KillEvent:event() = event(){}
    UpdateEvent:event() = event(){}

    # 初期化関数（インスタンス作成時に一度だけ呼び出す）
    Init():void=
        # 持続データ系の処理
        PlayerStatsManager.InitializePlayerStat(Player) # 一応、持続データの初期化

        OPlayerStat := PlayerStatsManager.GetPlayerStats(Player)
        if(PlayerStat := OPlayerStat?):
            set Presets = PlayerStat.WeaponPresets # 武器プリセットの取得

        # 各ウィジェットの設定
        set BackBtn = button_loud{DefaultText:=S2M("Back")}
        set SaveBtn = button_loud{DefaultText:=S2M("Save")}
        set NextBtn = button_loud{DefaultText:=S2M("Next")}
        set ExitBtn = button_loud{DefaultText:=S2M("Exit")}
        for(Index := 0 .. MaxPage - 1):
            set PagiNationBorders += array{color_block{DefaultColor := color{R := 0.8, G := 0.0, B := 0.0}, DefaultDesiredSize := vector2{X := 50.0, Y := 50.0}}} # 赤
            set PagiNationBlocks += array{color_block{DefaultColor := color{R := 1.0, G := 1.0, B := 1.0}, DefaultDesiredSize := vector2{X := 38.0, Y := 38.0}}} # 白 
        for(Index := 0 .. WeaponSlotsNum - 1):
            set HoldingWeaponTextures += array{texture_block{DefaultImage := weapon_enum.DMR_L1.ToTexture(), DefaultDesiredSize := vector2{X := 150.0, Y := 150.0}}}
            set PresetWeaponTextures += array{texture_block{DefaultImage := weapon_enum.DMR_L1.ToTexture(), DefaultDesiredSize := vector2{X := 150.0, Y := 150.0}}}

        CreateUI()
        spawn{HandleBtn()}

    # UIを作成する関数（一度だけ呼び出す）
    CreateUI():void=
        var NewSlots:[]canvas_slot = array{}

        # ボタン系を追加
        set NewSlots += array:
            canvas_slot:
                Widget := BackBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := -260.0, Top := 250.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
            canvas_slot:
                Widget := SaveBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 250.0, Right := 250.0, Bottom := 80.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := false
            canvas_slot:
                Widget := NextBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 260.0, Top := 250.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
            canvas_slot:
                Widget := ExitBtn
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 360.0, Right := 250.0, Bottom := 80.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := false
            
        # ページネーションを追加
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 150.0, Right := -0.0, Bottom := -0.0}
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

        # 手持ちの武器リストを追加
        # 具体的な武器なUpdateUI()で設定する。（ここではとりあえずデフォルト画像を設定）
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := -300.0, Right := -0.0, Bottom := -0.0}
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
                                    var WeaponTexture:texture_block = texture_block{DefaultImage := weapon_enum.DMR_L1.ToTexture()}
                                    var PaddingLeft:float = 0.0

                                    if(Texture := HoldingWeaponTextures[Index]):
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

        # 持続データのそのページに登録しているプリセットを追加
        # 具体的な武器なUpdateUI()で設定する（ここではとりあえずデフォルト画像を設定）
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := 0.0, Right := -0.0, Bottom := -0.0}
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
                                    var WeaponTexture:texture_block = texture_block{DefaultImage := weapon_enum.DMR_L1.ToTexture()}
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

        # 手持ち武器リストとプリセットの間に表示する矢印の追加
        set NewSlots += array:
            canvas_slot:
                Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                Offsets := margin{Left := 0.0, Top := -150.0, Right := -0.0, Bottom := -0.0}
                Alignment := vector2{X:=0.5,Y:=0.5}
                SizeToContent := true
                Widget := color_block{DefaultColor := color{R := 1.0, G := 1.0, B := 0.0}, DefaultDesiredSize := vector2{X := 80.0, Y := 80.0}}

        set Widget = canvas{Slots := NewSlots}

        UpdateUI() # 表示・非表示を設定する


    # UIの更新処理を行う関数
    UpdateUI():void=

        # Backボタンの表示・非表示切り替え
        if(PageNum <= 0):
            BackBtn.SetVisibility(widget_visibility.Hidden)
        else:
            BackBtn.SetVisibility(widget_visibility.Visible)

        # Nextボタンの表示・非表示切り替え
        if(PageNum >= MaxPage - 1):
            NextBtn.SetVisibility(widget_visibility.Hidden)
        else:
            NextBtn.SetVisibility(widget_visibility.Visible)

        # ページネーションの更新
        for(Index->PagiNationBorder:PagiNationBorders):
            if(Index = PageNum):
                PagiNationBorder.SetVisibility(widget_visibility.Visible)
            else:
                PagiNationBorder.SetVisibility(widget_visibility.Hidden)

        # 手持ちの武器リストの画像の更新
        for(Index->HoldingWeaponTexture:HoldingWeaponTextures):
            if(Weapon := HoldingWeapons[Index]):
                HoldingWeaponTexture.SetImage(Weapon.ToTexture())
                HoldingWeaponTexture.SetVisibility(widget_visibility.Visible)
            else:
                HoldingWeaponTexture.SetVisibility(widget_visibility.Hidden)

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
        SaveEvent:event(logic) = event(logic){}

        race:
            block:
                KillEvent.Await()
            loop:
                race:
                    block:
                        BackBtn.OnClick().Await()
                        set SelectedBtn = "Back"
                    block:
                        SaveBtn.OnClick().Await()
                        set SelectedBtn = "Save"
                    block:
                        NextBtn.OnClick().Await()
                        set SelectedBtn = "Next"
                    block:
                        ExitBtn.OnClick().Await()
                        set SelectedBtn = "Exit"

                if(SelectedBtn = "Back"):
                    Print("Backボタンが押された")
                    if(PageNum > 0): # なくても大丈夫だったけど一応
                        set PageNum -= 1
                else if(SelectedBtn = "Save"):
                    Print("Saveボタンが押された")
                    spawn{ShowSaveConfirmation(SaveEvent)}
                    SaveConfirmed := SaveEvent.Await()
                    if(SaveConfirmed?):
                        PlayerStatsManager.UpdateWeaponPresetsStat(Player, PageNum, HoldingWeapons) # セーブ処理

                        # 直前で持続データを更新したので取り直す
                        OPlayerStat := PlayerStatsManager.GetPlayerStats(Player)
                        if(PlayerStat := OPlayerStat?):
                            set Presets = PlayerStat.WeaponPresets # 武器プリセットの取得

                        Print("セーブしました")
                    else:
                        Print("セーブがキャンセルされました")
                else if(SelectedBtn = "Next"):
                    Print("Nextボタンが押された")
                    if(PageNum < MaxPage - 1): # なくても大丈夫だったけど一応
                        set PageNum += 1
                else if(SelectedBtn = "Exit"):
                    Print("Exitボタンが押された")
                    KillEvent.Signal()
                    break

                UpdateUI()

        Print("ボタン待ち処理終了")

    # 「本当に保存しますか？」というUIを表示する関数（Saveボタンを押したときに呼び出す）
    ShowSaveConfirmation(SaveEvent:event(logic))<suspends>:void=
        ConfirmText := text_block{DefaultText:=S2M("Are you sure you want to overwrite the save?")}
        SaveYesBtn := button_loud{DefaultText:=S2M("Yes")}
        SaveNoBtn := button_loud{DefaultText:=S2M("No")}

        ConfirmWidget := canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets := margin{Left := 0.0, Top := -150.0, Right := -0.0, Bottom := -0.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                    Widget := ConfirmText
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets := margin{Left := 175.0, Top := 0.0, Right := 250.0, Bottom := 100.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := false
                    Widget := SaveYesBtn
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets := margin{Left := -175.0, Top := 0.0, Right := 250.0, Bottom := 100.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := false
                    Widget := SaveNoBtn
      
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(ConfirmWidget, player_ui_slot{InputMode := ui_input_mode.All})
            race:
                KillEvent.Await()
                block:
                    SaveYesBtn.OnClick().Await()
                    SaveEvent.Signal(true)
                block:
                    SaveNoBtn.OnClick().Await()
                    SaveEvent.Signal(false)
            PlayerUI.RemoveWidget(ConfirmWidget)