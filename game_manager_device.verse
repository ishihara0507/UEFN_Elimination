using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }

Stage := struct<concrete>:
    Teleporters1:[]teleporter_device = array{}
    Teleporters2:[]teleporter_device = array{}

game_manager_device := class(creative_device):

    ### @editable --------------------------------------------------
    @editable
    MatchPlayerNum:int = 2

    @editable
    WeaponSelectTime:int = 60

    @editable
    Stages:[]Stage = array{}
    
    @editable
    MessageHud:hud_message_device = hud_message_device{}
    @editable
    CountDownHud:hud_message_device = hud_message_device{}
    ### ------------------------------------------------------------

    ### ゲーム中に変動する変数 -------------------------------------
    var GamePlayers:[]player = array{}

    var Team1:[]player = array{}
    var Team2:[]player = array{}
    ### ------------------------------------------------------------

    S2M<localizes>(S:string):message = "{S}"

    # プレイヤーが揃うまで待機する関数
    OnBegin<override>()<suspends>:void=
        loop:
            Players := GetPlayspace().GetPlayers()
            if(Players.Length >= MatchPlayerNum):
                Print("プレイヤーが揃ったのでゲームを開始する")
                MessageHud.Show(S2M("Players are ready. Starting the game."))
                var Count:int = 3
                loop:
                    CountDownHud.Show(S2M("{Count}"))
                    Sleep(1.0)
                    set Count -= 1
                CountDownHud.Hide()
                set GamePlayers = Player
                StageSelect()
                break
            NeedPlayerNum:int = MatchPlayerNum - Players.Length
            MessageHud.Show(S2M("Waiting for {NeedPlayerNum} more players to join.")) # プレイヤー全員にHUDを表示
            Sleep(1.0)

    # ステージをランダムで選択して、その場所にプレイヤーをテレポートさせる関数
    # チーム分けもする
    StageSelect():void=
        if(S := Shuffle(Stages)[0]):
            Players := Shuffle(GamePlayers)
            if:
                TeamPlayerNum := Int[MatchPlayerNum * 1.0 / 2.0]
                T1 := Players.Slice[0, TeamPlayerNum - 1]
                T2 := Players.Slice[TeamPlayerNum]
            then:
                set Team1 = T1
                set Team2 = T2

                for(Index := 0..Team1.Length-1):
                    if(Player := Team1[Index], Teleporter := S.Teleporters1[Index]):
                        Teleporter.Teleport(Player)
                for(Index := 0..Team2.Length-1):
                    if(Player := Team2[Index], Teleporter := S.Teleporters1[Index]):
                        Teleporter.Teleport(Player)
        else:
            Print("ステージ選択の際にエラーが発生しました。")