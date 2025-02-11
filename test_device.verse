using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

aaa := class:
    
    Version:int = 0 # 現在の統計テーブルのバージョン
    TotalWins:int = 0
    TotalLosses:int = 0

MakeUpdatedPlayerStat2<constructor>(OldStats:aaa)<transacts> := aaa:
    Version := OldStats.Version
    TotalWins := OldStats.TotalWins
    TotalLosses := OldStats.TotalLosses

test_device := class(creative_device):
    @editable
    Seconds:[]float = {180.0, 180.7, 181.1}
    

    OnBegin<override>()<suspends>:void=
        Sleep(3.0)

        for(Second:Seconds):
            if(S := Int[Second]):
                Print("int[] 結果:{S}")
                if(M := Ceil(S / 60)):
                    Print("Ceil 結果: {M}")
                if(M := Floor(S / 60)):
                    Print("Floor 結果: {M}")
            
