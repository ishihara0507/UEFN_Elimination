using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Assets }

S2M<localizes>(S:string):message = "{S}"

presets_device := class(creative_device):

    @editable
    GameManagerDevice:game_manager_device = game_manager_device{}

    @editable
    PlayerPresetsUIMap:[player]presets_ui = map{}

    @editable
    Trigger:trigger_device = trigger_device{} # プリセット登録を行うUIを付与するトリガー

    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(OnTriggered)

    OnTriggered(OAgent:?agent):void=
        if(Agent := OAgent?):
            MakePresetsUI(Agent)

    # プリセットUIを作成する関数        
    MakePresetsUI(Agent:agent, ):presets_ui=






presets_ui := class:

    var Widget:widget = color_block{} # widget{}は初期値として使えないから、color_block{}を使っている

    WeaponPresets:[]weapon_enum = map{}

    LeftBtn:button_loud = button_loud{DefaultText:=S2M("Left")}
    SaveBtn:button_loud = button_loud{DefaultText:=S2M("Save")}
    DeleteBtn:button_loud = button_loud{DefaultText:=S2M("Delete")}
    RightBtn:button_loud = button_loud{DefaultText:=S2M("Right")}

    Init():void=
        set Widget = canvas:

        spawn{HandleArrowBtn()}


    # 矢印ボタンを押したら実行される関数
    HandleBtn()<suspends>:void=
        var SelectedBtn:string = ""

        race:
            KillEvent.Await()
            loop:
                race:
                    block:
                        LeftBtn.OnClick.Await()
                        set SelectedBtn = "Left"
                    block:
                        SaveBtnOnClick.Await()
                        set SelectedBtn = "Save"
                    block:
                        DeleteBtn.OnClick.Await()
                        set SelectedBtn = "Delete"
                    block:
                        RightBtn.OnClick.Await()
                        set SelectedBtn = "Right"
                if(SelectedBtn = "Left"):
                    # 左にページに進む処理
                    set Widget = canvas:
                else if(SelectedBtn = "Save"):
                    # プリセットを登録する処理
                else if(SelectedBtn = "Delete"):
                    # プリセットを削除する処理
                else if(SelectedBtn = "Right"):
                    # 右にページに進む処理