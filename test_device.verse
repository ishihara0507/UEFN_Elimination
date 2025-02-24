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
    RoundResultDevice:round_ui_device = round_ui_device{}

    @editable
    UITringger:trigger_device = trigger_device{}

    @editable
    HudDevice:hud_message_device = hud_message_device{}

    @editable
    Trigger:trigger_device = trigger_device{}
    @editable
    Trigger2:trigger_device = trigger_device{}

    @editable
    MaxGoldsGranter:item_granter_device = item_granter_device{} # ゴールドを初期値に戻すため
    @editable
    GoldCondBtn:conditional_button_device = conditional_button_device{} # プレイヤーの所持ゴールドの枚数を取得するための条件付きボタン

    Event:event() = event(){}

    var Map:[agent]int = map{}

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)
        Trigger2.TriggeredEvent.Subscribe(OnTriggered2)
        

    OnTriggered(OAgent:?agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        TeamArray := TeamCollection.GetTeams()

        var TeamWinsMap:[team]int = map{}
        RoundCount := 1
        ORoundWinTeam := option{TeamArray[0]}

        for(Index->Team:TeamArray):
            if(Index = 0):
                if. set TeamWinsMap[Team] = 3
            else:
                if. set TeamWinsMap[Team] = 0

        return

            
    OnTriggered2(OAgent:?agent):void=
        if(Agent := OAgent?):
            if(Hud := RoundResultDevice.WinMTHudDevices[0]):
                # Hud.SetDisplayTime(10.0)
                Hud.Show(Agent)
            return

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
