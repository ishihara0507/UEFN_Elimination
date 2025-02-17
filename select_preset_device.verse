using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }

select_preset_device := class(creative_device):



    PlayerStatsManager:player_stats_manager = player_stats_manager{}

    OnBegin<override>()<suspends>:void=

    # UIを作成する関数
    CreateUI():void=

    # UIを更新する関数
    UpdateUI():void=

    # ボタン入力を管理する関数
    HandleBtn()<suspends>:void=