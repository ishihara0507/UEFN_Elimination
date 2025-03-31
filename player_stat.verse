using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

player_stat := class<final><persistable>:
    
    Version:int = 0 # 現在の統計テーブルのバージョン

    # 前のラウンドの状況を把握するためのデータ
    IsPrevWin:logic = false # 前のラウンドで勝利したか否かを保持する（与えるクレジットの量を変えるため）
    IsPrevDeath:logic = false # 前のラウンドでデスしたかを保持する（敗北した場合、デスしたか否かによってクレジットの量が変わるから）

    # 今回の試合のデータ系（ラウンドの仕掛けを使うので、クラス変数などでデータを保持できないから）
    RoundCount:int = 0 # 試合の現在のラウンド数
    RoundWins:int = -1 # このプレイヤーが所属するチームが何ラウンド勝利したかを保持。試合が始まっているかを判定するために必要不可欠。初期値は-1。
    CurrentGold:int = 800 # その試合での所持金を保持する
    CurrentKills:int = 0
    CurrentDeaths:int = 0
    CurrentStartBombs:int = 0
    CurrentStopBombs:int = 0
    CurrentRarityPullsArray:[]int = array{0, 0, 0, 0, 0, 0, 0}

    # 全試合のデータ系
    TotalWins:int = 0
    TotalLosses:int = 0
    TotalKills:int = 0
    TotalDeaths:int = 0
    TotalStartBombs:int = 0
    TotalStopBombs:int = 0
    TotalRarityPullsArray:[]int = array{0, 0, 0, 0, 0, 0, 0} # レアリティごとに引いた回数を保持（合計値はガチャを引いた回数になる）
    
    # ペナルティ系
    # InMatch:logic = false # 試合中か否かを保持。試合中に抜けたらこれが true のままロビーに参加してくることになる。
    # PenaltyEndTime:float = -1.0 # ペナルティが解除される日時

    ### ↓ バージョンアップで使わなくなったデータ ###

    # 武器プリセット系
    Preset0:[]weapon_enum = array{weapon_enum.PumpShotgun_L1, weapon_enum.SideArmPistol_L1, weapon_enum.SubmachineGun_L1, weapon_enum.AssaultRifle_L1, weapon_enum.FalconEyeSniper_L1}
    Preset1:[]weapon_enum = array{}
    Preset2:[]weapon_enum = array{}
    Preset3:[]weapon_enum = array{}
    Preset4:[]weapon_enum = array{}

    # この配列は公開マップでバグったので使わないことにした。
    # 同じセッション中はちゃんと機能するが、別のセッションになるとマップに入った時点で空になった。0番目の配列が空になったので、初期化でもない。
    WeaponPresets:[][]weapon_enum = array: # 武器のプリセット登録を保存。ここの要素の数が登録できるプリセットの個数になる
        array{}
        array{}
        array{}
        array{}
        array{}

# 前の player_stats_table と同じ値を持つ新しい player_stats_table を作成するコンストラクタ関数
MakeUpdatedPlayerStat<constructor>(OldStats:player_stat)<transacts> := player_stat:
    Version := OldStats.Version
    
    # 前のラウンドの状況を把握するためのデータ系
    IsPrevWin := OldStats.IsPrevWin
    IsPrevDeath := OldStats.IsPrevDeath

    # 今回の試合のデータ系
    RoundCount := OldStats.RoundCount
    RoundWins := OldStats.RoundWins
    CurrentGold := OldStats.CurrentGold
    CurrentKills := OldStats.CurrentKills
    CurrentDeaths := OldStats.CurrentDeaths
    CurrentStartBombs := OldStats.CurrentStartBombs
    CurrentStopBombs := OldStats.CurrentStopBombs
    CurrentRarityPullsArray := OldStats.CurrentRarityPullsArray

    # 全試合のデータ系
    TotalWins := OldStats.TotalWins
    TotalLosses := OldStats.TotalLosses
    TotalKills := OldStats.TotalKills
    TotalDeaths := OldStats.TotalDeaths
    TotalStartBombs := OldStats.TotalStartBombs
    TotalStopBombs := OldStats.TotalStopBombs
    TotalRarityPullsArray := OldStats.TotalRarityPullsArray
    
    # ペナルティ系
    # PenaltyEndTime := OldStats.PenaltyEndTime

    ### ↓ バージョンアップで使わなくなったデータ ###

    # 武器プリセット系
    Preset0 := OldStats.Preset0
    Preset1 := OldStats.Preset1
    Preset2 := OldStats.Preset2
    Preset3 := OldStats.Preset3
    Preset4 := OldStats.Preset4

    # 武器プリセット（バグったから使わない）
    WeaponPresets := OldStats.WeaponPresets

# プレイヤーを、そのプレイヤーの統計テーブルにマッピングします。
var PlayerStatMap : weak_map(player, player_stat) = map{}