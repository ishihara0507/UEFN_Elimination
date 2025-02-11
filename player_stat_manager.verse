using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# 統計データを更新するためのクラス
player_stats_manager := class():

    # プレイヤーの統計データを返す関数（オプション型を返す）
    GetPlayerStats(Agent:agent):?player_stat=
        var PlayerStat:?player_stat = false
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            set PlayerStat = option{CurrentPlayerStat}
        return PlayerStat

    # すべてのプレイヤーの統計データを初期化する関数（あまり使い時はないかも？）
    InitializeAllPlayers(Players:[]player):void=
        for (Player:Players):
            InitializePlayerStat(Player)

    # 特定のプレイヤーの統計データを初期化する関数
    InitializePlayerStat(Agent:agent):void=
        if:
            Player := player[Agent]
            not PlayerStatMap[Player]
            set PlayerStatMap[Player] = player_stat{}

    ### 更新関数 -------------------------------------------------------
    # Version, 引数：なし
    # Version を１加算する
    UpdateVersionStat(Agent:agent):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                Version := CurrentPlayerStat.Version + 1
            if. set PlayerStatMap[Player] = NewStat

    # TotalWins, 引数：なし
    # TotalWins を１加算する
    UpdateTotalWinsStat(Agent:agent):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalWins := CurrentPlayerStat.TotalWins + 1
            if. set PlayerStatMap[Player] = NewStat
    
    # TotalLosses, 引数：なし
    # TotalLosses を１加算する
    UpdateTotalLossesStat(Agent:agent):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalLosses := CurrentPlayerStat.TotalLosses + 1
            if. set PlayerStatMap[Player] = NewStat

    # TotalKills, 引数：int
    # TotalKills に AddValue の値を加算する
    UpdateTotalKillsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalKills := CurrentPlayerStat.TotalKills + AddValue
            if. set PlayerStatMap[Player] = NewStat
    
    # TotalDeaths, 引数：int
    # TotalDeaths に AddValue の値を加算する
    UpdateTotalDeathsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalDeaths := CurrentPlayerStat.TotalDeaths + AddValue
            if. set PlayerStatMap[Player] = NewStat

    # InMatch, 引数：logic
    # InMatch を Flag に変更する
    UpdateInMatchStat(Agent:agent, Flag:logic):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                InMatch := Flag
            if. set PlayerStatMap[Player] = NewStat

    # PenaltyEndTime, 引数：float
    # PenaltyEndTime を EndTime に変更する
    UpdatePenaltyEndTimeStat(Agent:agent, EndTime:float):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                PenaltyEndTime := EndTime
            if. set PlayerStatMap[Player] = NewStat

    # WeaponPresets, 引数：int, []int
    # WeaponPresets の SetIndex 番目の要素を SetPreset に変更する
    UpdateWeaponPresetsStat(Agent:agent, SetIndex:int, SetPreset:[]int):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):

            var NewWeaponPresets:[][]int = array{}
            CurrentWeaponPresets := CurrentPlayerStat.WeaponPresets
            for(Index->Preset:CurrentWeaponPresets):
                if(Index = SetIndex):
                    set NewWeaponPresets += array{
                        SetPreset
                    }
                else:
                    set NewWeaponPresets += array{
                        Preset
                    }

            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                WeaponPresets := NewWeaponPresets
            if. set PlayerStatMap[Player] = NewStat

    # プレイヤーの統計データを初期値にリセットする関数
    ResetPlayerStat(Agent:agent):void=
        if:
            Player := player[Agent]
            PlayerStatMap[Player]
            set PlayerStatMap[Player] = player_stat{}