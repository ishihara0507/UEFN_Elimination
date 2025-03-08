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
    HudDevice:hud_message_device = hud_message_device{}
    @editable
    HudDevice2:hud_message_device = hud_message_device{}

    @editable
    Trigger:trigger_device = trigger_device{}
    @editable
    Trigger2:trigger_device = trigger_device{}
    @editable
    Trigger3:trigger_device = trigger_device{}

    @editable
    Teleporter:teleporter_device = teleporter_device{}
        
    @editable
    CaptureArea:capture_area_device = capture_area_device{}
    
    @editable
    MapIndicator:map_indicator_device = map_indicator_device{}

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(ChangeTeam)
        Trigger2.TriggeredEvent.Subscribe(OnTriggered)
        Trigger3.TriggeredEvent.Subscribe(OnTriggered3)


    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?, Fort := player[Agent].GetFortCharacter[]):
            spawn{AA(Fort)}

    AA(Fort:fort_character)<suspends>:void=
        loop:
            Transform := Fort.GetTransform()
            NewPosition := vector3{X := Transform.Translation.X, Y := Transform.Translation.Y, Z := Transform.Translation.Z + 500.0}
            if. MapIndicator.TeleportTo[NewPosition, Transform.Rotation]
            Sleep(0.01)
            
    OnTriggered2(OAgent:?agent):void=
        return
        
         
    OnTriggered3(OAgent:?agent):void=
        return

    ChangeTeam(OAgent:?agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
        if:
            Agent := OAgent?
            Player := player[Agent]
            CurrentTeam := TeamCollection.GetTeam[Player]
        then:
            for(Index->Team:TeamArray):
                if(not Team = CurrentTeam):
                    if(TeamCollection.AddToTeam[Player, Team]):
                        Print("チーム{Index}に切り替えました")
