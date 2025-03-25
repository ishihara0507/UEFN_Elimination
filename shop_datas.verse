using { /Verse.org/Assets }
using { /Verse.org/Colors }

## ショップで購入できる武器やアイテム、パワーアップなどの定義を行うファイル

# ショップで購入できる武器やアイテム、パワーアップなどの名前を定義。レアリティが複数ある場合でも、同名のアイテムは１つ定義すればいい。
item_enum := enum:
    AssaultRifle

(IE:item_enum).ToTexture():texture=
    case(IE):
        item_enum.AssaultRifle => ShopTextures_Items.AssaultRifle # フォルダ名.テクスチャ名

(IE:item_enum).ToItemData():item_data=
    ShopDatas:shop_datas = shop_datas{}
    case(IE):
        item_enum.AssaultRifle => ShopDatas.AssaultRifle

(IE:item_enum).ToString():string=
    case(IE):
        item_enum.AssaultRifle => "Assault Rifle"

# アイテムのカテゴリー
item_category_enum := enum:
    SG
    P
    SMG
    AR
    SR
    SP
    ITEM
    PU

rarity_enum := enum:
    L1_Common
    L2_Uncommon
    L3_Rare
    L4_Epic
    L5_Legend
    L6_Mythic
    L7_Exotic

# 購入UIの方のアイテム背景
(RE:rarity_enum).ToBackground():texture=
    case(RE):
        rarity_enum.L1_Common => ShopTextures_Rarities.L1_common
        rarity_enum.L2_Uncommon => ShopTextures_Rarities.L2_uncommon
        rarity_enum.L3_Rare => ShopTextures_Rarities.L3_rare
        rarity_enum.L4_Epic => ShopTextures_Rarities.L4_epic
        rarity_enum.L5_Legend => ShopTextures_Rarities.L5_legend
        rarity_enum.L6_Mythic => ShopTextures_Rarities.L6_mythic
        rarity_enum.L7_Exotic => ShopTextures_Rarities.L7_exotic

# 所持中UIの方のアイテム背景
(RE:rarity_enum).ToSquare():texture=
    case(RE):
        rarity_enum.L1_Common => ShopTextures_Rarities.square_L1_common
        rarity_enum.L2_Uncommon => ShopTextures_Rarities.square_L2_uncommon
        rarity_enum.L3_Rare => ShopTextures_Rarities.square_L3_rare
        rarity_enum.L4_Epic => ShopTextures_Rarities.square_L4_epic
        rarity_enum.L5_Legend => ShopTextures_Rarities.square_L5_legend
        rarity_enum.L6_Mythic => ShopTextures_Rarities.square_L6_mythic
        rarity_enum.L7_Exotic => ShopTextures_Rarities.square_L7_exotic

(RE:rarity_enum).ToString():string=
    case(RE):
        rarity_enum.L1_Common => "Common"
        rarity_enum.L2_Uncommon => "Uncommon"
        rarity_enum.L3_Rare => "Rare"
        rarity_enum.L4_Epic => "Epic"
        rarity_enum.L5_Legend => "Legend"
        rarity_enum.L6_Mythic => "Mythic"
        rarity_enum.L7_Exotic => "Exotic"

(RE:rarity_enum).ToTextColor():color=
    case(RE):
        rarity_enum.L1_Common => color{R := 0.148, G := 0.148, B := 0.148}
        rarity_enum.L2_Uncommon => color{R := 0.0, G := 0.513, B := 0.0}
        rarity_enum.L3_Rare => color{R := 0.0, G := 0.1, B := 1.0}
        rarity_enum.L4_Epic => color{R := 0.275, G := 0.0, B := 0.753}
        rarity_enum.L5_Legend => color{R := 0.905, G := 0.122, B := 0.0}
        rarity_enum.L6_Mythic => color{R := 0.578, G := 0.275, B := 0.0}
        rarity_enum.L7_Exotic => color{R := 0.0, G := 0.52, B := 0.48}


item_data := struct:
    Item:item_enum # アイテムの識別名
    MaxCapacity:int # １スロットでそのアイテムを保持できる数
    Rarities:[]rarity_enum # レアリティの種類
    RarityPriceMap:[rarity_enum]int # レアリティと値段のペア
    RarityDescMap:[rarity_enum][]string # レアリティと説明配列のペア
    
# rarity_enum.L1_Common
# rarity_enum.L2_Uncommon
# rarity_enum.L3_Rare
# rarity_enum.L4_Epic
# rarity_enum.L5_Legend
# rarity_enum.L6_Mythic
# rarity_enum.L7_Exotic

shop_datas := class:
    # 引数で与えられたカテゴリーに分類されたアイテムを配列で返す関数
    GetItemsByCategory(Category:item_category_enum):[]item_enum=
        var ReturnItems:[]item_enum = array{}

        case(Category):
            item_category_enum.SG => set ReturnItems = array:
            item_category_enum.P => set ReturnItems = array:
            item_category_enum.SMG => set ReturnItems = array:
            item_category_enum.AR => set ReturnItems = array:
            item_category_enum.SR => set ReturnItems = array:
                item_enum.AssaultRifle
            item_category_enum.SP => set ReturnItems = array:
            item_category_enum.ITEM => set ReturnItems = array:
            item_category_enum.PU => set ReturnItems = array:

        return ReturnItems


    # 実際にアイテムのデータの中身を定義
    AssaultRifle:item_data = item_data: # アサルトライフル
        Item := item_enum.AssaultRifle
        MaxCapacity := 3
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
        RarityPriceMap := map:
            rarity_enum.L1_Common => 200
            rarity_enum.L2_Uncommon => 300
            rarity_enum.L3_Rare => 400
            rarity_enum.L4_Epic => 500
            rarity_enum.L5_Legend => 600
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "DPS: 100"
                "DMG: 100"
                "Mag Size: 100"
                "Fire Rate: 100"
                "Reload: 100"
            rarity_enum.L2_Uncommon => array:
                "DPS: 100"
                "DMG: 100"
                "Mag Size: 100"
                "Fire Rate: 100"
                "Reload: 100"
            rarity_enum.L3_Rare => array:
                "DPS: 100"
                "DMG: 100"
                "Mag Size: 100"
                "Fire Rate: 100"
                "Reload: 100"
            rarity_enum.L4_Epic => array:
                "DPS: 100"
                "DMG: 100"
                "Mag Size: 100"
                "Fire Rate: 100"
                "Reload: 100"
            rarity_enum.L5_Legend => array:
                "DPS: 100"
                "DMG: 100"
                "Mag Size: 100"
                "Fire Rate: 100"
                "Reload: 100"