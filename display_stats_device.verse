using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

display_stats_device := class(creative_device):

    @editable
    EnglishBtn:button_device = button_device{}
    @editable
    JapaneseBtn:button_device = button_device{}

    @editable
    PlayerReferenceDevice:player_reference_device = player_reference_device{}

    @editable
    BillBoard:billboard_device = billboard_device{}

    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    OnBegin<override>()<suspends>:void=
        EnglishBtn.InteractedWithEvent.Subscribe(OnPushEnglishBtn)
        JapaneseBtn.InteractedWithEvent.Subscribe(OnPushJapaneseBtn)

    # ボタンを押したときに実行される関数
    OnPushEnglishBtn(Agent:agent):void=
        PlayerReferenceDevice.Register(Agent)

        var Str:string = ""
        OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
        if(PlayerStats := OPlayerStats?):
            set Str += "Matches: {PlayerStats.TotalWins + PlayerStats.TotalLosses}\n"
            set Str += "Wins: {PlayerStats.TotalWins}\n"
            set Str += "Kills: {PlayerStats.TotalKills}\n"
            set Str += "Deaths: {PlayerStats.TotalDeaths}\n"
            set Str += "Bomb plants: {PlayerStats.TotalStartBombs}\n"
            set Str += "Bomb defuses: {PlayerStats.TotalStopBombs}"

            BillBoard.SetText(S2M(Str))

    # ボタンを押したときに実行される関数
    OnPushJapaneseBtn(Agent:agent):void=
        PlayerReferenceDevice.Register(Agent)

        var Str:string = ""
        OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
        if(PlayerStats := OPlayerStats?):
            set Str += "試合: {PlayerStats.TotalWins + PlayerStats.TotalLosses}\n"
            set Str += "勝利: {PlayerStats.TotalWins}\n"
            set Str += "キル: {PlayerStats.TotalKills}\n"
            set Str += "デス: {PlayerStats.TotalDeaths}\n"
            set Str += "爆弾設置: {PlayerStats.TotalStartBombs}\n"
            set Str += "爆弾解除: {PlayerStats.TotalStopBombs}"

            BillBoard.SetText(S2M(Str))
