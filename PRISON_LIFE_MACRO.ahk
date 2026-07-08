; made by @Idkwhattonamethis223 (youtube) / @cooluser75_10906 (discord)
; this is lowkey hardcoded

#Requires AutoHotkey v2.0
#SingleInstance Force
;#MaxThreadsPerHotkey 2
A_HotkeyInterval := 0

KeyHistory 0
ListLines 0

ProcessSetPriority "High"
SendMode "Input"

SetKeyDelay -1, -1
SetMouseDelay -1
SetDefaultMouseSpeed 0
SetWinDelay -1
SetControlDelay -1

DllCall("ntdll\NtSetTimerResolution", "UInt", 10000, "Int", 1, "UInt*", &CurrentResolution := 0)

; -- Settings load --
SettingSavePathINI := A_ScriptDir "\SettingsConfig.ini"

; -- Variables --
ScriptActive := false
ShiftHolder := false
ShowUi := false

CheckBoxShiftHolderBOOL := false
CheckBoxLagSwitchBOOL := false
CheckBoxSoundBeepBOOL := false
CheckBoxShiftHolder := ""
CheckBoxLagSwitch := ""
CheckBoxSoundBeep := ""

GunSlot1CheckboxBool := false
GunSlot2CheckboxBool := false
GunSlot3CheckboxBool := false
GunSlot4CheckboxBool := false
GunSlot5CheckboxBool := false
GunSlot6CheckboxBool := false
GunSlot7CheckboxBool := false
GunSlot8CheckboxBool := false
GunSlot9CheckboxBool := false
GunSlot10CheckboxBool := false

GunSlot1Checkbox := ""
GunSlot2Checkbox := ""
GunSlot3Checkbox := ""
GunSlot4Checkbox := ""
GunSlot5Checkbox := ""
GunSlot6Checkbox := ""
GunSlot7Checkbox := ""
GunSlot8Checkbox := ""
GunSlot9Checkbox := ""
GunSlot10Checkbox := ""

GunSlotCheckboxBoolNames := [
    "GunSlot1CheckboxBool", "GunSlot2CheckboxBool", "GunSlot3CheckboxBool",
    "GunSlot4CheckboxBool", "GunSlot5CheckboxBool", "GunSlot6CheckboxBool",
    "GunSlot7CheckboxBool", "GunSlot8CheckboxBool", "GunSlot9CheckboxBool",
    "GunSlot10CheckboxBool"
]

/* ; this doesnt work
OtherCheckboxSettingVarsValues := []
mode := ""
LoadedOtherCheckboxSettings := IniRead(SettingSavePathINI, "other_checkbox_saves", "OtherCheckboxValues", "empty") ; INI use

if (LoadedOtherCheckboxSettings != "empty") {
    OtherCheckboxSettingVarsValues := StrSplit(LoadedOtherCheckboxSettings, "|")

    for i, CurObject in GunSlotCheckboxBoolNames {
        CurBoolValue := OtherCheckboxSettingVarsValues[i]

        if (CurBoolValue) {
            mode := "true"
        } else {
            mode := "false"
        }

        GunSlotsLogic(i, mode)
    }
}
*/

global GunSlotCheckboxNames := [
    "GunSlot1Checkbox", "GunSlot2Checkbox", "GunSlot3Checkbox",
    "GunSlot4Checkbox", "GunSlot5Checkbox", "GunSlot6Checkbox",
    "GunSlot7Checkbox", "GunSlot8Checkbox", "GunSlot9Checkbox",
    "GunSlot10Checkbox"
]

DummyValue := { Value: 0 }
KeybindSettingsVars := [
    "MainToggleKeybind", "FastGunSwapKeybind", "FastGunSwapChoiceStatus", "ShuffleReloadKeybind",
    "LagSwitchKeybind", "PressureJumpKeybind", "FreezeClipKeybind",
    "FreezeRobloxKeybind", "ResetSprintToggleKeybind", "ShowOrMinimizeKeybind",
    "CloseMacroKeybind", "IncreaseGunAmount", "DecreaseGunAmount", "DummyValue"
]

IsHelpVisible := false
IsSettingsVisible := true
IsGunAmmoShowVisible := false
IsChangeLogVisible := false
IsCrouching := false
IsChatting := false
IsLagging := false
IsFrozen := false
IsFastGunSwapHolding := false

LagSwitchTL := 0
FreezeTL := 0
GuiThing := ""
GuiSetting := ""
GuiHelp := ""
GuiChangeLog := ""

GunsSettingEditbox := ""
ShootDelayEditbox := ""
ReloadDelayEditbox := ""
MousePointerSpeed_Input := ""
Sens_Input := ""

GunAmountVar := 0
FastGunSwapChoiceIsHold := true

Turn180Deg := false
WindowsRawSensitivity := 0

MainToggleKeybindString := ""
FastGunSwapKeybindString := ""
SecondaryFastGunSwapKeybindString := ""
ShuffleReloadKeybindString := ""
LagSwitchKeybindString := ""
PressureJumpKeybindString := ""
FreezeClipKeybindString := ""
FreezeRobloxKeybindString := ""
ResetSprintToggleKeybindString := ""
ShowOrMinimizeKeybindString := ""
CloseMacroKeybindString := ""
IncreaseGunAmountString := ""
DecreaseGunAmountString := ""

MainToggleKeybind := ""
FastGunSwapKeybind := ""
ShuffleReloadKeybind := ""
LagSwitchKeybind := ""
PressureJumpKeybind := ""
FreezeClipKeybind := ""
FreezeRobloxKeybind := ""
ResetSprintToggleKeybind := ""
ShowOrMinimizeKeybind := ""
CloseMacroKeybind := ""
IncreaseGunAmount := ""
DecreaseGunAmount := ""

; -- Main GUI Call --
if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)")) {
    try {
        if A_IsCompiled {
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        }
        else {
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
        }

        StopMacro()
    } catch {
        MsgBox("Warning: Some features may not work properly or not work at all. If you want the best experience close the macro, open it back, and run as an administrator")
    }
}

MainGui()
SettingsGui()
ChangeLogGui()

OnMessage(0x0201, (*) => PostMessage(0xA1, 2, , , "A")) ; for gui drag

; -- Toggle Almost Everything --
MainToggle(hk := "") {
    global ScriptActive := !ScriptActive

    StatusLabel.Text := ScriptActive ? "ON" : "OFF"
    StatusLabel.Opt(ScriptActive ? "Background00FF7F" : "BackgroundD81F25")
    StatusLabel.Redraw()

    if CheckBoxSoundBeepBOOL
        SoundBeep(ScriptActive ? 550 : 400, 20)
}

; -- Fast Gun Swap --
FastGunSwap(hk := "") {
    global IsFastGunSwapHolding

    delay := Number(ShootDelayEditbox.Value)

    if (FastGunSwapChoiceIsHold) {
        while GetKeyState(SecondaryFastGunSwapKeybindString, "P") {
            OptimizedShoot(ActiveSlots, delay)
        }
    }
    else {
        IsFastGunSwapHolding := !IsFastGunSwapHolding

        switch IsFastGunSwapHolding {
            case true:
                SetTimer(GunLoop, -1)
            case false:
                SetTimer(GunLoop, 0)
        }
    }

    GunLoop() { ; only for fast gun swap toggle mode
        if (!IsFastGunSwapHolding) {
            return
        }

        OptimizedShoot(ActiveSlots, delay)

        SetTimer(GunLoop, -1)
    }
}

OptimizedShoot(CurArray, CurDelay) {
    for Key in CurArray {
        Send("{Blind}{" Key "}")
        SuperSleep(CurDelay)
        Click()
        SuperSleep(CurDelay)
    }
}

; -- Shuffle Reload --
ShuffleReload(hk := "") {
    global ReloadDelayEditbox

    delay := Number(ReloadDelayEditbox.Value)

    for Key in ActiveSlots {
        Send "{Blind}{" Key "}"
        SuperSleep(delay)
        Send "{Blind}r"
    }
}

; -- Decrease Gun Amount Shortcut --
DecreaseGunAmountFunc(hk := "") {
    global GunsAmountStatus, GunAmountVar, GunsSettingEditbox

    IncreaseOrDecreaseShortcutLogic("false")
}

; -- Increase gun amount shortcut --
IncreaseGunAmountFunc(hk := "") {
    global GunsAmountStatus, GunAmountVar, GunsSettingEditbox

    GunAmountVar += 1

    IncreaseOrDecreaseShortcutLogic("true")
}

; increase/decrease shortcut logic function
IncreaseOrDecreaseShortcutLogic(input) {
    global

    if (GunAmountVar <= 0) {
        GunAmountVar := 0
        return
    }
    if (GunAmountVar > 10) {
        GunAmountVar := 0
        return
    }

    GunSlotsLogic(GunAmountVar, input)

    GunsAmountStatus.Value := GunAmountVar
    GunsAmountStatus.Redraw()

    UpdateRealGunStuff()

    if CheckBoxSoundBeepBOOL
        SoundBeep(550, 20)
}

; -- Lag Switcher --
Lagswitch(hk := "") {
    global PID := ProcessExist("RobloxPlayerBeta.exe") ? "RobloxPlayerBeta.exe" : "WindowsUniversal.exe"

    if (!CheckBoxLagSwitchBOOL or !PID) {
        return
    }

    IsLagging := !IsLagging
    CurrentPath := GetProcessPath(PID)
    global LagSwitchTL, IsLagging, currentPath

    switch IsLagging {
        case true:
            LagSwitchTurn(true)

            LagSwitchTL := 19
            LagSwitchStatus.Value := LagSwitchTL
            LagSwitchStatus.Opt("Background00FF7F")
            LagSwitchStatus.Redraw()
            SetTimer(LagSwitchCount, 1000)
        case false:
            SetTimer(LagSwitchCount, 0)

            LagSwitchTurn(false)

            LagSwitchTL := 0
            LagSwitchStatus.Value := 0
            LagSwitchStatus.Opt("BackgroundD81F25")
            LagSwitchStatus.Redraw()
    }

    if (CheckBoxSoundBeepBOOL) {
        SoundBeep(IsLagging ? 550 : 400, 20)
    }
}

LagSwitchTurn(bool) { ; suspend / resume roblox
    switch bool {
        case true:
            RunWait('netsh advfirewall firewall add rule name="RobloxLagSwitch" dir=out action=block program="' . CurrentPath . '" enable=yes', , "Hide")
        case false:
            RunWait('netsh advfirewall firewall delete rule name="RobloxLagSwitch"', , "Hide")
    }
}

LagSwitchCount() {
    global IsLagging, LagSwitchTL
    if (!IsLagging) {
        SetTimer(LagSwitchCount, 0)
        return
    }

    LagSwitchTL -= 1
    LagSwitchStatus.Value := LagSwitchTL
    LagSwitchStatus.Redraw()

    if (LagSwitchTL <= 0) {
        IsLagging := false
        SetTimer(LagSwitchCount, 0) ; Turn off timer
        LagSwitchTurn(false)

        LagSwitchStatus.Value := 0
        LagSwitchStatus.Opt("BackgroundD81F25")
        LagSwitchStatus.Redraw()

        if CheckBoxSoundBeepBOOL
            SoundBeep(400, 20)
    }
}

GetProcessPath(processName) { ; lowkey dont understand what this does but it works
    for proc in ComObjGet("winmgmts:").ExecQuery("Select ExecutablePath from Win32_Process Where Name = '" . processName . "'") {
        if proc.ExecutablePath
            return proc.ExecutablePath
    }
    throw Error("Process not found")
}

; -- Pressure Jump --
PressureJump(hk := "") {
    if CheckBoxSoundBeepBOOL
        SoundBeep(550, 20)

    if (Sens_Input.Value == 0 or MousePointerSpeed_Input.Value == 0) {
        MsgBox("Put your Roblox Sensitivity and Mouse Pointer Speed in the settings. More info in the help GUI")
        return
    }

    if Number(MousePointerSpeed_Input.Value) < 4
        MousePointerSpeed_Input.Value := 4

    global WindowsRawSensitivity := float(4.0 / Number(MousePointerSpeed_Input.Value))
    global Turn180Var := float(WindowsRawSensitivity * (4000.0 / Number(Sens_Input.Value)))

    Send "{Blind}c"
    Sleep(17)

    Send "{Space down}"
    Sleep(60)
    Send "{Space up}"

    StartTime := A_TickCount
    Loop {
        global Turn180Deg := !Turn180Deg
        if (A_TickCount - StartTime > 300)
            break

        if (Turn180Deg) {
            DllCall("user32\mouse_event", "UInt", 0x0001, "Int", Turn180Var, "Int", 0, "UInt", 0, "UPtr", 0)
        } else {
            DllCall("user32\mouse_event", "UInt", 0x0001, "Int", -Turn180Var, "Int", 0, "UInt", 0, "UPtr", 0)
        }
    }

    global IsCrouching := false
}

; -- Freeze Clip --
FreezeClip(hk := "") {
    ; turn off vars for sprint holder
    global ShiftHolder := false
    global IsCrouching := !IsCrouching
    global IsChatting := false
    Send "{LShift up}"

    ; turn off sprint gui
    ShiftHolderStatus.Opt("BackgroundD81F25")
    ShiftHolderStatus.Redraw()

    Send "{Blind}c"

    SuperSleep(15)

    freeze(1) ; starts freezing roblox

    Sleep(450)

    freeze(2) ; stops freezing roblox
}

; -- Freeze Roblox --
FreezeRoblox(hk := "") {
    global IsFrozen := !IsFrozen

    ; Freeze/Unfreeze
    switch IsFrozen {
        case true:
            freeze(1)
        case false:
            freeze(2)
    }
}

/*; -- Floofy clip -- doesnt work
~$*e:: {
    if (!ScriptActive) {
        return
    }

    Send("{Space Down}")

    Sleep(15)

    Send("{Ctrl}") ; shiftlock

    SuperSleep(5)

    Send("{Blind}{c Down}") ; hold c

    Sleep(32)

    freeze(1) ; freeze roblox

    Sleep(250)

    Send("{Space Up}")
    Send("{Blind}{c Up}")

    freeze(2) ; stop freezing
}
*/

; -- Freeze Functions --
freeze(FreezeChoice) {
    targetWin := WinExist("ahk_exe RobloxPlayerBeta.exe")
        ? "ahk_exe RobloxPlayerBeta.exe"
        : "ahk_exe ApplicationFrameHost.exe"

    if !WinExist(targetWin) {
        TrayTip("Roblox not found")
        SetTimer(HideTrayTip, 1500)
        return
    }

    pid := 0
    winThreadId := DllCall("User32.dll\GetWindowThreadProcessId", "Ptr", WinExist(targetWin), "Ptr*", pid, "UInt")

    ; (0x1F0FFF)
    hThread := DllCall("Kernel32.dll\OpenThread", "UInt", 0x1F0FFF, "Int", false, "UInt", winThreadId, "Ptr")

    if (!hThread) {
        HideTrayTip()
        TrayTip("Failed to connect to roblox window")
        return
    }

    ; Switch statement
    switch (FreezeChoice) {
        case 1:
            DllCall("Kernel32.dll\SuspendThread", "Ptr", hThread)
        case 2:
            DllCall("Kernel32.dll\ResumeThread", "Ptr", hThread)
    }

    ; Clean up
    DllCall("Kernel32.dll\CloseHandle", "Ptr", hThread)
}

FreezeCount() { ; useless function
    global FreezeTL
    FreezeTL -= 1

    if (FreezeTL <= 0) {
        freeze(2)
        SetTimer(FreezeCount, 0)
    }
}

; -- Shift Holder --
~$*LShift:: {
    if (!CheckBoxShiftHolderBOOL or IsChatting or IsCrouching) {
        return
    }

    global ShiftHolder := !ShiftHolder
    global IsCrouching := false
    global IsChatting := false

    if (ShiftHolder) {
        KeyWait "LShift"
        Send "{LShift down}"
        ShiftHolderStatus.Opt("Background00FF7F")
    } else {
        Send "{LShift up}"
        ShiftHolderStatus.Opt("BackgroundD81F25")
    }
    ShiftHolderStatus.Redraw()
}

; Disables sprint toggle if crouched
*$c:: {
    global ShiftHolder := false
    global IsCrouching := true
    ShiftHolderStatus.Opt("BackgroundD81F25")
    ShiftHolderStatus.Redraw()

    Send "{LShift up}"
    Send "{Blind}c"
}

; Resets sprint toggle
SprintToggleReset(hk := "") {
    global ShiftHolder := false
    global IsCrouching := false
    global IsChatting := false

    ShiftHolderStatus.Opt("BackgroundD81F25")
    ShiftHolderStatus.Redraw()

    Send "{LShift up}"
}

; Disable sprint toggle if chatting
*$?:: {
    global ShiftHolder := false
    global IsChatting := true
    global ScriptActive := false

    StatusLabel.Text := "OFF"
    StatusLabel.Opt("BackgroundD81F25")
    ShiftHolderStatus.Opt("BackgroundD81F25")
    ShiftHolderStatus.Redraw()
    StatusLabel.Redraw()

    Send "{LShift up}"
    Send "/"
}

; Disable sprint toggle if chatting
*$/:: {
    global ShiftHolder := false
    global IsChatting := true
    global ScriptActive := false

    StatusLabel.Text := "OFF"
    StatusLabel.Opt("BackgroundD81F25")
    ShiftHolderStatus.Opt("BackgroundD81F25")
    ShiftHolderStatus.Redraw()
    StatusLabel.Redraw()

    Send "{LShift up}"
    Send "/"
}

#HotIf IsChatting
; If done chatting then allow toggle sprint again
*$Enter:: {
    global IsChatting := false

    Send("{Enter}")
}

; If done chatting then allow toggle sprint again
~$*LButton:: {
    global IsChatting := false

    Click
}

#HotIf IsCrouching
; If done crouching allow sprinting again
*$c:: {
    global ShiftHolder := true

    Send "{Blind}c"

    Sleep(64)
    global IsCrouching := false
    Send "{LShift down}"

    ShiftHolderStatus.Opt("Background00FF7F")
    ShiftHolderStatus.Redraw()
}
#HotIf

; -- Minimize/Show GUI --
MinimizeOrShowGUI(hk := "") {
    global GuiThing, GuiHelp, GuiSetting
    global ShowUi := !ShowUi

    if (ShowUi) {
        if (GuiThing is Gui)
            GuiThing.Show()
    } else {
        if (GuiThing is Gui)
            GuiThing.Minimize()
        if (GuiSetting is Gui)
            GuiSetting.Minimize()
        if (GuiHelp is Gui)
            GuiHelp.Minimize()
    }
}

; -- Panic Exit --
; Already done

; -- Macro close --
StopMacro(hk := "") {
    Send "{LShift up}"

    try WinClose("ahk_exe clumsy.exe")
    DllCall("Winmm\timeEndPeriod", "UInt", 1)

    ; Close autohotkey
    try ProcessClose("AutoHotkey64.exe")
    try ProcessClose("AutoHotkey.exe")

    ; If closing fails
    ExitApp()
}


; -- Main GUI --
MainGUI() {
    global ShiftHolderStatus, GuiThing, LagSwitchStatus, GunAmountVar, GunsAmountStatus, Guns

    ; black thing
    GuiThing := Gui("-Caption +AlwaysOnTop")
    GuiThing.BackColor := "060606" ; black hex code

    ; Shift Holder Gui
    GuiThing.SetFont("s7 bold cF0F0F0", "Arial")
    ShiftHolderStatus := GuiThing.Add("Text", "x77 y0 w34 h15 Center 0x200 BackgroundD81F25 Hidden", "SPRINT")

    ; Lag switch gui
    GuiThing.SetFont("s7 bold cF0F0F0", "Arial")
    LagSwitchStatus := GuiThing.Add("Text", "x61 y0 w15 h15 Center 0x200 BackgroundD81F25 Hidden", LagSwitchTL)

    ; Title
    GuiThing.SetFont("s12 bold cF0F0F0", "Segoe UI")
    GuiThing.Add("Text", "x71 y13 w145 BackgroundTrans", "Prison Life Macro")

    ; Credit
    GuiThing.SetFont("s4 bold cF0F0F0", "Consolas")
    GuiThing.Add("Text", "xp+3 yp+21 w130 BackgroundTrans", "Made By @Idkwhattonamethis223 On Youtube")

    ; On/Off button
    GuiThing.SetFont("s23 bold cF0F0F0", "Arial")
    global StatusLabel := GuiThing.Add("Text", "x0 y0 w60 h55 0x200 BackgroundD81F25 -0x100 0x1", "OFF")

    ; X button
    GuiThing.SetFont("s10 cF0F0F0", "Arial")
    GuiThing.Add("Text", "x195 y0 w20 h15 Center 0x200 BackgroundD81F25", "X").OnEvent("Click", (*) => StopMacro())

    ; Help button
    GuiThing.SetFont("s8 bold c060606", "Arial")
    GuiThing.Add("Text", "x145 y0 w30 h15 Center 0x200 BackgroundF0F0F0", "HELP").OnEvent("Click", (*) => HelpGui())

    ; Settings Button
    GuiThing.SetFont("s10 cF0F0F0", "Segoe UI Symbol")
    GuiThing.Add("Text", "x175 y0 w20 h15 Center 0x200 Background1D4ED8", Chr(0x2699)).OnEvent("Click", (*) => SettingsGui()) ; setting symbol

    ; Guns To Swap Status
    GuiThing.SetFont("s6 bold cF0F0F0", "Arial")
    GuiThing.Add("Text", "x120 y39 w100 h15 Center 0x200 BackgroundTrans", "Guns to swap:")
    GunsAmountStatus := GuiThing.Add("Text", "xp+80 yp w10 h15 Center 0x200 BackgroundTrans", 0)
    global GunsAmountStatus

    MainGuiW := 270
    MaingGuiH := 65
    GuiThing.Show("y740 w" MainGuiW " h" MaingGuiH "") ; shows the ui
    WinSetRegion("0-0 w" MainGuiW " h" MaingGuiH " r15-15", GuiThing.Hwnd)
}

; -- Help GUI --
HelpGui() {
    static HelpGuiShow := false

    if (!HelpGuiShow) {
        global GuiHelp

        global MainToggleHelp, FastGunSwapHelp, ShuffleReloadHelp
        global LagswitchHelp, PressureJumpHelp, FreezeClipHelp
        global FreezeRobloxHelp, ResetSprintToggleHelp, ShowOrMinimizeHelp
        global CloseMacroHelp, DecreaseGunAmountHelp, IncreaseGunAmountHelp

        global MainToggleKeybind, FastGunSwapKeybind, ShuffleReloadKeybind
        global LagSwitchKeybind, PressureJumpKeybind, FreezeClipKeybind
        global FreezeRobloxKeybind, ResetSprintToggleKeybind, ShowOrMinimizeKeybind
        global CloseMacroKeybind, IncreaseGunAmount, DecreaseGunAmount

        GuiHelp := Gui("-Caption +AlwaysOnTop")
        GuiHelp.BackColor := "060606" ; black hex code

        ; Title for help GUI
        GuiHelp.SetFont("s35 bold cF0F0F0", "Segoe UI")
        GuiHelp.Add("Text", "x150 y0 w370 Center", "Macro Help")

        ; -- Keybinds show --
        ToggleHelpVars := [
            "MainToggleHelp", "FastGunSwapHelp", "ShuffleReloadHelp",
            "LagswitchHelp", "PressureJumpHelp", "FreezeClipHelp",
            "FreezeRobloxHelp", "ResetSprintToggleHelp", "ShowOrMinimizeHelp",
            "CloseMacroHelp", "DecreaseGunAmountHelp", "IncreaseGunAmountHelp"
        ]

        KeybindSettingsVars := [
            "MainToggleKeybind", "FastGunSwapKeybind", "ShuffleReloadKeybind",
            "LagSwitchKeybind", "PressureJumpKeybind", "FreezeClipKeybind",
            "FreezeRobloxKeybind", "ResetSprintToggleKeybind", "ShowOrMinimizeKeybind",
            "CloseMacroKeybind", "IncreaseGunAmount", "DecreaseGunAmount"
        ]

        HelpStrings := [
            "= Main Toggle        ",
            "= Fast Gun Swap      ",
            "= Shuffle Reload     ",
            "= Lag Switch         ",
            "= Pressure Jump      ",
            "= Freeze Clip        ",
            "= Freeze Roblox      ",
            "= Reset sprint toggle",
            "= Show/Minimize      ",
            "= Close Macro        ",
            "= Decrease Gun Amount",
            "= Increase Gun Amount"
        ]

        ; Keybinds title
        GuiHelp.SetFont("s25 bold cF0F0F0", "Tahoma") ; HELP GUI FIRST ANCHOR
        GuiHelp.Add("Text", "x-8 y70 w330 Center", "Keybinds")

        for i, CurOject in ToggleHelpVars {
            global CurObject
            GuiHelp.SetFont("s15 bold cF0F0F0", "Consolas")

            CurKeybindVar := KeybindSettingsVars[i]
            CurHelpString := HelpStrings[i]

            if (i == 1) {
                %CurOject% := GuiHelp.Add("Text", "xp+60 yp+45 w60 BackgroundTrans", StrUpper((%CurKeybindVar%).Value))
            } else {
                %CurOject% := GuiHelp.Add("Text", "xp y+5 w60 BackgroundTrans", StrUpper((%CurKeybindVar%).Value))
            }

            ; Help name
            GuiHelp.Add("Text", "xp yp w330 Center BackgroundTrans", CurHelpString)
        }

        ; -- Extra info --
        ExtraInfoHelpStrings := [
            " ; fast gun swap info
            (Join
                To use the fast weapon swap macro,
                 you need to select your inventory slots where your guns are
                 in the settings or use the O/P keybinds.
                 The recommended shoot delay for 60+ fps is 3 milisecond.
                 And the recommended shoot delay for 30 fps is 4 milisecond (so your pc doesn't get fried)
            )",
            
            " ; pressure jump info
            (Join
                To activate the pressure jump macro,
                 put your roblox sensitivity and your mouse pointer speed (search it your windows settings) in the macro settings. 
                 Walk up to one of the pressure jump spots (search up youtube tutorial for the spots). 
                 Then crouch and shove your head fully into the object. 
                 Then press G. Also if you set your mouse pointer lower than 4 the script
                 would automatically set your mouse pointer speed to 4 in the MACRO settings
                 so the pressure jump would work. The more fps you have, the better the macro works. 
                 If you only have 30 fps or 60 fps this might not work
            )",
            " ; freeze clip info
            (Join
                To freeze clip, you need to walk directly to a thin wall (around 0.9 studs). 
                 Set your camera angle to around 120 degrees or exactly 180 degrees (google a protractor image). 
                 Then press B and try to reach the other side of the wall you chose
            )"
        ]

        GuiHelp.SetFont("s25 bold cF0F0F0", "Tahoma")
        static ExtraInfoHelpGuiNameX := 335
        static ExtraInfoHelpGuiNameY := 70
        GuiHelp.Add("Text", "x" ExtraInfoHelpGuiNameX " y" ExtraInfoHelpGuiNameY " w330 Center", "Extra Info")

        GuiHelp.SetFont("s7 cF0F0F0", "Consolas")
        for i, CurObject in ExtraInfoHelpStrings {
            if (i == 1) {
                GuiHelp.Add("Text", "xp+45 yp+45 w240 Center", CurObject)
            } else {
                ExtraInfoHelpGuiNameY += 8
                GuiHelp.Add("Text", "xp y+8 w240 Center", CurObject)
            }
        }

        ; Credit in help GUI
        GuiHelp.SetFont("s15 cF0F0F0", "Consolas")
        GuiHelp.Add("Text", "x55 y+25 w530 Center", "Made By @Idkwhattonamethis223 On Youtube")

        ; X button for help GUI
        GuiHelp.SetFont("s17 bold cF0F0F0", "Arial")
        GuiHelp.Add("Text", "x625 y0 w40 h25 Center BackgroundD81F25", "X").OnEvent("Click", (*) => HideHelp())

        HideHelp(*) {
            GuiHelp.Hide()
            global IsHelpVisible := false
        }

        HelpGuiShow := true
    }

    global IsHelpVisible := !IsHelpVisible

    ; Shows/closes help GUI
    if (IsHelpVisible) {
        HelpGuiW := 830
        HelpGuiH := 630
        GuiHelp.Show("w" HelpGuiW " h" HelpGuiH "")
        WinSetRegion("0-0 w" HelpGuiW " h" HelpGuiH " r20-20", GuiHelp.Hwnd)
    } else {
        GuiHelp.Hide()
    }
}

; -- Settings GUI --
SettingsGui() {
    static SettingsGuiShow := false

    if (!SettingsGuiShow) {
        global GuiSetting, Sens_Input, MousePointerSpeed_Input, GunsSettingEditbox
        global GunsAmountStatus, ShootDelayEditbox, ReloadDelayEditbox, GunAmountVar
        global CheckBoxShiftHolder, CheckBoxLagSwitch, CheckBoxSoundBeep

        global GunSlot1CheckboxBool, GunSlot2CheckboxBool, GunSlot3CheckboxBool
        global GunSlot4CheckboxBool, GunSlot5CheckboxBool, GunSlot6CheckboxBool
        global GunSlot7CheckboxBool, GunSlot8CheckboxBool, GunSlot9CheckboxBool
        global GunSlot10CheckboxBool, GunSlotCheckboxBoolNames, GunSlotCheckboxNames

        global GunSlot1Checkbox, GunSlot2Checkbox, GunSlot3Checkbox
        global GunSlot4Checkbox, GunSlot5Checkbox, GunSlot6Checkbox
        global GunSlot7Checkbox, GunSlot8Checkbox, GunSlot9Checkbox
        global GunSlot10Checkbox

        global MainToggleKeybind := "", FastGunSwapKeybind := "", FastGunSwapChoiceStatus := ""
        global ShuffleReloadKeybind := "", LagSwitchKeybind := "", PressureJumpKeybind := ""
        global FreezeClipKeybind := "", FreezeRobloxKeybind := "", ResetSprintToggleKeybind := ""
        global ShowOrMinimizeKeybind := "", CloseMacroKeybind := "", IncreaseGunAmount := ""
        global DecreaseGunAmount := "", DummyValue

        GuiSetting := Gui("-Caption +AlwaysOnTop")
        GuiSetting.BackColor := "060606" ; black hex code

        ; Title for settings GUI
        GuiSetting.SetFont("s30 bold cF0F0F0", "Segoe UI")
        GuiSetting.Add("Text", "x178 y0 w700 Center", "Macro Settings")

        ; -- Keybind setting gui --
        KeybindSettingsStringVars := [
            "Main Toggle", "Fast Gun Swap", 0, "Shuffle Reload",
            "Lag Switch", "Pressure Jump", "Freeze Clip",
            "Freeze Roblox", "Reset Sprint Toggle", "Show/Minimize",
            "Close Macro", "Increase Gun Amount", "Decrease Gun Amount", ""
        ]

        global KeybindSettingVarsValue
        KeybindSettingVarsValue := []
        LoadedKeybindSettings := IniRead(SettingSavePathINI, "keybind_saves", "KeybindValues", "empty")

        if (LoadedKeybindSettings == "empty") {
            KeybindSettingVarsValue := [ ; INI use
                "Alt", "LMB", 0, "r",
                "t", "g", "b",
                "y", "m", "f4",
                "Del", "p", "o", 1
            ]
        } else {
            KeybindSettingVarsValue := StrSplit(LoadedKeybindSettings, "|")
        }

        ; -- Keybinds setting gui --
        for i, CurObject in KeybindSettingsVars {
            CurName := KeybindSettingsStringVars[i]
            CurKeybind := KeybindSettingsVars[i]
            CurKeybindValue := KeybindSettingVarsValue[i]

            static KeybindSettingsGuiX := 40
            static KeybindSettingsGuiY := 70
            static KeybindSettingsGuiEditbox := 30
            static EqualSignDistance := 240

            if (CurKeybindValue == 1) {
                break
            }

            if (i > 1 and CurKeybindValue != 0 and CurKeybindValue != "Hold" and CurKeybindValue != "Toggle") {
                KeybindSettingsGuiY += 30
            }

            ; for fast gun swap choice
            if (CurKeybind == "FastGunSwapChoiceStatus") {
                global FastGunSwapChoiceStatus
                GuiSetting.SetFont("s10 bold c060606", "Consolas")
                FastGunSwapChoiceStatus := GuiSetting.Add("Text", "xp-120 yp w45 h25 0x200 BackgroundF0F0F0 -0x100 0x1", "Hold")
                FastGunSwapChoiceStatus.OnEvent("Click", (*) => FastGunSwapHoldOrToggle("auto"))

                if (CurKeybindValue == "Hold") {
                    FastGunSwapHoldOrToggle("hold")
                }
                else if (CurKeybindValue == "Toggle") {
                    FastGunSwapHoldOrToggle("toggle")
                }
            }
            else if (CurKeybind == "DummyValue") {
                continue
            }
            ; Keybind name
            else {
                ; Keybind names
                GuiSetting.SetFont("s15 bold cF0F0F0", "Consolas")
                GuiSetting.Add("Text", "x" KeybindSettingsGuiX " y" KeybindSettingsGuiY " w400 BackgroundTrans", CurName)

                ; Equal sign
                GuiSetting.Add("Text", "xp+" EqualSignDistance " yp w10", "=")

                ; Editboxes
                GuiSetting.SetFont("s15 bold c060606", "Consolas")
                %CurKeybind% := GuiSetting.AddEdit("xp+" KeybindSettingsGuiEditbox " yp w45 h25 0x200 BackgroundF0F0F0", CurKeybindValue)
            }
        }

        ; -- Other settings --
        OtherSettingsNames := [
            "Shoot Delay", "milisecond1", "Reload Delay",
            "milisecond2", "Pressure Jump", "Sprint Toggle",
            "Lag Switch", "Sound Beep Toggle"
        ]

        OtherSettingsEditbox := [
            "ShootDelayEditbox", 0, "ReloadDelayEditbox", 0
        ]

        global OtherSettingsEditboxValue
        OtherSettingsEditboxValue := []

        LoadedEditboxSettings := IniRead(SettingSavePathINI, "editbox_saves", "EditboxValues", "empty")
        static IsAutoSaveEditbox := false
        if (LoadedEditboxSettings == "empty") {
            OtherSettingsEditboxValue := [ ; INI use default settings
                4, ; shoot delay
                0, ; reload delay
                0, 0 ; dummy values
                0, 0 ; pressure jump
            ]
        } else {
            OtherSettingsEditboxValue := StrSplit(LoadedEditboxSettings, "|")
            IsAutoSaveEditbox := true
        }

        OtherSettingsCheckbox := [
            "CheckBoxShiftHolder", "CheckBoxLagSwitch", "CheckBoxSoundBeep",
        ]

        ; -- Other settings --
        for i, CurObject in OtherSettingsNames {
            CurName := CurObject

            static OtherSettingGuiNameX := 390
            static OtherSettingGuiNameY := 70
            static OtherSettingsEditboxX := 250
            static CheckBoxX := OtherSettingsEditboxX - 1

            if (CurName == "Pressure Jump") {
                OtherSettingGuiNameY += 40
            }
            else if (CurName == "Sprint Toggle") {
                OtherSettingGuiNameY += 50
            }
            ; milisecond disclamer
            else if (CurName == "milisecond1" or CurName == "milisecond2") {
                GuiSetting.SetFont("s8 bold cF0F0F0", "Consolas")
                if (CurName == "milisecond1") {
                    MilisecondDistanceDisclamer := 125
                } else if (CurName == "milisecond2") {
                    MilisecondDistanceDisclamer := 115
                }

                GuiSetting.Add("Text", "xp-" MilisecondDistanceDisclamer " yp+10 w100 BackgroundTrans", "(milisecond)")

                continue
            }
            else if (i > 1) {
                OtherSettingGuiNameY += 30
            }

            ; Other settings name
            GuiSetting.SetFont("s15 bold cF0F0F0", "Consolas")
            GuiSetting.Add("Text", "x" OtherSettingGuiNameX " y" OtherSettingGuiNameY " w330", CurName)
            GuiSetting.SetFont("c060606")

            ; for editbox
            if (i <= OtherSettingsEditbox.Length) {
                global CurEditbox

                CurEditbox := OtherSettingsEditbox[i]
                CurEditboxValue := OtherSettingsEditboxValue[i]

                ; editbox
                %CurEditbox% := GuiSetting.AddEdit("xp+" OtherSettingsEditboxX " yp+4 w25 h25 0x200 +Number BackgroundF0F0F0", CurEditboxValue)
            }
            ; for pressure jump
            else if (CurName == "Pressure Jump") {
                global MousePointerSpeed_Input, Sens_Input

                CurEditboxValue := OtherSettingsEditboxValue[i]

                ; Mouse pointer speed editbox
                GuiSetting.SetFont("s12")
                MousePointerSpeed_Input := GuiSetting.AddEdit("xp+170 yp w30 h20 Number BackgroundF0F0F0", CurEditboxValue)

                ; Mouse pointer speed clarification
                GuiSetting.SetFont("s7 cF0F0F0")
                GuiSetting.Add("Text", "xp-22 yp+20 w73 Center", "Mouse`nPointer Speed")

                if (IsAutoSaveEditbox) {
                    CurEditboxValue := OtherSettingsEditboxValue[i + 1]
                } else {
                    CurEditboxValue := OtherSettingsEditboxValue[i]
                }
                ; Roblox sensitivity editbox
                GuiSetting.SetFont("s12 c060606")
                Sens_Input := GuiSetting.AddEdit("xp+90 yp-20 w45 h20 BackgroundF0F0F0", CurEditboxValue)

                ; Roblox sensitivity clarification
                GuiSetting.SetFont("s7 cF0F0F0")
                GuiSetting.Add("Text", "xp-9 yp+20 w50 Center", "Roblox sensitivity")
            }
            ; for checkbox
            else {
                GuiSetting.SetFont("s12 c060606")

                CurCheckboxCount := i - 5
                CurCheckbox := OtherSettingsCheckbox[CurCheckboxCount]

                ; checkbox
                GuiSetting.Add("Text", "xp+" CheckBoxX " yp+1 w28 h25 BackgroundF0F0F0") ; white square
                %CurCheckbox% := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background060606")
                BindCheckboxEvent(%CurCheckbox%, CurCheckboxCount)
            }
        }

        BindCheckboxEvent(ControlObject, ControlIndex) {
            ControlObject.OnEvent("Click", (*) => CheckboxFunction(ControlIndex))
        }

        ; -- Gun amount --
        GunSlotCheckboxBoolNames := [
            "GunSlot1CheckboxBool", "GunSlot2CheckboxBool", "GunSlot3CheckboxBool",
            "GunSlot4CheckboxBool", "GunSlot5CheckboxBool", "GunSlot6CheckboxBool",
            "GunSlot7CheckboxBool", "GunSlot8CheckboxBool", "GunSlot9CheckboxBool",
            "GunSlot10CheckboxBool"
        ]

        GunSlotCheckboxNames := [
            "GunSlot1Checkbox", "GunSlot2Checkbox", "GunSlot3Checkbox",
            "GunSlot4Checkbox", "GunSlot5Checkbox", "GunSlot6Checkbox",
            "GunSlot7Checkbox", "GunSlot8Checkbox", "GunSlot9Checkbox",
            "GunSlot10Checkbox"
        ]

        ; -- Gun Amount --
        for i, CurObject in GunSlotCheckboxBoolNames {
            global CurGunCheckbox

            CurGunStringName := "Slot " . i
            CurGunCheckbox := GunSlotCheckboxNames[i]

            static GunAmountSettingsGuiNameX := 710
            static GunAmountSettingsGuiNameY := 70
            static GunCheckboxX := 200

            if (i > 1) {
                GunAmountSettingsGuiNameY += 30
            }

            ; Gun number
            GuiSetting.SetFont("s15 bold cF0F0F0", "Consolas")
            GuiSetting.Add("Text", "x" GunAmountSettingsGuiNameX " y" GunAmountSettingsGuiNameY " w330 BackgroundTrans", CurGunStringName)

            ; Checkbox
            GuiSetting.Add("Text", "xp+" GunCheckBoxX " yp+1 w28 h25 BackgroundF0F0F0") ; white square
            %CurGunCheckbox% := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background060606")
            BindGunCheckboxEvent(%CurGunCheckbox%, i)
        }

        BindGunCheckboxEvent(ControlObject, ControlIndex) {
            ControlObject.OnEvent("Click", (*) => GunSlotsLogic(ControlIndex, "auto"))
        }

        ; Function for hiding setting GUI
        HideSetting(*) {
            GuiSetting.Hide()
            global IsSettingsVisible := false

            UpdateGunVarsForSettingGui()
        }

        ; X button in settings GUI
        GuiSetting.SetFont("s17 bold cF0F0F0", "Arial")
        GuiSetting.Add("Text", "x951 y0 w40 h25 Center BackgroundD81F25", "X").OnEvent("Click", (*) => HideSetting())

        ; Apply Settings
        GuiSetting.SetFont("s13 bold cF0F0F0", "Arial")
        GuiSetting.Add("Text", "x475 y350 w120 h40 Center 0x200 BackgroundD81F25", "Apply settings").OnEvent("Click", (*) => KeybindModifier())

        CheckboxFunction(num) {
            switch (num) {
                case 1:
                    ; Sprint toggle
                    global CheckBoxShiftHolderBOOL := !CheckBoxShiftHolderBOOL
                    CheckBoxShiftHolder.Opt(CheckBoxShiftHolderBOOL ? "Background00FF00" : "Background060606")
                    ShiftHolderStatus.Visible := (CheckBoxShiftHolderBOOL ? true : false)
                    CheckBoxShiftHolder.Redraw()

                    ; Resets shift holder if checkbox is disabled
                    if (!CheckBoxShiftHolderBOOL) {
                        SprintToggleReset()
                    }
                case 2:
                    global CheckBoxLagSwitchBOOL := !CheckBoxLagSwitchBOOL
                    CheckBoxLagSwitch.Opt(CheckBoxLagSwitchBOOL ? "Background00FF00" : "Background060606")
                    LagSwitchStatus.Visible := (CheckBoxLagSwitchBOOL ? true : false)
                    CheckBoxLagSwitch.Redraw()
                case 3:
                    ; Sound beep
                    global CheckBoxSoundBeepBOOL := !CheckBoxSoundBeepBOOL
                    CheckBoxSoundBeep.Opt(CheckBoxSoundBeepBOOL ? "Background00FF00" : "Background060606")
                    CheckBoxSoundBeep.Redraw()
            }
        }

        ; Credit in settings GUI
        GuiSetting.SetFont("s15 cF0F0F0", "Consolas")
        GuiSetting.Add("Text", "x290 y450 w490 Center", "Made By @Idkwhattonamethis223 On Youtube")

        SettingsGuiShow := true
        KeybindModifier()
    }

    global IsSettingsVisible := !IsSettingsVisible

    ; Shows/closes Settings GUI
    if (IsSettingsVisible) {
        SettingsGuiShowW := 1240
        SettingsGuiShowH := 600

        GuiSetting.Show("w" SettingsGuiShowW " h" SettingsGuiShowH "")
        WinSetRegion("0-0 w" SettingsGuiShowW " h" SettingsGuiShowH " r20-20", GuiSetting.Hwnd)
    } else {
        GuiSetting.Hide()
    }
}

GunSlotsLogic(slot, type) {
    global
    global GunSlotCheckboxNames

    CurGunCheckboxBool := GunSlotCheckboxBoolNames[slot]
    CurGunCheckbox := GunSlotCheckboxNames[slot]

    if (type == "auto") {
        %CurGunCheckboxBool% := !%CurGunCheckboxBool%
        %CurGunCheckbox%.Opt(%CurGunCheckboxBool% ? "Background00FF00" : "Background060606")
    }
    else if (type == "true") {
        %CurGunCheckboxBool% := true
        %CurGunCheckbox%.Opt("Background00FF00")
    }
    else if (type == "false") {
        %CurGunCheckboxBool% := false
        %CurGunCheckbox%.Opt("Background060606")
    }

    %CurGunCheckbox%.Redraw()
    UpdateGunVarsForSettingGui()
}

; Save settings ; INI
SaveSettings() {
    ; -- Keybind saves --
    KeybindValueSaves := ""

    for CurObject in KeybindSettingsVars {
        KeybindValueSaves .= %CurObject%.Value . "|"
    }

    KeybindValueSaves := RTrim(KeybindValueSaves, "|")

    IniWrite(KeybindValueSaves, SettingSavePathINI, "keybind_saves", "KeybindValues")

    ; -- Editbox saves --
    EditboxValueSaves := ""
    EditboxVars := [
        "ShootDelayEditbox", "ReloadDelayEditbox",
        0, 0, ; dummy values
        "MousePointerSpeed_Input", "Sens_Input"
    ]

    for CurObject in EditboxVars {
        if (CurObject == 0) {
            EditboxValueSaves .= 0 . "|"
            continue
        }

        EditboxValueSaves .= %CurObject%.Value . "|"
    }

    EditboxValueSaves := RTrim(EditboxValueSaves, "|")

    IniWrite(EditboxValueSaves, SettingSavePathINI, "editbox_saves", "EditboxValues")

    ; -- Gun checkbox saves --
    GunCheckboxValueSaves := ""

    for CurObject in GunSlotCheckboxBoolNames {
        GunCheckboxValueSaves .= %CurObject% . "|"
    }

    GunCheckboxValueSaves := RTrim(GunCheckboxValueSaves, "|")

    IniWrite(GunCheckboxValueSaves, SettingSavePathINI, "gun_checkbox_saves", "GunCheckboxValues")
}

; Update real gun stuff
UpdateRealGunStuff() {
    global
    global ActiveSlots

    ActiveSlots := []
    for i, CurObject in GunSlotCheckboxBoolNames {
        if (%CurObject%) {
            if (i == 10) {
                ActiveSlots.Push(0)
            } else {
                ActiveSlots.Push(i)
            }
        }
    }
}

; Modifies keybind string, very important function
KeybindModifier(*) {
    ; User input values
    global MainToggleKeybind, FastGunSwapKeybind, ShuffleReloadKeybind
    global LagSwitchKeybind, PressureJumpKeybind, FreezeClipKeybind
    global FreezeRobloxKeybind, ResetSprintToggleKeybind, ShowOrMinimizeKeybind
    global CloseMacroKeybind, IncreaseGunAmountString, DecreaseGunAmount

    ; String values
    global MainToggleKeybindString, FastGunSwapKeybindString, ShuffleReloadKeybindString
    global LagSwitchKeybindString, PressureJumpKeybindString, FreezeClipKeybindString
    global FreezeRobloxKeybindString, ResetSprintToggleKeybindString, ShowOrMinimizeKeybindString
    global CloseMacroKeybindString, IncreaseGunAmountString, DecreaseGunAmountString, SecondaryFastGunSwapKeybindString

    ; Vars for help gui
    global MainToggleHelp, FastGunSwapHelp, ShuffleReloadHelp, LagswitchHelp, PressureJumpHelp
    global FreezeClipHelp, FreezeRobloxHelp, ResetSprintToggleHelp, ShowOrMinimizeHelp
    global CloseMacroHelp, IncreaseGunAmountHelp, DecreaseGunAmountHelp

    KeybindStringAdd := "*$"
    KeybindStringAdd2 := "~*$"
    HelpText := ""

    static UseCount := 0
    UseCount++

    Keybinds := [
        MainToggleKeybind,
        FastGunSwapKeybind,
        ShuffleReloadKeybind,
        LagSwitchKeybind,
        PressureJumpKeybind,
        FreezeClipKeybind,
        FreezeRobloxKeybind,
        ResetSprintToggleKeybind,
        ShowOrMinimizeKeybind,
        CloseMacroKeybind,
        IncreaseGunAmount,
        DecreaseGunAmount
    ]

    FinalKeyBindString := [
        "MainToggleKeybindString",
        "FastGunSwapKeybindString",
        "ShuffleReloadKeybindString",
        "LagSwitchKeybindString",
        "PressureJumpKeybindString",
        "FreezeClipKeybindString",
        "FreezeRobloxKeybindString",
        "ResetSprintToggleKeybindString",
        "ShowOrMinimizeKeybindString",
        "CloseMacroKeybindString",
        "IncreaseGunAmountString",
        "DecreaseGunAmountString"
    ]

    FunctionNames := [
        MainToggle,
        FastGunSwap,
        ShuffleReload,
        Lagswitch,
        PressureJump,
        FreezeClip,
        FreezeRoblox,
        SprintToggleReset,
        MinimizeOrShowGUI,
        StopMacro,
        IncreaseGunAmountFunc,
        DecreaseGunAmountFunc
    ]

    HelpGuiVariables := [
        "MainToggleHelp",
        "FastGunSwapHelp",
        "ShuffleReloadHelp",
        "LagswitchHelp",
        "PressureJumpHelp",
        "FreezeClipHelp",
        "FreezeRobloxHelp",
        "ResetSprintToggleHelp",
        "ShowOrMinimizeHelp",
        "CloseMacroHelp",
        "IncreaseGunAmountHelp",
        "DecreaseGunAmountHelp"
    ]

    NonHotIfs := [
        "MainToggleKeybindString",
        "ShowOrMinimizeKeybindString",
        "CloseMacroKeybindString"
    ]

    for i, KeybindObject in Keybinds {
        CurText := KeybindObject.Value
        HelpText := HelpGuiVariables[i]
        VarName := FinalKeybindString[i]
        FuncName := FunctionNames[i]

        if (CurText == "") {
            continue
        }

        OldHotkey := Max(1, 1) ? (%VarName%) : ""

        ; Deactivate old hotkey
        if (OldHotkey != "") {
            Try {
                Hotkey(%VarName%, "Off")
            }
        }

        ; Modifies strings and stuff
        if (CurText == "LMB") {
            %VarName% := KeybindStringAdd . "LButton"

            if (VarName == "FastGunSwapKeybindString") {
                SecondaryFastGunSwapKeybindString := "LButton"
            }
        } else {
            %VarName% := KeybindStringAdd . CurText

            if (VarName == "FastGunSwapKeybindString") {
                SecondaryFastGunSwapKeybindString := CurText
            }
        }
        CurAssignedHotkey := %VarName%

        ; Help gui update
        Try {
            if IsSet(%HelpText%) {
                %HelpText%.Value := StrUpper(CurText)
                %HelpText%.Redraw()
            }
        }

        ; Bind new hotkey
        Try {
            IsNonHotif := false

            for x, NonHotIfCheck in NonHotIfs {
                if (String(VarName) == String(NonHotIfCheck)) {
                    IsNonHotIf := true
                    break
                }
            }

            if (IsNonHotIf) {
                HotIf()
            } else {
                HotIf (*) => ScriptActive
            }

            Hotkey(CurAssignedHotkey, FuncName.Bind())
            Hotkey(CurAssignedHotkey, "On")

            HotIf()
        }
    }
    UpdateGunVarsForSettingGui()
    if (UseCount >= 2) {
        SaveSettings()

        HideTrayTip()
        TrayTip("Applied Settings")
    }
}

; Hold or toggle fast gun swap
FastGunSwapHoldOrToggle(mode) {
    ; true = hold, false = toggle
    global

    if (mode == "auto") {
        FastGunSwapChoiceIsHold := !FastGunSwapChoiceIsHold
    }
    else if (mode == "hold") {
        FastGunSwapChoiceIsHold := true
        FastGunSwapChoiceStatus.Value := "Hold"
    }
    else if (mode == "toggle") {
        FastGunSwapChoiceIsHold := false
        FastGunSwapChoiceStatus.Value := "Toggle"
    }

    FastGunSwapChoiceStatus.Value := FastGunSwapChoiceIsHold ? "Hold" : "Toggle"
    FastGunSwapChoiceStatus.Redraw()
}

UpdateGunVarsForSettingGui() {
    global

    if (ShootDelayEditbox.Value < 1) {
        MsgBox("
        (Join
            Your pc can't handle 0 ms delay except if you somehow have 1000+ fps.
            `nShoot delay is automatically set to 1 ms
        )",
            "Warning",
            0x1000)
        ShootDelayEditbox.Value := 1
    }

    GunAmountVar := 0
    CountVar := 0

    for i, CurObject in GunSlotCheckboxBoolNames {
        if (%CurObject%) {
            GunAmountVar := i
            CountVar++
        }
    }
    UpdateRealGunStuff()

    GunsAmountStatus.Value := CountVar
    GunsAmountStatus.Redraw()
}

/*TestGui := Gui("-Caption +AlwaysOnTop")
TestGui.BackColor := "060606"
TestGui.Show("x400 y930 w900 h110")
; -- Gun Ammo Show Gui -- doesnt work
GunAmmoShowGui() {
    static GunAmmoShowGuiShow := false
    static GunAmountShowW := 200
    static GunAmountShowH := 300

    global GunAmountShowArray := [
        [], ; gun name
        [] ; gun ammo
    ]

    GunNameArray := [
        "AK-47", "M4A1", "M700",
        "M9", "MP5", "FAL",
        "Remington", "Revolver", "Taser"
    ]

    try {
        GameHWND := WinExist("ahk_exe RobloxPlayerBeta.exe")
        HotbarRegion := { X: 300, Y: 930, W: 900, H: 70 }

        OCR_Result := OCR.FromWindow(GameHWND, HotbarRegion, scale := 3)
        OCR_CleanResult := StrReplace(Trim(OCR_Result.Text), " ")
        MsgBox(OCR_Result.Text)

        for CurWord in GunNameArray {
            if InStr(OCR_CleanResult, CurWord) {
                GunAmountShowArray[1].Push(CurWord)
            }
        }
    } catch Error as err {
        MsgBox("OCR CRASHED!`n`nError Type: " . type(err) . "`nReason: " . err.Message . "`nLine: " . err.Line)
    }

    if (!GunAmmoShowGuiShow) {
        global GuiAmmoShow
        GuiAmmoShow := Gui("-Caption +AlwaysOnTop")
        GuiAmmoShow.BackColor := "060606"

        ; DRAGGABLE title in gun ammo show gui
        GuiAmmoShow.SetFont("s10 bold cF0F0F0", "Segoe UI")
        GuiAmmoShow.Add("Text", "x0 y5 w" GunAmountShowW " Center", "DRAGGABLE")

        for i, CurObject in GunAmountShowArray[1] {
            GuiAmmoShow.Add("Text", "x50 yp+25 w50 BackgroundTrans", GunAmountShowArray[1][i]) ; gun name

            GuiAmmoShow.Add("Text", "x93 yp w50 BackgroundTrans", ":") ; equal to

            GuiAmmoShow.Add("Text", "xp+10 yp w50 BackgroundTrans", "") ; ammo count
        }

        GunAmmoShowGuiShow := true
    }

    global IsGunAmmoShowVisible := !IsGunAmmoShowVisible

    ; Shows/closes Gun Amount show Gui
    if (IsGunAmmoShowVisible) {
        GuiAmmoShow.Show("w" GunAmountShowW " h" GunAmountShowH "")
    } else {
        GuiAmmoShow.Hide()
    }
}*/

; -- Change Log Gui --
ChangeLogGui() {
    static ChangeLogGuiShow := false

    if (!ChangeLogGuiShow) {
        global GuiChangeLog
        GuiChangeLog := Gui("-Caption +AlwaysOnTop")
        GuiChangeLog.BackColor := "060606" ; Black hex code
        static FirstLog := 50
        static OneLog := 45
        static DoubleLog := 75
        static TripleLog := 105
        static QuadrupleLog := 150

        ; Title for Change Log GUI
        GuiChangeLog.SetFont("s25 bold cF0F0F0", "Segoe UI")
        GuiChangeLog.Add("Text", "x0 y5 w360 Center", "Change Log V4.8")

        ; -- Change Logs --
        GuiChangeLog.SetFont("s30 bold cF0F0F0", "Segoe UI")

        ; 1
        AddText("Made macro run better", FirstLog)

        ; 2
        ;AddText("Lag switch improved. Clumsy app isnt needed anymore. You can uninstall clumsy", DoubleLog)

        ; 3
        ;AddText("Fixed freeze clip", TripleLog)

        ; 4
        ;AddText("Improved macro closing", TripleLog)

        ; Credit in Change Log GUI
        GuiChangeLog.SetFont("s10 cF0F0F0", "Consolas")
        GuiChangeLog.Add("Text", "x0 y380 w360 Center", "Made By @Idkwhattonamethis223 On Youtube")

        AddText(ChangeLogTextInput, YposInput) {
            GuiChangeLog.SetFont("s18 bold cF0F0F0", "Segoe UI")
            GuiChangeLog.Add("Text", "x50 yp+" YposInput " w265 Center", ChangeLogTextInput)

            GuiChangeLog.SetFont("s20 bold cF0F0F0", "Segoe UI")
            GuiChangeLog.Add("Text", "x10 yp w5", "•")
        }

        ; X button in Change Log GUI
        GuiChangeLog.SetFont("s13 bold cF0F0F0", "Arial")
        GuiChangeLog.Add("Text", "x329 y0 w30 h20 Center BackgroundD81F25", "X").OnEvent("Click", (*) => HideChangeLog())

        ; function for hiding setting GUI
        HideChangeLog(*) {
            GuiChangeLog.Hide()
            global IsChangeLogVisible := false
            ;GunAmmoShowGui() ; <<<<<
        }

        ChangeLogGuiShow := true
    }

    global IsChangeLogVisible := !IsChangeLogVisible

    ; Shows/closes changelog GUI
    if (IsChangeLogVisible) {
        ChangeLogW := 450
        ChangeLogH := 500
        GuiChangeLog.Show("w" ChangeLogW " h" ChangeLogH "")
        WinSetRegion("0-0 w" ChangeLogW " h" ChangeLogH " r20-20", GuiChangeLog.Hwnd)
    } else {
        GuiChangeLog.Hide()
    }
}

; -- Kill Tray Trip Function --
HideTrayTip() {
    TrayTip() ; Clears tray tip

    if (SubStr(A_OSVersion, 1, 3) = "10.") { ; Hides tray trip
        A_IconHidden := false
    }

    SetTimer(HideTrayTip, 0) ; if i decide to use SetTimer
}

; -- Sleep below 10 ms --
SuperSleep(ms) {
    if (ms <= 0) {
        DllCall("Sleep", "UInt", 0)
        return
    }

    static freq := 0
    if (!freq)
        DllCall("QueryPerformanceFrequency", "Int64*", &freq)


    current := 0
    start := 0

    DllCall("QueryPerformanceCounter", "Int64*", &start)
    target := start + (ms * freq / 1000)

    while (current < target) {
        DllCall("QueryPerformanceCounter", "Int64*", &current)
    }
}


~^s:: {
    Sleep(200)
    Reload()
}
