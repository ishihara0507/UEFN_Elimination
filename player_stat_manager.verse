using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# 統計データを更新するためのクラス
player_stat_manager := class():

    # プレイヤーの統計データを返す関数（オプション型を返す）
    GetPlayerStats(Agent:agent):?player_stat=
        var PlayerStat:?player_stat = false
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
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
            Player.IsActive[]
            not PlayerStatMap[Player]
            set PlayerStatMap[Player] = player_stat{}
        then:
            Print("新しく持続データを紐づけた")
        else:
            Print("すでに持続データが紐づいている")

    ### 更新関数 -------------------------------------------------------
    # Version を１加算する
    UpdateVersionStat(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                Version := CurrentPlayerStat.Version + 1
            if. set PlayerStatMap[Player] = NewStat

    # RoundCount を１加算する
    UpdateRoundCountStat(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                RoundCount := CurrentPlayerStat.RoundCount + 1
            if. set PlayerStatMap[Player] = NewStat

    # RoundWins に AddValue の値を加算する
    UpdateRoundWinsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                RoundWins := CurrentPlayerStat.RoundWins + AddValue
            if. set PlayerStatMap[Player] = NewStat

    # CurrentKills を１加算する
    UpdateCurrentKillsStat(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                CurrentKills := CurrentPlayerStat.CurrentKills + 1
            if. set PlayerStatMap[Player] = NewStat

    # CurrentDeaths を１加算する
    UpdateCurrentDeathsStat(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                CurrentDeaths := CurrentPlayerStat.CurrentDeaths + 1
            if. set PlayerStatMap[Player] = NewStat
            
    # CurrentStartBombs を１加算する
    UpdateCurrentStartBombsStat(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                CurrentStartBombs := CurrentPlayerStat.CurrentStartBombs + 1
            if. set PlayerStatMap[Player] = NewStat
            
    # CurrentStopBombs を１加算する
    UpdateCurrentStopBombsStat(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                CurrentStopBombs := CurrentPlayerStat.CurrentStopBombs + 1
            if. set PlayerStatMap[Player] = NewStat

    # TotalWins を１加算する
    UpdateTotalWinsStat(Agent:agent):void=
        Print("UpdateTotalWinsStatが呼び出された")
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalWins := CurrentPlayerStat.TotalWins + 1
            if. set PlayerStatMap[Player] = NewStat
    
    # TotalLosses を１加算する
    UpdateTotalLossesStat(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalLosses := CurrentPlayerStat.TotalLosses + 1
            if. set PlayerStatMap[Player] = NewStat

    # TotalKills に AddValue の値を加算する
    UpdateTotalKillsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalKills := CurrentPlayerStat.TotalKills + AddValue
            if. set PlayerStatMap[Player] = NewStat
    
    # TotalDeaths に AddValue の値を加算する
    UpdateTotalDeathsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalDeaths := CurrentPlayerStat.TotalDeaths + AddValue
            if. set PlayerStatMap[Player] = NewStat

    # TotalStartBombs に AddValue の値を加算する
    UpdateTotalStartBombsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalStartBombs := CurrentPlayerStat.TotalStartBombs + AddValue
            if. set PlayerStatMap[Player] = NewStat
    
    # TotalStopBombs に AddValue の値を加算する
    UpdateTotalStopBombsStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalStopBombs := CurrentPlayerStat.TotalStopBombs + AddValue
            if. set PlayerStatMap[Player] = NewStat

    # # InMatch を Flag に変更する
    # UpdateInMatchStat(Agent:agent, Flag:logic):void=
    #     if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
    #         NewStat := player_stat:
    #             MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
    #             InMatch := Flag
    #         if. set PlayerStatMap[Player] = NewStat

    # # PenaltyEndTime を EndTime に変更する
    # UpdatePenaltyEndTimeStat(Agent:agent, EndTime:float):void=
    #     if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
    #         NewStat := player_stat:
    #             MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
    #             PenaltyEndTime := EndTime
    #         if. set PlayerStatMap[Player] = NewStat

    # WeaponPresets の SetIndex 番目の要素を SetPreset に変更する
    UpdateWeaponPresetsStat(Agent:agent, SetIndex:int, SetPreset:[]weapon_enum):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
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
            Player.IsActive[]
            PlayerStatMap[Player]
            set PlayerStatMap[Player] = player_stat{}

    # 試合ごとに初期化されるデータを、試合開始前または試合開始後という状態に変更する関数
    ResetGameStats(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                RoundWins := -1
            if. set PlayerStatMap[Player] = NewStat
    
    # 試合ごとに初期化されるデータを、試合開始直後という状態に変更する関数（プレイヤーが揃ったという意味）
    SetGameStats(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                RoundCount := 0
                RoundWins := 0
                CurrentKills := 0
                CurrentDeaths := 0
                CurrentStartBombs := 0
                CurrentStopBombs := 0
            if. set PlayerStatMap[Player] = NewStat

    ### デバッグ用 ------------------------------------------------------------------------------------
    # WeaponPresetsの中身を表示する関数
    ShowPresets(Agent:agent):string=
        var Str:string = ""

        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            for(Index->Preset:CurrentPlayerStat.WeaponPresets, Index = 0): ### Index = 0 追加
                set Str += "プリセット{Index}, 長さ{Preset.Length}:\n"
                for(Index2->Weapon:Preset):
                    set Str += "{Index2}番目: {Weapon.ToString()}\n"
            Print(Str)
        else:
            Print("持続データが見つからない")
        
        return Str

    # すべての持続データを表示する関数
    ShowStats(Agent:agent):void=
        OPlayerStats := GetPlayerStats(Agent)
        if(PlayerStats := OPlayerStats?):
            Print("Version: {PlayerStats.Version}")

            Print("試合ごとに変わるデータ系")
            Print("RoundCount: {PlayerStats.RoundCount}")
            Print("RoundWins: {PlayerStats.RoundWins}")
            Print("CurrentKills: {PlayerStats.CurrentKills}")
            Print("CurrentDeaths: {PlayerStats.CurrentDeaths}")
            Print("CurrentStartBombs: {PlayerStats.CurrentStartBombs}")
            Print("CurrentStopBombs: {PlayerStats.CurrentStopBombs}")

            Print("統計データ系")
            Print("TotalWins: {PlayerStats.TotalWins}")
            Print("TotalLosses: {PlayerStats.TotalLosses}")
            Print("TotalKills: {PlayerStats.TotalKills}")
            Print("TotalDeaths: {PlayerStats.TotalDeaths}")
            Print("TotalStartBombs: {PlayerStats.TotalStartBombs}")
            Print("TotalStopBombs: {PlayerStats.TotalStopBombs}")

            ShowPresets(Agent) # プリセットの表示