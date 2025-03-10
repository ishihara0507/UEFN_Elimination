using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

link_bombs_and_ballistics_device := class(creative_device):

    @editable
    RiftPointVolumeA:rift_point_volume_device = rift_point_volume_device{}
    @editable
    RiftPointVolumeB:rift_point_volume_device = rift_point_volume_device{}
    @editable
    RiftPointVolumeC:rift_point_volume_device = rift_point_volume_device{}

    @editable
    ExplosiveDevicesA:[]explosive_device = array{}
    @editable
    ExplosiveDevicesB:[]explosive_device = array{}
    @editable
    ExplosiveDevicesC:[]explosive_device = array{}

    OnBegin<override>()<suspends>:void=
        RiftPointVolumeA.DetonateEvent.Subscribe(RiftDetonateA)
        RiftPointVolumeB.DetonateEvent.Subscribe(RiftDetonateB)
        RiftPointVolumeC.DetonateEvent.Subscribe(RiftDetonateC)

    # バリスティックの仕掛けを爆破したときに実行する関数
    RiftDetonateA(Agent:agent):void=
        for(ExplosiveDevice:ExplosiveDevicesA):
            ExplosiveDevice.Explode(Agent)
    
    # バリスティックの仕掛けを爆破したときに実行する関数
    RiftDetonateB(Agent:agent):void=
        for(ExplosiveDevice:ExplosiveDevicesB):
            ExplosiveDevice.Explode(Agent)

    # バリスティックの仕掛けを爆破したときに実行する関数
    RiftDetonateC(Agent:agent):void=
        for(ExplosiveDevice:ExplosiveDevicesC):
            ExplosiveDevice.Explode(Agent)