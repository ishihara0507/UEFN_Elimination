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
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Fortnite.com/Teams }

test_device := class(creative_device):

    @editable
    UITringger:trigger_device = trigger_device{}


    @editable
    Trigger:trigger_device = trigger_device{}
    @editable
    Trigger2:trigger_device = trigger_device{}

    Event:event() = event(){}

    var Map:[agent]int = map{}

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)
        Trigger2.TriggeredEvent.Subscribe(OnTriggered2)

    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?):
            if. set Map[Agent] = 0
            else. Print("初期化error")

            if(Value := Map[Agent]):
                Print("Map :{Value}")
            
    OnTriggered2(OAgent:?agent):void=
        if(Agent := OAgent?):
            if. set Map[Agent] += 1
            else. Print("加算error")

            if(Value := Map[Agent]):
                Print("Map :{Value}")

    # ChangeTeam(OAgent:?agent):void=
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
