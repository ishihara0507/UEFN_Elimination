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
    Pistol
    Revolver
    MammothPistol
    TacticalPistol
    SentinelPumpShotgun
    TwinfireAutoShotgun
    OutlawShotgun
    PumpAndDump
    CombatSMG
    VeiledPrecisionSMG
    RapidFireSMG
    ChargeSMG
    StrikerBurstRifle
    HoloTwisterAssaultRifle
    CollateralDamageAssaultRifle
    CombatAssaultRifle
    TacticalAssaultRifle
    BoltActionSniperRifle
    HeavySniperRifle
    LeverActionRifle
    RocketLauncher
    FireOniMask
    TheKneecapper
    ThornesVampiricBlade
    TyphoonBlade
    Grappler
    GrappleGlove

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
        item_enum.Pistol =>  ShopTextures_Items.Pistol # ここから
        item_enum.Revolver =>  ShopTextures_Items.Revolver
        item_enum.MammothPistol =>  ShopTextures_Items.MammothPistol
        item_enum.TacticalPistol =>  ShopTextures_Items.TacticalPistol
        item_enum.SentinelPumpShotgun =>  ShopTextures_Items.SentinelPumpShotgun
        item_enum.TwinfireAutoShotgun =>  ShopTextures_Items.TwinfireAutoShotgun
        item_enum.OutlawShotgun =>  ShopTextures_Items.OutlawShotgun
        item_enum.PumpAndDump =>  ShopTextures_Items.PumpAndDump
        item_enum.CombatSMG =>  ShopTextures_Items.CombatSMG
        item_enum.VeiledPrecisionSMG =>  ShopTextures_Items.VeiledPrecisionSMG
        item_enum.RapidFireSMG =>  ShopTextures_Items.RapidFireSMG
        item_enum.ChargeSMG =>  ShopTextures_Items.ChargeSMG
        item_enum.StrikerBurstRifle =>  ShopTextures_Items.StrikerBurstRifle
        item_enum.HoloTwisterAssaultRifle =>  ShopTextures_Items.HoloTwisterAssaultRifle
        item_enum.CollateralDamageAssaultRifle =>  ShopTextures_Items.CollateralDamageAssaultRifle
        item_enum.CombatAssaultRifle =>  ShopTextures_Items.CombatAssaultRifle
        item_enum.TacticalAssaultRifle =>  ShopTextures_Items.TacticalAssaultRifle
        item_enum.BoltActionSniperRifle =>  ShopTextures_Items.BoltActionSniperRifle
        item_enum.HeavySniperRifle =>  ShopTextures_Items.HeavySniperRifle
        item_enum.LeverActionRifle =>  ShopTextures_Items.LeverActionRifle
        item_enum.RocketLauncher =>  ShopTextures_Items.RocketLauncher
        item_enum.FireOniMask =>  ShopTextures_Items.FireOniMask
        item_enum.TheKneecapper =>  ShopTextures_Items.TheKneecapper
        item_enum.ThornesVampiricBlade =>  ShopTextures_Items.ThornesVampiricBlade
        item_enum.TyphoonBlade =>  ShopTextures_Items.TyphoonBlade
        item_enum.Grappler => ShopTextures_Items.Grappler
        item_enum.GrappleGlove => ShopTextures_Items.GrappleGlove
        
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
        item_enum.Pistol =>  ShopDatas.Pistol
        item_enum.Revolver =>  ShopDatas.Revolver
        item_enum.MammothPistol =>  ShopDatas.MammothPistol
        item_enum.TacticalPistol =>  ShopDatas.TacticalPistol
        item_enum.SentinelPumpShotgun =>  ShopDatas.SentinelPumpShotgun
        item_enum.TwinfireAutoShotgun =>  ShopDatas.TwinfireAutoShotgun
        item_enum.OutlawShotgun =>  ShopDatas.OutlawShotgun
        item_enum.PumpAndDump =>  ShopDatas.PumpAndDump
        item_enum.CombatSMG =>  ShopDatas.CombatSMG
        item_enum.VeiledPrecisionSMG =>  ShopDatas.VeiledPrecisionSMG
        item_enum.RapidFireSMG =>  ShopDatas.RapidFireSMG
        item_enum.ChargeSMG =>  ShopDatas.ChargeSMG
        item_enum.StrikerBurstRifle =>  ShopDatas.StrikerBurstRifle
        item_enum.HoloTwisterAssaultRifle =>  ShopDatas.HoloTwisterAssaultRifle
        item_enum.CollateralDamageAssaultRifle =>  ShopDatas.CollateralDamageAssaultRifle
        item_enum.CombatAssaultRifle =>  ShopDatas.CombatAssaultRifle
        item_enum.TacticalAssaultRifle =>  ShopDatas.TacticalAssaultRifle
        item_enum.BoltActionSniperRifle =>  ShopDatas.BoltActionSniperRifle
        item_enum.HeavySniperRifle =>  ShopDatas.HeavySniperRifle
        item_enum.LeverActionRifle =>  ShopDatas.LeverActionRifle
        item_enum.RocketLauncher =>  ShopDatas.RocketLauncher
        item_enum.FireOniMask =>  ShopDatas.FireOniMask
        item_enum.TheKneecapper =>  ShopDatas.TheKneecapper
        item_enum.ThornesVampiricBlade =>  ShopDatas.ThornesVampiricBlade
        item_enum.TyphoonBlade =>  ShopDatas.TyphoonBlade
        item_enum.Grappler =>  ShopDatas.Grappler
        item_enum.GrappleGlove => ShopDatas.GrappleGlove


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
        item_enum.Pistol =>  "Pistol"
        item_enum.Revolver =>  "Revolver"
        item_enum.MammothPistol =>  "Mammoth Pistol"
        item_enum.TacticalPistol =>  "Tactical Pistol"
        item_enum.SentinelPumpShotgun =>  "Sentinel Pump\nShotgun"
        item_enum.TwinfireAutoShotgun =>  "Twinfire Auto\nShotgun"
        item_enum.OutlawShotgun =>  "Outlaw Shotgun"
        item_enum.PumpAndDump =>  "Pump & Dump"
        item_enum.CombatSMG =>  "Combat SMG"
        item_enum.VeiledPrecisionSMG =>  "Veiled Precision\nSMG"
        item_enum.RapidFireSMG =>  "Rapid Fire SMG"
        item_enum.ChargeSMG =>  "Charge SMG"
        item_enum.StrikerBurstRifle =>  "Striker Burst Rifle"
        item_enum.HoloTwisterAssaultRifle =>  "Holo Twister\nAssault Rifle"
        item_enum.CollateralDamageAssaultRifle =>  "Collateral Damage\nAssault Rifle"
        item_enum.CombatAssaultRifle =>  "Combat\nAssault Rifle"
        item_enum.TacticalAssaultRifle =>  "Tactical\nAssault Rifle"
        item_enum.BoltActionSniperRifle =>  "Bolt-Action\nSniper Rifle"
        item_enum.HeavySniperRifle =>  "Heavy Sniper Rifle"
        item_enum.LeverActionRifle =>  "Lever Action Rifle"
        item_enum.RocketLauncher =>  "Rocket Launcher"
        item_enum.FireOniMask =>  "Fire Oni Mask"
        item_enum.TheKneecapper =>  "The Kneecapper"
        item_enum.ThornesVampiricBlade => "Thorne\'s Vampiric\nBlade"
        item_enum.TyphoonBlade =>  "Typhoon Blade"
        item_enum.Grappler =>  "Grappler"
        item_enum.GrappleGlove => "GrappleGlove"

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
        item_enum.Pistol # ここから
        item_enum.Revolver
        item_enum.MammothPistol
        item_enum.TacticalPistol
        item_enum.SentinelPumpShotgun
        item_enum.TwinfireAutoShotgun
        item_enum.OutlawShotgun
        item_enum.PumpAndDump
        item_enum.CombatSMG
        item_enum.VeiledPrecisionSMG
        item_enum.RapidFireSMG
        item_enum.ChargeSMG
        item_enum.StrikerBurstRifle
        item_enum.HoloTwisterAssaultRifle
        item_enum.CollateralDamageAssaultRifle
        item_enum.CombatAssaultRifle
        item_enum.TacticalAssaultRifle
        item_enum.BoltActionSniperRifle
        item_enum.HeavySniperRifle
        item_enum.LeverActionRifle
        item_enum.RocketLauncher
        item_enum.FireOniMask
        item_enum.TheKneecapper
        item_enum.ThornesVampiricBlade
        item_enum.TyphoonBlade
        item_enum.Grappler
        item_enum.GrappleGlove

    # 引数で与えられたカテゴリーに分類されたアイテムを配列で返す関数
    # ここでの順番がUIに表示される順番になる
    GetItemsByCategory(Category:item_category_enum):[]item_enum=
        var ReturnItems:[]item_enum = array{}

        case(Category):
            item_category_enum.SG => set ReturnItems = array:
                item_enum.CombatShotgun
                item_enum.SentinelPumpShotgun
                item_enum.TwinfireAutoShotgun
                item_enum.OutlawShotgun
                item_enum.PumpAndDump
            item_category_enum.P => set ReturnItems = array:
                item_enum.Pistol
                item_enum.SidearmPistol
                item_enum.TacticalPistol
                item_enum.MammothPistol
                item_enum.Revolver
            item_category_enum.SMG => set ReturnItems = array:
                item_enum.SubmachineGun
                item_enum.CombatSMG
                item_enum.VeiledPrecisionSMG
                item_enum.RapidFireSMG
                item_enum.ChargeSMG
                item_enum.PumpAndDump
            item_category_enum.AR => set ReturnItems = array:
                item_enum.AssaultRifle
                item_enum.CombatAssaultRifle
                item_enum.TacticalAssaultRifle
                item_enum.StrikerBurstRifle
                item_enum.HoloTwisterAssaultRifle
                item_enum.CollateralDamageAssaultRifle
            item_category_enum.SR => set ReturnItems = array:
                item_enum.FalconEyeSniper
                item_enum.BoltActionSniperRifle
                item_enum.HeavySniperRifle
                item_enum.LeverActionRifle
            item_category_enum.ITEM => set ReturnItems = array:
                item_enum.Bandage
                item_enum.Medkit
                item_enum.SmallShieldPotion
                item_enum.ShieldPot
                item_enum.Grappler
            item_category_enum.SP => set ReturnItems = array:
                item_enum.RocketLauncher
                item_enum.GrappleGlove
                item_enum.NitroFists
                item_enum.FireOniMask
                item_enum.TyphoonBlade
                item_enum.ThornesVampiricBlade
                item_enum.TheKneecapper
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
    #             "Dmg: "
    #             "Fire Rate: "
    #             "Mag Size: "
    #             "Reload: "
    #             ""
    #         rarity_enum.L2_Uncommon => array:
    #             "Dmg: "
    #             "Fire Rate: "
    #             "Mag Size: "
    #             "Reload: "
    #             ""
    #         rarity_enum.L3_Rare => array:
    #             "Dmg: "
    #             "Fire Rate: "
    #             "Mag Size: "
    #             "Reload: "
    #             ""
    #         rarity_enum.L4_Epic => array:
    #             "Dmg: "
    #             "Fire Rate: "
    #             "Mag Size: "
    #             "Reload: "
    #             ""
    #         rarity_enum.L5_Legend => array:
    #             "Dmg: "
    #             "Fire Rate: "
    #             "Mag Size: "
    #             "Reload: "
    #             ""

    # 実際にアイテムのデータの中身を定義
    AssaultRifle:item_data = item_data: # アサルトライフル　お
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
                "Dmg: 30"
                "Fire Rate: 5.5"
                "Mag Size: 30"
                "Reload: 2.75"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 31"
                "Fire Rate: 5.5"
                "Mag Size: 30"
                "Reload: 2.62"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 33"
                "Fire Rate: 5.5"
                "Mag Size: 30"
                "Reload: 2.5"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 35"
                "Fire Rate: 5.5"
                "Mag Size: 30"
                "Reload: 2.38"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 36"
                "Fire Rate: 5.5"
                "Mag Size: 30"
                "Reload: 2.25"
                ""

    SidearmPistol:item_data = item_data: # サイドアームピストル　お
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
            rarity_enum.L1_Common => 800
            rarity_enum.L2_Uncommon => 850
            rarity_enum.L3_Rare => 900
            rarity_enum.L4_Epic => 950
            rarity_enum.L5_Legend => 1000
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 25"
                "Fire Rate: 6.75"
                "Mag Size: 15"
                "Reload: 1.54"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 27"
                "Fire Rate: 6.75"
                "Mag Size: 15"
                "Reload: 1.47"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 28"
                "Fire Rate: 6.75"
                "Mag Size: 15"
                "Reload: 1.4"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 29"
                "Fire Rate: 6.75"
                "Mag Size: 15"
                "Reload: 1.33"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 31"
                "Fire Rate: 6.75"
                "Mag Size: 15"
                "Reload: 1.26"
                ""
                
    CombatShotgun:item_data = item_data: # コンバットショットガン　お
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
            rarity_enum.L1_Common => 800
            rarity_enum.L2_Uncommon => 850
            rarity_enum.L3_Rare => 900
            rarity_enum.L4_Epic => 950
            rarity_enum.L5_Legend => 1000
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 60"
                "Fire Rate: 1.7"
                "Mag Size: 8"
                "Reload: 5.79"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 64"
                "Fire Rate: 1.7"
                "Mag Size: 8"
                "Reload: 5.53"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 67"
                "Fire Rate: 1.7"
                "Mag Size: 8"
                "Reload: 5.27"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 70"
                "Fire Rate: 1.7"
                "Mag Size: 8"
                "Reload: 5"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 74"
                "Fire Rate: 1.7"
                "Mag Size: 8"
                "Reload: 4.74"
                ""
                
    SubmachineGun:item_data = item_data: # サブマシンガン　お
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
            rarity_enum.L1_Common => 900
            rarity_enum.L2_Uncommon => 950
            rarity_enum.L3_Rare => 1000
            rarity_enum.L4_Epic => 1050
            rarity_enum.L5_Legend => 1100
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 16"
                "Fire Rate: 11"
                "Mag Size: 30"
                "Reload: 2.31"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 17"
                "Fire Rate: 11"
                "Mag Size: 30"
                "Reload: 2.2"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 18"
                "Fire Rate: 11"
                "Mag Size: 30"
                "Reload: 2.1"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 19"
                "Fire Rate: 11"
                "Mag Size: 30"
                "Reload: 2"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 20"
                "Fire Rate: 11"
                "Mag Size: 30"
                "Reload: 1.89"
                ""
                
    FalconEyeSniper:item_data = item_data: # ファルコンアイスナイパー　お
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
                "Dmg: 76"
                "Fire Rate: 1.1"
                "Mag Size: 3"
                "Reload: 4.4"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 80"
                "Fire Rate: 1.1"
                "Mag Size: 3"
                "Reload: 4.2"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 84"
                "Fire Rate: 1.1"
                "Mag Size: 3"
                "Reload: 4"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 88"
                "Fire Rate: 1.1"
                "Mag Size: 3"
                "Reload: 3.8"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 92"
                "Fire Rate: 1.1"
                "Mag Size: 3"
                "Reload: 3.6"
                ""
                
    SmallShieldPotion:item_data = item_data: # ミニシールドポーション　お
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
                
    ShieldPot:item_data = item_data: # シールドポーション　お
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
                
    Bandage:item_data = item_data: # 包帯　お
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
                
    Medkit:item_data = item_data: # 医療キット　お
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
                
    NitroFists:item_data = item_data: # ニトロフィスト　お
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
    
    Pistol:item_data = item_data: # ピストル　おｋ
        Item := item_enum.Pistol
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
        RarityPriceMap := map:
            rarity_enum.L1_Common => 800
            rarity_enum.L2_Uncommon => 850
            rarity_enum.L3_Rare => 900
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 24"
                "Fire Rate: 6.75"
                "Mag Size: 16"
                "Reload: 1.54"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 25"
                "Fire Rate: 6.75"
                "Mag Size: 16"
                "Reload: 1.47"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 26"
                "Fire Rate: 6.75"
                "Mag Size: 16"
                "Reload: 1.4"
                ""

    Revolver:item_data = item_data: # リボルバー お
        Item := item_enum.Revolver
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
        RarityPriceMap := map:
            rarity_enum.L1_Common => 700
            rarity_enum.L2_Uncommon => 750
            rarity_enum.L3_Rare => 800
            rarity_enum.L4_Epic => 850
            rarity_enum.L5_Legend => 900
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 54"
                "Fire Rate: 0.9"
                "Mag Size: 6"
                "Reload: 2.42"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 57"
                "Fire Rate: 0.9"
                "Mag Size: 6"
                "Reload: 2.31"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 60"
                "Fire Rate: 0.9"
                "Mag Size: 6"
                "Reload: 2.2"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 63"
                "Fire Rate: 0.9"
                "Mag Size: 6"
                "Reload: 2.09"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 66"
                "Fire Rate: 0.9"
                "Mag Size: 6"
                "Reload: 1.98"
                ""
                
    MammothPistol:item_data = item_data: # マンモスピストル　お
        Item := item_enum.MammothPistol
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
        RarityPriceMap := map:
            rarity_enum.L1_Common => 750
            rarity_enum.L2_Uncommon => 800
            rarity_enum.L3_Rare => 850
            rarity_enum.L4_Epic => 900
            rarity_enum.L5_Legend => 950
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 89"
                "Fire Rate: 1"
                "Mag Size: 1"
                "Reload: 1.89"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 91"
                "Fire Rate: 1"
                "Mag Size: 1"
                "Reload: 1.85"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 94"
                "Fire Rate: 1"
                "Mag Size: 1"
                "Reload: 1.8"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 97"
                "Fire Rate: 1"
                "Mag Size: 1"
                "Reload: 1.75"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 99"
                "Fire Rate: 1"
                "Mag Size: 1"
                "Reload: 1.71"
                ""
                
    TacticalPistol:item_data = item_data: # タクティカルピストル　お
        Item := item_enum.TacticalPistol
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
            rarity_enum.L6_Mythic
        RarityPriceMap := map:
            rarity_enum.L1_Common => 800
            rarity_enum.L2_Uncommon => 850
            rarity_enum.L3_Rare => 900
            rarity_enum.L4_Epic => 950
            rarity_enum.L5_Legend => 1000
            rarity_enum.L6_Mythic => 1050
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 23"
                "Fire Rate: 6.8"
                "Mag Size: 15"
                "Reload: 1.5"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 24"
                "Fire Rate: 6.8"
                "Mag Size: 15"
                "Reload: 1.45"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 25"
                "Fire Rate: 6.8"
                "Mag Size: 15"
                "Reload: 1.4"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 26"
                "Fire Rate: 6.8"
                "Mag Size: 15"
                "Reload: 1.35"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 28"
                "Fire Rate: 6.8"
                "Mag Size: 15"
                "Reload: 1.3"
                ""
            rarity_enum.L6_Mythic => array:
                "Dmg: 29"
                "Fire Rate: 6.8"
                "Mag Size: 15"
                "Reload: 1.25"
                ""
                
    SentinelPumpShotgun:item_data = item_data: # センチネル ポンプショットガン　お
        Item := item_enum.SentinelPumpShotgun
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
        RarityPriceMap := map:
            rarity_enum.L1_Common => 850
            rarity_enum.L2_Uncommon => 900
            rarity_enum.L3_Rare => 950
            rarity_enum.L4_Epic => 1000
            rarity_enum.L5_Legend => 1050
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 92"
                "Fire Rate: 0.85"
                "Mag Size: 4"
                "Reload: 5.39"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 98"
                "Fire Rate: 0.85"
                "Mag Size: 4"
                "Reload: 5.14"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 103"
                "Fire Rate: 0.85"
                "Mag Size: 4"
                "Reload: 4.9"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 108"
                "Fire Rate: 0.85"
                "Mag Size: 4"
                "Reload: 4.66"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 114"
                "Fire Rate: 0.85"
                "Mag Size: 4"
                "Reload: 4.41"
                ""
                
    TwinfireAutoShotgun:item_data = item_data: # ツインファイア オートショットガン　お
        Item := item_enum.TwinfireAutoShotgun
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
        RarityPriceMap := map:
            rarity_enum.L1_Common => 850
            rarity_enum.L2_Uncommon => 900
            rarity_enum.L3_Rare => 950
            rarity_enum.L4_Epic => 1000
            rarity_enum.L5_Legend => 1050
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 65"
                "Fire Rate: 1.9"
                "Mag Size: 14"
                "Reload: 5.06"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 68"
                "Fire Rate: 1.9"
                "Mag Size: 14"
                "Reload: 4.83"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 72"
                "Fire Rate: 1.9"
                "Mag Size: 14"
                "Reload: 4.6"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 76"
                "Fire Rate: 1.9"
                "Mag Size: 14"
                "Reload: 4.37"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 79"
                "Fire Rate: 1.9"
                "Mag Size: 14"
                "Reload: 4.14"
                ""
                
    OutlawShotgun:item_data = item_data: # アウトローショットガン　お
        Item := item_enum.OutlawShotgun
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
        RarityPriceMap := map:
            rarity_enum.L1_Common => 750
            rarity_enum.L2_Uncommon => 800
            rarity_enum.L3_Rare => 850
            rarity_enum.L4_Epic => 900
            rarity_enum.L5_Legend => 950
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 96"
                "Fire Rate: 1.42"
                "Mag Size: 2"
                "Reload: 2.09"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 102"
                "Fire Rate: 1.42"
                "Mag Size: 2"
                "Reload: 2"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 107"
                "Fire Rate: 1.42"
                "Mag Size: 2"
                "Reload: 1.9"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 112"
                "Fire Rate: 1.42"
                "Mag Size: 2"
                "Reload: 1.8"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 118"
                "Fire Rate: 1.42"
                "Mag Size: 2"
                "Reload: 1.71"
                ""
                
    PumpAndDump:item_data = item_data: # ポンプ&ダンプ　お
        Item := item_enum.PumpAndDump
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
            rarity_enum.L6_Mythic
        RarityPriceMap := map:
            rarity_enum.L1_Common => 800
            rarity_enum.L2_Uncommon => 850
            rarity_enum.L3_Rare => 900
            rarity_enum.L4_Epic => 950
            rarity_enum.L5_Legend => 1000
            rarity_enum.L6_Mythic => 1050
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 81"
                "Fire Rate: 0.95"
                "Mag Size: 4"
                "Reload: 2.04"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 86"
                "Fire Rate: 0.95"
                "Mag Size: 4"
                "Reload: 1.94"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 90"
                "Fire Rate: 0.95"
                "Mag Size: 4"
                "Reload: 1.85"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 94"
                "Fire Rate: 0.95"
                "Mag Size: 4"
                "Reload: 1.76"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 99"
                "Fire Rate: 0.95"
                "Mag Size: 4"
                "Reload: 1.66"
                ""
            rarity_enum.L6_Mythic => array:
                "Dmg: 104"
                "Fire Rate: 0.95"
                "Mag Size: 4"
                "Reload: 1.57"
                ""
                
    CombatSMG:item_data = item_data: # コンバットサブマシンガン　お
        Item := item_enum.CombatSMG
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
            rarity_enum.L6_Mythic
        RarityPriceMap := map:
            rarity_enum.L1_Common => 950
            rarity_enum.L2_Uncommon => 1000
            rarity_enum.L3_Rare => 1050
            rarity_enum.L4_Epic => 1100
            rarity_enum.L5_Legend => 1150
            rarity_enum.L6_Mythic => 1200
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 18"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.64"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 19"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.52"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 20"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.4"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 21"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.28"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 22"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.16"
                ""
            rarity_enum.L6_Mythic => array:
                "Dmg: 23"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.04"
                ""
                
    VeiledPrecisionSMG:item_data = item_data: # ヴェールド プレシジョンSMG　お
        Item := item_enum.VeiledPrecisionSMG
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
        RarityPriceMap := map:
            rarity_enum.L1_Common => 850
            rarity_enum.L2_Uncommon => 900
            rarity_enum.L3_Rare => 950
            rarity_enum.L4_Epic => 1000
            rarity_enum.L5_Legend => 1050
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 15"
                "Fire Rate: 10.3"
                "Mag Size: 21"
                "Reload: 2.26"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 16"
                "Fire Rate: 10.3"
                "Mag Size: 21"
                "Reload: 2.15"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 17"
                "Fire Rate: 10.3"
                "Mag Size: 21"
                "Reload: 2.05"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 18"
                "Fire Rate: 10.3"
                "Mag Size: 21"
                "Reload: 1.95"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 19"
                "Fire Rate: 10.3"
                "Mag Size: 21"
                "Reload: 1.85"
                ""
                
    RapidFireSMG:item_data = item_data: # 速射式サブマシンガン　お
        Item := item_enum.RapidFireSMG
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
            rarity_enum.L6_Mythic
        RarityPriceMap := map:
            rarity_enum.L1_Common => 900
            rarity_enum.L2_Uncommon => 950
            rarity_enum.L3_Rare => 1000
            rarity_enum.L4_Epic => 1050
            rarity_enum.L5_Legend => 1100
            rarity_enum.L6_Mythic => 1150
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 13"
                "Fire Rate: 15"
                "Mag Size: 20"
                "Reload: 1.65"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 14"
                "Fire Rate: 15"
                "Mag Size: 20"
                "Reload: 1.58"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 15"
                "Fire Rate: 15"
                "Mag Size: 20"
                "Reload: 1.5"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 16"
                "Fire Rate: 15"
                "Mag Size: 26"
                "Reload: 1.42"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 17"
                "Fire Rate: 15"
                "Mag Size: 26"
                "Reload: 1.32"
                ""
            rarity_enum.L6_Mythic => array:
                "Dmg: 17"
                "Fire Rate: 15"
                "Mag Size: 26"
                "Reload: 1.27"
                ""
                
    ChargeSMG:item_data = item_data: # チャージサブマシンガン　お
        Item := item_enum.ChargeSMG
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
            rarity_enum.L6_Mythic
        RarityPriceMap := map:
            rarity_enum.L1_Common => 900
            rarity_enum.L2_Uncommon => 950
            rarity_enum.L3_Rare => 1000
            rarity_enum.L4_Epic => 1050
            rarity_enum.L5_Legend => 1100
            rarity_enum.L6_Mythic => 1150
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 15"
                "Fire Rate: 16.82"
                "Mag Size: 30"
                "Reload: 1.76"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 16"
                "Fire Rate: 16.82"
                "Mag Size: 30"
                "Reload: 1.68"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 17"
                "Fire Rate: 16.82"
                "Mag Size: 30"
                "Reload: 1.6"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 18"
                "Fire Rate: 16.82"
                "Mag Size: 30"
                "Reload: 1.52"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 19"
                "Fire Rate: 16.82"
                "Mag Size: 30"
                "Reload: 1.44"
                ""
            rarity_enum.L6_Mythic => array:
                "Dmg: 20"
                "Fire Rate: 16.82"
                "Mag Size: 30"
                "Reload: 1.36"
                ""
                
    StrikerBurstRifle:item_data = item_data: # ストライカーバーストライフル　お
        Item := item_enum.StrikerBurstRifle
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L1_Common
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
            rarity_enum.L6_Mythic
        RarityPriceMap := map:
            rarity_enum.L1_Common => 200
            rarity_enum.L2_Uncommon => 300
            rarity_enum.L3_Rare => 400
            rarity_enum.L4_Epic => 500
            rarity_enum.L5_Legend => 600
            rarity_enum.L6_Mythic => 600
        RarityDescMap := map:
            rarity_enum.L1_Common => array:
                "Dmg: 27"
                "Fire Rate: 3.86"
                "Mag Size: 20"
                "Reload: 2.86"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 29"
                "Fire Rate: 3.86"
                "Mag Size: 20"
                "Reload: 2.73"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 30"
                "Fire Rate: 3.86"
                "Mag Size: 20"
                "Reload: 2.6"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 32"
                "Fire Rate: 3.86"
                "Mag Size: 20"
                "Reload: 2.47"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 33"
                "Fire Rate: 3.86"
                "Mag Size: 20"
                "Reload: 2.34"
                ""
            rarity_enum.L6_Mythic => array:
                "Dmg: 35"
                "Fire Rate: 3.86"
                "Mag Size: 20"
                "Reload: 2.21"
                ""
                
    HoloTwisterAssaultRifle:item_data = item_data: # ホロツイスター アサルトライフル　お
        Item := item_enum.HoloTwisterAssaultRifle
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
                "Dmg: 27"
                "Fire Rate: 5.2"
                "Mag Size: 25"
                "Reload: 2.91"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 29"
                "Fire Rate: 5.2"
                "Mag Size: 25"
                "Reload: 2.78"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 30"
                "Fire Rate: 5.2"
                "Mag Size: 25"
                "Reload: 2.65"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 32"
                "Fire Rate: 5.2"
                "Mag Size: 25"
                "Reload: 2.52"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 33"
                "Fire Rate: 5.2"
                "Mag Size: 25"
                "Reload: 2.38"
                ""
                
    CollateralDamageAssaultRifle:item_data = item_data: # コラテラルダメージ アサルトライフル　お
        Item := item_enum.CollateralDamageAssaultRifle
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
                "Dmg: 15"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.47"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 16"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.36"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 17"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.25"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 18"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.14"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 19"
                "Fire Rate: 12"
                "Mag Size: 32"
                "Reload: 2.03"
                ""
                
    CombatAssaultRifle:item_data = item_data: # コンバットアサルトライフル　お
        Item := item_enum.CombatAssaultRifle
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
                "Dmg: 19"
                "Fire Rate: 9"
                "Mag Size: 35"
                "Reload: 3.41"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 20"
                "Fire Rate: 9"
                "Mag Size: 35"
                "Reload: 3.26"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 21"
                "Fire Rate: 9"
                "Mag Size: 35"
                "Reload: 3.1"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 22"
                "Fire Rate: 9"
                "Mag Size: 35"
                "Reload: 2.94"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 23"
                "Fire Rate: 9"
                "Mag Size: 35"
                "Reload: 2.79"
                ""
                
    TacticalAssaultRifle:item_data = item_data: # タクティカルアサルトライフル　お
        Item := item_enum.TacticalAssaultRifle
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
                "Dmg: 19"
                "Fire Rate: 7"
                "Mag Size: 30"
                "Reload: 2.42"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 20"
                "Fire Rate: 7"
                "Mag Size: 30"
                "Reload: 2.31"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 21"
                "Fire Rate: 7"
                "Mag Size: 30"
                "Reload: 2.2"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 22"
                "Fire Rate: 7"
                "Mag Size: 30"
                "Reload: 2.09"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 23"
                "Fire Rate: 7"
                "Mag Size: 30"
                "Reload: 1.98"
                ""
                
    BoltActionSniperRifle:item_data = item_data: # ボルトアクションスナイパーライフル　お
        Item := item_enum.BoltActionSniperRifle
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
                "Dmg: 99"
                "Fire Rate: 0.75"
                "Mag Size: 1"
                "Reload: 3.3"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 105"
                "Fire Rate: 0.75"
                "Mag Size: 1"
                "Reload: 3.15"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 110"
                "Fire Rate: 0.75"
                "Mag Size: 1"
                "Reload: 3"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 116"
                "Fire Rate: 0.75"
                "Mag Size: 1"
                "Reload: 2.5"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 121"
                "Fire Rate: 0.75"
                "Mag Size: 1"
                "Reload: 2.35"
                ""
                
    HeavySniperRifle:item_data = item_data: # ヘビースナイパーライフル　お
        Item := item_enum.HeavySniperRifle
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
            rarity_enum.L6_Mythic
        RarityPriceMap := map:
            rarity_enum.L4_Epic => 500
            rarity_enum.L5_Legend => 600
            rarity_enum.L6_Mythic => 600
        RarityDescMap := map:
            rarity_enum.L4_Epic => array:
                "Dmg: 126"
                "Fire Rate: 0.64"
                "Mag Size: 1"
                "Reload: 3.8"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 132"
                "Fire Rate: 0.64"
                "Mag Size: 1"
                "Reload: 3.6"
                ""
            rarity_enum.L6_Mythic => array:
                "Dmg: 138"
                "Fire Rate: 0.64"
                "Mag Size: 1"
                "Reload: 3.4"
                ""
                
    LeverActionRifle:item_data = item_data: # レバーアクションライフル　お
        Item := item_enum.LeverActionRifle
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L2_Uncommon
            rarity_enum.L3_Rare
            rarity_enum.L4_Epic
            rarity_enum.L5_Legend
        RarityPriceMap := map:
            rarity_enum.L2_Uncommon => 300
            rarity_enum.L3_Rare => 400
            rarity_enum.L4_Epic => 500
            rarity_enum.L5_Legend => 600
        RarityDescMap := map:
            rarity_enum.L2_Uncommon => array:
                "Dmg: 67"
                "Fire Rate: 1.25"
                "Mag Size: 9"
                "Reload: 6.3"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 70"
                "Fire Rate: 1.25"
                "Mag Size: 9"
                "Reload: 6"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 74"
                "Fire Rate: 1.25"
                "Mag Size: 9"
                "Reload: 5.7"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 77"
                "Fire Rate: 1.25"
                "Mag Size: 9"
                "Reload: 5.4"
                ""
                
    RocketLauncher:item_data = item_data: # ロケットランチャー　お
        Item := item_enum.RocketLauncher
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
                "Dmg: 70"
                "Fire Rate: 0.75"
                "Mag Size: 1"
                "Reload: 4.68"
                ""
            rarity_enum.L2_Uncommon => array:
                "Dmg: 85"
                "Fire Rate: 0.75"
                "Mag Size: 1"
                "Reload: 4.14"
                ""
            rarity_enum.L3_Rare => array:
                "Dmg: 100"
                "Fire Rate: 0.75"
                "Mag Size: 1"
                "Reload: 3.6"
                ""
            rarity_enum.L4_Epic => array:
                "Dmg: 115"
                "Fire Rate: 0.75"
                "Mag Size: 1"
                "Reload: 3.06"
                ""
            rarity_enum.L5_Legend => array:
                "Dmg: 130"
                "Fire Rate: 0.75"
                "Mag Size: 1"
                "Reload: 2.52"
                ""
                
    FireOniMask:item_data = item_data: # 火の鬼の仮面　お
        Item := item_enum.FireOniMask
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
                "Dmg: 100"
                "Ammo Capacity: 2"
                "Uses: 8"
                "Cooldown: 8 sec"
                ""
            rarity_enum.L6_Mythic => array:
                "Dmg: 100"
                "Ammo Capacity: 2"
                "Uses: 16"
                "Cooldown: 8 sec"
                ""
                
    TheKneecapper:item_data = item_data: # ニーキャッパー　お
        Item := item_enum.TheKneecapper
        CanBuyMultiple := false
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L4_Epic
        RarityPriceMap := map:
            rarity_enum.L4_Epic => 500
        RarityDescMap := map:
            rarity_enum.L4_Epic => array:
                "Dmg:"
                "30 35 20 20 55"
                "Charge Dmg:"
                "Min: 60"
                "Max: 90"
                
    ThornesVampiricBlade:item_data = item_data: # ソーンのヴァンパイアブレイド　お
        Item := item_enum.ThornesVampiricBlade
        CanBuyMultiple := false
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L6_Mythic
        RarityPriceMap := map:
            rarity_enum.L6_Mythic => 1000
        RarityDescMap := map:
            rarity_enum.L6_Mythic => array:
                "Dmg: 35"
                "Dash Dmg: 60"
                "Heal:"
                "7(On Attack)"
                "12(On Dash Attack)"
         
    TyphoonBlade:item_data = item_data: # タイフーン・ブレイド　お
        Item := item_enum.TyphoonBlade
        CanBuyMultiple := false
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L4_Epic
            rarity_enum.L6_Mythic
        RarityPriceMap := map:
            rarity_enum.L4_Epic => 500
            rarity_enum.L6_Mythic => 1000
        RarityDescMap := map:
            rarity_enum.L4_Epic => array:
                "Dmg:"
                "30(Slash)"
                "70(Slam)"
                "90(Cyclone Slash)"
                "Cooldown: 9 sec"
            rarity_enum.L6_Mythic => array:
                "Dmg:"
                "30(Slash)"
                "70(Slam)"
                "90(Cyclone Slash)"
                "Cooldown: 6.5 sec"
                
    Grappler:item_data = item_data: # グラップラー　お
        Item := item_enum.Grappler
        CanBuyMultiple := true
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L4_Epic
        RarityPriceMap := map:
            rarity_enum.L4_Epic => 500
        RarityDescMap := map:
            rarity_enum.L4_Epic => array:
                "Uses: 10"
                "Cooldown: 1.26 sec"
                ""
                ""
                ""

    GrappleGlove:item_data = item_data: # グラップルグローブ　お
        Item := item_enum.GrappleGlove
        CanBuyMultiple := false
        MaxCapacity := 1
        Rarities := array:
            rarity_enum.L4_Epic
        RarityPriceMap := map:
            rarity_enum.L4_Epic => 500
        RarityDescMap := map:
            rarity_enum.L4_Epic => array:
                "Uses: 30"
                ""
                ""
                ""
                ""


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
