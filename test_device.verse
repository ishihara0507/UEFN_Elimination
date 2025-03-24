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
    Trigger:trigger_device = trigger_device{}
    @editable
    Trigger2:trigger_device = trigger_device{}

    @editable
    SelectPresetDevice:select_preset_device = select_preset_device{}

    @editable
    HudDevice:hud_message_device = hud_message_device{}

    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    @editable
    CondBtn:conditional_button_device = conditional_button_device{}

    @editable
    ShopUIDevice:shop_ui_device = shop_ui_device{}
    
    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)
        Trigger2.TriggeredEvent.Subscribe(OnTriggered2)
        

    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?, Player := player[Agent]):
            Print("持っている数: {CondBtn.GetItemCount(Agent, 0)}個")
            ShopUIDevice.CarryOverItemsToData(Player)
        return

    OnTriggered2(OAgent:?agent):void=
        if(Agent := OAgent?, Player := player[Agent]):
            ShopUIDevice.AddShopUIForAll(array{Player})
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
