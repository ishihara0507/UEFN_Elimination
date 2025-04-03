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

    # IsPrevWin を IsWin にする
    UpdateIsPrevWinStat(Agent:agent, IsWin:logic):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                IsPrevWin := IsWin
            if. set PlayerStatMap[Player] = NewStat

    # IsPrevDeath を IsWin にする
    UpdateIsPrevDeathStat(Agent:agent, IsDeath:logic):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                IsPrevDeath := IsDeath
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
    
    # CurrentGold に AddValue の値を加算する
    UpdateCurrentGoldStat(Agent:agent, AddValue:int):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                CurrentGold := CurrentPlayerStat.CurrentGold + AddValue
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
       
    # CurrentRarityPullsArray の RarityIndex 番目に 1 を加算する
    UpdateCurrentRarityPullsArrayStat(Agent:agent, RarityIndex:int):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            var NewCurrentRarityPullsArray:[]int = array{0, 0, 0, 0, 0, 0, 0}
            
            OldCurrentRarityPullsArray := CurrentPlayerStat.CurrentRarityPullsArray
            for(Index->Pulls:OldCurrentRarityPullsArray):
                var AddValue:int = 0
                if(Index = RarityIndex):
                    set AddValue = 1
                if:
                    Count := OldCurrentRarityPullsArray[Index]
                    set NewCurrentRarityPullsArray[Index] =  Count + AddValue

            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                CurrentRarityPullsArray := NewCurrentRarityPullsArray
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
    
    # TotalRarityPullsArray に CurrentRarityPullsArray の値を加算する
    UpdateTotalRarityPullsArrayStat(Agent:agent):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            var NewTotalRarityPullsArray:[]int = array{0, 0, 0, 0, 0, 0, 0}

            OldTotalRarityPullsArray := CurrentPlayerStat.TotalRarityPullsArray
            CurrentRarityPullsArray := CurrentPlayerStat.CurrentRarityPullsArray
            for(Index := 0..OldTotalRarityPullsArray.Length - 1):
                if:
                    OldTotal := OldTotalRarityPullsArray[Index]
                    Current := CurrentRarityPullsArray[Index]
                    set NewTotalRarityPullsArray[Index] = OldTotal + Current

            NewStat := player_stat:
                MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                TotalRarityPullsArray := NewTotalRarityPullsArray
            if. set PlayerStatMap[Player] = NewStat

    # SetIndex 番目の Preset を SetPreset に変更する
    UpdatePresetStat(Agent:agent, SetIndex:int, SetPreset:[]weapon_enum):void=
        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            var NewStat:player_stat = player_stat{}
            
            case(SetIndex):
                0 =>
                    set NewStat = player_stat:
                        MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                        Preset0 := SetPreset
                1 =>
                    set NewStat = player_stat:
                        MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                        Preset1 := SetPreset
                2 =>
                    set NewStat = player_stat:
                        MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                        Preset2 := SetPreset
                3 =>
                    set NewStat = player_stat:
                        MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                        Preset3 := SetPreset
                4 =>
                    set NewStat = player_stat:
                        MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
                        Preset4 := SetPreset
                _ =>
                    set NewStat = CurrentPlayerStat # 何も変更しない

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

    # # WeaponPresets の SetIndex 番目の要素を SetPreset に変更する
    # UpdateWeaponPresetsStat(Agent:agent, SetIndex:int, SetPreset:[]weapon_enum):void=
    #     if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
    #         var NewWeaponPresets:[][]weapon_enum = array{}
    #         CurrentWeaponPresets := CurrentPlayerStat.WeaponPresets

    #         for(Index->Preset:CurrentWeaponPresets):
    #             if(Index = SetIndex):
    #                 set NewWeaponPresets += array{SetPreset}
    #             else:
    #                 set NewWeaponPresets += array{Preset}

    #         NewStat := player_stat:
    #             MakeUpdatedPlayerStat<constructor>(CurrentPlayerStat)
    #             WeaponPresets := NewWeaponPresets

    #         if. set PlayerStatMap[Player] = NewStat

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
                CurrentGold := 1000 # 初期値は 1000 にしておく
                CurrentKills := 0
                CurrentDeaths := 0
                CurrentStartBombs := 0
                CurrentStopBombs := 0
                CurrentRarityPullsArray := array{0, 0, 0, 0, 0, 0, 0}
            if. set PlayerStatMap[Player] = NewStat

    ### デバッグ用 ------------------------------------------------------------------------------------
    # WeaponPresetsの中身を表示する関数
    ShowPresets(Agent:agent):string=
        var Str:string = ""

        if(Player := player[Agent], Player.IsActive[], CurrentPlayerStat := PlayerStatMap[Player]):
            var Preset:[]weapon_enum = array{}
            for(Index := 0..4):
                var Tmp:string = "Preset{Index}:\n"
                case(Index):
                    0 => set Preset = CurrentPlayerStat.Preset0
                    1 => set Preset = CurrentPlayerStat.Preset1
                    2 => set Preset = CurrentPlayerStat.Preset2
                    3 => set Preset = CurrentPlayerStat.Preset3
                    4 => set Preset = CurrentPlayerStat.Preset4
                    _ => # 何もしない
                for(Weapon:Preset):
                    set Tmp += "{Weapon.ToString()}\n"
                Print(Tmp)
                set Str += Tmp

        return Str

    # すべての持続データを表示する関数
    ShowStats(Agent:agent):void=
        OPlayerStats := GetPlayerStats(Agent)
        if(PlayerStats := OPlayerStats?):
            Print("Version: {PlayerStats.Version}")

            Print("前のラウンドの状況を把握するためのデータ系")
            if(PlayerStats.IsPrevWin?):
                Print("IsPrevWin: true")
            else:
                Print("IsPrevWin: else")
            if(PlayerStats.IsPrevDeath?):
                Print("IsPrevDeath: true")
            else:
                Print("IsPrevDeath: else")

            Print("試合ごとに変わるデータ系")
            Print("RoundCount: {PlayerStats.RoundCount}")
            Print("RoundWins: {PlayerStats.RoundWins}")
            Print("CurrentGold: {PlayerStats.CurrentGold}")
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