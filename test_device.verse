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

    @editable
    RoundUIDevice:round_ui_device = round_ui_device{}
    
    var TeamRemainingMap:[team]int = map{}
    var TeamWinsMap:[team]int = map{}

    var GameAgents:[]agent = array{}

    @editable
    Spawner:player_spawner_device = player_spawner_device{}

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)
        Trigger2.TriggeredEvent.Subscribe(OnTriggered2)
        Trigger3.TriggeredEvent.Subscribe(OnTriggered3)
        Trigger4.TriggeredEvent.Subscribe(OnTriggered4)
        Trigger5.TriggeredEvent.Subscribe(OnTriggered5)
        Button.InteractedWithEvent.Subscribe(OnPush)
        Button2.InteractedWithEvent.Subscribe(ChangeTeam)

        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        set GameAgents = GetPlayspace().GetParticipants()
        for(Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
            var Count:int = 0
            for(Agent:Agents, GameAgents.Find[Agent]):
                set Count += 1
            if:
                set TeamRemainingMap[Team] = Count
                set TeamWinsMap[Team] = 0

        
        loop:
            Sleep(1.0)
            if(Fort := GetPlayspace().GetPlayers()[0].GetFortCharacter[]):
                Transform := Fort.GetTransform()
                Print("{Transform.Rotation}")    


    OnTriggered(OAgent:?agent):void=
        Rotation := MakeRotation(vector3{X := 0.0, Y := 0.0, Z := 1.0}, 87.998901) # リスポーン時の向きを作成（これは最初にマップにスポーンしたときの向き）
        if(Agent := OAgent?, Player := player[Agent]):
            Player.Respawn(Spawner.GetTransform().Translation, Rotation)

            if(Fort := Player.GetFortCharacter[]):
                Transform := Fort.GetTransform()
                Print("{Transform.Rotation}") 
            
    OnTriggered2(OAgent:?agent):void=
        Print("残り人数を更新")
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        if(Agent := OAgent?):
            for(Team:TeamArray, TeamCollection.GetTeam[Agent] = Team):
                if. set TeamRemainingMap[Team] -= 1
        RoundUIDevice.UpdateRoundStatusUI(TeamRemainingMap, TeamWinsMap)
        return

    OnTriggered3(OAgent:?agent):void=
        Print("勝利数を更新")
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        if(Agent := OAgent?):
            for(Team:TeamArray, TeamCollection.GetTeam[Agent] = Team):
                if. set TeamWinsMap[Team] += 1
        RoundUIDevice.UpdateRoundStatusUI(TeamRemainingMap, TeamWinsMap)
        return
        
    OnTriggered4(OAgent:?agent):void=
        Print("ラウンド状態を削除")
        RoundUIDevice.RemoveRoundStatusUI()
        return

    OnPush(Agent:agent):void=
        Print("ラウンド状態を表示")
        RoundUIDevice.AddRoundStatusUI(TeamRemainingMap, TeamWinsMap)
        return

    OnTriggered5(fffAgent:?agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        Print("普通に長さを出力")
        for(Index->Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
            Print("チーム{Index + 1}の人数: {Agents.Length}")
        Print("Findした長さを出力")
        for(Index->Team:TeamArray, Agents := TeamCollection.GetAgents[Team]):
            var Count:int = 0
            for(Agent:Agents, GameAgents.Find[Agent]):
                set Count += 1
            Print("チーム{Index + 1}の人数: {Count}")
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
