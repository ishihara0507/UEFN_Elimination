using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }

## テスト

Stage := struct<concrete>:
    Teleporters1:[]teleporter_device = array{}
    Teleporters2:[]teleporter_device = array{}

game_manager_device := class(creative_device):

    @editable
    MatchPlayerNum:int = 2

    @editable
    Stages:[]Stage = array{}

    @editable
    WaitingPlayerHud:hud_message_device = hud_message_device{}

    var GamePlayers:[]player = array{}

    OnBegin<override>()<suspends>:void=

        loop:
            Players := GetPlayspace().GetPlayers()
            if(Players.Length >= MatchPlayerNum):
                Print("プレイヤーが揃ったのでゲームを開始する")
                set GamePlayers = Players
                StageSelect()
                break
            Sleep(1.0)

    StageSelect():void=
        if(S := Shuffle(Stages)[0]):
            Players := Shuffle(GamePlayers)
            if:
                TeamPlayerNum := Int[MatchPlayerNum * 1.0 / 2.0]
                Team1 := Players.Slice[0, TeamPlayerNum - 1]
                Team2 := Players.Slice[TeamPlayerNum]
            then:
                for(Index := 0..Team1.Length-1):
                    if(Player := Team1[Index], Teleporter := S.Teleporters1[Index]):
                        Teleporter.Teleport(Player)
                for(Index := 0..Team2.Length-1):
                    if(Player := Team2[Index], Teleporter := S.Teleporters1[Index]):
                        Teleporter.Teleport(Player)
        else:
            Print("ステージ選択の際にエラーが発生しました。")