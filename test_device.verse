using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

bb := struct<concrete>:
    @editable
    a:int = 0
    @editable
    b:int = 1

aaa := class<concrete>:
    @editable
    a:int = 0
    @editable
    b:int = 0

test_device:= class(creative_device):

    @editable
    v:[]bb = array{}

    @editable
    var AA:[]aaa = array{}

    e:event(int) := event(int){}

    OnBegin<override>()<suspends>:void=
        # TeamCollection := GetPlayspace().GetTeamCollection()
        # Players := GetPlayspace().GetPlayers()
        # if(Team := TeamCollection.GetTeam[Players[0]], l := TeamCollection.GetAgents[Team].Length):
        #     Print("プレイヤー退出前のチームの長さ: {l}")
        # loop: # プレイヤー退出待ち
        #     LeavingAgent := GetPlayspace().PlayerRemovedEvent().Await()
        #     if(Team := TeamCollection.GetTeam[LeavingAgent], l2 := TeamCollection.GetAgents[Team].Length):
        #         Print("プレイヤー退出後のチームの長さ: {l2}")
        var Count:int = 10
        loop:
            Print("{Count}")
            Sleep(1.0)
            set Count -= 1
            if(Count <= 0):
                break
        Players := GetPlayspace().GetPlayers()
        if. Players[0].SendToLobby()
    
    Wait(c:int)<suspends>:void=
        Sleep(5.0)
        e.Signal(c)
