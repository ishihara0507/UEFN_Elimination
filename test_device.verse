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

    @editable
    Trigger:trigger_device = trigger_device{}

    @editable
    Trigger1:trigger_device = trigger_device{}

    OnBegin<override>()<suspends>:void=
        # TeamCollection := GetPlayspace().GetTeamCollection()
        # Players := GetPlayspace().GetPlayers()
        # if(Team := TeamCollection.GetTeam[Players[0]], l := TeamCollection.GetAgents[Team].Length):
        #     Print("プレイヤー退出前のチームの長さ: {l}")
        # loop: # プレイヤー退出待ち
        #     LeavingAgent := GetPlayspace().PlayerRemovedEvent().Await()
        #     if(Team := TeamCollection.GetTeam[LeavingAgent], l2 := TeamCollection.GetAgents[Team].Length):
        #         Print("プレイヤー退出後のチームの長さ: {l2}")

        Trigger.TriggeredEvent.Subscribe(OnTriggered)
        Trigger1.TriggeredEvent.Subscribe(OnTriggered1)

        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()
    
        Sleep(3.0)
        for(Index->Team:TeamArray):
            if(Num := TeamCollection.GetAgents[Team].Length):
                Print("チーム{Index}の人数: {Num}人")



    OnTriggered(OAgent:?agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        if(Agent := OAgent?):
            if. TeamCollection.AddToTeam[Agent, TeamArray[0]]

        for(Index->Team:TeamArray):
            if(Num := TeamCollection.GetAgents[Team].Length):
                Print("チーム{Index}の人数: {Num}人")

    
    OnTriggered1(OAgent:?agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        if(Agent := OAgent?):
            if. TeamCollection.AddToTeam[Agent, TeamArray[1]]
        
        for(Index->Team:TeamArray):
            if(Num := TeamCollection.GetAgents[Team].Length):
                Print("チーム{Index}の人数: {Num}人")