using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org }
using { /Verse.org/Random }

# アイテムグランターと設定されたアイテムの数を紐づけるための構造体
granter_item_num := struct<concrete>:
    @editable
    ItemGranter:item_granter_device = item_granter_device{}

    @editable
    ItemCount:int = 0 # そのアイテムグランターに設定されているアイテムの数


gacha_device := class(creative_device):

    @editable
    ItemGranters_Pistol:[]granter_item_num = array{} # ピストル
    @editable
    ItemGranters_ShutGun:[]granter_item_num = array{} # ショットガン
    @editable
    ItemGranters_SMG:[]granter_item_num = array{} # SMG
    @editable
    ItemGranters_AR:[]granter_item_num = array{} # AR
    @editable
    ItemGranters_Sniper:[]granter_item_num = array{} # スナイパー
    @editable
    ItemGranters_Marksman:[]granter_item_num = array{} # マークスマンライフル
    @editable
    ItemGranters_Bow:[]granter_item_num = array{} # 弓
    @editable
    ItemGranters_Crossbow:[]granter_item_num = array{} # クロスボウ
    @editable
    ItemGranters_BombWeapon:[]granter_item_num = array{} # 爆弾武器
    @editable
    ItemGranters_OtherWeapon:[]granter_item_num = array{} # その他の武器
    @editable
    ItemGranters_Item:[]granter_item_num = array{} # アイテム
    
    @editable
    InputTriggerDevice:input_trigger_device = input_trigger_device{}

    @editable
    ShowGoldHud:hud_message_device = hud_message_device{}
    @editable
    AnimGoldHud:hud_message_device = hud_message_device{}
    @editable
    NotEnoughGoldHud:hud_message_device = hud_message_device{}

    # 練習エリアの出入り口に設置するミューテーターゾーン
    @editable
    ShootingEnterMutator:mutator_zone_device = mutator_zone_device{}
    @editable
    ShootingExitMutator:mutator_zone_device = mutator_zone_device{}

    # 栄誉の仕掛け
    @editable
    GachaXPDevice:accolades_device = accolades_device{}
    @editable
    PulledMythicXPDevice:accolades_device = accolades_device{}

    GachaCost:int = 1000 # ガチャを一回引くのに必要な金額

    var AllItemGranters:[]granter_item_num = array{} # すべてのアイテムグランターを保持
    var AllItemCount:int = 0 # すべてのアイテムグランターに設定されているアイテムの総数

    RarityCount:int = 7 # レアリティの数
    RarityProbs:[]int = array: # リアリティごとに出る確率を変える
        35 # Common
        25 # Uncommon
        15 # Rare
        10 # Epic
        7  # Legendary
        3  # Mythic
        5  # Exotic
    var ProbArray:[]int = array{}

    var RarityGranters:[][]granter_item_num = array:
        array{} # Common
        array{} # Uncommon
        array{} # Rare
        array{} # Epic
        array{} # Legendary
        array{} # Mythic
        array{} # Exotic
    var RarityItemCounts:[]int = array:
        0 # Common
        0 # Uncommon
        0 # Rare
        0 # Epic
        0 # Legendary
        0 # Mythic
        0 # Exotic

    PlayerStatsManager:player_stat_manager = player_stat_manager{}
    
    OnBegin<override>()<suspends>:void=
        InputTriggerDevice.PressedEvent.Subscribe(TriggerSpinGacha)

        ShootingEnterMutator.AgentEntersEvent.Subscribe(EnterMutator)
        ShootingExitMutator.AgentEntersEvent.Subscribe(ExitMutator)

        ItemGrantersArray := array:
            ItemGranters_Pistol
            ItemGranters_ShutGun
            ItemGranters_SMG
            ItemGranters_AR
            ItemGranters_Sniper
            ItemGranters_Marksman
            ItemGranters_Bow
            ItemGranters_Crossbow
            ItemGranters_BombWeapon
            ItemGranters_OtherWeapon
            ItemGranters_Item

        for(Index->Prob:RarityProbs):
            for(Index2 := 0..Prob - 1):
                set ProbArray += array{Index}
        
        for(ItemGranters:ItemGrantersArray):
            for(RarityIndex := 0..RarityCount - 1):
                if:
                    ItemGranter := ItemGranters[RarityIndex]
                    set RarityGranters[RarityIndex] += array{ItemGranter}
                    set RarityItemCounts[RarityIndex] += ItemGranter.ItemCount

        for(Index->Count:RarityItemCounts):
            Print("{Index}番目のレアリティは、アイテム数が{Count}個")


        # # ピストル
        # set AllItemGranters += ItemGranters_Pistol
        # for(ItemGranter:ItemGranters_Pistol):
        #     set AllItemCount += ItemGranter.ItemCount

        # # ショットガン
        # set AllItemGranters += ItemGranters_ShutGun
        # for(ItemGranter:ItemGranters_ShutGun):
        #     set AllItemCount += ItemGranter.ItemCount

        # # SMG
        # set AllItemGranters += ItemGranters_SMG
        # for(ItemGranter:ItemGranters_SMG):
        #     set AllItemCount += ItemGranter.ItemCount

        # # AR
        # set AllItemGranters += ItemGranters_AR
        # for(ItemGranter:ItemGranters_AR):
        #     set AllItemCount += ItemGranter.ItemCount

        # # スナイパー
        # set AllItemGranters += ItemGranters_Sniper
        # for(ItemGranter:ItemGranters_Sniper):
        #     set AllItemCount += ItemGranter.ItemCount

        # # マークスマンライフル
        # set AllItemGranters += ItemGranters_Marksman
        # for(ItemGranter:ItemGranters_Marksman):
        #     set AllItemCount += ItemGranter.ItemCount

        # # 弓
        # set AllItemGranters += ItemGranters_Bow
        # for(ItemGranter:ItemGranters_Bow):
        #     set AllItemCount += ItemGranter.ItemCount

        # # クロスボウ
        # set AllItemGranters += ItemGranters_Crossbow
        # for(ItemGranter:ItemGranters_Crossbow):
        #     set AllItemCount += ItemGranter.ItemCount
            
        # # 爆弾武器
        # set AllItemGranters += ItemGranters_BombWeapon
        # for(ItemGranter:ItemGranters_BombWeapon):
        #     set AllItemCount += ItemGranter.ItemCount
            
        # # その他の武器
        # set AllItemGranters += ItemGranters_OtherWeapon
        # for(ItemGranter:ItemGranters_OtherWeapon):
        #     set AllItemCount += ItemGranter.ItemCount
            
        # # アイテム
        # set AllItemGranters += ItemGranters_Item
        # for(ItemGranter:ItemGranters_Item):
        #     set AllItemCount += ItemGranter.ItemCount

        Print("AllItemCount: {AllItemCount}")

    EnterMutator(Agent:agent):void=
        Print("練習場に入った")
        RegisterInputTriggerDevice(Agent)

    ExitMutator(Agent:agent):void=
        Print("練習場から出た")
        UnregisterInputTriggerDevice(Agent)
    
    # 入力トリガーの仕掛けに登録する関数
    RegisterInputTriggerDevice(Agent:agent):void=
        InputTriggerDevice.Register(Agent)
        ShowGold(Agent)
        Print("入力トリガーの仕掛けに登録した")
    
    # 入力トリガーの仕掛けから解除する関数
    UnregisterInputTriggerDevice(Agent:agent):void=
        InputTriggerDevice.Unregister(Agent)
        ShowGoldHud.Hide(Agent)
        AnimGoldHud.Hide(Agent)
        NotEnoughGoldHud.Hide(Agent)
        Print("入力トリガーの仕掛けから解除した")

    # 所持金表示HUDの更新を行う関数
    ShowGold(Agent:agent):void=
        OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
        if(PlayerStats := OPlayerStats?):
            ShowGoldHud.Show(Agent, S2M("{PlayerStats.CurrentGold}"))

    # 所持金が変動する際のアニメーションを表示する関数
    AnimGold(Agent:agent, Gold:int):void=
        AnimGoldHud.Hide(Agent)
        var Str:string = ""
        if(0 <= Gold):
            set Str = "+{Gold}"
        else:
            set Str = "{Gold}"
        AnimGoldHud.Show(Agent, S2M(Str))

    # ゴールドを獲得する処理を実行する関数
    GetGold(Agent:agent, AddGold:int):void=
        PlayerStatsManager.UpdateCurrentGoldStat(Agent, AddGold)
        ShowGold(Agent) # 所持金HUDの更新
        AnimGold(Agent, AddGold) # 所持金変動アニメを表示

    # 入力トリガーの仕掛けに登録する関数。AddShopUIを呼び出すだけ
    TriggerSpinGacha(Agent:agent):void=
        Print("入力を感知した")
        SpinGacha(Agent)

    # レアリティごとに重みをつけたガチャを引く処理を実行する関数
    SpinGacha(Agent:agent):void=
        NotEnoughGoldHud.Hide(Agent)

        OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
        if(PlayerStats := OPlayerStats?, GachaCost <= PlayerStats.CurrentGold):
            RandomArray := Shuffle(ProbArray)

            var Str:string = ""
            for(Index->a:RandomArray):
                set Str += "{a} "
                if(Mod[Index, 10] = 0):
                    set Str += "\n"
            Print(Str)

            if:
                SelectedRarity := RandomArray[0]
                RandomNum := Random.GetRandomInt(1, RarityItemCounts[SelectedRarity])
                ItemGranters := RarityGranters[SelectedRarity]
            then:
                Print("{SelectedRarity}番目のレアリティが選ばれた")
                var CurrentItemCount:int = 0
                for(Index->ItemGranter:ItemGranters):
                    if(RandomNum <= (CurrentItemCount + ItemGranter.ItemCount)):
                        # アイテムを与える処理
                        ItemGranter.ItemGranter.GrantItemIndex(Agent, (RandomNum - CurrentItemCount) - 1)
                        PlayerStatsManager.UpdateCurrentGoldStat(Agent, -GachaCost)
                        ShowGold(Agent) # 所持金HUDの更新
                        AnimGold(Agent, GachaCost) # 所持金変動アニメを表示

                        # XPを与える
                        GachaXPDevice.Award(Agent) # ガチャを引いた
                        if(SelectedRarity = 5):
                            Print("ミシックを引いた！！")
                            PulledMythicXPDevice.Award(Agent) # ミシックを引いた

                        # 持続データへの反映
                        if(0 < PlayerStats.RoundWins): # 試合中だったらって意味
                            # 持続データへ保存
                            PlayerStatsManager.UpdateCurrentRarityPullsArrayStat(Agent, SelectedRarity)
                            Print("持続データに保存: ガチャを引いた回数と、{SelectedRarity}を引いた回数をそれぞれ +1 した。")

                        Print("{Index}個目の種類の{(RandomNum - CurrentItemCount) - 1}番目のアイテムを渡した！！")
                        return
                    else:
                        set CurrentItemCount += ItemGranter.ItemCount
        else:
            NotEnoughGoldHud.Show(Agent)
            if(PlayerStats := OPlayerStats?):
                Print("所持金: {PlayerStats.CurrentGold}")
            Print("所持金が足りなかったため、ガチャを回せなかった")

    # # 確率調整のない完全にランダムなガチャを引く処理を実行する関数
    # SpinCompletelyrandomGacha(Agent:agent):void=
    #     NotEnoughGoldHud.Hide(Agent)

    #     OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
    #     if(PlayerStats := OPlayerStats?, GachaCost <= PlayerStats.CurrentGold):
    #         RandomNum := Random.GetRandomInt(1, AllItemCount) # 1 以上 AllItemCount 以下の整数をランダムに生成
    #         Print("RandomNum: {RandomNum}")

    #         var CurrentItemCount:int = 0
    #         for(Index->ItemGranter:AllItemGranters):
    #             if(RandomNum <= (CurrentItemCount + ItemGranter.ItemCount)):
    #                 ItemGranter.ItemGranter.GrantItemIndex(Agent, (RandomNum - CurrentItemCount) - 1)
    #                 PlayerStatsManager.UpdateCurrentGoldStat(Agent, -GachaCost)
    #                 ShowGold(Agent) # 所持金HUDの更新
    #                 AnimGold(Agent, GachaCost) # 所持金変動アニメを表示
    #                 Print("{Index + 1}個目のグランターの{(RandomNum - CurrentItemCount) - 1}番目のアイテムを渡した！！")
    #                 return
    #             else:
    #                 set CurrentItemCount += ItemGranter.ItemCount
    #     else:
    #         NotEnoughGoldHud.Show(Agent)
    #         if(PlayerStats := OPlayerStats?):
    #             Print("所持金: {PlayerStats.CurrentGold}")
    #         Print("所持金が足りなかったため、ガチャを回せなかった")