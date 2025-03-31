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
    Trigger3:trigger_device = trigger_device{}
    @editable
    Trigger4:trigger_device = trigger_device{}

    @editable
    ItemGranter:item_granter_device = item_granter_device{}

    @editable
    Button:button_device = button_device{}

    Event:event() = event(){}

    @editable
    GachaDevice:gacha_device = gacha_device{}

    @editable
    InputTriggerDevice:input_trigger_device = input_trigger_device{}

    PlayerStatManager:player_stat_manager = player_stat_manager{}
    
    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)
        Trigger2.TriggeredEvent.Subscribe(OnTriggered2)
        Button.InteractedWithEvent.Subscribe(AA)

        Event.Await()

        for(Agent:GetPlayspace().GetParticipants(), not player[Agent]):
            Print("アイテムを付与した")
            ItemGranter.GrantItem(Agent)

    AA(Agent:agent):void=
        Print("ボタンが押された")
        OPlayerStats := PlayerStatManager.GetPlayerStats(Agent)
        if(Player := player[Agent]):
            Print("1")
            if(Player.IsActive[]):
                Print("2")
            if(CurrentPlayerStat := PlayerStatMap[Player]):
                Print("3")
        if(PlayerStats := OPlayerStats?):
            Print("持続データをとれた")
        else:
            Print("持続データを取れなかった")

    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?):
            Print("登録した")
            GachaDevice.RegisterInputTriggerDevice(Agent)
        return

    OnTriggered2(OAgent:?agent):void=
        if(Agent := OAgent?):
            Print("解除した")
            GachaDevice.UnregisterInputTriggerDevice(Agent)
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
