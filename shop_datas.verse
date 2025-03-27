using { /Verse.org/Assets }
using { /Verse.org/Colors }

### ショップで購入できるアイテムの定義を行うファイル ###

# ショップで購入できる武器やアイテム、パワーアップなどの名前を定義。レアリティが複数ある場合でも、同名のアイテムは１つ定義すればいい。
item_enum := enum:
    AssaultRifle
    SidearmPistol
    CombatShotgun
    SubmachineGun
    FalconEyeSniper
    SmallShieldPotion
    ShieldPot
    Bandage
    Medkit
    NitroFists

(IE:item_enum).ToTexture():texture=
    case(IE):
        item_enum.AssaultRifle => ShopTextures_Items.AssaultRifle1 # フォルダ名.テクスチャ名
        item_enum.SidearmPistol => ShopTextures_Items.SidearmPistol
        item_enum.CombatShotgun => ShopTextures_Items.CombatShotgun
        item_enum.SubmachineGun => ShopTextures_Items.SubmachineGun
        item_enum.FalconEyeSniper => ShopTextures_Items.FalconEyeSniper
        item_enum.SmallShieldPotion => ShopTextures_Items.SmallShieldPotion
        item_enum.ShieldPot => ShopTextures_Items.ShieldPot
        item_enum.Bandage => ShopTextures_Items.Bandage
        item_enum.Medkit => ShopTextures_Items.Medkit
        item_enum.NitroFists => ShopTextures_Items.NitroFists

(IE:item_enum).ToItemData():item_data=
    ShopDatas:shop_datas = shop_datas{}
    case(IE):
        item_enum.AssaultRifle => ShopDatas.AssaultRifle
        item_enum.SidearmPistol => ShopDatas.SidearmPistol
        item_enum.CombatShotgun => ShopDatas.CombatShotgun
        item_enum.SubmachineGun => ShopDatas.SubmachineGun
        item_enum.FalconEyeSniper => ShopDatas.FalconEyeSniper
        item_enum.SmallShieldPotion => ShopDatas.SmallShieldPotion
        item_enum.ShieldPot => ShopDatas.ShieldPot
        item_enum.Bandage => ShopDatas.Bandage
        item_enum.Medkit => ShopDatas.Medkit
        item_enum.NitroFists => ShopDatas.NitroFists


(IE:item_enum).ToString():string=
    case(IE):
        item_enum.AssaultRifle => "Assault Rifle"
        item_enum.SidearmPistol => "Sidearm Pistol"
        item_enum.CombatShotgun => "Combat Shotgun"
        item_enum.SubmachineGun => "Submachine Gun"
        item_enum.FalconEyeSniper => "Falcon Eye Sniper"
        item_enum.SmallShieldPotion => "Small Shield Potion"
        item_enum.ShieldPot => "Shield Pot"
        item_enum.Bandage => "Bandage"
        item_enum.Medkit => "Medkit"
        item_enum.NitroFists => "Nitro Fists"

# rarity_enum.L1_Common
# rarity_enum.L2_Uncommon
# rarity_enum.L3_Rare
# rarity_enum.L4_Epic
# rarity_enum.L5_Legend
# rarity_enum.L6_Mythic
# rarity_enum.L7_Exotic

shop_datas := class:
    ### ↓ 新しいアイテムを追加する際に加筆する必要がある -------------------------------------------------------

    # アイテム配列を定義
    AllItems:[]item_enum = array:
        item_enum.CombatShotgun
        item_enum.SidearmPistol
        item_enum.SubmachineGun
        item_enum.AssaultRifle
        item_enum.FalconEyeSniper
        item_enum.Bandage
        item_enum.Medkit
        item_enum.SmallShieldPotion
        item_enum.ShieldPot
        item_enum.NitroFists

    # 引数で与えられたカテゴリーに分類されたアイテムを配列で返す関数
    # ルール：空のカテゴリーは作成してはいけない。同じアイテム名を２度追加してはいけない。
    GetItemsByCategory(Category:item_category_enum):[]item_enum=
        var ReturnItems:[]item_enum = array{}

        case(Category):
            item_category_enum.SG => set ReturnItems = array:
                item_enum.CombatShotgun
            item_category_enum.P => set ReturnItems = array:
                item_enum.SidearmPistol
            item_category_enum.SMG => set ReturnItems = array:
                item_enum.SubmachineGun
            item_category_enum.AR => set ReturnItems = array:
                item_enum.AssaultRifle
            item_category_enum.SR => set ReturnItems = array:
                item_enum.FalconEyeSniper
            item_category_enum.ITEM => set ReturnItems = array:
                item_enum.Bandage
                item_enum.Medkit
                item_enum.SmallShieldPotion
                item_enum.ShieldPot
            item_category_enum.SP => set ReturnItems = array:
                item_enum.NitroFists
            item_category_enum.EX => set ReturnItems = array:

        return ReturnItems

    # :item_data = item_data: # 
    #     Item := item_enum.
    #     CanBuyMultiple := true
    #     MaxCapacity := 1
    #     Rarities := array:
    #         rarity_enum.L1_Common
    #         rarity_enum.L2_Uncommon
    #         rarity_enum.L3_Rare
    #         rarity_enum.L4_Epic
    #         rarity_enum.L5_Legend
    #     RarityPriceMap := map:
    #         rarity_enum.L1_Common => 200
    #         rarity_enum.L2_Uncommon => 300
    #         rarity_enum.L3_Rare => 400
    #         rarity_enum.L4_Epic => 500
    #         rarity_enum.L5_Legend => 600
    #     RarityDescMap := map:
    #         rarity_enum.L1_Common => array:
    #             "DMG: "
    #             "Fire Rate: "
    #             "Mag Size: "
    #             "Reload: "
    #             ""
    #         rarity_enum.L2_Uncommon => array:
    #             "DMG: "
    #             "Fire Rate: "
    #             "Mag Size: "
    #             "Reload: "
    #             ""
    #         rarity_enum.L3_Rare => array:
    #             "DMG: "
    #             "Fire Rate: "
    #             "Mag Size: "
    #             "Reload: "
    #             ""
    #         rarity_enum.L4_Epic => array:
    #             "DMG: "
    #             "Fire Rate: "
    #             "Mag Size: "
    #             "Reload: "
    #             ""
    #         rarity_enum.L5_Legend => array:
    #             "DMG: "
    #             "Fire Rate: "
    #             "Mag Size: "
    #             "Reload: "
    #             ""

    # 実際にアイテムのデータの中身を定義
    AssaultRifle:item_data = item_data: # アサルトライフル
        Item := item_enum.AssaultRifle
        CanBuyMultiple := true
        MaxCapacity := 1
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
                "DMG: 30"
                "Fire Rate: 5.5"
                "Mag Size: 30"
                "Reload: 2.75"
                ""
            rarity_enum.L2_Uncommon => array:
                "DMG: 31"
                "Fire Rate: 5.5"
                "Mag Size: 30"
                "Reload: 2.62"
                ""
            rarity_enum.L3_Rare => array:
                "DMG: 33"
                "Fire Rate: 5.5"
                "Mag Size: 30"
                "Reload: 2.5"
                ""
            rarity_enum.L4_Epic => array:
                "DMG: 35"
                "Fire Rate: 5.5"
                "Mag Size: 30"
                "Reload: 2.38"
                ""
            rarity_enum.L5_Legend => array:
                "DMG: 36"
                "Fire Rate: 5.5"
                "Mag Size: 30"
                "Reload: 2.25"
                ""

    SidearmPistol:item_data = item_data: # サイドアームピストル
        Item := item_enum.SidearmPistol
        CanBuyMultiple := true
        MaxCapacity := 1
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
                "DMG: 25"
                "Fire Rate: 6.75"
                "Mag Size: 15"
                "Reload: 1.54"
                ""
            rarity_enum.L2_Uncommon => array:
                "DMG: 27"
                "Fire Rate: 6.75"
                "Mag Size: 15"
                "Reload: 1.47"
                ""
            rarity_enum.L3_Rare => array:
                "DMG: 28"
                "Fire Rate: 6.75"
                "Mag Size: 15"
                "Reload: 1.4"
                ""
            rarity_enum.L4_Epic => array:
                "DMG: 29"
                "Fire Rate: 6.75"
                "Mag Size: 15"
                "Reload: 1.33"
                ""
            rarity_enum.L5_Legend => array:
                "DMG: 31"
                "Fire Rate: 6.75"
                "Mag Size: 15"
                "Reload: 1.26"
                ""
                
    CombatShotgun:item_data = item_data: # コンバットショットガン
        Item := item_enum.CombatShotgun
        CanBuyMultiple := true
        MaxCapacity := 1
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
                "DMG: 60"
                "Fire Rate: 1.7"
                "Mag Size: 8"
                "Reload: 5.79"
                ""
            rarity_enum.L2_Uncommon => array:
                "DMG: 64"
                "Fire Rate: 1.7"
                "Mag Size: 8"
                "Reload: 5.53"
                ""
            rarity_enum.L3_Rare => array:
                "DMG: 67"
                "Fire Rate: 1.7"
                "Mag Size: 8"
                "Reload: 5.27"
                ""
            rarity_enum.L4_Epic => array:
                "DMG: 70"
                "Fire Rate: 1.7"
                "Mag Size: 8"
                "Reload: 5"
                ""
            rarity_enum.L5_Legend => array:
                "DMG: 74"
                "Fire Rate: 1.7"
                "Mag Size: 8"
                "Reload: 4.74"
                ""
                
    SubmachineGun:item_data = item_data: # サブマシンガン
        Item := item_enum.SubmachineGun
        CanBuyMultiple := true
        MaxCapacity := 1
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
                "DMG: 16"
                "Fire Rate: 11"
                "Mag Size: 30"
                "Reload: 2.31"
                ""
            rarity_enum.L2_Uncommon => array:
                "DMG: 17"
                "Fire Rate: 11"
                "Mag Size: 30"
                "Reload: 2.2"
                ""
            rarity_enum.L3_Rare => array:
                "DMG: 18"
                "Fire Rate: 11"
                "Mag Size: 30"
                "Reload: 2.1"
                ""
            rarity_enum.L4_Epic => array:
                "DMG: 19"
                "Fire Rate: 11"
                "Mag Size: 30"
                "Reload: 2"
                ""
            rarity_enum.L5_Legend => array:
                "DMG: 20"
                "Fire Rate: 11"
                "Mag Size: 30"
                "Reload: 1.89"
                ""
                
    FalconEyeSniper:item_data = item_data: # ファルコンアイスナイパー
        Item := item_enum.FalconEyeSniper
        CanBuyMultiple := true
        MaxCapacity := 1
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
                "DMG: 76"
                "Fire Rate: 1.1"
                "Mag Size: 3"
                "Reload: 4.4"
                ""
            rarity_enum.L2_Uncommon => array:
                "DMG: 80"
                "Fire Rate: 1.1"
                "Mag Size: 3"
                "Reload: 4.2"
                ""
            rarity_enum.L3_Rare => array:
                "DMG: 84"
                "Fire Rate: 1.1"
                "Mag Size: 3"
                "Reload: 4"
                ""
            rarity_enum.L4_Epic => array:
                "DMG: 88"
                "Fire Rate: 1.1"
                "Mag Size: 3"
                "Reload: 3.8"
                ""
            rarity_enum.L5_Legend => array:
                "DMG: 92"
                "Fire Rate: 1.1"
                "Mag Size: 3"
                "Reload: 3.6"
                ""
                
    SmallShieldPotion:item_data = item_data: # ミニシールドポーション
        Item := item_enum.SmallShieldPotion
        CanBuyMultiple := true
        MaxCapacity := 6
        Rarities := array:
            rarity_enum.L2_Uncommon
        RarityPriceMap := map:
            rarity_enum.L2_Uncommon => 300
        RarityDescMap := map:
            rarity_enum.L2_Uncommon => array:
                "Use Time: 2 sec"
                "Heal: 25 Shield"
                "Max: 50 Shield"
                "Stack: 6"
                ""
                
    ShieldPot:item_data = item_data: # シールドポーション
        Item := item_enum.ShieldPot
        CanBuyMultiple := true
        MaxCapacity := 3
        Rarities := array:
            rarity_enum.L3_Rare
        RarityPriceMap := map:
            rarity_enum.L3_Rare => 400
        RarityDescMap := map:
            rarity_enum.L3_Rare => array:
                "Use Time: 5 sec"
                "Heal: 50 Shield"
                "Stack: 3"
                ""
                ""
                
    Bandage:item_data = item_data: # 包帯
        Item := item_enum.Bandage
        CanBuyMultiple := true
        MaxCapacity := 15
        Rarities := array:
            rarity_enum.L1_Common
        RarityPriceMap := map:
            rarity_enum.L1_Common => 200
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Use Time: 3 sec"
                "Heal: 15 Health"
                "Max: 75 Health"
                "Stack: 15"
                ""
                
    Medkit:item_data = item_data: # 医療キット
        Item := item_enum.Medkit
        CanBuyMultiple := true
        MaxCapacity := 3
        Rarities := array:
            rarity_enum.L2_Uncommon
        RarityPriceMap := map:
            rarity_enum.L2_Uncommon => 300
        RarityDescMap := map:
            rarity_enum.L2_Uncommon => array:
                "Use Time: 10 sec"
                "Heal: Full Health"
                "Stack: 3"
                ""
                ""
                
    NitroFists:item_data = item_data: # ニトロフィスト
        Item := item_enum.NitroFists
        CanBuyMultiple := false
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L4_Epic
            rarity_enum.L6_Mythic
        RarityPriceMap := map:
            rarity_enum.L4_Epic => 500
            rarity_enum.L6_Mythic => 600
        RarityDescMap := map:
            rarity_enum.L4_Epic => array:
                "Punch: 55 55 70"
                "Air Punch: 50"
                "Uppercut: 60"
                "Ammo Capacity: 4"
                "Cooldown: 11 sec"
            rarity_enum.L6_Mythic => array:
                "Punch: 55 55 70"
                "Air Punch: 50"
                "Uppercut: 60"
                "Ammo Capacity: 5"
                "Cooldown: 11 sec"

    ### ↓ 新しいアイテムを追加する際に加筆する必要はない -------------------------------------------------------

    # カテゴリー配列
    AllCategories:[]item_category_enum = array:
        item_category_enum.SG
        item_category_enum.P
        item_category_enum.SMG 
        item_category_enum.AR
        item_category_enum.SR
        item_category_enum.ITEM
        item_category_enum.SP
        item_category_enum.EX
    
    # レアリティ配列
    AllRarities:[]rarity_enum = array:
        rarity_enum.L1_Common
        rarity_enum.L2_Uncommon
        rarity_enum.L3_Rare
        rarity_enum.L4_Epic
        rarity_enum.L5_Legend
        rarity_enum.L6_Mythic
        rarity_enum.L7_Exotic

    # アイテムのアイテムグランター上でのインデックスを返す関数
    GetIndexByItemAndRarity(ItemEnum:item_enum, RarityEnum:rarity_enum):int=
        var Result:int = 0

        # インデックスを特定
        for(Item:AllItems):
            if(ItemEnum = Item):
                Rarities := Item.ToItemData().Rarities
                for(Rarity:Rarities):
                    if(RarityEnum = Rarity):
                        return Result
                    else:
                        set Result += 1
            else:
                set Result += Item.ToItemData().Rarities.Length

        return -1 # 失敗

### ↓ 新しいアイテムを追加する際に加筆する必要はない -------------------------------------------------------

# アイテムのカテゴリー
item_category_enum := enum:
    SG
    P
    SMG
    AR
    SR
    ITEM
    SP
    EX

(ICE:item_category_enum).ToString():string=
    case(ICE):
        item_category_enum.SG => "SG"
        item_category_enum.P => "P"
        item_category_enum.SMG => "SMG"
        item_category_enum.AR => "AR"
        item_category_enum.SR => "SR"
        item_category_enum.ITEM => "ITEM"
        item_category_enum.SP => "SP"
        item_category_enum.EX => "EX"

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
        rarity_enum.L5_Legend => color{R := 1.0, G := 0.25, B := 0.0}
        rarity_enum.L6_Mythic => color{R := 0.578, G := 0.275, B := 0.0}
        rarity_enum.L7_Exotic => color{R := 0.0, G := 0.52, B := 0.48}


item_data := struct:
    Item:item_enum # アイテムの識別名
    CanBuyMultiple:logic # 複数スロットに持てるかを保持（スロットに空きがあっても１つしか持てないアイテムがある）。true: 複数持てる, false: 1スロット分しか持てない
    MaxCapacity:int # １スロットでそのアイテムを保持できる数
    Rarities:[]rarity_enum # レアリティの種類
    RarityPriceMap:[rarity_enum]int # レアリティと値段のペア
    RarityDescMap:[rarity_enum][]string # レアリティと説明配列のペア
