using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/SpatialMath }

generation_range := struct<concrete>:
    @editable
    X_Min:float = 0.0
    @editable
    X_Max:float = 0.0
    
    @editable
    Y_Min:float = 0.0
    @editable
    Y_Max:float = 0.0

gold_item_generator_device := class(creative_device):

    @editable
    GachaDevice:gacha_device = gacha_device{}

    @editable
    DiamondSpawner:item_spawner_device = item_spawner_device{}

    # 建物の中に設定したりする、固定のスポナー
    @editable
    FixedCoinSpawners_ATK:[]item_spawner_device = array{}
    @editable
    FixedCoinSpawners_DEF:[]item_spawner_device = array{}

    # ランダムな座標にコインを生成するためのスポナー
    @editable
    RandomSpawner_ATK:item_spawner_device = item_spawner_device{}
    @editable
    RandomSpawner_DEF:item_spawner_device = item_spawner_device{}

    @editable
    AttackerRange:generation_range = generation_range{}
    @editable
    DefenderRange:generation_range = generation_range{}
    
    @editable
    DiamondXPDevice:accolades_device = accolades_device{}
    @editable
    CoinXPDevice:accolades_device = accolades_device{}
    
    @editable
    Z:float = 0.0 # コインを生成するZ座標

    @editable
    DiamondCooldown:float = 45.0
    @editable
    RandomCooldown:float = 5.0
    @editable
    FixedCooldown:float = 10.0

    GoldPerCoin:int = 250 # コインを１枚拾ったらもらえるゴールドの数
    GoldPerDiamond:int = 1000 # ダイアモンドを１個拾ったらもらえるゴールドの数

    var Rotation:rotation = rotation{}

    StartingEvent:event() = event(){}
    EndingEvent:event() = event(){}

    OnBegin<override>()<suspends>:void=
        set Rotation = RandomSpawner_ATK.GetTransform().Rotation

        DiamondSpawner.ItemPickedUpEvent.Subscribe(OnPickUpDiamond)

        var CoinSpawners:[]item_spawner_device = array{RandomSpawner_ATK, RandomSpawner_DEF}
        set CoinSpawners += FixedCoinSpawners_ATK
        set CoinSpawners += FixedCoinSpawners_DEF
        for(CoinSpawner:CoinSpawners):
            CoinSpawner.ItemPickedUpEvent.Subscribe(OnPickUpCoin)
        
        return

    # ダイヤモンドを拾ったときに実行される関数
    OnPickUpDiamond(Agent:agent):void=
        Print("ダイアモンドを拾った")
        DiamondXPDevice.Award(Agent) # XPを与える
        GachaDevice.GetGold(Agent, GoldPerDiamond)

    # コインを拾ったときに実行される関数
    OnPickUpCoin(Agent:agent):void=
        Print("コインを拾った")
        CoinXPDevice.Award(Agent) # XPを与える
        GachaDevice.GetGold(Agent, GoldPerCoin)

    # コインを生成する関数
    StartGeneration():void=
        Print("ゴールドアイテムの生成を開始する")
        spawn{GenerateDiamond()}
        spawn{RandomGenerateCoin()}
        spawn{FixedGenerateCoin()}
        return

    EndGeneration():void=
        EndingEvent.Signal()
        return

    # ダイヤモンドを生成する関数
    GenerateDiamond()<suspends>:void=
        race:
            EndingEvent.Await()
            loop:
                DiamondSpawner.SpawnItem()
                Print("ダイヤモンドを生成した")
                Sleep(DiamondCooldown)
        Print("ダイヤモンドの生成を終了した")

        return

    # ランダムな座標にコインを生成する関数
    RandomGenerateCoin()<suspends>:void=
        race:
            EndingEvent.Await()
            loop:
                Attacker_X := GetRandomFloat(AttackerRange.X_Min, AttackerRange.X_Max)
                Attacker_Y := GetRandomFloat(AttackerRange.Y_Min, AttackerRange.Y_Max)
                Defender_X := GetRandomFloat(DefenderRange.X_Min, DefenderRange.X_Max)
                Defender_Y := GetRandomFloat(DefenderRange.Y_Min, DefenderRange.Y_Max)

                if:
                    RandomSpawner_ATK.TeleportTo[vector3{X := Attacker_X, Y := Attacker_Y, Z := Z}, Rotation]
                    RandomSpawner_DEF.TeleportTo[vector3{X := Defender_X, Y := Defender_Y, Z := Z}, Rotation]
                then:
                    RandomSpawner_ATK.SpawnItem()
                    RandomSpawner_DEF.SpawnItem()

                Print("ランダムコインを生成した")
                Sleep(RandomCooldown)
        Print("ランダムコインの生成を終了した")

        return

    # 固定スポナーをランダムに選んで、コインを生成する関数
    FixedGenerateCoin()<suspends>:void=
        if(0 < FixedCoinSpawners_ATK.Length, 0 < FixedCoinSpawners_DEF.Length):
            race:
                EndingEvent.Await()
                loop:
                    Index_ATK := GetRandomInt(0, FixedCoinSpawners_ATK.Length - 1)
                    Index_DEF := GetRandomInt(0, FixedCoinSpawners_DEF.Length - 1)

                    if:
                        Spawner_ATK := FixedCoinSpawners_ATK[Index_ATK]
                        Spawner_DEF := FixedCoinSpawners_DEF[Index_DEF]
                    then:
                        Spawner_ATK.SpawnItem()
                        Spawner_DEF.SpawnItem()
                    
                    Print("固定コインを生成した")
                    Sleep(RandomCooldown)
            Print("固定コインの生成を終了した")
        else:
            Print("固定コインスポナーが設定されていない")

        return