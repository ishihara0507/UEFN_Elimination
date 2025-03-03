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
    WeaponCondBtn:conditional_button_device = conditional_button_device{}

    var GoldCondBtn:conditional_button_device = conditional_button_device{} # ゴールドの枚数を取得するためのやつ
    var GoldHudDevice:hud_message_device = hud_message_device{}

    var GoldsGranter:item_granter_device = item_granter_device{} # 武器返却時にゴールドを返すためのグランター

    var WeaponsSelectDevice:weapons_select_device = weapons_select_device{}

    # WeaponsSelectDeviceのWeaponPlayerMapに、このインスタンスの武器を追加する関数
    AddWeaponsPlayerMap(Agent:agent):void=
        if(Player := player[Agent]):
            if(not WeaponsSelectDevice.WeaponsPlayerMap[Player]): # 初期化されていなかったら、mapにプレイヤーを登録する
                if. set WeaponsSelectDevice.WeaponsPlayerMap[Player] = array{}
            if(WeaponsSelectDevice.WeaponsPlayerMap[Player].Length < 5):
                if. set WeaponsSelectDevice.WeaponsPlayerMap[Player] += array{Weapon}

            WeaponsSelectDevice.ChangePlayerClass(Agent)
            spawn{ShowGoldHud(Agent)}
    
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
        if(Index := Quotient[RequireGolds, 5] - 1):
            GoldsGranter.GrantItemIndex(Agent, Index)
            
    # プレイヤーのゴールド枚数を表示・更新する関数
    ShowGoldHud(Agent:agent)<suspends>:void=
        Sleep(0.0)
        GoldNum := GoldCondBtn.GetItemCount(Agent, 0)
        GoldHudDevice.Show(Agent, S2M("{GoldNum}"))

    # CondBtnが押されたときに実行する処理（上の３つの関数）をひとつにまとめた関数
    ActivateCondBtn(Agent:agent):void=
        ReturnGolds(Agent)
        RemoveWeaponsPlayerMap(Agent)
        spawn{ShowGoldHud(Agent)}

weapons_select_device := class(creative_device):

    @editable
    WeaponDatas:[]weapon_data = array{} # このゲームで使用できる武器の情報を保持する配列

    @editable
    HoldingWeaponReturnTriggers:[]trigger_device = array{} # 手に持っている武器を返却するためのトリガー
    
    @editable
    AllWeaponsReturnTriggers:[]trigger_device = array{} # すべての武器を返却するためのトリガー
    
    @editable
    Mutator:mutator_zone_device = mutator_zone_device{} # 武器選択エリアの入口兼出口に設置するミューテーターゾーン

    @editable
    GoldsGranter:item_granter_device = item_granter_device{} # 武器返却時にゴールドを返すためのグランター

    @editable
    MaxGoldsGranter:item_granter_device = item_granter_device{} # ゴールドを初期値に戻すため

    @editable
    ItemRemover:item_remover_device = item_remover_device{} # すべての武器を削除するため

    @editable
    NoneClassSelector:class_and_team_selector_device = class_and_team_selector_device{} # 「クラスなし」に変更するクラスセレクター（クラスなしは自販機を実行できる）
    
    @editable
    OneClassSelector:class_and_team_selector_device = class_and_team_selector_device{} # 「クラス１」に変更するクラスセレクター（クラス１は自販機を実行できない）

    @editable
    GoldHudDevice:hud_message_device = hud_message_device{} # 所持ゴールドの枚数を表示するHUDデバイス
    @editable
    GoldCondBtn:conditional_button_device = conditional_button_device{} # プレイヤーの所持ゴールドの枚数を取得するための条件付きボタン
    
    @editable
    DebugTrigger:trigger_device = trigger_device{} # ログでそのプレイヤーのWeaponsPlayerMapの値を表示するトリガー
    
    var WeaponsPlayerMap:[player][]weapon_enum = map{} # 各プレイヤーが現在保持している武器を記憶しておくmap
    
    var PlayerInEreaMap:[player]logic = map{} # プレイヤーが武器選択エリアに入っているかいなかを保持するmap

    OnBegin<override>()<suspends>:void=
        for(WeaponData:WeaponDatas):
            set WeaponData.GoldCondBtn = GoldCondBtn
            set WeaponData.GoldHudDevice = GoldHudDevice
            set WeaponData.GoldsGranter = GoldsGranter
            set WeaponData.WeaponsSelectDevice = Self
            WeaponData.WeaponCondBtn.ActivatedEvent.Subscribe(WeaponData.ActivateCondBtn)
            WeaponData.VendingMachine.ItemSpawnedEvent.Subscribe(WeaponData.AddWeaponsPlayerMap)

        for(HoldingWeaponReturnTrigger:HoldingWeaponReturnTriggers):
            HoldingWeaponReturnTrigger.TriggeredEvent.Subscribe(HoldingWeaponReturn)

        for(AllWeaponsReturnTrigger:AllWeaponsReturnTriggers):
            AllWeaponsReturnTrigger.TriggeredEvent.Subscribe(AllWeaponsReturn)

        Mutator.AgentEntersEvent.Subscribe(EnterMutator)

        DebugTrigger.TriggeredEvent.Subscribe(OnDebugTriggered) # デバッグ用

    # 入口兼出口のミューテーターゾーンに入ったときに実行する関数
    EnterMutator(Agent:agent):void=
        if(Player := player[Agent]):
            if(InErea := PlayerInEreaMap[Player], InErea?): # すでに入っていたら（出るとき）
                GoldHudDevice.Hide(Agent)
                ItemRemover.Remove(Agent)
                if. set PlayerInEreaMap[Player] = false
            else: # まだ入っていなかったら（入るとき）
                ItemRemover.Remove(Agent)
                MaxGoldsGranter.GrantItem(Agent)
                spawn{ShowGoldHud(Agent)}
                if. set PlayerInEreaMap[Player] = true

    # プレイヤーのゴールド枚数を表示・更新する関数
    ShowGoldHud(Agent:agent)<suspends>:void=
        Sleep(0.0) # 一瞬待たないとGrantItemの処理が完了するまえに以下の処理が実行されちゃう
        GoldNum := GoldCondBtn.GetItemCount(Agent, 0)
        GoldHudDevice.Show(Agent, S2M("{GoldNum}"))

    # 特定の武器（プレイヤーが手に持っている武器）を返却するための関数
    HoldingWeaponReturn(OAgent:?agent):void=
        if(Agent := OAgent?):
            for(WeaponData:WeaponDatas):
                WeaponData.WeaponCondBtn.Activate(Agent)

    # プレイヤーが持っているすべての武器を返却する関数
    AllWeaponsReturn(OAgent:?agent):void=
        if(Agent := OAgent?, Player := player[Agent]):
            ItemRemover.Remove(Agent)
            MaxGoldsGranter.GrantItem(Agent)
            if. set WeaponsPlayerMap[Player] = array{}
            spawn{ShowGoldHud(Agent)}
            
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