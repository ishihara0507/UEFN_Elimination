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
    @editable
    GachaBillBoard:billboard_device = billboard_device{}

    PlayerStatsManager:player_stat_manager = player_stat_manager{}

    OnBegin<override>()<suspends>:void=
        EnglishBtn.InteractedWithEvent.Subscribe(OnPushEnglishBtn)
        JapaneseBtn.InteractedWithEvent.Subscribe(OnPushJapaneseBtn)

    # ボタンを押したときに実行される関数
    OnPushEnglishBtn(Agent:agent):void=
        PlayerReferenceDevice.Register(Agent)

        PlayerStatsManager.InitializePlayerStat(Agent)
        
        var Str:string = "【BATTLE】\n"
        var GachaStr:string = "【GACHA(in the match)】\n"
        OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
        if(PlayerStats := OPlayerStats?):
            set Str += "Matches: {PlayerStats.TotalWins + PlayerStats.TotalLosses}\n"
            set Str += "Wins: {PlayerStats.TotalWins}\n"
            set Str += "Kills: {PlayerStats.TotalKills}, Deaths: {PlayerStats.TotalDeaths}\n"
            set Str += "Bomb plants: {PlayerStats.TotalStartBombs}\n"
            set Str += "Bomb defuses: {PlayerStats.TotalStopBombs}"

            # ガチャ系統計
            TotalRarityPullsArray := PlayerStats.TotalRarityPullsArray
            var TotalGachaCount:int = 0
            for(Pulls:TotalRarityPullsArray):
                set TotalGachaCount += Pulls
            set GachaStr += "GachaPulls: {TotalGachaCount}\n"
            if:
                set GachaStr += "Common: {TotalRarityPullsArray[0]}\n"
                set GachaStr += "Uncommon: {TotalRarityPullsArray[1]}, Rare: {TotalRarityPullsArray[2]}\n"
                set GachaStr += "Epic: {TotalRarityPullsArray[3]}, Legendary: {TotalRarityPullsArray[4]}\n"
                set GachaStr += "Mythic: {TotalRarityPullsArray[5]}, Exotic: {TotalRarityPullsArray[6]}"
                
            BillBoard.SetText(S2M(Str))
            GachaBillBoard.SetText(S2M(GachaStr))


    # ボタンを押したときに実行される関数
    OnPushJapaneseBtn(Agent:agent):void=
        PlayerReferenceDevice.Register(Agent)
        
        PlayerStatsManager.InitializePlayerStat(Agent)

        var Str:string = "【戦闘】\n"
        var GachaStr:string = "【ガチャ(試合中)】\n"
        OPlayerStats := PlayerStatsManager.GetPlayerStats(Agent)
        if(PlayerStats := OPlayerStats?):
            set Str += "試合: {PlayerStats.TotalWins + PlayerStats.TotalLosses}\n"
            set Str += "勝利: {PlayerStats.TotalWins}\n"
            set Str += "キル: {PlayerStats.TotalKills}, デス: {PlayerStats.TotalDeaths}\n"
            set Str += "爆弾設置: {PlayerStats.TotalStartBombs}\n"
            set Str += "爆弾解除: {PlayerStats.TotalStopBombs}"

            # ガチャ系統計
            TotalRarityPullsArray := PlayerStats.TotalRarityPullsArray
            var TotalGachaCount:int = 0
            for(Pulls:TotalRarityPullsArray):
                set TotalGachaCount += Pulls
            set GachaStr += "引いた回数: {TotalGachaCount}\n"
            if:
                set GachaStr += "コモン: {TotalRarityPullsArray[0]}\n"
                set GachaStr += "アンコモン: {TotalRarityPullsArray[1]}, レア: {TotalRarityPullsArray[2]}\n"
                set GachaStr += "エピック: {TotalRarityPullsArray[3]}, レジェンド: {TotalRarityPullsArray[4]}\n"
                set GachaStr += "ミシック: {TotalRarityPullsArray[5]}, エキゾチック: {TotalRarityPullsArray[6]}"

            BillBoard.SetText(S2M(Str))
            GachaBillBoard.SetText(S2M(GachaStr))
