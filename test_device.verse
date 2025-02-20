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
    HudDevice:hud_message_device = hud_message_device{}

    @editable
    Trigger:trigger_device = trigger_device{}
    @editable
    Trigger2:trigger_device = trigger_device{}
    @editable
    Trigger3:trigger_device = trigger_device{}

    Event:event() = event(){}

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)

    OnTriggered(OAgent:?agent):void=
        Widget := canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}}
                    Offsets := margin{Left := 0.0, Top := 600.0, Right := -0.0, Bottom := -0.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                    Widget := color_block{DefaultColor := color{R := 1.0, G := 1.0, B := 1.0}, DefaultDesiredSize := vector2{X := 128.0, Y := 54.0}}

        if(Agent := OAgent?, PlayerUI := GetPlayerUI[player[Agent]]):
            PlayerUI.AddWidget(Widget)
        else:
            Print("失敗")
        Print("追加した")

        
        if(Agent := OAgent?):
            HudDevice.Show(Agent)
        
            



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
