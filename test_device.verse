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
    HudDevice:hud_message_device = hud_message_device{}
    @editable
    HudDevice2:hud_message_device = hud_message_device{}

    @editable
    Trigger:trigger_device = trigger_device{}
    @editable
    Trigger2:trigger_device = trigger_device{}
    @editable
    Trigger3:trigger_device = trigger_device{}

    GetAgentsName<localizes>(Msg:message, Msg2:message):message="{Msg} {Msg2}"
        


    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)
        Trigger2.TriggeredEvent.Subscribe(OnTriggered2)
        Trigger3.TriggeredEvent.Subscribe(OnTriggered3)
        

    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?):
            PlayerName := GetAgentName(Agent)
            Msg := GetAgentsName(PlayerName, S2M("は神"))
            Print(Msg)
        return

            
    OnTriggered2(OAgent:?agent):void=
        if(Agent := OAgent?):
            HudDevice.Hide(Agent)
            HudDevice2.Hide(Agent)
        return
        
         
    OnTriggered3(OAgent:?agent):void=
        return

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
