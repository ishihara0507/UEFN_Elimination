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
player_item_data := struct:
    ItemData:item_data # アイテムの固有データ
    CarryOverCount:int # 以前のラウンドから持ち越された数（捨てるというボタンになる）
    BuyCount:int # その購入フェーズで購入した数（売るというボタンになる）

shop_ui_device := class(creative_device):

    @editable
    ItemCondBtns:[]conditional_button_device = array{} # 以前のラウンドからの持ち越しアイテムを特定するために必要

    @editable
    ItemGranter:item_granter_device = item_granter_device{} # 購入したアイテムをプレイヤーに渡すために必要

    @editable
    PlayerIconHudDevice:hud_message_device = hud_message_device{}
    @editable
    HoldGoldsHudDevice:hud_message_device = hud_message_device{}

    var PlayerItemDatasMap:[player][]player_item_data = map{}

    ShopDatas:shop_datas = shop_datas{}

    KillUIEvent:event() = event(){}
    
    OnBegin<override>()<suspends>:void=
        return

    # すべてのプレイヤーにショップUIを付与する関数
    AddShopUIForAll(GamePlayers:[]player):void=
        for(Player:GamePlayers, PlayerUI := GetPlayerUI[Player]):

    # 引数のプレイヤーの、以前のラウンドからの持ち越しアイテムをデータ化する関数
    CarryOverItemsToData(Player:player):[]player_item_data=
        


shop_ui := class:
    AddPlayer:player
    PlayerItemDatas:[]player_item_data
    KillUIEvent:event()
    PlayerIconHudDevice:hud_message_device
    HoldGoldsHudDevice:hud_message_device
