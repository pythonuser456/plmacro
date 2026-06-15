; made by @Idkwhattonamethis223 (youtube) / @cooluser75_10906 (discord)

#Requires AutoHotkey v2.0
#SingleInstance Force
ProcessSetPriority "High"
SetControlDelay(-1)
#MaxThreadsPerHotkey 2

; -- Variables --
ScriptActive := false
ShiftHolder := false
ShowUi := false

CheckBoxShiftHolderBOOL := false
CheckBoxLagSwitchBOOL := false
CheckBoxSoundBeepBOOL := false

IsHelpVisible := false
IsSettingsVisible := true
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

i := 0
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

; -- Main GUI Call --
if not A_IsAdmin {
    try {
        Run('*RunAs "' A_ScriptFullPath '"')
        ExitApp() ; Closes non admin version
    } catch as err {
        MsgBox("Admin privileges denied. Some features may not work properly or work at all.")
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
    StatusLabel.Opt(ScriptActive ? "Background00FF7F" : "BackgroundFF0000")
    StatusLabel.Redraw()

    if CheckBoxSoundBeepBOOL
        SoundBeep(ScriptActive ? 550 : 400, 20)
}


; -- Fast Gun Swap --
FastGunSwap(hk := "") {
    global Guns, i, IsFastGunSwapHolding

    if (!ScriptActive) {
        return
    }

    ; Shoots
    if (FastGunSwapChoiceIsHold) {
        while GetKeyState(SecondaryFastGunSwapKeybindString, "P") {
            ShootGun()
        }
    }
    else {
        IsFastGunSwapHolding := !IsFastGunSwapHolding

        Loop {
            if (!IsFastGunSwapHolding) {
                break
            }
            ShootGun()
        }
    }
}
#HotIf

ShootGun() {
    global GunAmountVar, i, ShootDelay

    if (!ScriptActive) {
        return
    }

    DllCall("Winmm\timeBeginPeriod", "UInt", 1)
    Loop GunAmountVar {
        i++

        if (i >= 10) {
            i := 0
        }

        Send "{Blind}{" i "}"
        DllCall("Sleep", "UInt", Number(ShootDelay.Value)) 
        Click
        DllCall("Sleep", "UInt", Number(ShootDelay.Value)) 

    }
    i := 0
    DllCall("Winmm\timeEndPeriod", "UInt", 1)
}

; -- Shuffle Reload --
ShuffleReload(hk := "") {
    global i, Guns

    if (!ScriptActive) {
        return
    }

    DllCall("Winmm\timeBeginPeriod", "UInt", 1)
    Loop GunAmountVar {
        i++

        Send "{Blind}{" i "}"
        DllCall("Sleep", "UInt", Number(ReloadDelay.Value)) 
        Send "{Blind}r"
    }
    i := 0
    DllCall("Winmm\timeEndPeriod", "UInt", 1)

    if CheckBoxSoundBeepBOOL
        SoundBeep(550, 20)
}

; -- Increase/decrease Gun Amount Shortcut --
DecreaseGunAmountFunc(hk := "") {
    global GunsAmountStatus, GunAmountVar, Guns

    if (!ScriptActive) {
        return
    }

    GunAmountVar -= 1

    if (GunAmountVar < 0) {
        GunAmountVar := 0
    } else if (GunAmountVar > 10) {
        GunAmountVar := 0
    }

    GunsAmountStatus.Value := GunAmountVar
    GunsAmountStatus.Redraw()

    Guns.Value := GunAmountVar
    Guns.Redraw()

    if CheckBoxSoundBeepBOOL
        SoundBeep(550, 20)
}

IncreaseGunAmountFunc(hk := "") {
    global GunsAmountStatus, GunAmountVar, Guns

    if (!ScriptActive) {
        return
    }

    GunAmountVar += 1

    if (GunAmountVar < 0) {
        GunAmountVar := 0
    } else if (GunAmountVar > 10) {
        GunAmountVar := 0
    }

    GunsAmountStatus.Value := GunAmountVar
    GunsAmountStatus.Redraw()

    Guns.Value := GunAmountVar
    Guns.Redraw()

    if CheckBoxSoundBeepBOOL
        SoundBeep(550, 20)
}

; -- Lag Switcher --
Lagswitch(hk := "") {
    global IsLagging := !IsLagging
    global LagSwitchTL

    if (!ScriptActive or !WinExist("ahk_exe clumsy.exe") or !CheckBoxLagSwitchBOOL) {
        return
    }

    ; IF TURNING OFF
    if (!IsLagging) {
        SetTimer(LagSwitchCount, 0)
        Try {
            ControlClick("Button2", "ahk_exe clumsy.exe")
        } catch {
            ControlClick("Button2", "ahk_exe clumsy.exe")
        }

        LagSwitchTL := 0
        LagSwitchStatus.Value := 0
        LagSwitchStatus.Opt("BackgroundFF0000")
        LagSwitchStatus.Redraw()

        if CheckBoxSoundBeepBOOL
            SoundBeep(400, 20)
        return
    }

    ; IF TURNING ON
    Try {
        ControlClick("Button2", "ahk_exe clumsy.exe")
    } catch {
        ControlClick("Button2", "ahk_exe clumsy.exe")
    }

    LagSwitchTL := 19
    LagSwitchStatus.Value := LagSwitchTL
    LagSwitchStatus.Opt("Background00FF7F")
    LagSwitchStatus.Redraw()
    SetTimer(LagSwitchCount, 1000)

    if CheckBoxSoundBeepBOOL
        SoundBeep(550, 20)
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
        Try {
            ControlClick("Button2", "ahk_exe clumsy.exe")
        } catch {
            ControlClick("Button2", "ahk_exe clumsy.exe")
        }

        LagSwitchStatus.Value := 0
        LagSwitchStatus.Opt("BackgroundFF0000")
        LagSwitchStatus.Redraw()

        if CheckBoxSoundBeepBOOL
            SoundBeep(400, 20)
    }
}

#HotIf ScriptActive
; -- Pressure Jump --
PressureJump(hk := "") {
    if (!ScriptActive) {
        return
    }

    if CheckBoxSoundBeepBOOL
        SoundBeep(550, 20)

    if (Sens_Input.Value == 0 or MousePointerSpeed_Input.Value == 0) {
        MsgBox("Put your Roblox Sensitivity and Mouse Pointer Speed in the settings. More info in the help GUI")
        return
    }

    DllCall("Winmm\timeBeginPeriod", "UInt", 1)
    if Number(MousePointerSpeed_Input.Value) < 4
        MousePointerSpeed_Input.Value := 4

    global WindowsRawSensitivity := float(4.0 / Number(MousePointerSpeed_Input.Value))
    global Turn180Var := float(WindowsRawSensitivity * (4000.0 / Number(Sens_Input.Value)))

    Send "{Blind}c"
    DllCall("Sleep", "UInt", 6) 

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

    DllCall("Winmm\timeEndPeriod", "UInt", 1)
    global IsCrouching := false
}

; -- Freeze Clip --
FreezeClip(hk := "") {
    if (!ScriptActive) {
        return
    }
    DllCall("Winmm\timeBeginPeriod", "UInt", 1)

    global ShiftHolder := false
    global IsCrouching := !IsCrouching
    global IsChatting := false
    Send "{LShift up}"
    ShiftHolderStatus.Opt("BackgroundFF0000")
    ShiftHolderStatus.Redraw()

    Send "{Blind}c"

    DllCall("Sleep", "UInt", 1) 

    freeze(1) ; starts freezing roblox

    Sleep(850)

    freeze(2) ; stops freezing roblox

    DllCall("Winmm\timeEndPeriod", "UInt", 1)
}

; -- Freeze Roblox --
FreezeRoblox(hk := "") {
    if (!ScriptActive) {
        return
    }

    global IsFrozen := !IsFrozen

    ; Freeze/Unfreeze
    if (IsFrozen) {
        freeze(1)
    } else {
        freeze(2)
    }
}

; -- Freeze Functions --
freeze(FreezeChoice) {
    targetProcess := "RobloxPlayerBeta.exe"
    pid := ProcessExist(targetProcess)

    if (!pid) {
        ToolTip("Roblox not found")
        SetTimer(() => ToolTip(), -1500)
        return
    }

    switch (FreezeChoice) {
        case 1:
            ToggleProcessState(pid, true)
        case 2:
            ToggleProcessState(pid, false)
    }

    SetTimer(() => ToolTip(), -1500)
}

ToggleProcessState(pid, Freeze) {
    ; Suspend/resume privileges (0x0800)
    hProcess := DllCall("Kernel32.dll\OpenProcess", "UInt", 0x0800, "Int", false, "UInt", pid, "Ptr")
    if (!hProcess) {
        MsgBox("Allow admin permissions")
        SetTimer(() => ToolTip(), -1500)
        return false
    }

    ; Suspend/Resume
    if (Freeze) {
        DllCall("ntdll.dll\NtSuspendProcess", "Ptr", hProcess)
    } else {
        ; Call NtResumeProcess
        DllCall("ntdll.dll\NtResumeProcess", "Ptr", hProcess)
    }

    ; Clean Up
    DllCall("Kernel32.dll\CloseHandle", "Ptr", hProcess)
    return true
}

FreezeCount() { ; useless function
    global FreezeTL
    FreezeTL -= 1

    if (FreezeTL <= 0) {
        freeze(2)
        SetTimer(FreezeCount, 0)
    }
}
#HotIf

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
        ShiftHolderStatus.Opt("BackgroundFF0000")
    }
    ShiftHolderStatus.Redraw()
}

; Disables sprint toggle if crouched
*$c:: {
    global ShiftHolder := false
    global IsCrouching := true
    ShiftHolderStatus.Opt("BackgroundFF0000")
    ShiftHolderStatus.Redraw()

    Send "{LShift up}"
    Send "{Blind}c"
}

; Resets sprint toggle
SprintToggleReset(hk := "") {
    global ShiftHolder := false
    global IsCrouching := false
    global IsChatting := false

    ShiftHolderStatus.Opt("BackgroundFF0000")
    ShiftHolderStatus.Redraw()

    Send "{LShift up}"
}

; Disable sprint toggle if chatting
*$?:: {
    global ShiftHolder := false
    global IsChatting := true
    global ScriptActive := false

    StatusLabel.Text := "OFF"
    StatusLabel.Opt("BackgroundFF0000")
    ShiftHolderStatus.Opt("BackgroundFF0000")
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
    StatusLabel.Opt("BackgroundFF0000")
    ShiftHolderStatus.Opt("BackgroundFF0000")
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

    try ProcessClose("AutoHotkey64.exe")
    try ProcessClose("AutoHotkey.exe")
    try WinClose("ahk_exe clumsy.exe")
    
    ExitApp()
}

; -- Main GUI --
MainGUI() {
    global ShiftHolderStatus, GuiThing, LagSwitchStatus, GunAmountVar, GunsAmountStatus, Guns

    ; black thing
    GuiThing := Gui("-Caption +AlwaysOnTop")
    GuiThing.BackColor := "000000" ; black hex code
    WinSetRegion("0-0 w270 h65 r15-15", GuiThing.Hwnd)

    ; Shift Holder Gui
    GuiThing.SetFont("s6 bold cWhite", "Arial")
    ShiftHolderStatus := GuiThing.Add("Text", "x95 y0 w30 h15 Center 0x200 BackgroundFF0000 -0x100 0x1 Hidden", "SPRINT")

    ; Lag switch gui
    GuiThing.SetFont("s7 bold cWhite", "Arial")
    LagSwitchStatus := GuiThing.Add("Text", "x75 y0 w15 h15 Center 0x200 BackgroundFF0000 -0x100 0x1 Hidden", LagSwitchTL)

    ; Title
    GuiThing.SetFont("s12 bold cWhite", "Segoe UI")
    GuiThing.Add("Text", "x72 y14 w150", "Prison Life Macro")

    ; On/Off button
    GuiThing.SetFont("s23 bold cWhite", "Arial")
    global StatusLabel := GuiThing.Add("Text", "x0 y0 w60 h50 0x200 BackgroundFF0000 -0x100 0x1", "OFF")

    ; X button
    GuiThing.SetFont("s10 cWhite", "Arial")
    GuiThing.Add("Text", "x195 y0 w20 h15 Center 0x200 BackgroundFF0000", "X").OnEvent("Click", (*) => StopMacro())

    ; Help button
    GuiThing.SetFont("s8 bold cBlack", "Arial")
    GuiThing.Add("Text", "x145 y0 w30 h15 Center 0x200 BackgroundFFFFFF", "HELP").OnEvent("Click", (*) => HelpGui())

    ; Settings Button
    GuiThing.SetFont("s10 cWhite", "Segoe UI Symbol")
    GuiThing.Add("Text", "x175 y0 w20 h15 Center 0x200 Background00008B", Chr(0x2699)).OnEvent("Click", (*) => SettingsGui()) ; setting symbol

    ; Guns To Swap Status
    GuiThing.SetFont("s6 bold cWhite", "Arial")
    GuiThing.Add("Text", "x115 y39 w100 h15 Center 0x200", "Guns to swap:")
    GunsAmountStatus := GuiThing.Add("Text", "x200 y39 w10 h15 Center 0x200", 0)
    global GunsAmountStatus

    ; Credit
    GuiThing.SetFont("s4 bold cWhite", "Consolas")
    GuiThing.Add("Text", "x75 y35 w130", "Made By @Idkwhattonamethis223 On Youtube")

    GuiThing.Show("w260 h50") ; shows the ui
}

; -- Help GUI --
HelpGui() {
    static HelpGuiShow := false

    if (!HelpGuiShow) {
        global GuiHelp
        GuiHelp := Gui("-Caption +AlwaysOnTop")
        GuiHelp.BackColor := "000000" ; black hex code

        ; Title for help GUI
        GuiHelp.SetFont("s35 bold cWhite", "Segoe UI")
        GuiHelp.Add("Text", "x150 y0 w370 Center", "Macro Help")

        ; X button for help GUI
        GuiHelp.SetFont("s13 bold cWhite", "Arial")
        GuiHelp.Add("Text", "x634 y0 w30 h20 Center BackgroundFF0000", "X").OnEvent("Click", (*) => HideHelp())

        HideHelp(*) {
            GuiHelp.Hide()
            global IsHelpVisible := false
        }

        ; -- Keybinds Show --
        GuiHelp.SetFont("s25 bold cWhite", "Tahoma") ; HELP GUI FIRST ANCHOR
        GuiHelp.Add("Text", "x-8 y70 w330 Center", "Keybinds")

        GuiHelp.SetFont("s15 bold cWhite", "Consolas")
        ; Main toggle help
        GuiHelp.Add("Text", "xp+60 yp+45 w330 Center", "= Main Toggle        ")
        MainToggleHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(MainToggleKeybind.Value))
        global MainToggleHelp

        ; Fast gun swap help
        GuiHelpAddKeyBindHelp("= Fast Gun Swap      ")
        FastGunSwapHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(FastGunSwapKeybind.Value))
        global FastGunSwapHelp

        ; Shuffle reload help
        GuiHelpAddKeyBindHelp("= Shuffle Reload     ")
        ShuffleReloadHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(ShuffleReloadKeybind.Value))
        global ShuffleReloadHelp

        ; Lag switch help
        GuiHelpAddKeyBindHelp("= Lag Switch         ")
        LagswitchHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(LagSwitchKeybind.Value))
        global LagswitchHelp

        ; Pressure jump help
        GuiHelpAddKeyBindHelp("= Pressure Jump      ")
        PressureJumpHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(PressureJumpKeybind.Value))
        global PressureJumpHelp

        ; Freeze clip help
        GuiHelpAddKeyBindHelp("= Freeze Clip        ")
        FreezeClipHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(FreezeClipKeybind.Value))
        global FreezeClipHelp

        ; Freeze roblox help
        GuiHelpAddKeyBindHelp("= Freeze Roblox      ")
        FreezeRobloxHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(FreezeRobloxKeybind.Value))
        global FreezeRobloxHelp

        ; Reset sprint toggle help
        GuiHelpAddKeyBindHelp("= Reset sprint toggle")
        ResetSprintToggleHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(ResetSprintToggleKeybind.Value))
        global ResetSprintToggleHelp

        ; Show/minimize help
        GuiHelpAddKeyBindHelp("= Show/Minimize      ")
        ShowOrMinimizeHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(ShowOrMinimizeKeybind.Value))
        global ShowOrMinimizeHelp

        ; Close macro help
        GuiHelpAddKeyBindHelp("= Close Macro        ")
        CloseMacroHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(CloseMacroKeybind.Value))
        global CloseMacroHelp

        ; Decrease gun amount help
        GuiHelpAddKeyBindHelp("= Decrease Gun Amount")
        DecreaseGunAmountHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(DecreaseGunAmount.Value))
        global DecreaseGunAmountHelp

        ; Increase gun amount help
        GuiHelpAddKeyBindHelp("= Increase Gun Amount")
        IncreaseGunAmountHelp := GuiHelp.Add("Text", "xp-10 yp w60", StrUpper(IncreaseGunAmount.Value))
        global IncreaseGunAmountHelp

        ; Keybind name function for help gui
        GuiHelpAddKeyBindHelp(string) {
            GuiHelp.Add("Text", "xp+10 y+5 w330 Center", string)
        }

        ; -- Extra Info --
        GuiHelp.SetFont("s25 bold cWhite", "Tahoma")
        GuiHelp.Add("Text", "x335 y70 w330 Center", "Extra Info") ; HELP GUI SECOND ANCHOR

        GuiHelp.SetFont("s7 cWhite", "Consolas")

        ; Gun Macro Help
        GuiHelp.Add("Text", "xp+45 yp+45 w240 Center", "
        (Join
            To use the fast weapon swap macro,
             you need to type in how many guns you have
             in the settings or use the O/P keybinds
        )")

        ; Lag Switch Help
        GuiHelp.Add("Text", "xp y+8 wp Center", "
        (Join
            To use the lag switch feature,
             you have to wait until a window called clumsy pops up.
             IF YOU SEE A BUTTON CALED "STOP", click it.
             IF THE AUTO CONFIG FAILS, set these settings manually in the clumsy app. 
             Filtering: outbound and udp.
             Check the lag box and set 'Delay(ms)' to 5000. Check the drop box and set 'Chance(%)' to 100.
             And check the throttle box and set 'timeframe(ms)' to 1000 and 'Chance(%)' to 100
        )")

        ; Pressure jump help
        GuiHelp.Add("Text", "xp y+8 wp Center", "
        (Join
            To activate the pressure jump macro,
             put your roblox sensitivity and your mouse pointer speed (search it your windows settings) in the macro settings. 
             Walk up to one of the pressure jump spots (search up youtube tutorial for the spots). 
             Then crouch and shove your head fully into the object. 
             Then press G. Also if you set your mouse pointer lower than 4 the script
             would automatically set your mouse pointer speed to 4 in the MACRO settings
             so the pressure jump would work
        )")

        ; Freeze Clip Help
        GuiHelp.Add("Text", "xp y+8 wp Center", "
        (Join
            To freeze clip, you need to walk directly to a thin wall (around 0.9 studs). 
             Set your camera angle to around 120 degrees or exactly 180 degrees (google a protractor image). 
             Then press B and try to reach the other side of the wall you chose
        )")

        ; Dm help
        GuiHelp.Add("Text", "xp y+8 wp Center", "
        (Join
            If you want to contact me,
             my discord is @cooluser75_10906
        )")

        ; Credit in help GUI
        GuiHelp.SetFont("s15 cWhite", "Consolas")
        GuiHelp.Add("Text", "x55 y+8 w530 Center", "Made By @Idkwhattonamethis223 On Youtube")

        HelpGuiShow := true
    }

    global IsHelpVisible := !IsHelpVisible

    ; Shows/closes help GUI
    if (IsHelpVisible) {
        HelpGuiW := 830
        HelpGuiH := 710
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
        global GuiSetting, Sens_Input, MousePointerSpeed_Input, Guns, GunsAmountStatus, ShootDelay, GunAmountVar
        GuiSetting := Gui("-Caption +AlwaysOnTop")
        GuiSetting.BackColor := "000000" ; black hex code
        EditBoxX := 250 ; other settings
        EditBox2X := 30 ; keybind
        CheckBoxX := EditBoxX - 1 ; other settings
        FirstSettingNameX := 50 ; keybind
        SecondSettingNameX := 400 ; other settings
        KeybindYAnchor := 70 ; keybind
        EqualSignDistance := 290 ; keybind

        ; Title for settings GUI
        GuiSetting.SetFont("s30 bold cWhite", "Segoe UI")
        GuiSetting.Add("Text", "x20 y0 w700 Center", "Macro Settings")

        ; -- Gun Amount Choose --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" SecondSettingNameX " y" KeybindYAnchor " w330", "Gun Amount")

        ; Editbox
        GuiSetting.SetFont("cBlack")
        Guns := GuiSetting.AddEdit("xp+" EditBoxX " yp+4 w25 h25 0x200 +Number", GunAmountVar)

        ; -- Shoot Delay --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" SecondSettingNameX " yp+25 w330", "Shoot Delay")

        ; Editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        ShootDelay := GuiSetting.AddEdit("xp+" EditBoxX " yp+4 w25 h25 0x200 +Number", 5)

        ; Milisecond disclamer
        GuiSetting.SetFont("s8 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "xp-120 yp+10 w100", "(milisecond)")

        ; -- Reload Delay --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" SecondSettingNameX " yp+15 w330", "Reload Delay")

        ; Editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        ReloadDelay := GuiSetting.AddEdit("xp+" EditBoxX " yp+4 w25 h25 0x200 +Number", 0)
        global ReloadDelay

        ; Milisecond disclamer
        GuiSetting.SetFont("s8 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "xp-110 yp+10 w90", "(milisecond)")

        ; -- Pressure Jump --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" SecondSettingNameX " yp+25 w330", "Pressure Jump")

        ; Mouse Pointer Speed editbox
        GuiSetting.SetFont("s12 bold cBlack", "Consolas")
        MousePointerSpeed_Input := GuiSetting.AddEdit("xp+170 yp w30 h20 Number", 0)

        ; Mouse pointer clarification
        GuiSetting.SetFont("s7 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "xp-22 yp+20 w73 Center", "Mouse`nPointer Speed")

        ; Roblox Sensitivity editbox
        GuiSetting.SetFont("s12 bold cBlack", "Consolas")
        Sens_Input := GuiSetting.AddEdit("xp+90 yp-20 w45 h20", 0)

        ; Roblox sens clarification
        GuiSetting.SetFont("s7 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "xp-9 yp+20 w50 Center", "Roblox sensitivity")

        ; -- Shift Option --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" SecondSettingNameX " yp+30 w330", "Sprint Toggler")

        ; Checkbox
        GuiSetting.Add("Text", "xp+" CheckBoxX " yp+1 w28 h25 BackgroundFFFFFF")
        CheckBoxShiftHolder := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background000000")
        CheckBoxShiftHolder.OnEvent("Click", (*) => SlotsClicked(1))

        ; -- Lag Switch Option --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" SecondSettingNameX " yp+25 w330", "Lag Switch")

        ; Checkbox
        GuiSetting.Add("Text", "xp+" CheckBoxX " yp+1 w28 h25 BackgroundFFFFFF")
        CheckBoxLagSwitch := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background000000")
        CheckBoxLagSwitch.OnEvent("Click", (*) => SlotsClicked(2))

        ; -- Sound Beep Toggle --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" SecondSettingNameX " yp+25 w330", "Sound Beep Toggle")

        ; Checkbox
        GuiSetting.Add("Text", "xp+" CheckBoxX " yp+1 w28 h25 BackgroundFFFFFF")
        CheckBoxSoundBeep := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background000000")
        CheckBoxSoundBeep.OnEvent("Click", (*) => SlotsClicked(3))

        ; -- Keybinds Settings --
        ; Main toggle name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w150", "Main Toggle")
        EqualSignFunc()

        ; Main toggle editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        MainToggleKeybind := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "Alt")
        global MainToggleKeybind

        ; Fast gun swap name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w150", "Fast Gun Swap")
        EqualSignFunc()

        ; Fast gun swap editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        FastGunSwapKeybind := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "LMB")
        global FastGunSwapKeybind

        ; Hold or toggle
        GuiSetting.SetFont("s10 bold cBlack", "Arial")
        global FastGunSwapChoiceStatus
        FastGunSwapChoiceStatus := GuiSetting.Add("Text", "xp-120 yp w45 h25 0x200 BackgroundFFFFFF -0x100 0x1", "Hold")
        FastGunSwapChoiceStatus.OnEvent("Click", (*) => FastGunSwapHoldOrToggle())

        ; Shuffle reload name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w170", "Shuffle Reload")
        EqualSignFunc()

        ; Shuffle reload editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        ShuffleReloadKeybind := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "r")
        global ShuffleReloadKeybind

        ; Lag switch name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w150", "Lag Switch")
        EqualSignFunc()

        ; Lag switch editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        LagSwitchKeybind := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "t")
        global LagSwitchKeybind

        ; Pressure jump name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w150", "Pressure Jump")
        EqualSignFunc()

        ; Pressure jump editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        PressureJumpKeybind := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "g")
        global PressureJumpKeybind

        ; Freeze clip name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w150", "Freeze Clip")
        EqualSignFunc()

        ; Freeze clip editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        FreezeClipKeybind := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "b")
        global FreezeClipKeybind

        ; Freeze roblox name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w150", "Freeze Roblox")
        EqualSignFunc()

        ; Freeze roblox editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        FreezeRobloxKeybind := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "y")
        global FreezeRobloxKeybind

        ; Reset sprint toggle name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w250", "Reset Sprint Toggle")
        EqualSignFunc()

        ; Reset sprint toggle editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        ResetSprintToggleKeybind := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "m")
        global ResetSprintToggleKeybind

        ; Show/Minimize name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w200", "Show/Minimize")
        EqualSignFunc()

        ; Show/minimize editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        ShowOrMinimizeKeybind := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "F4")
        global ShowOrMinimizeKeybind

        ; Close macro name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w200", "Close Macro")
        EqualSignFunc()

        ; Close macro editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        CloseMacroKeybind := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "Del")
        global CloseMacroKeybind

        ; Increase gun amount name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w250", "Increase Gun Amount")
        EqualSignFunc()

        ; Increase gun amount editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        IncreaseGunAmount := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "p")
        global IncreaseGunAmount

        ; Decrease gun amount name
        KeybindYAnchor += 30
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x" FirstSettingNameX " y" KeybindYAnchor " w250", "Decrease Gun Amount")
        EqualSignFunc()

        ; Decrease gun amount editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        DecreaseGunAmount := GuiSetting.AddEdit("xp+" EditBox2X " yp w45 h25 0x200", "o")
        global DecreaseGunAmount

        ; X button in settings GUI
        GuiSetting.SetFont("s17 bold cWhite", "Arial")
        GuiSetting.Add("Text", "x713 y0 w40 h25 Center BackgroundFF0000", "X").OnEvent("Click", (*) => HideSetting())

        ; Apply Settings
        GuiSetting.SetFont("s13 bold cWhite", "Arial")
        GuiSetting.Add("Text", "x490 y350 w120 h40 Center 0x200 BackgroundFF0000", "Apply settings").OnEvent("Click", (*) => KeybindModifier())

        ; Function for hiding setting GUI
        HideSetting(*) {
            GuiSetting.Hide()
            global IsSettingsVisible := false

            GunAmountVar := Guns.Value
            GunsAmountStatus.Value := GunAmountVar

            Guns.Redraw()
            GunsAmountStatus.Redraw()

            SetTimer(KeybindModifier, 0)
        }

        ; Equal sign function
        EqualSignFunc() {
            GuiSetting.Add("Text", "x" EqualSignDistance " yp w10", "=")
        }

        ; function for toggle
        SlotsClicked(slot) {
            switch (slot) {
                case 1:
                    ; Sprint toggle
                    global CheckBoxShiftHolderBOOL := !CheckBoxShiftHolderBOOL
                    CheckBoxShiftHolder.Opt(CheckBoxShiftHolderBOOL ? "Background00FF00" : "Background000000")
                    ShiftHolderStatus.Visible := (CheckBoxShiftHolderBOOL ? true : false)
                    CheckBoxShiftHolder.Redraw()

                    ; Resets shift holder if checkbox is disabled
                    if (!CheckBoxShiftHolderBOOL) {
                        SprintToggleReset()
                    }
                case 2:
                    ZipPath := A_ScriptDir "\clumsy-0.3-win64-a.zip"
                    TargetFolder := A_ScriptDir "\clumsy-0.3-win64-a"
                    ClumsyPath := TargetFolder "\clumsy.exe"
                    FilterConfig := "outbound and udp"

                    if (CheckBoxLagSwitchBOOL) {
                        if WinExist("ahk_exe clumsy.exe") {
                            ProcessClose("clumsy.exe")
                        }

                        global CheckBoxLagSwitchBOOL := false
                        CheckBoxLagSwitch.Opt("Background000000")
                        LagSwitchStatus.Visible := false
                        CheckBoxLagSwitch.Redraw()
                        return
                    }

                    ; if clumsy isnt installed
                    if (!FileExist(TargetFolder) && !FileExist(ZipPath)) {
                        HideTrayTip() ; removes tray trip
                        TrayTip("Downloading Clumsy (required file for lag switching)", "Macro Installer")

                        try {
                            Download("https://github.com/jagt/clumsy/releases/download/0.3/clumsy-0.3-win64-a.zip", ZipPath)
                            MsgBox("Automated installation success")
                        } catch Error as err {
                            MsgBox("Automated installation failed. Install clumsy-0.3-win64-a.zip bit from https://jagt.github.io/clumsy/download `n`n Error: " err.Message)
                            return
                        }
                    }

                    ; auto extract
                    if !FileExist(TargetFolder) {
                        HideTrayTip() ; Removes tray trip
                        TrayTip("Extracting Clumsy files", "Macro Installer")

                        try {
                            DirCreate(TargetFolder) ; creates folder
                            ShellObj := ComObject("Shell.Application")
                            ZipFolder := ShellObj.NameSpace(ZipPath)
                            DestFolder := ShellObj.NameSpace(TargetFolder)

                            if (ZipFolder && DestFolder) {
                                DestFolder.CopyHere(ZipFolder.Items, 4 | 16)
                                Sleep(800)
                            }
                        } catch Error as err {
                            MsgBox("Extraction failed. Extract the zip file manually `n`nError:" err.Message)
                            return
                        }
                    }
                    if (!WinExist("ahk_exe clumsy.exe") && FileExist(ClumsyPath)) {
                        ProcessClose("clumsy.exe")
                        Sleep(200)

                        Run('*RunAs "' ClumsyPath '" --filter "' FilterConfig '" --lag on --lag-time 5000 --drop on --drop-chance 100 --throttle on --throttle-chance 100 --throttle-frame 1000')

                        ; turns off lag switch
                        WinWait("ahk_exe clumsy.exe")
                        BlockInput true
                        Sleep(50)
                        BlockInput false
                        Try {
                            ControlClick("Button2", "ahk_exe clumsy.exe")
                        } catch {
                            ControlClick("Button2", "ahk_exe clumsy.exe")
                        }
                    } else {
                        if WinExist("ahk_exe clumsy.exe") {
                            WinClose("ahk_exe clumsy.exe")
                        }
                    }

                    global CheckBoxLagSwitchBOOL := !CheckBoxLagSwitchBOOL
                    CheckBoxLagSwitch.Opt(CheckBoxLagSwitchBOOL ? "Background00FF00" : "Background000000")
                    LagSwitchStatus.Visible := (CheckBoxLagSwitchBOOL ? true : false)
                    CheckBoxLagSwitch.Redraw()
                case 3:
                    ; Sound beep
                    global CheckBoxSoundBeepBOOL := !CheckBoxSoundBeepBOOL
                    CheckBoxSoundBeep.Opt(CheckBoxSoundBeepBOOL ? "Background00FF00" : "Background000000")
                    CheckBoxSoundBeep.Redraw()
            }
        }

        ; Credit in settings GUI
        GuiSetting.SetFont("s13 cWhite", "Consolas")
        GuiSetting.Add("Text", "x175 y450 w390 Center", "Made By @Idkwhattonamethis223 On Youtube")

        SettingsGuiShow := true
        KeybindModifier()
    }

    global IsSettingsVisible := !IsSettingsVisible

    ; Shows/closes Settings GUI
    if (IsSettingsVisible) {
        SettingsGuiShowW := 940
        SettingsGuiShowH := 600
        GuiSetting.Show("w" SettingsGuiShowW " h" SettingsGuiShowH "")
        WinSetRegion("0-0 w" SettingsGuiShowW " h" SettingsGuiShowH " r20-20", GuiSetting.Hwnd)
    } else {
        GuiSetting.Hide()
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

    KeybindStringAdd := "~*$"
    HelpText := ""

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
            Hotkey(CurAssignedHotkey, FuncName.Bind())
            Hotkey(CurAssignedHotkey, "On")
        }
    }
    GunAmountVar := Guns.Value
    GunsAmountStatus.Value := GunAmountVar

    Guns.Redraw()
    GunsAmountStatus.Redraw()

    HideTrayTip()
    TrayTip("Applied Settings")
    SetTimer(HideTrayTip, 1500)
}

; Hold or toggle fast gun swap
FastGunSwapHoldOrToggle(*) {
    ; true = hold, false = toggle
    global FastGunSwapChoiceIsHold := !FastGunSwapChoiceIsHold

    FastGunSwapChoiceStatus.Value := FastGunSwapChoiceIsHold ? "Hold" : "Toggle"
    FastGunSwapChoiceStatus.Redraw()
}

; -- Change Log Gui --
ChangeLogGui() {
    static ChangeLogGuiShow := false

    if (!ChangeLogGuiShow) {
        global GuiChangeLog
        GuiChangeLog := Gui("-Caption +AlwaysOnTop")
        GuiChangeLog.BackColor := "000000" ; Black hex code
        static FirstLog := 50
        static OneLog := 45
        static DoubleLog := 75
        static TripleLog := 105

        ; Title for Change Log GUI
        GuiChangeLog.SetFont("s25 bold cWhite", "Segoe UI")
        GuiChangeLog.Add("Text", "x0 y0 w360 Center", "Change Log V2.2")

        ; -- Change Logs --
        GuiChangeLog.SetFont("s30 bold cWhite", "Segoe UI")

        ; 1
        AddText("Fixed unwanted delays for multiple features", FirstLog)

        ; 2
        ;AddText("Fast gun swap's toggle feature no longer has a 1ms delay", DoubleLog)

        ; 3
        ;AddText("Settings gui modified", TripleLog)

        AddText(ChangeLogTextInput, YposInput) {
            GuiChangeLog.SetFont("s18 bold cWhite", "Segoe UI")
            GuiChangeLog.Add("Text", "x50 yp+" YposInput " w265 Center", ChangeLogTextInput)

            GuiChangeLog.SetFont("s20 bold cWhite", "Segoe UI")
            GuiChangeLog.Add("Text", "x10 yp w5", "•")
        }

        ; X button in Change Log GUI
        GuiChangeLog.SetFont("s13 bold cWhite", "Arial")
        GuiChangeLog.Add("Text", "x329 y0 w30 h20 Center BackgroundFF0000", "X").OnEvent("Click", (*) => HideChangeLog())

        ; function for hiding setting GUI
        HideChangeLog(*) {
            GuiChangeLog.Hide()
            global IsChangeLogVisible := false
        }

        ; Credit in Change Log GUI
        GuiChangeLog.SetFont("s10 cWhite", "Consolas")
        GuiChangeLog.Add("Text", "x0 y340 w360 Center", "Made By @Idkwhattonamethis223 On Youtube")

        ChangeLogGuiShow := true
    }

    global IsChangeLogVisible := !IsChangeLogVisible

    ; Shows/closes changelog GUI
    if (IsChangeLogVisible) {
        ChangeLogW := 450
        ChangeLogH := 450
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
        A_IconHidden := true
        Sleep 200
        A_IconHidden := false
    }
    SetTimer(HideTrayTip, 0)
}

; -- Sleep below 10ms --
SuperSleep(ms) {
    DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
    DllCall("QueryPerformanceCounter", "Int64*", &start := 0)

    target := start + (ms * freq / 1000)
    current := 0

    loop {
        Sleep(-1)

        DllCall("QueryPerformanceCounter", "Int64*", &current)
        if (current >= target)
            break
    }
}

/*~^s:: {
    Sleep(200)
    Reload()
}*/
