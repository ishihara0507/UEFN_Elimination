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
    Trigger0:trigger_device = trigger_device{}

    var RobbyAgents:[]agent = array{}

    OnBegin<override>()<suspends>:void=
        Trigger0.TriggeredEvent.Subscribe(OnTriggered0) ###

        loop:
            Sleep(3.0)
            if(Fort := RobbyAgents[0].GetFortCharacter[]):
                Pos:= Fort.GetTransform().Translation
                Rot:= Fort.GetTransform().Rotation

                Print("NPCをリスポーン")
                if. RobbyAgents[0].Respawn(Pos, Rot)

    OnTriggered0(OAgent:?agent):void=
        if(Agent := OAgent?):
            set RobbyAgents += array{Agent}