using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/UI }

test_device := class(creative_device):

    @editable
    UITringger:trigger_device = trigger_device{}

    @editable
    HudDevice:hud_message_device = hud_message_device{}

    @editable
    Trigger:trigger_device = trigger_device{}

    Event:event() = event(){}

    OnBegin<override>()<suspends>:void=
        Print("")
        UITringger.TriggeredEvent.Subscribe(OnUITriggered)


    OnUITriggered(OAgent:?agent):void=
        if(Agent := OAgent?):
            HudDevice.Show(Agent)


    
    # OnTriggered(OAgent:?agent):void=
    #     TeamCollection := GetPlayspace().GetTeamCollection()
    #     TeamArray := TeamCollection.GetTeams()
    #     if:
    #         Agent := OAgent?
    #         Player := player[Agent]
    #         CurrentTeam := TeamCollection.GetTeam[Player]
    #     then:
    #         for(Index->Team:TeamArray):
    #             if(not Team = CurrentTeam):
    #                 if(TeamCollection.AddToTeam[Player, Team]):
    #                     Print("チーム{Index}に切り替えました")
                

