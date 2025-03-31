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
using { /Verse.org/Colors/NamedColors }

## ラウンド開始前の購入フェーズでアイテムの購入を行えるUIの作成・追加を担当するファイル

# 試合中にプレイヤーが保持しているアイテムに関するデータ
player_item := class:
    ItemEnum:item_enum # アイテムの識別名
    RarityEnum:rarity_enum # アイテムのレアリティ
    var CarryOverCount:int = 0 # 以前のラウンドから持ち越された数（捨てるというボタンになる）
    var BuyCount:int = 0 # その購入フェーズで購入した数（売るというボタンになる）


condbtn_struct := struct<concrete>:
    @editable
    CondBtn:conditional_button_device = conditional_button_device{}
    
    @editable
    ItemEnum:item_enum = item_enum.AssaultRifle
    @editable
    RarityEnum:rarity_enum = rarity_enum.L1_Common

# 条件付きボタンとアイテムを紐づけるためのクラス。以前のラウンドからの持ち越しアイテムを特定するために必要
condbtn_item_lick := class:
    CondBtn:conditional_button_device
    ItemEnum:item_enum
    RarityEnum:rarity_enum
    ShopUIDevice:shop_ui_device

    ActivateCondBtn(Agent:agent):void=
        Print("該当するアイテムを持っている！！！")
        var ItemNum:int = CondBtn.GetItemCount(Agent, 0) # プレイヤーがそのアイテムを持っている個数（同じ武器を２つ持っていたら、ちゃんと２と表示される）
        if(Player := player[Agent], PlayerItems := ShopUIDevice.PlayerItemsMap[Player]):
            if(PlayerItems.Length < 5): # 一応
                loop:
                    if(0 < ItemNum):
                        N := Min(ItemEnum.ToItemData().MaxCapacity, ItemNum)
                        if:
                            set ShopUIDevice.PlayerItemsMap[Player] += array{player_item{ItemEnum := ItemEnum, RarityEnum := RarityEnum, CarryOverCount := N}}
                            set ItemNum -= N
                    else:
                        break


shop_ui_device := class(creative_device):

    @editable
    CondBtnStructs:[]condbtn_struct = array{} # 以前のラウンドからの持ち越しアイテムを特定するために必要

    @editable
    InputTriggerDevice:input_trigger_device = input_trigger_device{} # Fを押したらショップUIを開けるようにする

    @editable
    ItemRemover:item_remover_device = item_remover_device{} # 手持ちアイテムをデータ化した後に削除するために必要

    @editable
    ItemGranter:item_granter_device = item_granter_device{} # 購入したアイテムをプレイヤーに渡すために必要

    @editable
    PlayerGoldHudDevice:hud_message_device = hud_message_device{}
    @editable
    PlayerHealthHudDevice:hud_message_device = hud_message_device{}
    @editable
    PlayerShieldHudDevice:hud_message_device = hud_message_device{}
    @editable
    BuyPhaseTimeHudDevice:hud_message_device = hud_message_device{}

    var CondBtnItemLinks:[]condbtn_item_lick = array{}
    var PlayerItemsMap:[player][]player_item = map{}
    var PlayerShopUIMap:[player]shop_ui = map{}

    ShopDatas:shop_datas = shop_datas{} # アイテムのデータを定義したクラス
    BuyPhaseTimeEvent:event() = event(){}
    
    OnBegin<override>()<suspends>:void=
        for(CondBtnStruct:CondBtnStructs):
            CondBtnItemLink := condbtn_item_lick{
                CondBtn := CondBtnStruct.CondBtn
                ItemEnum := CondBtnStruct.ItemEnum
                RarityEnum := CondBtnStruct.RarityEnum
                ShopUIDevice := Self
            }
            CondBtnItemLink.CondBtn.ActivatedEvent.Subscribe(CondBtnItemLink.ActivateCondBtn)
            set CondBtnItemLinks += array{CondBtnItemLink}

        InputTriggerDevice.PressedEvent.Subscribe(TriggerAddShopUI)

    # 入力トリガーの仕掛けを有効化する関数
    EnableInputTriggerDevice():void=
        InputTriggerDevice.Enable()
        Print("入力トリガーの仕掛けを有効化した")
    
    # 入力トリガーの仕掛けを無効化する関数
    DisableInputTriggerDevice():void=
        InputTriggerDevice.Disable()
        Print("入力トリガーの仕掛けを無効化した")

    # 入力トリガーの仕掛けに登録する関数。AddShopUIを呼び出すだけ
    TriggerAddShopUI(Agent:agent):void=
        Print("入力を感知した")
        if(Player := player[Agent]):
            spawn{AddShopUI(Player)}

    # プレイヤーにショップUIを付与する関数
    AddShopUI(Player:player)<suspends>:void=
        # 以前のラウンドからの持ち越しアイテムをデータ化
        CarryOverItemsToData(Player)

        Sleep(0.0) # ディレイを設けないと、条件付きボタンの処理が終わる前にUIを作成してしまう

        RemovePlayersItems(Player) # 手持ちアイテムの削除

        # ショップUIを付与
        if(PlayerUI := GetPlayerUI[Player], PlayerItems := PlayerItemsMap[Player]):
            NewShopUI := shop_ui:
                AddPlayer := Player
                PlayerItems := PlayerItems
                BuyPhaseTimeEvent := BuyPhaseTimeEvent
                PlayerGoldHudDevice := PlayerGoldHudDevice
                PlayerHealthHudDevice := PlayerHealthHudDevice
                PlayerShieldHudDevice := PlayerShieldHudDevice
                BuyPhaseTimeHudDevice := BuyPhaseTimeHudDevice
                ItemGranter := ItemGranter
            spawn{NewShopUI.Init()}
            if. set PlayerShopUIMap[Player] = NewShopUI

    # すべてのプレイヤーからショップUIを削除する関数
    KillAllUI():void=
        for(ShopUI:PlayerShopUIMap):
            ShopUI.KillUIEvent.Signal()

    # 購入フェーズの時間テキストを更新する関数
    UpdataBuyPhaseTime():void=
        BuyPhaseTimeEvent.Signal()

    # 引数のプレイヤーの、以前のラウンドからの持ち越しアイテムをデータ化させる関数
    CarryOverItemsToData(Player:player):void=
        if(set PlayerItemsMap[Player] = array{}):
            for(CondBtnItemLink:CondBtnItemLinks, CondBtn := CondBtnItemLink.CondBtn):
                CondBtn.Activate(Player)
        
        # デバッグ用
        for(P->PlayerItems:PlayerItemsMap):
            PlayerName := GetAgentName(P)
            Print(PlayerName)
            Print("PlayerItems.Length: {PlayerItems.Length}")
            for(Index->Item:PlayerItems):
                ItemName := Item.ItemEnum.ToString()
                ItemRarity := Item.RarityEnum.ToString()
                ItemNum := Item.CarryOverCount
                Print("{Index}番目: {ItemRarity}の{ItemName}が{ItemNum}個")

    # プレイヤーからアイテムを削除する関数
    RemovePlayersItems(Player:player):void=
        ItemRemover.Remove(Player)
        Print("アイテムを削除した")

# ボタンを識別するための列挙型
btn_enum := enum:
    # 手持ちアイテム
    Holding_0
    Holding_1
    Holding_2
    Holding_3
    Holding_4

    # タブ
    Tab_SG
    Tab_P
    Tab_SMG
    Tab_AR
    Tab_SR
    Tab_ITEM
    Tab_SP
    Tab_EX

    # アイテム
    Select_0
    Select_1
    Select_2
    Select_3
    Select_4
    Select_5
    Select_6
    Select_7
    Select_8
    Select_9

    # ページネーション
    Page_Left
    Page_Right

    # アイテム詳細
    Desc_Left
    Desc_Right
    Desc_Buy

    # 閉じる
    Exit

shop_ui := class:
    AddPlayer:player
    var PlayerItems:[]player_item
    BuyPhaseTimeEvent:event()
    PlayerGoldHudDevice:hud_message_device
    PlayerHealthHudDevice:hud_message_device
    PlayerShieldHudDevice:hud_message_device
    BuyPhaseTimeHudDevice:hud_message_device
    ItemGranter:item_granter_device

    var Widget:widget = canvas{}
    
    var Holding_Btns:[]button_quiet = array{}
    var Tab_Btns:[]button_loud = array{}
    var Item_SelectBtns:[]button_quiet = array{}

    # 手持ちアイテム
    var Holding_RarityTextures:[]texture_block = array{}
    var Holding_ItemTextures:[]texture_block = array{}
    var Holding_ItemCountText:[]text_block = array{}
    Holding_Btn0:button_quiet = button_quiet{}
    Holding_Btn1:button_quiet = button_quiet{}
    Holding_Btn2:button_quiet = button_quiet{}
    Holding_Btn3:button_quiet = button_quiet{}
    Holding_Btn4:button_quiet = button_quiet{}

    # タブ
    Tab_SGBtn:button_loud = button_loud{}
    Tab_PBtn:button_loud = button_loud{}
    Tab_SMGBtn:button_loud = button_loud{}
    Tab_ARBtn:button_loud = button_loud{}
    Tab_SRBtn:button_loud = button_loud{}
    Tab_SPBtn:button_loud = button_loud{}
    Tab_ITEMBtn:button_loud = button_loud{}
    Tab_EXBtn:button_loud = button_loud{}

    # アイテム
    var Item_RarityTextures:[]texture_block = array{}
    var Item_ItemTextures:[]texture_block = array{}
    var Item_GoldTextures:[]texture_block = array{}
    var Item_GoldsTexts:[]text_block = array{}
    Item_SelectBtn0:button_quiet = button_quiet{}
    Item_SelectBtn1:button_quiet = button_quiet{}
    Item_SelectBtn2:button_quiet = button_quiet{}
    Item_SelectBtn3:button_quiet = button_quiet{}
    Item_SelectBtn4:button_quiet = button_quiet{}
    Item_SelectBtn5:button_quiet = button_quiet{}
    Item_SelectBtn6:button_quiet = button_quiet{}
    Item_SelectBtn7:button_quiet = button_quiet{}
    Item_SelectBtn8:button_quiet = button_quiet{}
    Item_SelectBtn9:button_quiet = button_quiet{}

    # ページネーション
    var Page_Borders:[]color_block = array{}
    var Page_Backgrounds:[]color_block = array{}
    var Page_NumTexts:[]text_block = array{}
    var Page_PaddingRights:[]color_block = array{}
    Page_LeftBtn:button_loud = button_loud{}
    Page_RightBtn:button_loud = button_loud{}

    # アイテム詳細
    Desc_RarityTexture:texture_block = texture_block{DefaultImage := ShopTextures_Rarities.square_L1_common, DefaultDesiredSize := vector2{X := 300.0, Y := 300.0}}
    Desc_ItemTexture:texture_block = texture_block{DefaultImage := ShopTextures_Items.AssaultRifle1, DefaultDesiredSize := vector2{X := 300.0, Y := 300.0}}
    Desc_ItemNameText:text_block = text_block{}
    var Desc_DescTexts:[]text_block = array{}
    Desc_GoldsText:text_block = text_block{DefaultTextColor := color{R := 0.516, G := 0.272, B := 0.0}}
    Desc_LeftBtn:button_loud = button_loud{}
    Desc_RarityText:text_block = text_block{}
    Desc_RightBtn:button_loud = button_loud{}
    Desc_BuyBtn:button_loud = button_loud{}

    # 閉じるボタン
    ExitBtn:button_loud = button_loud{}

    # 変数
    var PageNum:int = 0 # 現在開いているページを保持
    var CategoryMaxPageNum:int = 1 # そのカテゴリーは何ページあるか

    var PlayerHealth:int = 10
    var PlayerShield:int = 10
    var PlayerGold:int = 0
    
    var SelectedCategoryItems:[]item_enum = array{} # 現在選択されているカテゴリーに属しているアイテムすべてを保持
    var DisplayedItems:[]item_enum = array{} # 現在ショップ部分に表示されているアイテムを保持する
    var SelectedItem:item_enum = item_enum.AssaultRifle # 現在選択されているアイテム
    var SelectedRarity:rarity_enum = rarity_enum.L1_Common # 現在選択されているレアリティ

    # 定数
    HoldingNum:int = 5 # 手持ちのアイテムの最大個数
    CategoryNum:int = 8 # カテゴリーの数
    RowPerPage:int = 2 # 1ページに配置するアイテムの行の数
    ItemPerRow:int = 5 # 1行に配置するアイテムの個数
    MaxPageNum:int = 5 # 1カテゴリーにおける最大のページ数
    DescTextNum:int = 5 # アイテム説明の箇条書き行数

    KillUIEvent:event() = event(){}

    ShopDatas:shop_datas = shop_datas{}
    PlayerStatManager:player_stat_manager = player_stat_manager{}

    Init()<suspends>:void=
        if(PlayerUI := GetPlayerUI[AddPlayer], Fort := AddPlayer.GetFortCharacter[]):
            SetUpWidgetElem() # ウィジェット要素のセットアップ

            OnTabClick(item_category_enum.SG) # UI系の各種変数に初期値を設定
            if(Health := Int[Fort.GetMaxHealth()], Shield := Int[Fort.GetMaxShield()]):
                set PlayerHealth = Health
                set PlayerShield = Shield
            
            # 所持金の設定
            var StartingGold:int = 0 # アイテム購入前の所持金
            OPlayerStats := PlayerStatManager.GetPlayerStats(AddPlayer)
            if(PlayerStats := OPlayerStats?):
                set PlayerGold = PlayerStats.CurrentGold
                set StartingGold = PlayerStats.CurrentGold

            CreateUI() # UIの作成
            InitializeUI() # UIにデータを適用し、初期化する
            
            PlayerUI.AddWidget(Widget, player_ui_slot{InputMode := ui_input_mode.All})
            spawn{HandleButtonClick()}
            spawn{UpdateShowBuyPhaseTime()}
            Print("ショップUIを付与した")

            KillUIEvent.Await() # UIの終了を待機

            PlayerGoldHudDevice.Hide(AddPlayer)
            PlayerHealthHudDevice.Hide(AddPlayer)
            PlayerShieldHudDevice.Hide(AddPlayer)
            BuyPhaseTimeHudDevice.Hide(AddPlayer)
            PlayerUI.RemoveWidget(Widget)
            Print("ショップUIを削除した")

            PlayerStatManager.UpdateCurrentGoldStat(AddPlayer, PlayerGold - StartingGold)
            Print("所持金の持続データを更新した")

            GrantAllSelectedItems()
            Print("プレイヤーにアイテムを与えた")
        return

    # 購入フェーズのカウントダウンを更新・表示する関数
    UpdateShowBuyPhaseTime()<suspends>:void=
        BuyPhaseTimeHudDevice.Show(AddPlayer)
        race:
            block:
                KillUIEvent.Await()
                Print("購入フェーズのカウントダウンが停止された")
            loop:
                BuyPhaseTimeEvent.Await()
                BuyPhaseTimeHudDevice.Show(AddPlayer)

    # ウィジェット要素を初期化する関数
    SetUpWidgetElem():void=
        # 手持ちアイテム
        for(Index := 0..HoldingNum - 1):
            set Holding_RarityTextures += array{texture_block{DefaultImage := rarity_enum.L1_Common.ToSquare(), DefaultDesiredSize := vector2{X := 170.0, Y := 170.0}}}
            set Holding_ItemTextures += array{texture_block{DefaultImage := item_enum.AssaultRifle.ToTexture(), DefaultDesiredSize := vector2{X := 170.0, Y := 170.0}}}
            set Holding_ItemCountText += array{text_block{DefaultText := S2M("3"), DefaultTextColor := White}}
        Holding_Btn0.SetText(S2M("TRASH"))
        Holding_Btn1.SetText(S2M("TRASH"))
        Holding_Btn2.SetText(S2M("TRASH"))
        Holding_Btn3.SetText(S2M("TRASH"))
        Holding_Btn4.SetText(S2M("TRASH"))
        set Holding_Btns = array:
            Holding_Btn0
            Holding_Btn1
            Holding_Btn2
            Holding_Btn3
            Holding_Btn4

        # タブ
        Tab_SGBtn.SetText(S2M("SG"))
        Tab_PBtn.SetText(S2M("P"))
        Tab_SMGBtn.SetText(S2M("SMG"))
        Tab_ARBtn.SetText(S2M("AR"))
        Tab_SRBtn.SetText(S2M("SR"))
        Tab_ITEMBtn.SetText(S2M("ITEM"))
        Tab_SPBtn.SetText(S2M("SP"))
        Tab_EXBtn.SetText(S2M("EX"))
        set Tab_Btns = array:
            Tab_SGBtn
            Tab_PBtn
            Tab_SMGBtn
            Tab_ARBtn
            Tab_SRBtn
            Tab_ITEMBtn
            Tab_SPBtn
            Tab_EXBtn

        # アイテム
        for(Index := 0..RowPerPage * ItemPerRow - 1):
            set Item_RarityTextures += array{texture_block{DefaultImage := rarity_enum.L1_Common.ToBackground(), DefaultDesiredSize := vector2{X := 220.0, Y := 260.0}}}
            set Item_ItemTextures += array{texture_block{DefaultImage := item_enum.AssaultRifle.ToTexture(), DefaultDesiredSize := vector2{X := 220.0, Y := 220.0}}}
            set Item_GoldTextures += array{texture_block{DefaultImage := Textures.Creative_Coin, DefaultDesiredSize := vector2{X := 35.0, Y := 35.0}}}
            set Item_GoldsTexts += array{text_block{DefaultText := S2M("99999"), DefaultTextColor := Black}}
        Item_SelectBtn0.SetText(S2M("SELECT"))
        Item_SelectBtn1.SetText(S2M("SELECT"))
        Item_SelectBtn2.SetText(S2M("SELECT"))
        Item_SelectBtn3.SetText(S2M("SELECT"))
        Item_SelectBtn4.SetText(S2M("SELECT"))
        Item_SelectBtn5.SetText(S2M("SELECT"))
        Item_SelectBtn6.SetText(S2M("SELECT"))
        Item_SelectBtn7.SetText(S2M("SELECT"))
        Item_SelectBtn8.SetText(S2M("SELECT"))
        Item_SelectBtn9.SetText(S2M("SELECT"))
        set Item_SelectBtns = array:
            Item_SelectBtn0
            Item_SelectBtn1
            Item_SelectBtn2
            Item_SelectBtn3
            Item_SelectBtn4
            Item_SelectBtn5
            Item_SelectBtn6
            Item_SelectBtn7
            Item_SelectBtn8
            Item_SelectBtn9

        # ページネーション
        Page_LeftBtn.SetText(S2M("<"))
        Page_RightBtn.SetText(S2M(">"))
        for(Index := 0..MaxPageNum - 1):
            set Page_Borders += array{color_block{DefaultColor := Red, DefaultDesiredSize := vector2{X := 50.0, Y := 50.0}}}
            set Page_Backgrounds += array{color_block{DefaultColor := White, DefaultDesiredSize := vector2{X := 38.0, Y := 38.0}}}
            set Page_NumTexts += array{text_block{DefaultText := S2M("{Index + 1}")}}
            set Page_PaddingRights += array{color_block{DefaultDesiredSize := vector2{X := 20.0, Y := 10.0}}}

        # アイテム詳細
        Desc_ItemNameText.SetText(S2M("Assault Rifle"))
        for(Index := 0..DescTextNum - 1):
            set Desc_DescTexts += array{text_block{DefaultText := S2M("DPS: 100")}}
        Desc_GoldsText.SetText(S2M("99999"))
        Desc_LeftBtn.SetText(S2M("<"))
        Desc_RarityText.SetText(S2M("Common"))
        Desc_RightBtn.SetText(S2M(">"))
        Desc_BuyBtn.SetText(S2M("BUY"))

        # 閉じるボタン
        ExitBtn.SetText(S2M("X"))

    # UI全体を作成する関数
    CreateUI():void=
        NewWidget := canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=1.0,Y:=1.0}}
                    Offsets := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                    Widget := overlay:
                        Slots := array:
                            overlay_slot: # メインコンテンツ
                                Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := canvas:
                                    Slots := array:
                                        canvas_slot: # 手持ちアイテム部分
                                            Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=0.0,Y:=0.0}}
                                            Offsets := margin{Left := 780.0, Top := 64.0, Right := 0.0, Bottom := 0.0}
                                            Alignment := vector2{X:=0.0,Y:=0.0}
                                            SizeToContent := true
                                            Widget := CreateHoldingItemStackBox()
                                        canvas_slot: # ショップ部分
                                            Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=1.0},Maximum:=vector2{X:=0.5,Y:=1.0}}
                                            Offsets := margin{Left := -165.0, Top := -45.0, Right := 0.0, Bottom := 0.0}
                                            Alignment := vector2{X:=0.5,Y:=1.0}
                                            SizeToContent := true
                                            Widget := CreateShopUIStackBox()
                                        canvas_slot: # アイテム詳細部分
                                            Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=1.0},Maximum:=vector2{X:=0.5,Y:=1.0}}
                                            Offsets := margin{Left := 625.0, Top := -50.0, Right := 0.0, Bottom := 0.0}
                                            Alignment := vector2{X:=0.5,Y:=1.0}
                                            SizeToContent := true
                                            Widget := CreateItemDetailStackBox()
                            overlay_slot: # 閉じるボタン
                                Padding := margin{Left := 0.0, Top := 180.0, Right := 45.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Right
                                VerticalAlignment := vertical_alignment.Top
                                Widget := canvas:
                                    Slots := array:
                                        canvas_slot:
                                            Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=0.0,Y:=0.0}}
                                            Offsets := margin{Left := 0.0, Top := 0.0, Right := 100.0, Bottom := 100.0}
                                            Alignment := vector2{X:=0.0,Y:=0.0}
                                            SizeToContent := false
                                            Widget := ExitBtn

        set Widget = NewWidget
        return

    # UIの手持ちアイテムの部分を作成して返す関数
    CreateHoldingItemStackBox():widget=
        NewWidget := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot:
                    Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := overlay:
                        Slots := array:
                            overlay_slot: # 背景画像
                                Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := color_block{DefaultColor := color{R := 1.0, G := 0.342, B := 0.02}}
                            overlay_slot: # アイテムスロット
                                Padding := margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                                HorizontalAlignment := horizontal_alignment.Left
                                VerticalAlignment := vertical_alignment.Top
                                Widget := stack_box:
                                    Orientation := orientation.Horizontal
                                    Slots := for(Index := 0..HoldingNum - 1, RarityTexture := Holding_RarityTextures[Index], ItemTexture := Holding_ItemTextures[Index], ItemCountText := Holding_ItemCountText[Index]):
                                        var PaddingLeft:float = 0.0
                                        if(0 < Index):
                                            set PaddingLeft = 10.0
                                        
                                        stack_box_slot:
                                            Padding := margin{Left := PaddingLeft, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                            HorizontalAlignment := horizontal_alignment.Fill
                                            VerticalAlignment := vertical_alignment.Fill
                                            Widget := overlay:
                                                Slots := array:
                                                    overlay_slot: # レアリティ背景
                                                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                                        HorizontalAlignment := horizontal_alignment.Fill
                                                        VerticalAlignment := vertical_alignment.Fill
                                                        Widget := RarityTexture
                                                    overlay_slot: # アイテム画像
                                                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                                        HorizontalAlignment := horizontal_alignment.Fill
                                                        VerticalAlignment := vertical_alignment.Fill
                                                        Widget := ItemTexture
                                                    overlay_slot: # アイテムの所持数
                                                        Padding := margin{Left := 0.0, Top := 0.0, Right := 10.0, Bottom := 2.0}
                                                        HorizontalAlignment := horizontal_alignment.Right
                                                        VerticalAlignment := vertical_alignment.Bottom
                                                        Widget := ItemCountText
                stack_box_slot: # 売却ボタン
                    Padding := margin{Left := 0.0, Top := 8.0, Right := 0.0, Bottom := 0.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Bottom
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := for(Index := 0..HoldingNum - 1, SellBtn := Holding_Btns[Index]):
                            var PaddingLeft:float = 0.0
                            if(0 < Index):
                                set PaddingLeft = 6.0

                            stack_box_slot:
                                Padding := margin{Left := PaddingLeft, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := canvas:
                                    Slots := array:
                                        canvas_slot:
                                            Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=0.0,Y:=0.0}}
                                            Offsets := margin{Left := 0.0, Top := 0.0, Right := 174.0, Bottom := 40.0}
                                            Alignment := vector2{X:=0.0,Y:=0.0}
                                            SizeToContent := false
                                            Widget := SellBtn

        return NewWidget

    # UIのショップの部分を作成して返す関数
    CreateShopUIStackBox():widget=
        NewWidget := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot: # タブボタン部分
                    Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 10.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := for(Index := 0..CategoryNum - 1, TabBtn := Tab_Btns[Index]):
                            var PaddingLeft:float = 0.0
                            if(0 < Index):
                                set PaddingLeft = 16.0

                            stack_box_slot: # タブボタン
                                Padding := margin{Left := PaddingLeft, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := canvas:
                                    Slots := array:
                                        canvas_slot:
                                            Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=0.0,Y:=0.0}}
                                            Offsets := margin{Left := 0.0, Top := 0.0, Right := 138.0, Bottom := 50.0}
                                            Alignment := vector2{X:=0.0,Y:=0.0}
                                            SizeToContent := false
                                            Widget := TabBtn
                stack_box_slot: # アイテム一覧部分
                    Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 15.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := for(Index := 0..RowPerPage - 1):
                            var PaddingTop:float = 0.0
                            if(0 < Index):
                                set PaddingTop = 15.0

                            stack_box_slot: # 行
                                Padding := margin{Left := 0.0, Top := PaddingTop, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Left
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := stack_box:
                                    Orientation := orientation.Horizontal
                                    Slots := for(
                                        Index2 := 0..ItemPerRow - 1
                                        ItemIndex := ItemPerRow * Index + Index2
                                        RarityTexture := Item_RarityTextures[ItemIndex]
                                        ItemTexture := Item_ItemTextures[ItemIndex]
                                        GoldTexture := Item_GoldTextures[ItemIndex]
                                        GoldsText := Item_GoldsTexts[ItemIndex]
                                        SelectBtn := Item_SelectBtns[ItemIndex]
                                    ):
                                        var PaddingLeft:float = 0.0
                                        if(0 < Index2):
                                            set PaddingLeft = 30.0

                                        stack_box_slot: # アイテム
                                            Padding := margin{Left := PaddingLeft, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                            HorizontalAlignment := horizontal_alignment.Fill
                                            VerticalAlignment := vertical_alignment.Fill
                                            Widget := overlay:
                                                Slots := array:
                                                    overlay_slot: # レアリティ背景
                                                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment := vertical_alignment.Center
                                                        Widget := RarityTexture
                                                    overlay_slot: # アイテム画像
                                                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment := vertical_alignment.Top
                                                        Widget := ItemTexture
                                                    overlay_slot: # 値段
                                                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 55.0}
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment := vertical_alignment.Bottom
                                                        Widget := stack_box:
                                                            Orientation := orientation.Horizontal
                                                            Slots := array:
                                                                stack_box_slot: # コイン画像
                                                                    Padding := margin{Left := 0.0, Top := 0.0, Right := 3.0, Bottom := 0.0}
                                                                    HorizontalAlignment := horizontal_alignment.Center
                                                                    VerticalAlignment := vertical_alignment.Center
                                                                    Widget := GoldTexture
                                                                stack_box_slot: # 値段テキスト
                                                                    Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                                                    HorizontalAlignment := horizontal_alignment.Center
                                                                    VerticalAlignment := vertical_alignment.Bottom
                                                                    Widget := GoldsText
                                                    overlay_slot: # セレクトボタン
                                                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 10.0}
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment := vertical_alignment.Bottom
                                                        Widget := canvas:
                                                            Slots := array:
                                                                canvas_slot:
                                                                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=0.0,Y:=0.0}}
                                                                    Offsets := margin{Left := 0.0, Top := 0.0, Right := 200.0, Bottom := 40.0}
                                                                    Alignment := vector2{X:=0.0,Y:=0.0}
                                                                    SizeToContent := false
                                                                    Widget := SelectBtn
                stack_box_slot: # ページネーション部分
                    Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := array:
                            stack_box_slot: # 左ボタン
                                Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := Page_LeftBtn
                            CreatePageNationNumBox() # 番号列
                            stack_box_slot: # 右ボタン
                                Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := Page_RightBtn

        return NewWidget

    # UIのショップ部分に配置するページネーションの、番号列部分を作成して返す関数
    CreatePageNationNumBox():stack_box_slot=
        var NewSlots:[]stack_box_slot = array{}

        for(Index := 0..MaxPageNum - 1):
            if:
                Border := Page_Borders[Index]
                Background := Page_Backgrounds[Index]
                NumText := Page_NumTexts[Index]
                PaddingRight := Page_PaddingRights[Index]
            then:
                set NewSlots += array:
                    stack_box_slot: # 数字ボックス
                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Center
                        Widget := overlay:
                            Slots := array:
                                overlay_slot: # ボーダー
                                    Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                    HorizontalAlignment := horizontal_alignment.Center
                                    VerticalAlignment := vertical_alignment.Center
                                    Widget := Border
                                overlay_slot: # 数字背景
                                    Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                    HorizontalAlignment := horizontal_alignment.Center
                                    VerticalAlignment := vertical_alignment.Center
                                    Widget := Background
                                overlay_slot: # 数字テキスト
                                    Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                    HorizontalAlignment := horizontal_alignment.Center
                                    VerticalAlignment := vertical_alignment.Center
                                    Widget := NumText
                
                set NewSlots += array:
                    stack_box_slot: # 右パディング
                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Center
                        Widget := PaddingRight

        NewStackBoxSlot := stack_box_slot: # 番号列部分
            Padding := margin{Left := 30.0, Top := 0.0, Right := 30.0, Bottom := 0.0}
            HorizontalAlignment := horizontal_alignment.Center
            VerticalAlignment := vertical_alignment.Center
            Widget := stack_box:
                Orientation := orientation.Horizontal
                Slots := NewSlots

        return NewStackBoxSlot

    # UIのアイテム詳細の部分を作成して返す関数
    CreateItemDetailStackBox():widget=
        NewWidget := overlay:
            Slots := array:
                overlay_slot: # 白半透明背景
                    Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := texture_block{DefaultImage := ShopTextures_Items.ItemDetailBackground, DefaultDesiredSize := vector2{X := 320.0, Y := 705.0}}
                overlay_slot: # メインコンテンツ
                    Padding := margin{Left := 0.0, Top := 10.0, Right := 0.0, Bottom := 0.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Top
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot: # アイテム画像部分
                                Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := overlay:
                                    Slots := array:
                                        overlay_slot: # レアリティ背景
                                            Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment := vertical_alignment.Top
                                            Widget := Desc_RarityTexture
                                        overlay_slot: # アイテム画像
                                            Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment := vertical_alignment.Top
                                            Widget := Desc_ItemTexture
                                        overlay_slot: # アイテム名
                                            Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 3.0}
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment := vertical_alignment.Bottom
                                            Widget := Desc_ItemNameText
                            stack_box_slot: # アイテム説明部分
                                Padding := margin{Left := 0.0, Top := 8.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Top
                                Widget := stack_box:
                                    Orientation := orientation.Vertical
                                    Slots := for(Index := 0..DescTextNum - 1, DescText := Desc_DescTexts[Index]):
                                        stack_box_slot:
                                            Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment := vertical_alignment.Top
                                            Widget := DescText
                            stack_box_slot: # 金額部分
                                Padding := margin{Left := 0.0, Top := 8.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := stack_box:
                                    Orientation := orientation.Horizontal
                                    Slots := array:
                                        stack_box_slot:
                                            Padding := margin{Left := 0.0, Top := 0.0, Right := 3.0, Bottom := 0.0}
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment := vertical_alignment.Center
                                            Widget := texture_block{DefaultImage := Textures.Creative_Coin, DefaultDesiredSize := vector2{X := 40.0, Y := 40.0}}
                                        stack_box_slot:
                                            Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                            HorizontalAlignment := horizontal_alignment.Left
                                            VerticalAlignment := vertical_alignment.Center
                                            Widget := Desc_GoldsText
                            stack_box_slot: # レアリティボタン部分
                                Padding := margin{Left := 0.0, Top := 5.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Center
                                Widget := stack_box:
                                    Orientation := orientation.Horizontal
                                    Slots := array:
                                        stack_box_slot: # 左ボタン
                                            Padding := margin{Left := 3.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                            Distribution := option{1.0}
                                            HorizontalAlignment := horizontal_alignment.Left
                                            VerticalAlignment := vertical_alignment.Center
                                            Widget := canvas:
                                                Slots := array:
                                                    canvas_slot:
                                                        Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=0.0,Y:=0.0}}
                                                        Offsets := margin{Left := 0.0, Top := 0.0, Right := 60.0, Bottom := 50.0}
                                                        Alignment := vector2{X:=0.0,Y:=0.0}
                                                        SizeToContent := false
                                                        Widget := Desc_LeftBtn
                                        stack_box_slot: # レアリティテキスト
                                            Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment := vertical_alignment.Center
                                            Widget := Desc_RarityText
                                        stack_box_slot: # 右ボタン
                                            Padding := margin{Left := 0.0, Top := 0.0, Right := 3.0, Bottom := 0.0}
                                            Distribution := option{1.0}
                                            HorizontalAlignment := horizontal_alignment.Right
                                            VerticalAlignment := vertical_alignment.Center
                                            Widget := canvas:
                                                Slots := array:
                                                    canvas_slot:
                                                        Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=0.0,Y:=0.0}}
                                                        Offsets := margin{Left := 0.0, Top := 0.0, Right := 60.0, Bottom := 50.0}
                                                        Alignment := vector2{X:=0.0,Y:=0.0}
                                                        SizeToContent := false
                                                        Widget := Desc_RightBtn
                            stack_box_slot: # 購入ボタン
                                Padding := margin{Left := 0.0, Top := 10.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := canvas:
                                    Slots := array:
                                        canvas_slot:
                                            Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=0.0,Y:=0.0}}
                                            Offsets := margin{Left := 0.0, Top := 0.0, Right := 250.0, Bottom := 50.0}
                                            Alignment := vector2{X:=0.0,Y:=0.0}
                                            SizeToContent := false
                                            Widget := Desc_BuyBtn

        return NewWidget

    # そのプレイヤーに合わせて、UI全体にデータを適用して初期化する関数
    InitializeUI():void=
        UpdatePlayerStatus()
        UpdateItemDetail()
        UpdateDisplayedItems()
        UpdatePageNation()

    # プレイヤーのステータスと手持ちアイテムの部分を更新する関数
    UpdatePlayerStatus():void=
        # ステータステキストの更新
        PlayerGoldHudDevice.Show(AddPlayer, S2M("{PlayerGold}"))
        PlayerHealthHudDevice.Show(AddPlayer, S2M("Health: {PlayerHealth}"))
        PlayerShieldHudDevice.Show(AddPlayer, S2M("Shield: {PlayerShield}"))

        # 手持ちアイテムの更新
        for(Index := 0..HoldingNum - 1):
            if:
                RarityTexture := Holding_RarityTextures[Index]
                ItemTexture := Holding_ItemTextures[Index]
                ItemCountText := Holding_ItemCountText[Index]
                HoldingBtn := Holding_Btns[Index]
            then:
                if(Item := PlayerItems[Index]):
                    RarityTexture.SetImage(Item.RarityEnum.ToSquare())
                    ItemTexture.SetImage(Item.ItemEnum.ToTexture())

                    Count := Item.CarryOverCount + Item.BuyCount
                    MaxCapacity := Item.ItemEnum.ToItemData().MaxCapacity
                    if(1 < MaxCapacity):
                        ItemCountText.SetText(S2M("{Count}"))
                    else:
                        ItemCountText.SetText(S2M(""))

                    if(0 < Item.BuyCount):
                        HoldingBtn.SetText(S2M("SELL"))
                    else if(0 < Item.CarryOverCount):
                        HoldingBtn.SetText(S2M("TRASH"))
                    else:
                        HoldingBtn.SetText(S2M(""))
                else:
                    ItemTexture.SetImage(ShopTextures_Items.Empty) # 空領域として表示
                    HoldingBtn.SetText(S2M(""))
            
    # アイテム詳細の部分を更新する関数
    UpdateItemDetail():void=
        ItemData := SelectedItem.ToItemData()

        Desc_RarityTexture.SetImage(SelectedRarity.ToSquare())
        Desc_ItemTexture.SetImage(SelectedItem.ToTexture())
        Desc_ItemNameText.SetText(S2M(SelectedItem.ToString()))
        for(Index := 0..DescTextNum - 1):
            if:
                DescText := Desc_DescTexts[Index]
                Descs := ItemData.RarityDescMap[SelectedRarity]
                Desc := Descs[Index]
            then:
                DescText.SetText(S2M(Desc))
        if(Price := ItemData.RarityPriceMap[SelectedRarity]):
            Desc_GoldsText.SetText(S2M("{Price}"))
        Desc_RarityText.SetText(S2M(SelectedRarity.ToString()))
        Desc_RarityText.SetTextColor(SelectedRarity.ToTextColor())

    # アイテム一覧の部分を更新する関数
    UpdateDisplayedItems():void=
        for(Index := 0..ItemPerRow * RowPerPage - 1):
            if:
                RarityTexture := Item_RarityTextures[Index]
                ItemTexture := Item_ItemTextures[Index]
                GoldTexture := Item_GoldTextures[Index]
                GoldsText := Item_GoldsTexts[Index]
                SelectBtn := Item_SelectBtns[Index]
            then:
                if(DisplayedItem := DisplayedItems[Index]):
                    ItemData := DisplayedItem.ToItemData()

                    # 最低レアリティで表示する
                    if(LowestRarity := ItemData.Rarities[0], LowestPrice := ItemData.RarityPriceMap[LowestRarity]):
                        RarityTexture.SetImage(LowestRarity.ToBackground())
                        ItemTexture.SetImage(DisplayedItem.ToTexture())
                        GoldsText.SetText(S2M("{LowestPrice}"))

                    # 表示する
                    RarityTexture.SetVisibility(widget_visibility.Visible)
                    ItemTexture.SetVisibility(widget_visibility.Visible)
                    GoldTexture.SetVisibility(widget_visibility.Visible)
                    GoldsText.SetVisibility(widget_visibility.Visible)
                    SelectBtn.SetVisibility(widget_visibility.Visible)
                else:
                    # 非表示する
                    RarityTexture.SetVisibility(widget_visibility.Hidden)
                    ItemTexture.SetVisibility(widget_visibility.Hidden)
                    GoldTexture.SetVisibility(widget_visibility.Hidden)
                    GoldsText.SetVisibility(widget_visibility.Hidden)
                    SelectBtn.SetVisibility(widget_visibility.Hidden)

    # ページネーションの部分を更新する関数
    UpdatePageNation():void=
        # ページ番号ボックスの表示非表示を更新
        for(Index := 0..MaxPageNum - 1):
            if(Border := Page_Borders[Index], Background := Page_Backgrounds[Index], NumText := Page_NumTexts[Index], PaddingRight := Page_PaddingRights[Index]):
                if(Index < CategoryMaxPageNum):
                    if(Index = PageNum):
                        Border.SetVisibility(widget_visibility.Visible) # ボーダーを表示
                    else:
                        Border.SetVisibility(widget_visibility.Hidden) # ボーダーを非表示
                    Background.SetVisibility(widget_visibility.Visible)
                    NumText.SetVisibility(widget_visibility.Visible)
                else:
                    Print("{Index + 1}ページボックスを Collapsed にした")
                    Border.SetVisibility(widget_visibility.Collapsed) # Collapsed: 場所も取らない
                    Background.SetVisibility(widget_visibility.Collapsed)
                    NumText.SetVisibility(widget_visibility.Collapsed)
                
                # 右パディングの表示非表示を設定
                if(Index < CategoryMaxPageNum - 1):
                    PaddingRight.SetVisibility(widget_visibility.Hidden)
                else:
                    PaddingRight.SetVisibility(widget_visibility.Collapsed)

    # 手持ちアイテムのボタンが押されたときに呼び出す関数
    OnHoldingClick(ItemIndex:int):void=
        Print("手持ちボタンが押された")
        
        if(Item := PlayerItems[ItemIndex]):
            if(0 < Item.BuyCount):
                ItemData := Item.ItemEnum.ToItemData()
                if(SoldPrice := ItemData.RarityPriceMap[Item.RarityEnum]):
                    set Item.BuyCount -= 1
                    set PlayerGold += SoldPrice
                    Print("{Item.RarityEnum.ToString()}の{Item.ItemEnum.ToString()}を{SoldPrice}ゴールドで売却した")
            else if(0 < Item.CarryOverCount):
                set Item.CarryOverCount -= 1
                Print("{Item.RarityEnum.ToString()}の{Item.ItemEnum.ToString()}を捨てた")

            # 所持数が０になったら配列から削除する
            if:
                Item.BuyCount = 0
                Item.CarryOverCount = 0
                NewPlayerItems := PlayerItems.RemoveElement[ItemIndex]
                set PlayerItems = NewPlayerItems
        else:
            Print("空のスロットのボタンが押された")

        # UIを更新
        UpdatePlayerStatus()

    # タブボタンが押されたときに呼び出す関数
    OnTabClick(ItemCategoryEnum:item_category_enum):void=
        Print("「{ItemCategoryEnum.ToString()}」カテゴリー変更ボタンが押された")
        
        set SelectedCategoryItems = ShopDatas.GetItemsByCategory(ItemCategoryEnum)
        set DisplayedItems = array{} # 配列をリセット
        for(Index := 0..ItemPerRow * RowPerPage - 1, Item := SelectedCategoryItems[Index]):
            set DisplayedItems += array{Item}
        if(Item := DisplayedItems[0]):
            set SelectedItem = Item
        ItemData := SelectedItem.ToItemData()
        if(LowestRarity := ItemData.Rarities[0]):
            set SelectedRarity = LowestRarity
        if(N := Ceil[SelectedCategoryItems.Length * 1.0 / (ItemPerRow * RowPerPage * 1.0)]):
            set CategoryMaxPageNum = N

        set PageNum = 0 # ページ数をリセット

        # UIを更新
        UpdateDisplayedItems()
        UpdateItemDetail()
        UpdatePageNation()

    # セレクトボタンが押されたときに呼び出す関数
    OnSelectClick(ItemIndex:int):void=
        Print("セレクトボタンが押された")
        
        if(Item := DisplayedItems[ItemIndex]):
            ItemData := Item.ToItemData()
            if(LowestRarity := ItemData.Rarities[0]):
                set SelectedItem = Item
                set SelectedRarity = LowestRarity

        # UIを更新
        UpdateItemDetail()

    # ページネーションのボタンが押されたときに呼び出す関数
    OnPageNationClick(IsLeft:logic):void=
        Print("ページネーションボタンが押された")

        var IsPageChanged:logic = false
        
        if(1 < CategoryMaxPageNum):
            if(IsLeft?): # 左ボタン
                if(PageNum = 0):
                    set PageNum = CategoryMaxPageNum - 1
                else:
                    set PageNum -= 1
            else: # 右ボタン
                if(PageNum = CategoryMaxPageNum - 1):
                    set PageNum = 0
                else:
                    set PageNum += 1
                
            set IsPageChanged = true
            Print("{PageNum + 1}ページ目に変更した")
        else:
            Print("このカテゴリーは１ページしかありません。")

        # ページが更新されたら
        if(IsPageChanged?):
            # アイテム一覧に表示するアイテムを設定
            var Items:[]item_enum = array{}
            ItemPerPage := ItemPerRow * RowPerPage
            for(Index := ItemPerPage * PageNum .. ItemPerPage * (PageNum + 1) - 1, Item := SelectedCategoryItems[Index]):
                set Items += array{Item}
            set DisplayedItems = Items

            # アイテム詳細に表示するアイテムを設定
            if(Item := DisplayedItems[0]):
                set SelectedItem = Item
            ItemData := SelectedItem.ToItemData()
            if(LowestRarity := ItemData.Rarities[0]):
                set SelectedRarity = LowestRarity

        # UIを更新
        UpdatePageNation()
        if(IsPageChanged?):
            UpdateDisplayedItems()
            UpdateItemDetail()

    # アイテム詳細部分のレアリティ変更ボタンが押されたときに呼び出す関数
    OnRarityClick(IsLeft:logic):void=
        Print("レアリティ変更ボタンが押された")
        
        Rarities := SelectedItem.ToItemData().Rarities
        MaxIndex := Rarities.Length - 1
        if(SelectedIndex := Rarities.Find[SelectedRarity]):
            if(IsLeft?): # 左ボタン
                if(SelectedIndex = 0, Rarity := Rarities[MaxIndex]):
                    set SelectedRarity = Rarity
                else if(Rarity := Rarities[SelectedIndex - 1]):
                    set SelectedRarity = Rarity
            else: # 右ボタン
                if(SelectedIndex = MaxIndex, Rarity := Rarities[0]):
                    set SelectedRarity = Rarity
                else if(Rarity := Rarities[SelectedIndex + 1]):
                    set SelectedRarity = Rarity

        # UIの更新
        UpdateItemDetail()

    # 購入ボタンが押されたときに呼び出す関数（パワーアップとそうでない場合で処理を分ける必要がある）
    OnBuyClick():void=
        Print("購入ボタンが押された")

        var Price:int = 100000
        SelectedItemData := SelectedItem.ToItemData()
        if(P := SelectedItemData.RarityPriceMap[SelectedRarity]):
            set Price = P
        
        # 所持金が足りていなかったら処理を終了する
        if(PlayerGold < Price):
            Print("所持金が足りなかった")
            return

        # 購入予定のアイテムを手持ちに追加できるかを確認する --------------------------------
        var IsNotBought:logic = true

        # 既存スロットに重ねて追加できるか
        for(Item:PlayerItems, IsNotBought?, SelectedItem = Item.ItemEnum): 
            if(SelectedItemData.CanBuyMultiple?):
                if(SelectedRarity = Item.RarityEnum):
                    ItemData := Item.ItemEnum.ToItemData()
                    if(Item.CarryOverCount + Item.BuyCount < ItemData.MaxCapacity):
                        set Item.BuyCount += 1
                        set PlayerGold -= Price
                        set IsNotBought = false
                        Print("アイテムを既存スロットに追加した: {Item.CarryOverCount + Item.BuyCount - 1} => {Item.CarryOverCount + Item.BuyCount}")
                    else:
                        Print("同じアイテムを所持していたが、重ねられなかった: {Item.CarryOverCount + Item.BuyCount}")
            else:
                set IsNotBought = false
                Print("複数スロットに保持できないアイテムです")
            
        # 重ねて追加できなかった場合に、新規スロットに追加できるか
        if(IsNotBought?):
            if(PlayerItems.Length < HoldingNum):
                set PlayerItems += array:
                    player_item:
                        ItemEnum := SelectedItem
                        RarityEnum := SelectedRarity
                        BuyCount := 1
                set PlayerGold -= Price
                Print("アイテムを新規スロットに追加した")
            else:
                Print("手持ちスロットに空きがなかった")
                return
        # ----------------------------------------------------------------

        # UIの更新
        UpdatePlayerStatus()

    # ボタンが押されるのを待機し、押されたボタンに応じて処理を実行する関数
    HandleButtonClick()<suspends>:void=
        var ClickedBtn:btn_enum = btn_enum.Desc_Right
        
        # ボタンのクリックを待機し、クリックされたボタンに応じて処理を実行する
        race:
            block:
                KillUIEvent.Await()
                Print("ショップUIが削除された")
            loop:
                race:
                    # 手持ちアイテムボタン
                    block: # ０
                        Holding_Btn0.OnClick().Await()
                        set ClickedBtn = btn_enum.Holding_0
                    block: # １
                        Holding_Btn1.OnClick().Await()
                        set ClickedBtn = btn_enum.Holding_1
                    block: # ２
                        Holding_Btn2.OnClick().Await()
                        set ClickedBtn = btn_enum.Holding_2
                    block: # ３
                        Holding_Btn3.OnClick().Await()
                        set ClickedBtn = btn_enum.Holding_3
                    block: # ４
                        Holding_Btn4.OnClick().Await()
                        set ClickedBtn = btn_enum.Holding_4

                    # タブボタン
                    block: # SG
                        Tab_SGBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Tab_SG
                    block: # P
                        Tab_PBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Tab_P
                    block: # SMG
                        Tab_SMGBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Tab_SMG
                    block: # AR
                        Tab_ARBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Tab_AR
                    block: # SR
                        Tab_SRBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Tab_SR
                    block: # ITEM
                        Tab_ITEMBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Tab_ITEM
                    block: # SP
                        Tab_SPBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Tab_SP
                    block: # EX
                        Tab_EXBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Tab_EX

                    # ディスプレイアイテムボタン
                    block: # ０
                        Item_SelectBtn0.OnClick().Await()
                        set ClickedBtn = btn_enum.Select_0
                    block: # １
                        Item_SelectBtn1.OnClick().Await()
                        set ClickedBtn = btn_enum.Select_1
                    block: # ２
                        Item_SelectBtn2.OnClick().Await()
                        set ClickedBtn = btn_enum.Select_2
                    block: # ３
                        Item_SelectBtn3.OnClick().Await()
                        set ClickedBtn = btn_enum.Select_3
                    block: # ４
                        Item_SelectBtn4.OnClick().Await()
                        set ClickedBtn = btn_enum.Select_4
                    block: # ５
                        Item_SelectBtn5.OnClick().Await()
                        set ClickedBtn = btn_enum.Select_5
                    block: # ６
                        Item_SelectBtn6.OnClick().Await()
                        set ClickedBtn = btn_enum.Select_6
                    block: # ７
                        Item_SelectBtn7.OnClick().Await()
                        set ClickedBtn = btn_enum.Select_7
                    block: # ８
                        Item_SelectBtn8.OnClick().Await()
                        set ClickedBtn = btn_enum.Select_8
                    block: # ９
                        Item_SelectBtn9.OnClick().Await()
                        set ClickedBtn = btn_enum.Select_9

                    # ページネーションのボタン
                    block: # 左
                        Page_LeftBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Page_Left
                    block: # 右
                        Page_RightBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Page_Right

                    # アイテム詳細
                    block: # 左
                        Desc_LeftBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Desc_Left
                    block: # 右
                        Desc_RightBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Desc_Right
                    block: # 購入
                        Desc_BuyBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Desc_Buy

                    # 閉じるボタン
                    block:
                        ExitBtn.OnClick().Await()
                        set ClickedBtn = btn_enum.Exit

                case(ClickedBtn):
                    # 手持ちアイテムボタン
                    btn_enum.Holding_0 => OnHoldingClick(0)
                    btn_enum.Holding_1 => OnHoldingClick(1)
                    btn_enum.Holding_2 => OnHoldingClick(2)
                    btn_enum.Holding_3 => OnHoldingClick(3)
                    btn_enum.Holding_4 => OnHoldingClick(4)

                    # タブボタン
                    btn_enum.Tab_SG => OnTabClick(item_category_enum.SG)
                    btn_enum.Tab_P => OnTabClick(item_category_enum.P)
                    btn_enum.Tab_SMG => OnTabClick(item_category_enum.SMG)
                    btn_enum.Tab_AR => OnTabClick(item_category_enum.AR)
                    btn_enum.Tab_SR => OnTabClick(item_category_enum.SR)
                    btn_enum.Tab_ITEM => OnTabClick(item_category_enum.ITEM)
                    btn_enum.Tab_SP => OnTabClick(item_category_enum.SP)
                    btn_enum.Tab_EX => OnTabClick(item_category_enum.EX)

                    # ディスプレイアイテムボタン
                    btn_enum.Select_0 => OnSelectClick(0)
                    btn_enum.Select_1 => OnSelectClick(1)
                    btn_enum.Select_2 => OnSelectClick(2)
                    btn_enum.Select_3 => OnSelectClick(3)
                    btn_enum.Select_4 => OnSelectClick(4)
                    btn_enum.Select_5 => OnSelectClick(5)
                    btn_enum.Select_6 => OnSelectClick(6)
                    btn_enum.Select_7 => OnSelectClick(7)
                    btn_enum.Select_8 => OnSelectClick(8)
                    btn_enum.Select_9 => OnSelectClick(9)

                    # ページネーションのボタン
                    btn_enum.Page_Left => OnPageNationClick(true)
                    btn_enum.Page_Right => OnPageNationClick(false)

                    # アイテム詳細
                    btn_enum.Desc_Left => OnRarityClick(true)
                    btn_enum.Desc_Right => OnRarityClick(false)
                    btn_enum.Desc_Buy => OnBuyClick()

                    # 閉じるボタン
                    btn_enum.Exit => KillUIEvent.Signal()
                    
    # すべての選んだアイテムをプレイヤーに与える関数
    GrantAllSelectedItems():void=
        for(Item:PlayerItems):
            ItemIndex := ShopDatas.GetIndexByItemAndRarity(Item.ItemEnum, Item.RarityEnum)
            for(Index := 0..(Item.CarryOverCount + Item.BuyCount) - 1, ItemIndex <> -1):
                Print("ItemIndex: {ItemIndex}")
                ItemGranter.GrantItemIndex(AddPlayer, ItemIndex)
        Print("アイテムを与えた")