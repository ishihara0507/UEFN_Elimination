using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

test_device:= class(creative_device):
    @editable
    Trigger:trigger_device = trigger_device{}

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(HpHeal)
        
    HpHeal(OAgent:?agent):void=
        if(Agent := OAgent?, F := Agent.GetFortCharacter[]):
            F.SetHealth(1000.0)