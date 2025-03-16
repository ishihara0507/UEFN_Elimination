using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

player_stat := class<final><persistable>:
    
    Version:int = 0 # 現在の統計テーブルのバージョン

    # 今回の試合のデータ系（ラウンドの仕掛けを使うので、クラス変数などでデータを保持できないから）
    RoundCount:int = -1 # 試合の現在のラウンド数
    RoundWins:int = -1 # このプレイヤーが所属するチームが何ラウンド勝利したかを保持
    CurrentKills:int = -1
    CurrentDeaths:int = -1
    CurrentStartBombs:int = -1
    CurrentStopBombs:int = -1

    # 全試合のデータ系
    TotalWins:int = 0
    TotalLosses:int = 0
    TotalKills:int = 0
    TotalDeaths:int = 0
    TotalStartBombs:int = 0
    TotalStopBombs:int = 0

    # ペナルティ系
    # InMatch:logic = false # 試合中か否かを保持。試合中に抜けたらこれが true のままロビーに参加してくることになる。
    # PenaltyEndTime:float = -1.0 # ペナルティが解除される日時

    WeaponPresets:[][]weapon_enum = array: # 武器のプリセット登録を保存。ここの要素の数が登録できるプリセットの個数になる
        array{weapon_enum.PumpShotgun_L1, weapon_enum.SideArmPistol_L1, weapon_enum.SubmachineGun_L1, weapon_enum.AssaultRifle_L1, weapon_enum.FalconEyeSniper_L1}
        array{}
        array{}
        array{}
        array{}

# 前の player_stats_table と同じ値を持つ新しい player_stats_table を作成するコンストラクタ関数
MakeUpdatedPlayerStat<constructor>(OldStats:player_stat)<transacts> := player_stat:
    Version := OldStats.Version

    # 今回の試合のデータ系
    RoundCount := OldStats.RoundCount
    RoundWins := OldStats.RoundWins
    CurrentKills := OldStats.CurrentKills
    CurrentDeaths := OldStats.CurrentDeaths
    CurrentStartBombs := OldStats.CurrentStartBombs
    CurrentStopBombs := OldStats.CurrentStopBombs

    # 全試合のデータ系
    TotalWins := OldStats.TotalWins
    TotalLosses := OldStats.TotalLosses
    TotalKills := OldStats.TotalKills
    TotalDeaths := OldStats.TotalDeaths
    TotalStartBombs := OldStats.TotalStartBombs
    TotalStopBombs := OldStats.TotalStopBombs

    # ペナルティ系
    # PenaltyEndTime := OldStats.PenaltyEndTime

    # 武器プリセット
    WeaponPresets := OldStats.WeaponPresets

# プレイヤーを、そのプレイヤーの統計テーブルにマッピングします。
var PlayerStatMap : weak_map(player, player_stat) = map{}