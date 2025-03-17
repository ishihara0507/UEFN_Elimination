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

test_device := class(creative_device):

    @editable
    BallisticDevice:ballistic_tracking_device = ballistic_tracking_device{}

    @editable
    Trigger:trigger_device = trigger_device{}

    @editable
    Trigger2:trigger_device = trigger_device{}
    @editable
    Trigger3:trigger_device = trigger_device{}
    @editable
    Trigger4:trigger_device = trigger_device{}
    @editable
    Trigger5:trigger_device = trigger_device{}

    @editable
    HudDevice:hud_message_device = hud_message_device{}
    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    @editable
    Button:button_device = button_device{}
    @editable
    Button2:button_device = button_device{}

    
    var TeamRemainingMap:[team]int = map{}
    var TeamWinsMap:[team]int = map{}

    var GameAgents:[]agent = array{}

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)
        Trigger2.TriggeredEvent.Subscribe(OnTriggered2)
        Trigger3.TriggeredEvent.Subscribe(OnTriggered3)
        Trigger4.TriggeredEvent.Subscribe(OnTriggered4)
        Trigger5.TriggeredEvent.Subscribe(OnTriggered5)
        Button.InteractedWithEvent.Subscribe(OnPush)
        Button2.InteractedWithEvent.Subscribe(ChangeTeam)


    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?):
            PlayerStatsManager.ShowStats(Agent)
        return
            
    OnTriggered2(OAgent:?agent):void=
        return

    OnTriggered3(OAgent:?agent):void=
        return
        
    OnTriggered4(OAgent:?agent):void=
        return

    OnPush(Agent:agent):void=
        return

    OnTriggered5(fffAgent:?agent):void=
        return

    # OnTriggered(OAgent:?agent):void=
    #     TeamCollection := GetPlayspace().GetTeamCollection()
    #     TeamArray := TeamCollection.GetTeams()

    #     if(Agent := OAgent?, Team := TeamArray[1]):
    #         if. TeamCollection.AddToTeam[Agent, Team]
    #         then:
    #             Print(GetAgentName(Agent))
    #             Print("のチームを１に変更しました。")
                  
    # OnTriggered2(OAgent:?agent):void=
    #     TeamCollection := GetPlayspace().GetTeamCollection()
    #     TeamArray := TeamCollection.GetTeams()

    #     for(Index->Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
    #         Print("チーム{Index+1}の人数: {Agents.Length}人")
    #         for(Index2->Agent:Agents, Player := player[Agent]):
    #             AgentName := GetAgentName(Agent)
    #             Print("No.{Index2}")
    #             Print(AgentName)
            
    ChangeTeam(Agent:agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        if:
            Player := player[Agent]
            CurrentTeam := TeamCollection.GetTeam[Player]
        then:
            for(Index->Team:TeamArray):
                if(not Team = CurrentTeam):
                    if(TeamCollection.AddToTeam[Player, Team]):
                        Print("チーム{Index}に切り替えました")
