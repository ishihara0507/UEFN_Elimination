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

ballistic_tracking_device := class(creative_device):

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

    DropEvent:event() = event(){}

    OnBegin<override>()<suspends>:void=
        # 最初はマップインジケーターは非表示にしておく
        var MapIndicators:[]map_indicator_device = array{AttackerMapIndicator, DefenderMapIndicator}
        set MapIndicators += BeforeMapIndicators + AfterMapIndicatorsA + AfterMapIndicatorsB + AfterMapIndicatorsC
        for(MapIndicator:MapIndicators):
            MapIndicator.Disable()

        RiftPointVolumeA.PlantEvent.Subscribe(PlantBombAtA)
        RiftPointVolumeB.PlantEvent.Subscribe(PlantBombAtB)
        RiftPointVolumeC.PlantEvent.Subscribe(PlantBombAtC)
        
        CaptureItemDevice.ItemPickedUpEvent.Subscribe(OnPickedUp)
        CaptureItemDevice.ItemDroppedEvent.Subscribe(OnDropped)

    # マップインジケーターを有効化する関数
    EnableMapIndicator():void=
        Print("マップインジケーターを有効化")
        AttackerMapIndicator.Enable()
        DefenderMapIndicator.Enable()
        for(MapIndicator:BeforeMapIndicators):
            MapIndicator.Enable()

    OnPickedUp(Agent:agent):void=
        Print("拾った")

        # バリスティックを設置したときに復活しないように無効化しておく
        if(NotFirstPickedUp?):
            set NotFirstPickedUp = false
            CaptureItemDevice.Disable()

        if(Player := player[Agent]):
            set OBallisticPlayer = option{Player}
            spawn{MarkPlayer()}
        DefenderMapIndicator.Disable()
            
    # バリスティックアイテムを所持しているプレイヤーの位置をマップに表示する関数
    MarkPlayer()<suspends>:void=
        if(BallisticPlayer := OBallisticPlayer?, Fort := BallisticPlayer.GetFortCharacter[]):
            race:
                loop:
                    Transform := Fort.GetTransform()
                    NewPosition := vector3{X := Transform.Translation.X, Y := Transform.Translation.Y, Z := Transform.Translation.Z + 500.0}
                    if. AttackerMapIndicator.TeleportTo[NewPosition, Transform.Rotation]
                    Sleep(0.01)
                DropEvent.Await()
        
    OnDropped(Agent:agent):void=
        Print("ドロップした")
        DropEvent.Signal()
        if(Player := player[Agent], Fort := Player.GetFortCharacter[]):
            Transform := Fort.GetTransform()
            NewPosition := vector3{X := Transform.Translation.X, Y := Transform.Translation.Y, Z := Transform.Translation.Z + 500.0}
            if(DefenderMapIndicator.TeleportTo[NewPosition, Transform.Rotation]):
                DefenderMapIndicator.Enable()

    # RiftPointVolumeA に爆弾が設置されたら実行される関数
    PlantBombAtA(Agent:agent):void=
        for(MapIndicator:BeforeMapIndicators):
            MapIndicator.Disable()
        for(MapIndicator:AfterMapIndicatorsA):
            MapIndicator.Enable()
        AttackerMapIndicator.Disable()
        DefenderMapIndicator.Disable()
        DropEvent.Signal()
        
    # RiftPointVolumeB に爆弾が設置されたら実行される関数
    PlantBombAtB(Agent:agent):void=
        for(MapIndicator:BeforeMapIndicators):
            MapIndicator.Disable()
        for(MapIndicator:AfterMapIndicatorsB):
            MapIndicator.Enable()
        AttackerMapIndicator.Disable()
        DefenderMapIndicator.Disable()
        DropEvent.Signal()
        
    # RiftPointVolumeC に爆弾が設置されたら実行される関数
    PlantBombAtC(Agent:agent):void=
        for(MapIndicator:BeforeMapIndicators):
            MapIndicator.Disable()
        for(MapIndicator:AfterMapIndicatorsC):
            MapIndicator.Enable()
        AttackerMapIndicator.Disable()
        DefenderMapIndicator.Disable()
        DropEvent.Signal()
