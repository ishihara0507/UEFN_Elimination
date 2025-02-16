using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

test_device := class(creative_device):

    @editable
    Trigger:trigger_device = trigger_device{}

    Event:event() = event(){}

    OnBegin<override>()<suspends>:void=
        Sleep(5.0)
        Trigger.TriggeredEvent.Subscribe(OnTriggered)

        race:
            Event.Await()
            loop:
                Print("ddd")
                Sleep(0.0)

    OnTriggered(OAgent:?agent):void=
        Print("トリガー")
        Event.Signal()
    
                

    
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
                

