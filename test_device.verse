using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

aaa := class:
    
    Version:int = 0 # 現在の統計テーブルのバージョン
    TotalWins:int = 0
    TotalLosses:int = 0

MakeUpdatedPlayerStat2<constructor>(OldStats:aaa)<transacts> := aaa:
    Version := OldStats.Version
    TotalWins := OldStats.TotalWins
    TotalLosses := OldStats.TotalLosses

test_device := class(creative_device):
    # 爆弾系
    @editable
    ExplosiveDevicesA:[]explosive_device = array{}
    @editable
    ExplosiveDevicesB:[]explosive_device = array{}
    @editable
    LimitDevice:timed_objective_device = timed_objective_device{}

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

    BombEvent:event() = event(){}
    Event:event() = event(){}


    OnBegin<override>()<suspends>:void=
        Sleep(5.0)
        Print("無効か")
        if(Player := GetPlayspace().GetPlayers()[0]):
            LimitDevice.Disable(Player)
    

    
    # OnTriggered(OAgent:?agent):void=
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
                

