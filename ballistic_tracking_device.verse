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

    @editable
    AttackerMapIndicator:map_indicator_device = map_indicator_device{} # 攻撃側に表示されるマップアイコン（青色アイコン）
    @editable
    DefenderMapIndicator:map_indicator_device = map_indicator_device{} # 守備側に表示されるマップアイコン（赤色アイコン）

    # 攻守交代時に使うデバイスを切り替える必要がある。
    # なぜなら、一度このデバイスからアイテムを取得したら、再度アイテムがリスポーンしたときに最初に取得したチーム以外は取得できなくなるからである。
    @editable
    CaptureItemDevices:[]capture_item_spawner_device = array{}

    OnBegin<override>()<suspends>:void=
        for(CaptureItemDevice:CaptureItemDevices):
            CaptureItemDevice.ItemPickedUpEvent.Subscribe(OnPickedUp)
            CaptureItemDevice.ItemDroppedEvent.Subscribe(OnDropped)

    OnPickedUp(Agent:agent):void=
        Print("2")
        
    OnDropped(Agent:agent):void=
        Print("3")