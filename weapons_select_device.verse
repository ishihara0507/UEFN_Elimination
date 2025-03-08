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

#########################################################
### 武器の購入や返却、手持ちの武器などを管理するプログラム ###
#########################################################

weapon_enum := enum<persistable>:
    # ポンプショットガン
    PumpShotgun_L1
    PumpShotgun_L2
    PumpShotgun_L3
    PumpShotgun_L4
    PumpShotgun_L5
    # サイドアームピストル
    SideArmPistol_L1
    SideArmPistol_L2
    SideArmPistol_L3
    SideArmPistol_L4
    SideArmPistol_L5
    # サブマシンガン
    SubmachineGun_L1
    SubmachineGun_L2
    SubmachineGun_L3
    SubmachineGun_L4
    SubmachineGun_L5
    # アサルトライフル
    AssaultRifle_L1
    AssaultRifle_L2
    AssaultRifle_L3
    AssaultRifle_L4
    AssaultRifle_L5
    # ファルコンアイ スナイパー
    FalconEyeSniper_L1
    FalconEyeSniper_L2
    FalconEyeSniper_L3
    FalconEyeSniper_L4
    FalconEyeSniper_L5
    # ロケットランチャー
    RocketLauncher_L1
    RocketLauncher_L2
    RocketLauncher_L3
    RocketLauncher_L4
    RocketLauncher_L5

(WE:weapon_enum).ToTexture():texture= #フォルダ名.テクスチャ名
    case(WE):
        # ポンプショットガン
        weapon_enum.PumpShotgun_L1 => WeaponTextures.PumpShotgun_L1
        weapon_enum.PumpShotgun_L2 => WeaponTextures.PumpShotgun_L2
        weapon_enum.PumpShotgun_L3 => WeaponTextures.PumpShotgun_L3
        weapon_enum.PumpShotgun_L4 => WeaponTextures.PumpShotgun_L4
        weapon_enum.PumpShotgun_L5 => WeaponTextures.PumpShotgun_L5
        # サイドアームピストル
        weapon_enum.SideArmPistol_L1 => WeaponTextures.SideArmPistol_L1
        weapon_enum.SideArmPistol_L2 => WeaponTextures.SideArmPistol_L2
        weapon_enum.SideArmPistol_L3 => WeaponTextures.SideArmPistol_L3
        weapon_enum.SideArmPistol_L4 => WeaponTextures.SideArmPistol_L4
        weapon_enum.SideArmPistol_L5 => WeaponTextures.SideArmPistol_L5
        # サブマシンガン
        weapon_enum.SubmachineGun_L1 => WeaponTextures.SubmachineGun_L1
        weapon_enum.SubmachineGun_L2 => WeaponTextures.SubmachineGun_L2
        weapon_enum.SubmachineGun_L3 => WeaponTextures.SubmachineGun_L3
        weapon_enum.SubmachineGun_L4 => WeaponTextures.SubmachineGun_L4
        weapon_enum.SubmachineGun_L5 => WeaponTextures.SubmachineGun_L5
        # アサルトライフル
        weapon_enum.AssaultRifle_L1 => WeaponTextures.AssaultRifle_L1
        weapon_enum.AssaultRifle_L2 => WeaponTextures.AssaultRifle_L2
        weapon_enum.AssaultRifle_L3 => WeaponTextures.AssaultRifle_L3
        weapon_enum.AssaultRifle_L4 => WeaponTextures.AssaultRifle_L4
        weapon_enum.AssaultRifle_L5 => WeaponTextures.AssaultRifle_L5
        # ファルコンアイスナイパー
        weapon_enum.FalconEyeSniper_L1 => WeaponTextures.FalconEyeSniper_L1
        weapon_enum.FalconEyeSniper_L2 => WeaponTextures.FalconEyeSniper_L2
        weapon_enum.FalconEyeSniper_L3 => WeaponTextures.FalconEyeSniper_L3
        weapon_enum.FalconEyeSniper_L4 => WeaponTextures.FalconEyeSniper_L4
        weapon_enum.FalconEyeSniper_L5 => WeaponTextures.FalconEyeSniper_L5
        # ロケットランチャー
        weapon_enum.RocketLauncher_L1 => WeaponTextures.RocketLauncher_L1
        weapon_enum.RocketLauncher_L2 => WeaponTextures.RocketLauncher_L2
        weapon_enum.RocketLauncher_L3 => WeaponTextures.RocketLauncher_L3
        weapon_enum.RocketLauncher_L4 => WeaponTextures.RocketLauncher_L4
        weapon_enum.RocketLauncher_L5 => WeaponTextures.RocketLauncher_L5

(WE:weapon_enum).ToIndex():int= #フォルダ名.テクスチャ名
    case(WE):
        # ポンプショットガン
        weapon_enum.PumpShotgun_L1 => 0
        weapon_enum.PumpShotgun_L2 => 1
        weapon_enum.PumpShotgun_L3 => 2
        weapon_enum.PumpShotgun_L4 => 3
        weapon_enum.PumpShotgun_L5 => 4
        # サイドアームピストル
        weapon_enum.SideArmPistol_L1 => 5
        weapon_enum.SideArmPistol_L2 => 6
        weapon_enum.SideArmPistol_L3 => 7
        weapon_enum.SideArmPistol_L4 => 8
        weapon_enum.SideArmPistol_L5 => 9
        # サブマシンガン
        weapon_enum.SubmachineGun_L1 => 10
        weapon_enum.SubmachineGun_L2 => 11
        weapon_enum.SubmachineGun_L3 => 12
        weapon_enum.SubmachineGun_L4 => 13
        weapon_enum.SubmachineGun_L5 => 14
        # アサルトライフル
        weapon_enum.AssaultRifle_L1 => 15
        weapon_enum.AssaultRifle_L2 => 16
        weapon_enum.AssaultRifle_L3 => 17
        weapon_enum.AssaultRifle_L4 => 18
        weapon_enum.AssaultRifle_L5 => 19
        # ファルコンアイスナイパー
        weapon_enum.FalconEyeSniper_L1 => 20
        weapon_enum.FalconEyeSniper_L2 => 21
        weapon_enum.FalconEyeSniper_L3 => 22
        weapon_enum.FalconEyeSniper_L4 => 23
        weapon_enum.FalconEyeSniper_L5 => 24
        # ロケットランチャー
        weapon_enum.RocketLauncher_L1 => 25
        weapon_enum.RocketLauncher_L2 => 26
        weapon_enum.RocketLauncher_L3 => 27
        weapon_enum.RocketLauncher_L4 => 28
        weapon_enum.RocketLauncher_L5 => 29

# weapon_enumの文字列をstringに変換して返すプロパティ（デバッグ用）
(WE:weapon_enum).ToString():string=
    case(WE):
        # ポンプショットガン
        weapon_enum.PumpShotgun_L1 => "PumpShotgun_L1"
        weapon_enum.PumpShotgun_L2 => "PumpShotgun_L2"
        weapon_enum.PumpShotgun_L3 => "PumpShotgun_L3"
        weapon_enum.PumpShotgun_L4 => "PumpShotgun_L4"
        weapon_enum.PumpShotgun_L5 => "PumpShotgun_L5"
        # サイドアームピストル
        weapon_enum.SideArmPistol_L1 => "SideArmPistol_L1"
        weapon_enum.SideArmPistol_L2 => "SideArmPistol_L2"
        weapon_enum.SideArmPistol_L3 => "SideArmPistol_L3"
        weapon_enum.SideArmPistol_L4 => "SideArmPistol_L4"
        weapon_enum.SideArmPistol_L5 => "SideArmPistol_L5"
        # サブマシンガン
        weapon_enum.SubmachineGun_L1 => "SubmachineGun_L1"
        weapon_enum.SubmachineGun_L2 => "SubmachineGun_L2"
        weapon_enum.SubmachineGun_L3 => "SubmachineGun_L3"
        weapon_enum.SubmachineGun_L4 => "SubmachineGun_L4"
        weapon_enum.SubmachineGun_L5 => "SubmachineGun_L5"
        # アサルトライフル
        weapon_enum.AssaultRifle_L1 => "AssaultRifle_L1"
        weapon_enum.AssaultRifle_L2 => "AssaultRifle_L2"
        weapon_enum.AssaultRifle_L3 => "AssaultRifle_L3"
        weapon_enum.AssaultRifle_L4 => "AssaultRifle_L4"
        weapon_enum.AssaultRifle_L5 => "AssaultRifle_L5"
        # ファルコンアイスナイパー
        weapon_enum.FalconEyeSniper_L1 => "FalconEyeSniper_L1"
        weapon_enum.FalconEyeSniper_L2 => "FalconEyeSniper_L2"
        weapon_enum.FalconEyeSniper_L3 => "FalconEyeSniper_L3"
        weapon_enum.FalconEyeSniper_L4 => "FalconEyeSniper_L4"
        weapon_enum.FalconEyeSniper_L5 => "FalconEyeSniper_L5"
        # ロケットランチャー
        weapon_enum.RocketLauncher_L1 => "RocketLauncher_L1"
        weapon_enum.RocketLauncher_L2 => "RocketLauncher_L2"
        weapon_enum.RocketLauncher_L3 => "RocketLauncher_L3"
        weapon_enum.RocketLauncher_L4 => "RocketLauncher_L4"
        weapon_enum.RocketLauncher_L5 => "RocketLauncher_L5"

weapon_data := class<concrete>:
    @editable
    Weapon:weapon_enum = weapon_enum.PumpShotgun_L1

    @editable
    RequireGolds:int = 0

    @editable
    VendingMachine:vending_machine_device = vending_machine_device{}

    @editable
    WeaponCondBtn:conditional_button_device = conditional_button_device{}

    var GoldCondBtn:conditional_button_device = conditional_button_device{} # ゴールドの枚数を取得するためのやつ
    var GoldHudDevice:hud_message_device = hud_message_device{}

    var GoldsGranter:item_granter_device = item_granter_device{} # 武器返却時にゴールドを返すためのグランター
    var GoldsIndexArray:[]int = array{} # GoldsGranterの何番目が何枚ゴールドを返すのかを特定するための整数配列

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
        for(Index -> GoldsNum : GoldsIndexArray, GoldsNum = RequireGolds):
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
    EnterMutator:mutator_zone_device = mutator_zone_device{} # 武器選択エリアの入口側に設置するミューテーターゾーン
    @editable
    ExitMutator:mutator_zone_device = mutator_zone_device{} # 武器選択エリアの入口側に設置するミューテーターゾーン
    @editable
    Barrier:barrier_device = barrier_device{} # 武器選択エリアのミューテーターゾーンの間に設置するバリア

    @editable
    GoldsGranter:item_granter_device = item_granter_device{} # 武器返却時にゴールドを返すためのグランター
    @editable
    GoldsIndexArray:[]int = array{} # GoldsGranterの何番目が何枚ゴールドを返すのかを特定するための整数配列

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

    MaxGolds:int = 1000 # ゴールドの最大枚数（最初に与えられるゴールドの枚数）

    OnBegin<override>()<suspends>:void=
        for(WeaponData:WeaponDatas):
            set WeaponData.GoldCondBtn = GoldCondBtn
            set WeaponData.GoldHudDevice = GoldHudDevice
            set WeaponData.GoldsGranter = GoldsGranter
            set WeaponData.GoldsIndexArray = GoldsIndexArray
            set WeaponData.WeaponsSelectDevice = Self
            WeaponData.WeaponCondBtn.ActivatedEvent.Subscribe(WeaponData.ActivateCondBtn)
            WeaponData.VendingMachine.ItemSpawnedEvent.Subscribe(WeaponData.AddWeaponsPlayerMap)

        for(HoldingWeaponReturnTrigger:HoldingWeaponReturnTriggers):
            HoldingWeaponReturnTrigger.TriggeredEvent.Subscribe(HoldingWeaponReturn)

        for(AllWeaponsReturnTrigger:AllWeaponsReturnTriggers):
            AllWeaponsReturnTrigger.TriggeredEvent.Subscribe(AllWeaponsReturn)

        EnterMutator.AgentEntersEvent.Subscribe(OnEnterMutator)
        ExitMutator.AgentEntersEvent.Subscribe(OnExitMutatorHandler)

        DebugTrigger.TriggeredEvent.Subscribe(OnDebugTriggered) # デバッグ用

    # 入口側のミューテーターゾーンに入ったときに実行する関数
    OnEnterMutator(Agent:agent):void=
        # 武器選択エリアから出る場合と、武器選択エリアにいるときに試合が始まって、再度武器選択エリアに入る場合に実行される
        if(Player := player[Agent]):
            if. set WeaponsPlayerMap[Player] = array{} # 手持ち武器の管理配列を初期化
            if. set PlayerInEreaMap[Player] = false

        Barrier.AddToIgnoreList(Agent) # バリアを通れるようにする
        ItemRemover.Remove(Agent)

    # 出口側のミューテーターゾーンに入ったときに実行する関数
    OnExitMutatorHandler(Agent:agent):void=
        spawn{OnExitMutator(Agent)}

    OnExitMutator(Agent:agent)<suspends>:void=
        ClickEvent:event(logic) = event(logic){}

        if(Player := player[Agent]):
            if(PlayerInEreaMap[Player]?): # すでに入っていたら（出るとき）
                spawn{ShowExitConfirmation(Player, ClickEvent)}
                ExitConfirmed := ClickEvent.Await()
                if(ExitConfirmed?):
                    GoldHudDevice.Hide(Agent)
                    Barrier.AddToIgnoreList(Agent) # バリアを通れるようにする
            else: # まだ入っていなかったら（入るとき）
                Barrier.RemoveFromIgnoreList(Agent)
                if. set PlayerInEreaMap[Player] = true
                MaxGoldsGranter.GrantItem(Agent)
                spawn{ShowGoldHud(Agent)}

    # 武器選択エリアから出ていいかを確認するUIを付与する関数
    ShowExitConfirmation(Player:player, ClickEvent:event(logic))<suspends>:void=
        ConfirmText := text_block{DefaultText:=S2M("プリセット登録は行いましたか？\nこのエリアから出ると手持ちのアイテムは削除されます。\nHave you saved your weapon presets?\nItems will be deleted once you leave this area."), DefaultJustification := text_justification.Center}
        YesBtn := button_loud{DefaultText:=S2M("Yes")}
        NoBtn := button_loud{DefaultText:=S2M("No")}

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
                    Widget := YesBtn
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets := margin{Left := -175.0, Top := 0.0, Right := 250.0, Bottom := 100.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := false
                    Widget := NoBtn
      
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(ConfirmWidget, player_ui_slot{InputMode := ui_input_mode.All})
            race:
                block:
                    YesBtn.OnClick().Await()
                    ClickEvent.Signal(true)
                block:
                    NoBtn.OnClick().Await()
                    ClickEvent.Signal(false)
            PlayerUI.RemoveWidget(ConfirmWidget)

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