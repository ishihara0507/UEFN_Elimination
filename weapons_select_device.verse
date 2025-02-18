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

#########################################################
### 武器の購入や返却、手持ちの武器などを管理するプログラム ###
#########################################################

weapon_enum := enum<persistable>:
    DMR_L1
    DMR_L2
    DMR_L3
    DMR_L4
    DMR_L5

(WE:weapon_enum).ToTexture():texture= #フォルダ名.テクスチャ名
    case(WE):
        weapon_enum.DMR_L1 => WeaponTextures.DMR_L1
        _ => WeaponTextures.DMR_L1

(WE:weapon_enum).ToIndex():int= #フォルダ名.テクスチャ名
    case(WE):
        weapon_enum.DMR_L1 => 0
        weapon_enum.DMR_L2 => 1
        weapon_enum.DMR_L3 => 2
        weapon_enum.DMR_L4 => 3
        _ => 4

# weapon_enumの文字列をstringに変換して返すプロパティ（デバッグ用）
(WE:weapon_enum).ToString():string=
    case(WE):
        weapon_enum.DMR_L1 => "DMR_L1"
        weapon_enum.DMR_L2 => "DMR_L2"
        weapon_enum.DMR_L3 => "DMR_L3"
        weapon_enum.DMR_L4 => "DMR_L4"
        weapon_enum.DMR_L5 => "DMR_L5"

weapon_data := class<concrete>:
    @editable
    Weapon:weapon_enum = weapon_enum.DMR_L1

    @editable
    RequireGolds:int = 0

    @editable
    VendingMachine:vending_machine_device = vending_machine_device{}

    @editable
    CondBtn:conditional_button_device = conditional_button_device{}

    var FiveGoldsGranter:item_granter_device = item_granter_device{}

    var WeaponsSelectDevice:weapons_select_device = weapons_select_device{}

    # WeaponsSelectDeviceのWeaponPlayerMapに、このインスタンスの武器を追加する関数
    AddWeaponsPlayerMap(Agent:agent):void=
        if(Player := player[Agent]):
            if(not WeaponsSelectDevice.WeaponsPlayerMap[Player]): # 初期化されていなかったら、mapにプレイヤーを登録する
                if. set WeaponsSelectDevice.WeaponsPlayerMap[Player] = array{}
            if(WeaponsSelectDevice.WeaponsPlayerMap[Player].Length < 5):
                if. set WeaponsSelectDevice.WeaponsPlayerMap[Player] += array{Weapon}

            WeaponsSelectDevice.ChangePlayerClass(Agent)
    
    # WeaponsSelectDeviceのWeaponPlayerMapから、このインスタンスの武器を削除する関数
    RemoveWeaponsPlayerMap(Agent:agent):void=
        if(Player := player[Agent]):
            var NewWeaponsPreset:[]weapon_enum = array{}
            var IsRemoved:logic = false
            for(W:WeaponsSelectDevice.WeaponsPlayerMap[Player]):
                if(not W = Weapon or IsRemoved?):
                    set NewWeaponsPreset += array{W}
                else if(IsRemoved = false):
                    set IsRemoved = true
            if. set WeaponsSelectDevice.WeaponsPlayerMap[Player] = NewWeaponsPreset

            WeaponsSelectDevice.ChangePlayerClass(Agent)

    # プレイヤーにゴールドを返す関数
    ReturnGolds(Agent:agent):void=
        for(Index := 1..Quotient[RequireGolds, 5]): # RequireGolds = 10 だったら2回ループする（10ゴールド増やす）
            FiveGoldsGranter.GrantItem(Agent)

    # CondBtnが押されたときに実行する処理（上の２つの関数）をひとつにまとめた関数
    ActivateCondBtn(Agent:agent):void=
        ReturnGolds(Agent)
        RemoveWeaponsPlayerMap(Agent)

weapons_select_device := class(creative_device):

    @editable
    WeaponDatas:[]weapon_data = array{} # このゲームで使用できる武器の情報を保持する配列

    @editable
    HoldingWeaponReturnTriggers:[]trigger_device = array{} # 手に持っている武器を返却するためのトリガー
    
    @editable
    AllWeaponsReturnTriggers:[]trigger_device = array{} # すべての武器を返却するためのトリガー

    @editable
    FiveGoldsGranter:item_granter_device = item_granter_device{} # ゴールドを５枚与えるために使用する

    @editable
    MaxGoldsGranter:item_granter_device = item_granter_device{} # ゴールドを初期値に戻すため

    @editable
    ItemRemover:item_remover_device = item_remover_device{} # すべての武器を削除するため

    @editable
    NoneClassSelector:class_and_team_selector_device = class_and_team_selector_device{} # 「クラスなし」に変更するクラスセレクター（クラスなしは自販機を実行できる）
    
    @editable
    OneClassSelector:class_and_team_selector_device = class_and_team_selector_device{} # 「クラス１」に変更するクラスセレクター（クラス１は自販機を実行できない）

    @editable
    DebugTrigger:trigger_device = trigger_device{}
    
    var WeaponsPlayerMap:[player][]weapon_enum = map{} # 各プレイヤーが現在保持している武器を記憶しておくmap

    OnBegin<override>()<suspends>:void=
        for(WeaponData:WeaponDatas):
            set WeaponData.FiveGoldsGranter = FiveGoldsGranter
            set WeaponData.WeaponsSelectDevice = Self
            WeaponData.CondBtn.ActivatedEvent.Subscribe(WeaponData.ActivateCondBtn)
            WeaponData.VendingMachine.ItemSpawnedEvent.Subscribe(WeaponData.AddWeaponsPlayerMap)

        for(HoldingWeaponReturnTrigger:HoldingWeaponReturnTriggers):
            HoldingWeaponReturnTrigger.TriggeredEvent.Subscribe(HoldingWeaponReturn)

        for(AllWeaponsReturnTrigger:AllWeaponsReturnTriggers):
            AllWeaponsReturnTrigger.TriggeredEvent.Subscribe(AllWeaponsReturn)

        DebugTrigger.TriggeredEvent.Subscribe(OnDebugTriggered) # デバッグ用

    # 特定の武器（プレイヤーが手に持っている武器）を返却するための関数
    HoldingWeaponReturn(OAgent:?agent):void=
        if(Agent := OAgent?):
            for(WeaponData:WeaponDatas):
                WeaponData.CondBtn.Activate(Agent)

    # プレイヤーが持っているすべての武器を返却する関数
    AllWeaponsReturn(OAgent:?agent):void=
        if(Agent := OAgent?, Player := player[Agent]):
            ItemRemover.Remove(Agent)
            MaxGoldsGranter.GrantItem(Agent)
            if. set WeaponsPlayerMap[Player] = array{}
            
            ChangePlayerClass(Agent)

    # プレイヤーのクラスを変更する関数（クラスなし: 自販機を使える, クラス１: 自販機を使えない）
    ChangePlayerClass(Agent:agent):void=
        if(Player := player[Agent], Len := WeaponsPlayerMap[Player].Length):
            if(Len < 5):
                NoneClassSelector.ChangeClass(Agent) # クラスなしに設定
            else:
                OneClassSelector.ChangeClass(Agent) # クラス１に設定

    # WeaponsPlayerMapの中身を表示する関数（デバッグ用）
    OnDebugTriggered(OAgent:?agent):void=
        if(Agent := OAgent?, Player := player[Agent], Weapons := WeaponsPlayerMap[Player]):
            if(not Weapons.Length = 0):
                for(Index->Weapon:Weapons):
                    Print("{Index}番目: {Weapon.ToString()}\n")
            else:
                Print("空です")
        else:
            Print("そのプレイヤーには、まだ WeaponsPlayerMap が登録されていません")