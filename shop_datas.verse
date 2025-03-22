using { /Verse.org/Assets }

## ショップで購入できる武器やアイテム、パワーアップなどの定義を行うファイル

item_data := struct:
    Item:item_enum # アイテムの識別名
    MaxCapacity:int # １スロットでそのアイテムを保持できる数
    RarityPricesMap:[rarity_enum]int # レアリティのその金額のペアを保持するマップ
    
# rarity_enum.L1_Common
# rarity_enum.L2_Uncommon
# rarity_enum.L3_Rare
# rarity_enum.L4_Epic
# rarity_enum.L5_Legend
# rarity_enum.L6_Mythic
# rarity_enum.L7_Exotic

shop_datas := class:
    ItemDatas:[]item_data = array:

        item_data: # アサルトライフル
            Item := item_enum.AssaultRifle
            MaxCapacity := 1
            RarityPricesMap := map:
                rarity_enum.L1_Common => 200
                rarity_enum.L2_Uncommon => 300
                rarity_enum.L3_Rare => 400
                rarity_enum.L4_Epic => 500
                rarity_enum.L5_Legend => 600

# ショップで購入できる武器やアイテム、パワーアップなどの名前を定義。レアリティが複数ある場合でも、同名のアイテムは１つ定義すればいい。
item_enum := enum:
    AssaultRifle

(IE:item_enum).ToTexture():texture=
    case(IE):
        item_enum.AssaultRifle => ShopTextures_Items.AssaultRifle # フォルダ名.テクスチャ名

# デバッグ用
(IE:item_enum).ToString():string=
    case(IE):
        item_enum.AssaultRifle => "AssaultRifle"

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
