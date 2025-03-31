using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Fortnite.com/Teams }

mapindicator_enum := enum<persistable>:
    AttackerMapIndicator
    DefenderMapIndicator
    BeforeMapIndicators
    AfterMapIndicatorsA
    AfterMapIndicatorsB
    AfterMapIndicatorsC

ballistic_tracking_device := class(creative_device):

    @editable
    DisablePos:vector3 = vector3{} # マップインジケーターの初期位置となる座標

    # マップインジケーターのX, Y座標は、キャプチャーアイテムスポナーの位置と一致させる。
    @editable
    AttackerMapIndicator:map_indicator_device = map_indicator_device{} # 攻撃側に表示されるマップアイコン（青色アイコン）
    @editable
    DefenderMapIndicator:map_indicator_device = map_indicator_device{} # 守備側に表示されるマップアイコン（赤色アイコン）

    @editable
    BeforeMapIndicators:[]map_indicator_device = array{} # 爆弾が設置される前に表示するマップインジケーター

    @editable
    AfterMapIndicatorsA:[]map_indicator_device = array{} # 爆弾が設置された後に表示するA地点のマップインジケーター
    @editable
    AfterMapIndicatorsB:[]map_indicator_device = array{} # 爆弾が設置された後に表示するB地点のマップインジケーター
    @editable
    AfterMapIndicatorsC:[]map_indicator_device = array{} # 爆弾が設置された後に表示するC地点のマップインジケーター

    @editable
    RiftPointVolumeA:rift_point_volume_device = rift_point_volume_device{}
    @editable
    RiftPointVolumeB:rift_point_volume_device = rift_point_volume_device{}
    @editable
    RiftPointVolumeC:rift_point_volume_device = rift_point_volume_device{}

    # 攻守交代時に使うデバイスを切り替える必要がある。
    # なぜなら、一度このデバイスからアイテムを取得したら、再度アイテムがリスポーンしたときに最初に取得したチーム以外は取得できなくなるからである。
    @editable
    CaptureItemDevice:capture_item_spawner_device = capture_item_spawner_device{}

    var OBallisticPlayer:?player = false # バリスティックの仕掛けを持っているプレイヤー

    var NotFirstPickedUp:logic = true

    var Rotation:rotation = rotation{}

    # map_indicator_deviceをキーとしてmapは作れなかったので、二つの配列で代用
    var AllMapIndicatorPoss:[]vector3 = array{}

    DropEvent:event() = event(){}

    OnBegin<override>()<suspends>:void=
        var AllMapIndicators:[]map_indicator_device = array{AttackerMapIndicator, DefenderMapIndicator}
        set AllMapIndicators += BeforeMapIndicators + AfterMapIndicatorsA + AfterMapIndicatorsB + AfterMapIndicatorsC
        for(MapIndicator:AllMapIndicators):
            set AllMapIndicatorPoss += array{MapIndicator.GetTransform().Translation}
        
        set Rotation = AttackerMapIndicator.GetTransform().Rotation

        InitializeMapIndicators()

        RiftPointVolumeA.PlantEvent.Subscribe(PlantBombAtA)
        RiftPointVolumeB.PlantEvent.Subscribe(PlantBombAtB)
        RiftPointVolumeC.PlantEvent.Subscribe(PlantBombAtC)
        
        CaptureItemDevice.ItemPickedUpEvent.Subscribe(OnPickedUp)
        CaptureItemDevice.ItemDroppedEvent.Subscribe(OnDropped)

    # ラウンド開始時に表示させたくないマップインジケーターを移動させる
    InitializeMapIndicators():void=
        DisableMI(mapindicator_enum.AfterMapIndicatorsA)
        DisableMI(mapindicator_enum.AfterMapIndicatorsB)
        DisableMI(mapindicator_enum.AfterMapIndicatorsC)

    DisableMI(MIEnum:mapindicator_enum):void=
        case(MIEnum):
            mapindicator_enum.AttackerMapIndicator => 
                if. AttackerMapIndicator.TeleportTo[DisablePos, Rotation]
                    
            mapindicator_enum.DefenderMapIndicator =>
                if. DefenderMapIndicator.TeleportTo[DisablePos, Rotation]

            mapindicator_enum.BeforeMapIndicators =>
                for(MI:BeforeMapIndicators):
                    if. MI.TeleportTo[DisablePos, Rotation]

            mapindicator_enum.AfterMapIndicatorsA =>
                for(MI:AfterMapIndicatorsA):
                    if. MI.TeleportTo[DisablePos, Rotation]

            mapindicator_enum.AfterMapIndicatorsB =>
                for(MI:AfterMapIndicatorsB):
                    if. MI.TeleportTo[DisablePos, Rotation]

            mapindicator_enum.AfterMapIndicatorsC =>
                for(MI:AfterMapIndicatorsC):
                    if. MI.TeleportTo[DisablePos, Rotation]

    EnableMI(MIEnum:mapindicator_enum):void=
        case(MIEnum):
            mapindicator_enum.AttackerMapIndicator => 
                if:
                    Pos := AllMapIndicatorPoss[0]
                    AttackerMapIndicator.TeleportTo[Pos, Rotation]
                    
            mapindicator_enum.DefenderMapIndicator =>
                if:
                    Pos := AllMapIndicatorPoss[1]
                    DefenderMapIndicator.TeleportTo[Pos, Rotation]

            mapindicator_enum.BeforeMapIndicators =>
                for(Index->Pos:AllMapIndicatorPoss, 2 <= Index <= 7):
                    if:
                        MI := BeforeMapIndicators[Index - 2]
                        MI.TeleportTo[Pos, Rotation]

            mapindicator_enum.AfterMapIndicatorsA =>
                for(Index->Pos:AllMapIndicatorPoss, 8 <= Index <= 9):
                    if:
                        MI := AfterMapIndicatorsA[Index - 8]
                        MI.TeleportTo[Pos, Rotation]

            mapindicator_enum.AfterMapIndicatorsB =>
                for(Index->Pos:AllMapIndicatorPoss, 10 <= Index <= 11):
                    if:
                        MI := AfterMapIndicatorsB[Index - 10]
                        MI.TeleportTo[Pos, Rotation]

            mapindicator_enum.AfterMapIndicatorsC =>
                for(Index->Pos:AllMapIndicatorPoss, 12 <= Index <= 13):
                    if:
                        MI := AfterMapIndicatorsC[Index - 12]
                        MI.TeleportTo[Pos, Rotation]

    OnPickedUp(Agent:agent):void=
        Print("拾った")

        # バリスティックを設置したときに復活しないように無効化しておく
        if(NotFirstPickedUp?):
            set NotFirstPickedUp = false
            CaptureItemDevice.Disable()

        if(Player := player[Agent]):
            set OBallisticPlayer = option{Player}
            spawn{MarkPlayer()}
            DisableMI(mapindicator_enum.DefenderMapIndicator)
            
    # バリスティックアイテムを所持しているプレイヤーの位置をマップに表示する関数
    MarkPlayer()<suspends>:void=
        if(BallisticPlayer := OBallisticPlayer?, Fort := BallisticPlayer.GetFortCharacter[]):
            race:
                loop:
                    Transform := Fort.GetTransform()
                    NewPosition := vector3{X := Transform.Translation.X, Y := Transform.Translation.Y, Z := Transform.Translation.Z + 500.0}
                    if. AttackerMapIndicator.TeleportTo[NewPosition, Transform.Rotation]
                    Sleep(0.01) # 更新頻度
                DropEvent.Await()
        
    OnDropped(Agent:agent):void=
        Print("ドロップした")
        DropEvent.Signal()
        if(Player := player[Agent], Fort := Player.GetFortCharacter[]):
            Transform := Fort.GetTransform()
            NewPosition := vector3{X := Transform.Translation.X, Y := Transform.Translation.Y, Z := Transform.Translation.Z + 500.0}
            if. DefenderMapIndicator.TeleportTo[NewPosition, Transform.Rotation]

    # RiftPointVolumeA に爆弾が設置されたら実行される関数
    PlantBombAtA(Agent:agent):void=
        EnableMI(mapindicator_enum.AfterMapIndicatorsA)

        DisableBeforeAtkDef()
        DropEvent.Signal()
        
    # RiftPointVolumeB に爆弾が設置されたら実行される関数
    PlantBombAtB(Agent:agent):void=
        EnableMI(mapindicator_enum.AfterMapIndicatorsB)

        DisableBeforeAtkDef()
        DropEvent.Signal()
        
    # RiftPointVolumeC に爆弾が設置されたら実行される関数
    PlantBombAtC(Agent:agent):void=
        EnableMI(mapindicator_enum.AfterMapIndicatorsC)

        DisableBeforeAtkDef()
        DropEvent.Signal()

    DisableBeforeAtkDef():void=
        DisableMI(mapindicator_enum.BeforeMapIndicators)
        DisableMI(mapindicator_enum.AttackerMapIndicator)
        DisableMI(mapindicator_enum.DefenderMapIndicator)