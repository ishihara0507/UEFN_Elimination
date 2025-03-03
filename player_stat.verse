using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

player_stat := class<final><persistable>:
    
    Version:int = 0 # 現在の統計テーブルのバージョン

    # 試合データ系
    TotalWins:int = 0
    TotalLosses:int = 0
    TotalKills:int = 0
    TotalDeaths:int = 0
    TotalStartBombs:int = 0
    TotalStopBombs:int = 0

    # ペナルティ系
    InMatch:logic = false # 試合中か否かを保持。試合中に抜けたらこれが true のままロビーに参加してくることになる。
    PenaltyEndTime:float = -1.0 # ペナルティが解除される日時

    WeaponPresets:[][]weapon_enum = array: # 武器のプリセット登録を保存
        array{weapon_enum.DMR_L1, weapon_enum.DMR_L1, weapon_enum.DMR_L1, weapon_enum.DMR_L1, weapon_enum.DMR_L1}
        array{}
        array{}

# 前の player_stats_table と同じ値を持つ新しい player_stats_table を作成するコンストラクタ関数
MakeUpdatedPlayerStat<constructor>(OldStats:player_stat)<transacts> := player_stat:
    Version := OldStats.Version
    TotalWins := OldStats.TotalWins
    TotalLosses := OldStats.TotalLosses
    TotalKills := OldStats.TotalKills
    TotalDeaths := OldStats.TotalDeaths
    TotalStartBombs := OldStats.TotalStartBombs
    TotalStopBombs := OldStats.TotalStopBombs
    PenaltyEndTime := OldStats.PenaltyEndTime
    WeaponPresets := OldStats.WeaponPresets

# プレイヤーを、そのプレイヤーの統計テーブルにマッピングします。
var PlayerStatMap : weak_map(player, player_stat) = map{}