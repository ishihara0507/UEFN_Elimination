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

    # 攻守交代時に使うデバイスを切り替える必要がある。
    # なぜなら、一度このデバイスからアイテムを取得したら、再度アイテムがリスポーンしたときに最初に取得したチーム以外は取得できなくなるからである。
    @editable
    CaptureItemDevices:[]capture_item_spawner_device = array{}

    var OBallisticPlayer:?player = false # バリスティックの仕掛けを持っているプレイヤー

    DropEvent:event() = event(){}

    OnBegin<override>()<suspends>:void=
        AttackerMapIndicator.Disable() # 一旦非表示にする
        DefenderMapIndicator.Disable() # 一旦非表示にする

        for(CaptureItemDevice:CaptureItemDevices):
            CaptureItemDevice.ItemPickedUpEvent.Subscribe(OnPickedUp)
            CaptureItemDevice.ItemDroppedEvent.Subscribe(OnDropped)
            CaptureItemDevice.Disable()

    # マップインジケーターを有効化する関数
    EnableMapIndicator():void=
        for(CaptureItemDevice:CaptureItemDevices):
            CaptureItemDevice.Enable()

    OnPickedUp(Agent:agent):void=
        Print("拾った")
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
