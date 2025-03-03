using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# 統計データを更新するためのクラス
player_stat_manager := class():

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
        then:
            Print("新しく持続データを紐づけた")
        else:
            Print("すでに持続データが紐づいている")

    ### 更新関数 -------------------------------------------------------
    # Version を１加算する
    UpdateVersionStat(Agent:agent):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                Version := CurrentPlayerStat.Version + 1
            if. set PlayerStatMap[Player] = NewStat

    # TotalWins を１加算する
    UpdateTotalWinsStat(Agent:agent):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalWins := CurrentPlayerStat.TotalWins + 1
            if. set PlayerStatMap[Player] = NewStat
    
    # TotalLosses を１加算する
    UpdateTotalLossesStat(Agent:agent):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalLosses := CurrentPlayerStat.TotalLosses + 1
            if. set PlayerStatMap[Player] = NewStat

    # TotalKills に AddValue の値を加算する
    UpdateTotalKillsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalKills := CurrentPlayerStat.TotalKills + AddValue
            if. set PlayerStatMap[Player] = NewStat
    
    # TotalDeaths に AddValue の値を加算する
    UpdateTotalDeathsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalDeaths := CurrentPlayerStat.TotalDeaths + AddValue
            if. set PlayerStatMap[Player] = NewStat

    # TotalStartBombs に AddValue の値を加算する
    UpdateTotalStartBombsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalStartBombs := CurrentPlayerStat.TotalStartBombs + AddValue
            if. set PlayerStatMap[Player] = NewStat
    
    # TotalStopBombs に AddValue の値を加算する
    UpdateTotalStopBombsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalStopBombs := CurrentPlayerStat.TotalStopBombs + AddValue
            if. set PlayerStatMap[Player] = NewStat

    # InMatch を Flag に変更する
    UpdateInMatchStat(Agent:agent, Flag:logic):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                InMatch := Flag
            if. set PlayerStatMap[Player] = NewStat

    # PenaltyEndTime を EndTime に変更する
    UpdatePenaltyEndTimeStat(Agent:agent, EndTime:float):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                PenaltyEndTime := EndTime
            if. set PlayerStatMap[Player] = NewStat

    # WeaponPresets の SetIndex 番目の要素を SetPreset に変更する
    UpdateWeaponPresetsStat(Agent:agent, SetIndex:int, SetPreset:[]weapon_enum):void=
        if(Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            var NewWeaponPresets:[][]weapon_enum = array{}
            CurrentWeaponPresets := CurrentPlayerStat.WeaponPresets

            for(Index->Preset:CurrentWeaponPresets):
                if(Index = SetIndex):
                    set NewWeaponPresets += array{SetPreset}
                else:
                    set NewWeaponPresets += array{Preset}

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



    ### デバッグ用 ------------------------------------------------------------------------------------
    # WeaponPresetsの中身を表示する関数
    ShowPresets(OAgent:?agent):void=
        if(Agent := OAgent?, Player := player[Agent], CurrentPlayerStat := PlayerStatMap[Player]):
            for(Index->Preset:CurrentPlayerStat.WeaponPresets):
                Print("プリセット{Index}:")
                for(Index2->Weapon:Preset):
                    Print("{Index2}番目: {Weapon.ToString()}")
        else:
            Print("持続データが見つからない")