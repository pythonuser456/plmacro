; made by @Idkwhattonamethis223 (youtube) / @cooluser75_10906 (discord)

#Requires AutoHotkey v2.0

; -- Admin call --
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

; -- Auto Execute --
#SingleInstance Force
#MaxThreads 255
#NoTrayIcon

A_MenuMaskKey := ""
A_HotkeyInterval := 0
A_MaxHotkeysPerInterval := 999999

KeyHistory 0
ListLines 0

ProcessSetPriority "High"
SendMode "Input"

SetKeyDelay -1, -1
SetMouseDelay -1
SetWinDelay -1
SetControlDelay -1

DllCall("ntdll\NtSetTimerResolution", "UInt", 10000, "Int", 1, "UInt*", &CurrentResolution := 0) ; for super sleep
DllCall("SetProcessWorkingSetSize", "Ptr", -1, "UPtr", -1, "UPtr", -1, "UInt", 1)
DllCall("winmm\timeBeginPeriod", "UInt", 1)

SettingSavePathINI := A_ScriptDir "\SettingsConfig.ini"

; -- Resolution scaling --
; The GUIs were laid out on a 1920x1080 screen at 125% Windows scaling (120 DPI).
; ScaledGui resizes everything from that layout, so it looks the same on any resolution or scaling.
DesignDPI := 120
UiScale := Min(A_ScreenWidth / 1920, A_ScreenHeight / 1080) ; window sizes/positions
LayoutScale := UiScale * DesignDPI / 96                      ; control positions/sizes
FontScale := UiScale * DesignDPI / A_ScreenDPI               ; font sizes (Windows already scales fonts by DPI)

class ScaledGui extends Gui {
    __New(Options := "", Title?) => super.__New("-DPIScale " Options, Title?)
    Add(ControlType, Options := "", Text?) => super.Add(ControlType, ScaleOptions(Options, LayoutScale), Text?)
    AddEdit(Options := "", Text?) => super.AddEdit(ScaleOptions(Options, LayoutScale), Text?)
    SetFont(Options := "", FontName?) => super.SetFont(ScaleOptions(Options, FontScale), FontName?)
    Show(Options := "") => super.Show(ScaleOptions(Options, UiScale))
}

; Multiplies the numbers in x/y/w/h (incl. xp+/yp-) and font size (s) options by Factor
ScaleOptions(Options, Factor) {
    Out := ""
    for Token in StrSplit(Options, " ") {
        if RegExMatch(Token, "i)^([xywh]p?|s)([+-]?)(\d+)$", &M)
            Token := M[1] M[2] (M[1] = "s" ? Max(1, Round(M[3] * Factor)) : Round(M[3] * Factor))
        Out .= (A_Index > 1 ? " " : "") Token
    }
    return Out
}

; Shows a GUI with rounded corners, using design (1920x1080) sizes
ShowRounded(G, W, H, R, Options := "") {
    G.Show(Options " w" W " h" H)
    WinSetRegion("0-0 w" Round(W * UiScale) " h" Round(H * UiScale) " r" Round(R * UiScale) "-" Round(R * UiScale), G.Hwnd)
}

; -- Variables --
ScriptActive := false
ShowUi := false
ShiftHolder := false
IsCrouching := false
IsChatting := false
IsLagging := false
IsFrozen := false
IsFastGunSwapHolding := false
FastGunSwapChoiceIsHold := true
Turn180Deg := false
LagSwitchTL := 0

IsHelpVisible := false
IsSettingsVisible := true ; SettingsGui() flips this on startup, so settings start hidden
IsChangeLogVisible := false

GuiThing := ""
GuiSetting := ""
GuiHelp := ""

; Settings checkboxes (order matches the INI save)
CheckBoxShiftHolderBOOL := false
CheckBoxLagSwitchRuleAutoBOOL := false
CheckBoxSoundBeepBOOL := false
CheckBoxTurnOffChangelogBOOL := false
OtherCheckboxes := []

; Gun slots
GunSlotBools := []
Loop 10
    GunSlotBools.Push(false)
GunSlotCheckboxes := []
ActiveSlots := []
GunAmountVar := 0

SecondaryFastGunSwapKeybindString := ""

; Keybinds (order matches the settings GUI and the INI save)
; When = condition the hotkey needs to fire ("" = always works)
Keybinds := [
    {Label: "Main Toggle",         Default: "Alt", Func: MainToggle,            When: ""},
    {Label: "Fast Gun Swap",       Default: "LMB", Func: FastGunSwap,           When: IsScriptActive},
    {Label: "Shuffle Reload",      Default: "r",   Func: ShuffleReload,         When: IsScriptActive},
    {Label: "Lag Switch",          Default: "t",   Func: Lagswitch,             When: IsScriptActive},
    {Label: "Pressure Jump",       Default: "g",   Func: PressureJump,          When: IsScriptActive},
    {Label: "Freeze Clip",         Default: "b",   Func: FreezeClip,            When: IsScriptActive},
    {Label: "Freeze Roblox",       Default: "y",   Func: FreezeRoblox,          When: IsScriptActive},
    {Label: "Reset Sprint Toggle", Default: "m",   Func: SprintToggleReset,     When: CanResetSprint}, ; works like sprint toggle, even with the macro OFF
    {Label: "Show/Minimize",       Default: "f4",  Func: MinimizeOrShowGUI,     When: ""},
    {Label: "Close Macro",         Default: "Del", Func: StopMacro,             When: ""},
    {Label: "Increase Gun Amount", Default: "p",   Func: IncreaseGunAmountFunc, When: IsScriptActive},
    {Label: "Decrease Gun Amount", Default: "o",   Func: DecreaseGunAmountFunc, When: IsScriptActive}
]

; -- GUI Call --
MainGui()
SettingsGui()

OnMessage(0x0201, (*) => PostMessage(0xA1, 2, , , "A")) ; for gui drag

; -- Load saved checkboxes --
for i, Value in StrSplit(IniRead(SettingSavePathINI, "other_checkbox_saves", "OtherCheckboxValues", ""), "|") {
    if (i <= OtherCheckboxes.Length && Value == "1")
        CheckboxFunction(i)
}

for i, Value in StrSplit(IniRead(SettingSavePathINI, "gun_checkbox_saves", "GunCheckboxValues", ""), "|") {
    if (i <= GunSlotBools.Length && Value == "1")
        SetGunSlot(i, true)
}

if (!CheckBoxTurnOffChangelogBOOL) {
    ChangeLogGui()
}

if (CheckBoxLagSwitchRuleAutoBOOL) {
    CreateLagSwitchRule()
}

; -- Helpers --
BeepIfEnabled(Freq := 550) {
    if CheckBoxSoundBeepBOOL
        DllCall("Beep", "UInt", Freq, "UInt", 20)
}

SetCheckboxColor(Ctrl, State) {
    Ctrl.Opt(State ? "Background00FF00" : "Background060606")
    Ctrl.Redraw()
}

IsScriptActive(*) => ScriptActive
CanResetSprint(*) => CheckBoxShiftHolderBOOL && !IsChatting

; -- Main Toggle --
MainToggle(hk := "") {
    global ScriptActive := !ScriptActive

    StatusLabel.Text := ScriptActive ? "ON" : "OFF"
    StatusLabel.Opt(ScriptActive ? "Background00FF7F" : "BackgroundD81F25")
    StatusLabel.Redraw()

    BeepIfEnabled(ScriptActive ? 550 : 400)
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

    GunLoop() {
        if (!IsFastGunSwapHolding) {
            return
        }

        OptimizedShoot(ActiveSlots, delay)

        SetTimer(GunLoop, -1)
    }
}

OptimizedShoot(CurArray, CurDelay) {
    for Key in CurArray {
        Sleep(-1)

        if (!ScriptActive) {
            return
        }

        Send("{Blind}{" Key "}")
        SuperSleep(CurDelay)
        Click()
        SuperSleep(CurDelay)
    }
}

; -- Shuffle Reload --
ShuffleReload(hk := "") {
    delay := Number(ReloadDelayEditbox.Value)

    for Key in ActiveSlots {
        Send "{Blind}{" Key "}"
        SuperSleep(delay)
        Send "{Blind}r"
    }

    BeepIfEnabled()
}

; -- Increase/Decrease Gun Amount Shortcuts --
IncreaseGunAmountFunc(hk := "") {
    global GunAmountVar
    GunAmountVar += 1
    ChangeGunAmount(true)
}

DecreaseGunAmountFunc(hk := "") {
    ChangeGunAmount(false)
}

; GunAmountVar is the highest checked slot, so this checks the next slot or unchecks the last one
ChangeGunAmount(State) {
    global GunAmountVar

    if (GunAmountVar <= 0 || GunAmountVar > 10) {
        GunAmountVar := 0
        return
    }

    SetGunSlot(GunAmountVar, State)
    BeepIfEnabled()
}

; -- Create lag switch rule --
CreateLagSwitchRule() {
    global

    ; -- Create new lag switch rule --
    PID := ProcessExist("RobloxPlayerBeta.exe") ? "RobloxPlayerBeta.exe" : "WindowsUniversal.exe"
    CurrentPath := GetProcessPath(PID)

    try {
        ; Cache the policy manager globally
        fwPolicy2 := ComObject("HNetCfg.FwPolicy2")
        rules := fwPolicy2.Rules

        ; Remove old rule
        try rules.Remove("RobloxLagSwitch")

        ; Create new rule
        ruleObj := ComObject("HNetCfg.FwRule")
        ruleObj.Name := "RobloxLagSwitch"
        ruleObj.ApplicationName := CurrentPath
        ruleObj.Direction := 2 ; Outbound
        ruleObj.Action := 0    ; Block
        ruleObj.InterfaceTypes := "All"
        ruleObj.Enabled := false

        rules.Add(ruleObj)

        ; Lock the rule
        fwRule := rules.Item("RobloxLagSwitch")

        ; Create lag switch rule button animation
        CreateLagSwitchRuleButton.Opt("Background18181c")
        CreateLagSwitchRuleButton.Redraw()

        SetTimer(anim, -150)

        anim() {
            CreateLagSwitchRuleButton.Opt("BackgroundF0F0F0")
            CreateLagSwitchRuleButton.Redraw()
        }
    }

    ; -- Give Roblox Max Performance --
    try {
        RunWait('REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\RobloxPlayerBeta.exe" /f', , "Hide")
        RunWait('REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\WindowsUniversal.exe" /f', , "Hide")
    }

    ; Restore default Fullscreen Optimization handlers
    try {
        RunWait('REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "' . GetProcessPath("RobloxPlayerBeta.exe") . '" /f', , "Hide")
    }

    ; Revert network congestion configurations back to Windows stock defaults
    try {
        RunWait('netsh int tcp set global autotuninglevel=normal', , "Hide")
        RunWait('netsh int tcp set global ecncapability=disabled', , "Hide")
    }
}

; -- Lag Switcher --
Lagswitch(hk := "") {
    global LagSwitchTL, IsLagging
    Critical 1

    IsLagging := !IsLagging

    switch IsLagging {
        case true:
            try fwRule.Enabled := true

            LagSwitchTL := 19
            LagSwitchStatus.Value := LagSwitchTL
            LagSwitchStatus.Opt("Background00FF7F")
            LagSwitchStatus.Redraw()
            SetTimer(LagSwitchCount, 1000)
        case false:
            SetTimer(LagSwitchCount, 0)

            try fwRule.Enabled := false

            LagSwitchTL := 0
            LagSwitchStatus.Value := 0
            LagSwitchStatus.Opt("BackgroundD81F25")
            LagSwitchStatus.Redraw()
    }

    BeepIfEnabled(IsLagging ? 550 : 400)
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
        try fwRule.Enabled := false

        LagSwitchStatus.Value := 0
        LagSwitchStatus.Opt("BackgroundD81F25")
        LagSwitchStatus.Redraw()

        BeepIfEnabled(400)
    }
}

GetProcessPath(processName) {
    static MSGBOXSTARTDONE := false

    for proc in ComObjGet("winmgmts:").ExecQuery("Select ExecutablePath from Win32_Process Where Name = '" . processName . "'") {
        if proc.ExecutablePath
            return proc.ExecutablePath
    }

    if (!MSGBOXSTARTDONE) {
        MsgBox("Roblox not found, close the macro and reopen it when you join Roblox if you want lag-switch to work")
    }

    MSGBOXSTARTDONE := true
}

; -- Pressure Jump --
PressureJump(hk := "") {
    BeepIfEnabled()

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

    BeepIfEnabled()
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

; -- Freeze Functions --
freeze(FreezeChoice) {
    targetWin := WinExist("ahk_exe RobloxPlayerBeta.exe") ? "ahk_exe RobloxPlayerBeta.exe" : "ahk_exe ApplicationFrameHost.exe"

    if !WinExist(targetWin) {
        ToolTip("Roblox not found")
        SetTimer () => ToolTip(), -1500
        return
    }

    pid := 0
    winThreadId := DllCall("User32.dll\GetWindowThreadProcessId", "Ptr", WinExist(targetWin), "Ptr*", pid, "UInt")

    ; (0x1F0FFF)
    hThread := DllCall("Kernel32.dll\OpenThread", "UInt", 0x1F0FFF, "Int", false, "UInt", winThreadId, "Ptr")

    if (!hThread) {
        ToolTip("Failed to connect to Roblox window")
        SetTimer () => ToolTip(), -1500
        return
    }

    switch (FreezeChoice) {
        case 1:
            DllCall("Kernel32.dll\SuspendThread", "Ptr", hThread)
        case 2:
            DllCall("Kernel32.dll\ResumeThread", "Ptr", hThread)
    }

    ; Clean up
    DllCall("Kernel32.dll\CloseHandle", "Ptr", hThread)
}

#HotIf CheckBoxShiftHolderBOOL and !IsChatting and !IsCrouching
; -- Shift Holder --
~$*LShift:: {
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

    BeepIfEnabled()
}

; Note: when several #HotIf variants of the same key are eligible, the one written first wins,
; so this "un-crouch" c must stay above the "crouch" c below
#HotIf CheckBoxShiftHolderBOOL and IsCrouching
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

#HotIf CheckBoxShiftHolderBOOL
; Disables sprint toggle if crouched
*$c:: {
    global ShiftHolder := false
    global IsCrouching := true
    ShiftHolderStatus.Opt("BackgroundD81F25")
    ShiftHolderStatus.Redraw()

    Send "{LShift up}"
    Send "{Blind}c"
}

; Disable sprint toggle if chatting
*$?::
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
~*$Enter::
~$*LButton:: {
    global IsChatting := false
}
#HotIf

; Resets sprint toggle
SprintToggleReset(hk := "") {
    global ShiftHolder := false
    global IsCrouching := false
    global IsChatting := false

    ShiftHolderStatus.Opt("BackgroundD81F25")
    ShiftHolderStatus.Redraw()

    Send "{LShift up}"
}

; -- Minimize/Show GUI --
MinimizeOrShowGUI(hk := "") {
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

; -- Macro close --
StopMacro(hk := "") {
    Send "{LShift up}"

    try rules.Remove("RobloxLagSwitch")
    DllCall("Winmm\timeEndPeriod", "UInt", 1)

    ; Close autohotkey
    try ProcessClose("AutoHotkey64.exe")
    try ProcessClose("AutoHotkey.exe")

    ; If closing fails
    ExitApp()
}

; -- Main GUI --
MainGUI() {
    global GuiThing, ShiftHolderStatus, LagSwitchStatus, GunsAmountStatus, StatusLabel

    GuiThing := ScaledGui("-Caption +AlwaysOnTop")
    GuiThing.BackColor := "060606"

    ; Shift Holder + Lag switch status
    GuiThing.SetFont("s7 bold cF0F0F0", "Arial")
    ShiftHolderStatus := GuiThing.Add("Text", "x77 y0 w34 h15 Center 0x200 BackgroundD81F25 Hidden", "SPRINT")
    LagSwitchStatus := GuiThing.Add("Text", "x61 y0 w15 h15 Center 0x200 BackgroundD81F25", LagSwitchTL)

    ; Title
    GuiThing.SetFont("s12 bold cF0F0F0", "Segoe UI")
    GuiThing.Add("Text", "x71 y13 w145 BackgroundTrans", "Prison Life Macro")

    ; Credit
    GuiThing.SetFont("s4 bold cF0F0F0", "Consolas")
    GuiThing.Add("Text", "xp+3 yp+21 w130 BackgroundTrans", "Made By @Idkwhattonamethis223 On Youtube")

    ; On/Off button
    GuiThing.SetFont("s23 bold cF0F0F0", "Arial")
    StatusLabel := GuiThing.Add("Text", "x0 y0 w60 h55 0x200 BackgroundD81F25 -0x100 0x1", "OFF")

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

    ShowRounded(GuiThing, 270, 65, 15, "y740")
}

; -- Help GUI --
HelpGui() {
    static HelpGuiShow := false
    global GuiHelp, IsHelpVisible

    if (!HelpGuiShow) {
        GuiHelp := ScaledGui("-Caption +AlwaysOnTop")
        GuiHelp.BackColor := "060606"

        ; Title for help GUI
        GuiHelp.SetFont("s35 bold cF0F0F0", "Segoe UI")
        GuiHelp.Add("Text", "x150 y0 w370 Center", "Macro Help")

        ; -- Keybinds show --
        GuiHelp.SetFont("s25 bold cF0F0F0", "Tahoma")
        GuiHelp.Add("Text", "x-8 y70 w330 Center", "Keybinds")

        GuiHelp.SetFont("s15 bold cF0F0F0", "Consolas")
        for i, kb in Keybinds {
            kb.HelpLabel := GuiHelp.Add("Text", (i == 1 ? "xp+60 yp+45" : "xp y+5") " w60 BackgroundTrans", StrUpper(kb.Edit.Value))
            GuiHelp.Add("Text", "xp yp w330 Center BackgroundTrans", Format("= {:-19}", kb.Label))
        }

        ; -- Extra info --
        ExtraInfoHelpStrings := [
            " ; fast gun swap info
            (Join
                To use the fast weapon swap macro,
                 you need to select your inventory slots where your guns are
                 in the settings or use the O/P keybinds.
                 The recommended shoot delay is 8 milisecond (might be false)
            )",
            " ; pressure jump info
            (Join
                To activate the pressure jump macro,
                 put your roblox sensitivity and your mouse pointer speed (search it your windows settings) in the macro settings.
                 Walk up to one of the pressure jump spots (search up youtube tutorial for the spots).
                 Then crouch and shove your head fully into the object
                 then press G. Also if you set your mouse pointer lower than 4 the script
                 would automatically set your mouse pointer speed to 4 in the macro settings
                 so the pressure jump would work. The more fps you have, the better the macro works.
                 If you only have 30 fps or 60 fps this might not work
            )",
            " ; freeze clip info
            (Join
                To freeze clip, you need to walk directly to a thin wall (around 0.9 studs).
                 Set your camera angle to around 120 degrees or exactly 180 degrees (google a protractor image).
                 Then press B and try to reach the other side of the wall you chose
            )",
            " ; lag switch info
            (Join
                To lag switch, click the "Create Lag-Switch Rule" button in settings gui while Roblox proccess
                 is running (RobloxPlayerBeta.exe). Aditionally, "Create Startup Lag-Switch Rule" checkbox in settings gui
                 automatically creates a lag switch rule upon starting the macro
            )"
        ]

        GuiHelp.SetFont("s25 bold cF0F0F0", "Tahoma")
        GuiHelp.Add("Text", "x335 y70 w330 Center", "Extra Info")

        GuiHelp.SetFont("s7 cF0F0F0", "Consolas")
        for i, InfoText in ExtraInfoHelpStrings {
            GuiHelp.Add("Text", (i == 1 ? "xp+45 yp+45" : "xp y+8") " w240 Center", InfoText)
        }

        ; Changelog button
        GuiHelp.SetFont("s17 bold cF0F0F0", "Arial")
        GuiHelp.Add("Text", "x240 y+30 w200 h40 Center 0x200 BackgroundE1A91A", "Change Logs").OnEvent("Click", (*) => ChangeLogGui())

        ; Credit in help GUI
        GuiHelp.SetFont("s15 cF0F0F0", "Consolas")
        GuiHelp.Add("Text", "x0 y+10 w680 Center", "Made By @Idkwhattonamethis223 On Youtube")

        ; X button for help GUI
        GuiHelp.SetFont("s17 bold cF0F0F0", "Arial")
        GuiHelp.Add("Text", "x625 y0 w40 h25 Center BackgroundD81F25", "X").OnEvent("Click", HideHelp)

        HideHelp(*) {
            GuiHelp.Hide()
            global IsHelpVisible := false
        }

        HelpGuiShow := true
    }

    IsHelpVisible := !IsHelpVisible

    ; Shows/closes help GUI
    if (IsHelpVisible) {
        ShowRounded(GuiHelp, 830, 780, 20)
    } else {
        GuiHelp.Hide()
    }
}

; -- Settings GUI --
SettingsGui() {
    static SettingsGuiShow := false
    global GuiSetting, IsSettingsVisible
    global ShootDelayEditbox, ReloadDelayEditbox, MousePointerSpeed_Input, Sens_Input
    global FastGunSwapChoiceStatus, CreateLagSwitchRuleButton

    if (!SettingsGuiShow) {
        GuiSetting := ScaledGui("-Caption +AlwaysOnTop")
        GuiSetting.BackColor := "060606"

        ; Title for settings GUI
        GuiSetting.SetFont("s30 bold cF0F0F0", "Segoe UI")
        GuiSetting.Add("Text", "x230 y0 w700 Center BackgroundTrans", "Macro Settings")

        ; -- Keybinds --
        ; INI layout: key1|key2|Hold/Toggle|key3..key12|0
        SavedKeys := StrSplit(IniRead(SettingSavePathINI, "keybind_saves", "KeybindValues", ""), "|")
        HasSavedKeys := SavedKeys.Length >= 13

        for i, kb in Keybinds {
            GuiSetting.SetFont("s15 bold cF0F0F0", "Consolas")
            GuiSetting.Add("Text", "x40 y" (70 + (i - 1) * 30) " w400 BackgroundTrans", kb.Label)
            GuiSetting.Add("Text", "xp+240 yp w10", "=")

            GuiSetting.SetFont("s15 bold c060606", "Consolas")
            kb.Edit := GuiSetting.AddEdit("xp+30 yp w45 h25 0x200 BackgroundF0F0F0", HasSavedKeys ? SavedKeys[i <= 2 ? i : i + 1] : kb.Default)

            ; Hold/Toggle button for fast gun swap
            if (kb.Func == FastGunSwap) {
                GuiSetting.SetFont("s10 bold c060606", "Consolas")
                FastGunSwapChoiceStatus := GuiSetting.Add("Text", "xp-120 yp w45 h25 0x200 BackgroundF0F0F0 -0x100 0x1", "Hold")
                FastGunSwapChoiceStatus.OnEvent("Click", (*) => SetFastGunSwapMode(!FastGunSwapChoiceIsHold))

                if HasSavedKeys
                    SetFastGunSwapMode(SavedKeys[3] != "Toggle")
            }
        }

        ; -- Other settings --
        ; INI layout: ShootDelay|ReloadDelay|0|0|MousePointerSpeed|Sensitivity
        EditboxValues := StrSplit(IniRead(SettingSavePathINI, "editbox_saves", "EditboxValues", "8|0|0|0|0|0"), "|")

        AddSettingLabel(GuiSetting, "Shoot Delay", 70)
        ShootDelayEditbox := GuiSetting.AddEdit("xp+360 yp+4 w25 h25 0x200 +Number BackgroundF0F0F0", EditboxValues[1])
        AddMillisecondLabel(GuiSetting, 125)

        AddSettingLabel(GuiSetting, "Reload Delay", 100)
        ReloadDelayEditbox := GuiSetting.AddEdit("xp+360 yp+4 w25 h25 0x200 +Number BackgroundF0F0F0", EditboxValues[2])
        AddMillisecondLabel(GuiSetting, 115)

        AddSettingLabel(GuiSetting, "Pressure Jump", 140)
        GuiSetting.SetFont("s12")
        MousePointerSpeed_Input := GuiSetting.AddEdit("xp+260 yp w30 h20 Number BackgroundF0F0F0", EditboxValues[5])
        GuiSetting.SetFont("s7 cF0F0F0")
        GuiSetting.Add("Text", "xp-22 yp+20 w73 Center", "Mouse`nPointer Speed")

        GuiSetting.SetFont("s12 c060606")
        Sens_Input := GuiSetting.AddEdit("xp+110 yp-20 w45 h20 BackgroundF0F0F0", EditboxValues[6])
        GuiSetting.SetFont("s7 cF0F0F0")
        GuiSetting.Add("Text", "xp-9 yp+20 w50 Center", "Roblox sensitivity")

        for i, Name in ["Sprint Toggle", "Create Startup Lag-Switch Rule", "Sound Beep Toggle", "Disable Startup Update Logs"] {
            AddSettingLabel(GuiSetting, Name, 190 + (i - 1) * 30)
            Checkbox := AddCheckbox(GuiSetting, 359)
            Checkbox.OnEvent("Click", CheckboxFunction.Bind(i))
            OtherCheckboxes.Push(Checkbox)
        }

        ; -- Gun slots --
        Loop GunSlotBools.Length {
            i := A_Index
            GuiSetting.SetFont("s15 bold cF0F0F0", "Consolas")
            GuiSetting.Add("Text", "x820 y" (70 + (i - 1) * 30) " w330 BackgroundTrans", "Slot " i)

            Checkbox := AddCheckbox(GuiSetting, 200)
            Checkbox.OnEvent("Click", ToggleGunSlot.Bind(i))
            GunSlotCheckboxes.Push(Checkbox)
        }

        ; X button in settings GUI
        GuiSetting.SetFont("s17 bold cF0F0F0", "Arial")
        GuiSetting.Add("Text", "x1058 y0 w40 h25 Center BackgroundD81F25", "X").OnEvent("Click", HideSetting)

        HideSetting(*) {
            GuiSetting.Hide()
            global IsSettingsVisible := false
            UpdateGunVars()
        }

        ; Save and apply button
        GuiSetting.SetFont("s11 bold cF0F0F0", "Arial")
        ApplyButtonSetting := GuiSetting.Add("Text", "x495 y375 w170 h50 Center 0x200 BackgroundD81F25", "Save && Apply Settings")
        ApplyButtonSetting.OnEvent("Click", ApplyAndSave)

        ApplyAndSave(*) {
            ApplyKeybinds()
            SaveSettings()

            ApplyButtonSetting.Opt("Background00FF7F")
            ApplyButtonSetting.Redraw()
            SetTimer(MakeApplyButtonRed, -150)
        }

        MakeApplyButtonRed() {
            ApplyButtonSetting.Opt("BackgroundD81F25")
            ApplyButtonSetting.Redraw()
        }

        ; Create lag switch rule button
        GuiSetting.SetFont("s11 bold c060606", "Arial")
        CreateLagSwitchRuleButton := GuiSetting.Add("Text", "x495 y325 w170 h50 Center 0x200 BackgroundF0F0F0", "Create Lag-Switch Rule")
        CreateLagSwitchRuleButton.OnEvent("Click", (*) => CreateLagSwitchRule())

        ; Update Button
        GuiSetting.SetFont("s11 bold cF0F0F0", "Arial")
        GuiSetting.Add("Text", "x880 y420 w130 h40 Center 0x200 BackgroundD81F25", "UPDATE MACRO").OnEvent("Click", UpdateMacro)

        UpdateMacro(*) {
            try {
                Download("https://raw.githubusercontent.com/pythonuser456/plmacro/refs/heads/main/PRISON_LIFE_MACRO.ahk", "PRISON_LIFE_MACRO.ahk")
                MsgBox("Reopen the macro file", "UPDATE INFO", 262144)
                StopMacro()
            } catch {
                MsgBox("Update failed", "UPDATE INFO", 262144)
            }
        }

        ; Credit in settings GUI
        GuiSetting.SetFont("s15 cF0F0F0", "Consolas")
        GuiSetting.Add("Text", "x80 y450 w1000 Center BackgroundTrans", "Made By @Idkwhattonamethis223 On Youtube")

        SettingsGuiShow := true
        ApplyKeybinds()
    }

    IsSettingsVisible := !IsSettingsVisible

    ; Shows/closes Settings GUI
    if (IsSettingsVisible) {
        ShowRounded(GuiSetting, 1370, 600, 20)
    } else {
        GuiSetting.Hide()
    }
}

; Settings GUI helpers
AddSettingLabel(G, Text, Y) {
    G.SetFont("s15 bold cF0F0F0", "Consolas")
    G.Add("Text", "x390 y" Y " w500 BackgroundTrans", Text)
    G.SetFont("c060606")
}

AddMillisecondLabel(G, OffsetX) {
    G.SetFont("s8 bold cF0F0F0", "Consolas")
    G.Add("Text", "xp-" OffsetX " yp+10 w100 BackgroundTrans", "(milisecond)")
}

AddCheckbox(G, OffsetX) {
    G.Add("Text", "xp+" OffsetX " yp+1 w28 h25 BackgroundF0F0F0") ; white square
    return G.Add("Text", "xp+2 yp+2 w23 h20 Background060606")
}

CheckboxFunction(num, *) {
    global CheckBoxShiftHolderBOOL, CheckBoxLagSwitchRuleAutoBOOL, CheckBoxSoundBeepBOOL, CheckBoxTurnOffChangelogBOOL

    switch (num) {
        case 1: ; Sprint toggle
            State := CheckBoxShiftHolderBOOL := !CheckBoxShiftHolderBOOL
            ShiftHolderStatus.Visible := State
        case 2: ; Lag switch auto startup
            State := CheckBoxLagSwitchRuleAutoBOOL := !CheckBoxLagSwitchRuleAutoBOOL
        case 3: ; Sound beep
            State := CheckBoxSoundBeepBOOL := !CheckBoxSoundBeepBOOL
        case 4: ; Change log auto startup
            State := CheckBoxTurnOffChangelogBOOL := !CheckBoxTurnOffChangelogBOOL
    }

    SetCheckboxColor(OtherCheckboxes[num], State)

    ; Resets shift holder if sprint toggle is disabled
    if (num == 1 && !State)
        SprintToggleReset()
}

SetGunSlot(slot, State) {
    GunSlotBools[slot] := State
    SetCheckboxColor(GunSlotCheckboxes[slot], State)
    UpdateGunVars()
}

ToggleGunSlot(slot, *) => SetGunSlot(slot, !GunSlotBools[slot])

SetFastGunSwapMode(IsHold) {
    global FastGunSwapChoiceIsHold := IsHold
    FastGunSwapChoiceStatus.Value := IsHold ? "Hold" : "Toggle"
    FastGunSwapChoiceStatus.Redraw()
}

; Save settings to INI (formats kept the same so old save files still load)
SaveSettings() {
    KeyValues := []
    for i, kb in Keybinds {
        KeyValues.Push(kb.Edit.Value)
        if (kb.Func == FastGunSwap)
            KeyValues.Push(FastGunSwapChoiceStatus.Value)
    }
    KeyValues.Push(0)
    IniWrite(JoinPipe(KeyValues), SettingSavePathINI, "keybind_saves", "KeybindValues")

    IniWrite(JoinPipe([ShootDelayEditbox.Value, ReloadDelayEditbox.Value, 0, 0, MousePointerSpeed_Input.Value, Sens_Input.Value]),
        SettingSavePathINI, "editbox_saves", "EditboxValues")

    IniWrite(JoinPipe([CheckBoxShiftHolderBOOL, CheckBoxLagSwitchRuleAutoBOOL, CheckBoxSoundBeepBOOL, CheckBoxTurnOffChangelogBOOL]),
        SettingSavePathINI, "other_checkbox_saves", "OtherCheckboxValues")

    IniWrite(JoinPipe(GunSlotBools), SettingSavePathINI, "gun_checkbox_saves", "GunCheckboxValues")
}

JoinPipe(Arr) {
    Str := ""
    for Value in Arr
        Str .= (A_Index > 1 ? "|" : "") Value
    return Str
}

; Recalculates the active gun slots and the "Guns to swap" counter
UpdateGunVars() {
    global GunAmountVar, ActiveSlots

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
    ActiveSlots := []

    for i, Checked in GunSlotBools {
        if (Checked) {
            GunAmountVar := i
            ActiveSlots.Push(i == 10 ? 0 : i)
        }
    }

    GunsAmountStatus.Value := ActiveSlots.Length
    GunsAmountStatus.Redraw()
}

; (Re)binds every hotkey from the settings editboxes, very important function
ApplyKeybinds() {
    global SecondaryFastGunSwapKeybindString

    for kb in Keybinds {
        CurText := Trim(kb.Edit.Value)

        if (CurText == "") {
            continue
        }

        KeyName := (CurText == "LMB") ? "LButton" : CurText

        if (kb.When)
            HotIf(kb.When)
        else
            HotIf()

        ; Deactivate old hotkey
        if kb.HasOwnProp("Hotkey")
            try Hotkey(kb.Hotkey, "Off")

        kb.Hotkey := "*$" KeyName

        if (kb.Func == FastGunSwap)
            SecondaryFastGunSwapKeybindString := KeyName

        ; Help gui update
        if kb.HasOwnProp("HelpLabel") {
            kb.HelpLabel.Value := StrUpper(CurText)
            kb.HelpLabel.Redraw()
        }

        ; Bind new hotkey
        try {
            Hotkey(kb.Hotkey, kb.Func, "B I1")
            Hotkey(kb.Hotkey, "On")
        }
    }

    HotIf()
    UpdateGunVars()
}

; -- Change Log Gui --
ChangeLogGui() {
    static ChangeLogGuiShow := false
    static GuiChangeLog := ""
    global IsChangeLogVisible

    if (!ChangeLogGuiShow) {
        GuiChangeLog := ScaledGui("-Caption +AlwaysOnTop")
        GuiChangeLog.BackColor := "060606"

        ; Title for Change Log GUI
        GuiChangeLog.SetFont("s27 bold cF0F0F0", "Segoe UI")
        GuiChangeLog.Add("Text", "x0 y5 w430 Center", "Update Log V6.5")

        ; -- Change Logs --
        ; Below tile = 65
        ; One line = 45
        ; Double line = 70
        ; Tripe line = 95
        ; Four line = 125
        AddText("Button placements in display resolution other than 1920 x 1080 doesn't look wacky now", 65)
        AddText("Code cleanup", 125)

        ; Credit in Change Log GUI
        GuiChangeLog.SetFont("s12 cF0F0F0", "Consolas")
        GuiChangeLog.Add("Text", "x0 y490 w430 Center", "Made By @Idkwhattonamethis223 On Youtube")

        AddText(ChangeLogTextInput, YposInput) {
            GuiChangeLog.SetFont("s15 cF0F0F0", "Segoe UI")
            GuiChangeLog.Add("Text", "x80 yp+" YposInput " w270 Center", ChangeLogTextInput)

            GuiChangeLog.SetFont("s20 bold cF0F0F0", "Segoe UI")
            GuiChangeLog.Add("Text", "x10 yp w5", "•")
        }

        ; X button in Change Log GUI
        GuiChangeLog.SetFont("s13 bold cF0F0F0", "Arial")
        GuiChangeLog.Add("Text", "x393 y0 w30 h20 Center BackgroundD81F25", "X").OnEvent("Click", HideChangeLog)

        HideChangeLog(*) {
            GuiChangeLog.Hide()
            global IsChangeLogVisible := false
        }

        ChangeLogGuiShow := true
    }

    IsChangeLogVisible := !IsChangeLogVisible

    ; Shows/closes changelog GUI
    if (IsChangeLogVisible) {
        ShowRounded(GuiChangeLog, 530, 650, 20)
    } else {
        GuiChangeLog.Hide()
    }
}

; -- Sleep below 10 ms --
SuperSleep(ms) {
    if (ms <= 0) {
        ms := 1
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
