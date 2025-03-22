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
    
    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)
        Trigger2.TriggeredEvent.Subscribe(OnTriggered2)

    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?, Player := player[Agent]):
            spawn{AddUI(Player)}
        return

    AddUI(Player:player)<suspends>:void=
        if(PlayerUI := GetPlayerUI[Player]):
            var Btn:button_quiet = button_quiet{DefaultText:=S2M("quiet 閉じる")}

            Widget := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Left := 0.0, Top := 0.0, Right := 100.0, Bottom := 100.0}
                        Alignment := vector2{X:=0.5,Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := color_block{}
                    canvas_slot:
                        Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Left := -0.0, Top := 0.0, Right := -0.0, Bottom := -0.0}
                        Alignment := vector2{X:=0.5,Y:=0.5}
                        SizeToContent := true
                        ZOrder := 0
                        Widget := Btn
                    canvas_slot:
                        Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Left := -400.0, Top := 0.0, Right := -0.0, Bottom := -0.0}
                        Alignment := vector2{X:=0.5,Y:=0.5}
                        SizeToContent := true
                        ZOrder := 0
                        Widget := button_loud{DefaultText:=S2M("loud")}
                    canvas_slot:
                        Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Left := -200.0, Top := 0.0, Right := -0.0, Bottom := -0.0}
                        Alignment := vector2{X:=0.5,Y:=0.5}
                        SizeToContent := true
                        ZOrder := 0
                        Widget := button_regular{DefaultText:=S2M("regular")}

            PlayerUI.AddWidget(Widget, player_ui_slot{InputMode := ui_input_mode.All})
            Btn.OnClick().Await()
            PlayerUI.RemoveWidget(Widget)
    
    OnTriggered2(OAgent:?agent):void=
        if(Agent := OAgent?):
            PlayerStatsManager.ShowPresets(Agent)
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
