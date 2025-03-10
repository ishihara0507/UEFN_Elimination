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

    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)

    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?):
            PlayerStatsManager.ShowStats(Agent)
                
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
