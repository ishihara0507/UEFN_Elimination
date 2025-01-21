using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

### 試したいこと
# LeavingAgent := GetPlayspace().PlayerRemovedEvent().Await()
# if. (Team := TeamCollection.GetTeam[LeavingAgent], set TeamRemainingMap[Team] -= 1)
# 退出したプレイヤーのTeamはちゃんと取得できるのか？
# ↑ができなかったら、ラウンドが始まった瞬間にteamとplayerをmapとして別で管理すればおっけー



test_device:= class(creative_device):

    OnBegin<override>()<suspends>:void=
        # TeamCollection := GetPlayspace().GetTeamCollection()
        # Players := GetPlayspace().GetPlayers()
        # if(Team := TeamCollection.GetTeam[Players[0]], l := TeamCollection.GetAgents[Team].Length):
        #     Print("プレイヤー退出前のチームの長さ: {l}")
        # loop: # プレイヤー退出待ち
        #     LeavingAgent := GetPlayspace().PlayerRemovedEvent().Await()
        #     if(Team := TeamCollection.GetTeam[LeavingAgent], l2 := TeamCollection.GetAgents[Team].Length):
        #         Print("プレイヤー退出後のチームの長さ: {l2}")

        Print("硬直")
        Players := GetPlayspace().GetPlayers()
        if(Fort := Players[0].GetFortCharacter[]):
            Fort.PutInStasis(stasis_args{AllowTurning := false, AllowFalling := true, AllowEmotes := true})

        Sleep(10)

        Print("解除")
        if(Fort := Players[0].GetFortCharacter[]):
            Fort.PutInStasis(stasis_args{AllowTurning := true, AllowFalling := true, AllowEmotes := true})