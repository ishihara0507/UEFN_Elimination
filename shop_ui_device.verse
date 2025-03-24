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
    ItemGranter:item_granter_device = item_granter_device{} # 購入したアイテムをプレイヤーに渡すために必要

    @editable
    PlayerIconHudDevice:hud_message_device = hud_message_device{}
    @editable
    HoldGoldsHudDevice:hud_message_device = hud_message_device{}

    var CondBtnItemLinks:[]condbtn_item_lick = array{}
    var PlayerItemsMap:[player][]player_item = map{}
    var PlayerShopUIMap:[player]shop_ui = map{}

    ShopDatas:shop_datas = shop_datas{} # アイテムのデータを定義したクラス
    KillUIEvent:event() = event(){}
    
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

    # すべてのプレイヤーにショップUIを付与する関数
    AddShopUIForAll(GamePlayers:[]player):void=
        # 以前のラウンドからの持ち越しアイテムをデータ化
        for(Player:GamePlayers):
            CarryOverItemsToData(Player)

        # ショップUIを付与
        for(Player:GamePlayers, PlayerUI := GetPlayerUI[Player], PlayerItems := PlayerItemsMap[Player]):
            NewShopUI := shop_ui:
                AddPlayer := Player
                PlayerItems := PlayerItems
                KillUIEvent := KillUIEvent
                PlayerIconHudDevice := PlayerIconHudDevice
                HoldGoldsHudDevice := HoldGoldsHudDevice
            spawn{NewShopUI.Init()}
            if. set PlayerShopUIMap[Player] = NewShopUI

    # すべてのプレイヤーからショップUIを削除する関数
    KillAllUI():void=
        KillUIEvent.Signal()

    # 引数のプレイヤーの、以前のラウンドからの持ち越しアイテムをデータ化させる関数
    CarryOverItemsToData(Player:player):void=
        if(set PlayerItemsMap[Player] = array{}):
            for(CondBtnItemLink:CondBtnItemLinks, CondBtn := CondBtnItemLink.CondBtn):
                CondBtn.Activate(Player)
        
        # デバッグ用
        for(P->PlayerItems:PlayerItemsMap):
            PlayerName := GetAgentName(P)
            Print(PlayerName)
            for(Index->Item:PlayerItems):
                ItemName := Item.ItemEnum.ToString()
                ItemNum := Item.CarryOverCount
                Print("{Index}番目: {ItemName}が{ItemNum}個")


# ボタンを識別するための列挙型
btn_enum := enum:
    # 手持ちアイテム
    Sell_0
    Sell_1
    Sell_2
    Sell_3
    Sell_4

    # タブ
    Tab_SG
    Tab_P
    Tab_SMG
    Tab_AR
    Tab_SR
    Tab_SP
    Tab_ITEM
    Tab_PU

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
    PlayerItems:[]player_item
    KillUIEvent:event()
    PlayerIconHudDevice:hud_message_device
    HoldGoldsHudDevice:hud_message_device

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
    Tab_ItemBtn:button_loud = button_loud{}
    Tab_PUBtn:button_loud = button_loud{}

    # アイテム
    var Item_RarityTextures:[]texture_block = array{}
    var Item_ItemTextures:[]texture_block = array{}
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
    Page_LeftBtn:button_loud = button_loud{}
    Page_RightBtn:button_loud = button_loud{}

    # アイテム詳細
    Desc_RarityTexture:texture_block = texture_block{DefaultImage := ShopTextures_Rarities.square_L1_common, DefaultDesiredSize := vector2{X := 300.0, Y := 300.0}}
    Desc_ItemTexture:texture_block = texture_block{DefaultImage := ShopTextures_Items.AssaultRifle, DefaultDesiredSize := vector2{X := 300.0, Y := 300.0}}
    Desc_ItemNameText:text_block = text_block{}
    var Desc_DescTexts:[]text_block = array{}
    Desc_GoldsText:text_block = text_block{}
    Desc_LeftBtn:button_loud = button_loud{}
    Desc_RarityText:text_block = text_block{}
    Desc_RightBtn:button_loud = button_loud{}
    Desc_BuyBtn:button_loud = button_loud{}

    # 閉じるボタン
    ExitBtn:button_loud = button_loud{}

    # 変数
    var PageNum:int = 0 # 現在開いているページを保持

    var PlayerHealth:float = 100.0
    var PlayerShield:float = 100.0
    var PlayerGolds:int = 1000
    
    var ShopItems:[]item_enum = array{} # 現在ショップ部分に表示されているアイテムを保持する
    var SelectRearity:rarity_enum = rarity_enum.L1_Common # 現在どのレアリティが選択されているか

    # 定数
    HoldingNum:int = 5 # 手持ちのアイテムの最大個数
    CategoryNum:int = 8 # カテゴリーの数
    RowPerPage:int = 2 # 1ページに配置するアイテムの行の数
    ItemPerRow:int = 5 # 1行に配置するアイテムの個数
    MaxPageNum:int = 5 # 1カテゴリーにおける最大のページ数
    DescTextNum:int = 5 # アイテム説明の箇条書き行数

    Init()<suspends>:void=
        if(PlayerUI := GetPlayerUI[AddPlayer]):
            SetUpWidgetElem() # ウィジェット要素のセットアップ

            CreateUI() # UIの作成
            InitializeUI() # UIにデータを適用し、初期化する
            
            PlayerUI.AddWidget(Widget, player_ui_slot{InputMode := ui_input_mode.All})
            PlayerIconHudDevice.Show(AddPlayer)
            HoldGoldsHudDevice.Show(AddPlayer)
            spawn{HandleButtonClick()}
            Print("ショップUIを付与した")

            KillUIEvent.Await()

            PlayerUI.RemoveWidget(Widget)
            PlayerIconHudDevice.Hide(AddPlayer)
            HoldGoldsHudDevice.Hide(AddPlayer)
            Print("ショップUIを削除した")
        return

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
        Tab_SPBtn.SetText(S2M("SP"))
        Tab_ItemBtn.SetText(S2M("ITEM"))
        Tab_PUBtn.SetText(S2M("PU"))
        set Tab_Btns = array:
            Tab_SGBtn
            Tab_PBtn
            Tab_SMGBtn
            Tab_ARBtn
            Tab_SRBtn
            Tab_SPBtn
            Tab_ItemBtn
            Tab_PUBtn

        # アイテム
        for(Index := 0..RowPerPage * ItemPerRow - 1):
            set Item_RarityTextures += array{texture_block{DefaultImage := rarity_enum.L1_Common.ToBackground(), DefaultDesiredSize := vector2{X := 220.0, Y := 260.0}}}
            set Item_ItemTextures += array{texture_block{DefaultImage := item_enum.AssaultRifle.ToTexture(), DefaultDesiredSize := vector2{X := 220.0, Y := 220.0}}}
            set Item_GoldsTexts += array{text_block{DefaultText := S2M("99999")}}
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
                            overlay_slot: # 暗転背景
                                Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := color_block{DefaultColor := color{R := 0.0, G := 0.0, B := 0.0}, DefaultOpacity := 0.6}  
                            overlay_slot: # メインコンテンツ
                                Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Widget := overlay:
                                    Slots := array:
                                        overlay_slot: # 白半透明背景
                                            Padding := margin{Left := 0.0, Top := 7.0, Right := 0.0, Bottom := 0.0}
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment := vertical_alignment.Center
                                            Widget := texture_block{DefaultImage := ShopTextures_Items.WhiteBackground, DefaultDesiredSize := vector2{X := 1610.0, Y := 1010.0}}
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
                                Padding := margin{Left := 0.0, Top := 42.5, Right := 45.0, Bottom := 0.0}
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
                                    Slots := for(Index2 := 0..ItemPerRow - 1, ItemIndex := ItemPerRow * Index + Index2, RarityTexture := Item_RarityTextures[ItemIndex], ItemTexture := Item_ItemTextures[ItemIndex], GoldsText := Item_GoldsTexts[ItemIndex], SelectBtn := Item_SelectBtns[ItemIndex]):
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
                                                                    Widget := texture_block{DefaultImage := Textures.Creative_Coin, DefaultDesiredSize := vector2{X := 35.0, Y := 35.0}}
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
                            stack_box_slot: # 番号列部分
                                Padding := margin{Left := 30.0, Top := 0.0, Right := 30.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := stack_box:
                                    Orientation := orientation.Horizontal
                                    Slots := for(Index := 0..MaxPageNum - 1):
                                        var PaddingLeft:float = 0.0
                                        if(0 < Index):
                                            set PaddingLeft = 20.0

                                        stack_box_slot: # 数字ボックス
                                            Padding := margin{Left := PaddingLeft, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment := vertical_alignment.Center
                                            Widget := overlay:
                                                Slots := array:
                                                    overlay_slot: # ボーダー
                                                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment := vertical_alignment.Center
                                                        Widget := color_block{DefaultColor := Red, DefaultDesiredSize := vector2{X := 50.0, Y := 50.0}}
                                                    overlay_slot: # 数字背景
                                                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment := vertical_alignment.Center
                                                        Widget := color_block{DefaultColor := White, DefaultDesiredSize := vector2{X := 38.0, Y := 38.0}}
                                                    overlay_slot: # 数字テキスト
                                                        Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment := vertical_alignment.Center
                                                        Widget := text_block{DefaultText := S2M("{Index + 1}")}
                            stack_box_slot: # 右ボタン
                                Padding := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := Page_RightBtn

        return NewWidget

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
        UpdateShop()
        UpdatePageNation()

    # プレイヤーのステータスと手持ちアイテムの部分を更新する関数
    UpdatePlayerStatus():void=
        # ステータステキストの更新
        PlayerIconHudDevice.SetText(S2M("Health: {PlayerHealth}\nShield: {PlayerShield}"))
        HoldGoldsHudDevice.SetText(S2M("{PlayerGolds}"))

        # 手持ちアイテムの更新
        for(Index->Item:PlayerItems, RarityTexture := Holding_RarityTextures[Index], ItemTexture := Holding_ItemTextures[Index], ItemCountText := Holding_ItemCountText[Index]):
            RarityTexture.SetImage()

            ItemTexture.SetImage(Item.ItemEnum.ToTexture())

            Count := Item.CarrayOverCount + Item.BuyCount
            if(1 < Count):
                ItemCountText.SetText(S2M("{Count}"))
            else:
                ItemCountText.SetText(S2M(""))
        
        # 空領域の表示
        if(PlayerItems.Length < 5):


        
    # アイテム詳細の部分を更新する関数
    UpdateItemDetail():void=

    # アイテム一覧の部分を更新する関数
    UpdateShop():void=

    # ページネーションの部分を更新する関数
    UpdatePageNation():void=

    # ボタンが押されるのを待機し、押されたボタンに応じて処理を実行する関数
    HandleButtonClick()<suspends>:void=
        race:
            block:
                KillUIEvent.Await()
                Print("ショップUIが削除された")
            loop:
                Sleep(1.0)