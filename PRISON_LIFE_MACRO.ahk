; made by @Idkwhattonamethis223 (youtube) / @cooluser75_10906 (discord)

#Requires AutoHotkey v2.0
#SingleInstance Force
ProcessSetPriority "High"
SetControlDelay(-1)

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

LagSwitchTL := 0
FreezeTL := 0
GuiThing := ""
GuiSetting := ""
GuiHelp := ""
GuiChangeLog := ""

i := 0
GunAmountVar := 0

Turn180Deg := false
WindowsRawSensitivity := 0

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
*$Alt:: {
    global ScriptActive := !ScriptActive

    StatusLabel.Text := ScriptActive ? "ON" : "OFF"
    StatusLabel.Opt(ScriptActive ? "Background00FF7F" : "BackgroundFF0000")
    StatusLabel.Redraw()

    if CheckBoxSoundBeepBOOL
        SoundBeep(ScriptActive ? 550 : 400, 20)
}

#HotIf ScriptActive
; -- Reload All --
*$r:: {
    global i, Guns

    Loop GunAmountVar {
        i++

        Send "{Blind}{" i "}"
        SuperSleep(Number(ReloadDelay.Value))
        Send "{Blind}r"
    }
    i := 0

    if CheckBoxSoundBeepBOOL
        SoundBeep(550, 20)
}

; -- Blatant Gun Macro --
~$*LButton:: {
    if (GunAmountVar > 10) { ; if the gun amount is more than 10, tell the user
        MsgBox("The maximum amount of guns is 10")
        return
    }

    global GunDelay := 5
    global Guns, i

    while GetKeyState("LButton", "P") {
        Loop GunAmountVar {
            i++

            if (i == 10) { ; if gun amount is 10, make i = 0 so ahk can swap to the 10th slot
                i := 0
            }

            Send "{Blind}{" i "}"
            SuperSleep(Number(ShootDelay.Value))
            Click
            SuperSleep(Number(ShootDelay.Value))
        }
        i := 0
    }
}

; Increase/decrease Gun Amount Shortcut
*$o:: {
    global GunsAmountStatus, GunAmountVar, Guns
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

*$p:: {
    global GunsAmountStatus, GunAmountVar, Guns
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
#HotIf WinExist("ahk_exe clumsy.exe") && CheckBoxLagSwitchBOOL && ScriptActive
$*t:: {
    global IsLagging := !IsLagging
    global LagSwitchTL

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
$*g:: {
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
    SuperSleep(6)

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
$*b:: {
    global ShiftHolder := false
    global IsCrouching := !IsCrouching
    global IsChatting := false
    Send "{LShift up}"
    ShiftHolderStatus.Opt("BackgroundFF0000")
    ShiftHolderStatus.Redraw()

    Send "{Blind}c"

    SuperSleep(1)

    freeze(1) ; starts freezing roblox

    Sleep(850)

    freeze(2) ; stops freezing roblox
}

$*y:: {
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
*$m:: SprintToggleReset()

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
$*F4:: {
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
$*Del:: StopMacro()

; -- Function to kill the macro --
StopMacro() {
    Send "{LShift up}"

    try ProcessClose("AutoHotkey64.exe")
    try ProcessClose("AutoHotkey.exe")

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
        GuiHelp.Add("Text", "x150 y0 w330 Center", "Macro Help")

        ; X button for help GUI
        GuiHelp.SetFont("s13 bold cWhite", "Arial")
        GuiHelp.Add("Text", "x610 y0 w30 h20 Center BackgroundFF0000", "X").OnEvent("Click", (*) => HideHelp())

        HideHelp(*) {
            GuiHelp.Hide()
            global IsHelpVisible := false
        }

        ; -- Keybinds Show --
        GuiHelp.SetFont("s25 bold cWhite", "Tahoma")
        GuiHelp.Add("Text", "x0 y70 w330 Center", "Keybinds")

        GuiHelp.SetFont("s15 bold cWhite", "Consolas")
        GuiHelp.Add("Text", "xp yp+45 w330 Center", "  ALT = LMB, R, T, G toggle")
        GuiHelp.Add("Text", "xp y+5 wp Center", "LMB = Fast Gun Swap    ")
        GuiHelp.Add("Text", "xp y+5 wp Center", "R   = Shuffle Reload   ")
        GuiHelp.Add("Text", "xp y+5 wp Center", "T   = Lag Switch       ")
        GuiHelp.Add("Text", "xp y+5 wp Center", "G   = Pressure Jump    ")
        GuiHelp.Add("Text", "xp y+5 wp Center", "B   = Freeze Clip      ")
        GuiHelp.Add("Text", "xp y+5 wp Center", "Y   = Freeze Roblox    ")
        GuiHelp.Add("Text", "xp y+5 wp Center", "  M   = Reset sprint toggle")
        GuiHelp.Add("Text", "xp y+5 wp Center", "F4  = Show/Minimize    ")
        GuiHelp.Add("Text", "xp y+5 wp Center", "DEL = Close Macro      ")
        GuiHelp.Add("Text", "xp y+5 wp Center", "O/P = Increase/Decrease`n     Gun Amount")

        ; -- Extra Info --
        GuiHelp.SetFont("s25 bold cWhite", "Tahoma")
        GuiHelp.Add("Text", "x310 y70 wp Center", "Extra Info")

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

        ; Credit in help GUI
        GuiHelp.SetFont("s15 cWhite", "Consolas")
        GuiHelp.Add("Text", "x50 yp+105 w530 Center", "Made By @Idkwhattonamethis223 On Youtube")

        HelpGuiShow := true
    }

    global IsHelpVisible := !IsHelpVisible

    ; Shows/closes help GUI
    if (IsHelpVisible) {
        GuiHelp.Show("w800 h710")
        WinSetRegion("0-0 w800 h710 r20-20", GuiHelp.Hwnd)
    } else {
        GuiHelp.Hide()
    }
}

; -- Settings GUI --
SettingsGui() {
    static SettingsGuiShow := false

    if (!SettingsGuiShow) {
        global GuiSetting, DPI_Input, Sens_Input, MousePointerSpeed_Input, Guns, GunsAmountStatus, ShootDelay, GunAmountVar
        GuiSetting := Gui("-Caption +AlwaysOnTop")
        GuiSetting.BackColor := "000000" ; black hex code
        EditBoxX := 300
        CheckBoxX := 299

        ; Title for settings GUI
        GuiSetting.SetFont("s25 bold cWhite", "Segoe UI")
        GuiSetting.Add("Text", "x22 y0 w330 Center", "Macro Settings")

        ; -- Gun Amount Choose --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 y60 w330", "Gun Amount")

        ; Editbox
        GuiSetting.SetFont("cBlack")
        Guns := GuiSetting.AddEdit("x" EditBoxX " yp+3 w25 h25 0x200 +Number", GunAmountVar)

        ; Safety net
        GunAmountVar := Guns.Value
        GunsAmountStatus.Value := GunAmountVar
        Guns.Redraw()
        GunsAmountStatus.Redraw()

        ; -- Shoot Delay --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330", "Shoot Delay")

        ; Milisecond disclamer
        GuiSetting.SetFont("s8 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "xp+125 yp+10 w330", "(milisecond)")

        ; Editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        ShootDelay := GuiSetting.AddEdit("x" EditBoxX " y93 w25 h25 0x200 +Number", 5)

        ; -- Reload Delay --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330", "Reload Delay")

        ; Milisecond disclamer
        GuiSetting.SetFont("s8 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "xp+135 yp+10 w330", "(milisecond)")

        ; Editbox
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        ReloadDelay := GuiSetting.AddEdit("x" EditBoxX " y121 w25 h25 0x200 +Number", 0)
        global ReloadDelay

        ; -- Shift Option --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+40 w330", "Sprint Toggler")

        ; Checkbox
        GuiSetting.Add("Text", "x" CheckBoxX " yp w28 h25 BackgroundFFFFFF")
        CheckBoxShiftHolder := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background000000")
        CheckBoxShiftHolder.OnEvent("Click", (*) => SlotsClicked(1))

        ; -- Lag Switch Option --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330", "Lag Switch")

        ; Checkbox
        GuiSetting.Add("Text", "x" CheckBoxX " yp w28 h25 BackgroundFFFFFF")
        CheckBoxLagSwitch := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background000000")
        CheckBoxLagSwitch.OnEvent("Click", (*) => SlotsClicked(2))

        ; -- Sound Beep Toggle --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330", "Sound Beep Toggle")

        ; Checkbox
        GuiSetting.Add("Text", "x" CheckBoxX " yp w28 h25 BackgroundFFFFFF")
        CheckBoxSoundBeep := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background000000")
        CheckBoxSoundBeep.OnEvent("Click", (*) => SlotsClicked(3))

        ; -- Pressure Jump --
        ; Setting name
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+35 w330", "Pressure Jump")

        ; Mouse Pointer Speed editbox
        GuiSetting.SetFont("s12 bold cBlack", "Consolas")
        MousePointerSpeed_Input := GuiSetting.AddEdit("x225 yp w30 h20 Number", 0)

        ; Roblox Sensitivity editbox
        Sens_Input := GuiSetting.AddEdit("x295 yp w45 h20", 0)

        ; Mouse pointer clarification
        GuiSetting.SetFont("s7 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x204 yp+20 w73 Center", "Mouse`nPointer Speed")

        ; Roblox sens clarification
        GuiSetting.Add("Text", "x287 yp w50 Center", "Roblox sensitivity")

        ; X button in settings GUI
        GuiSetting.SetFont("s13 bold cWhite", "Arial")
        GuiSetting.Add("Text", "x330 y0 w30 h20 Center BackgroundFF0000", "X").OnEvent("Click", (*) => HideSetting())

        ; Function for hiding setting GUI
        HideSetting(*) {
            GuiSetting.Hide()
            global IsSettingsVisible := false

            GunAmountVar := Guns.Value
            GunsAmountStatus.Value := GunAmountVar

            Guns.Redraw()
            GunsAmountStatus.Redraw()
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
                        Sleep(20)
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
        GuiSetting.SetFont("s10 cWhite", "Consolas")
        GuiSetting.Add("Text", "x35 y305 w300 Center", "Made By @Idkwhattonamethis223 On Youtube")

        SettingsGuiShow := true
    }

    global IsSettingsVisible := !IsSettingsVisible
    GunAmountVar := Guns.Value
    GunsAmountStatus.Value := GunAmountVar

    Guns.Redraw()
    GunsAmountStatus.Redraw()

    ; Shows/closes Settings GUI
    if (IsSettingsVisible) {
        GuiSetting.Show("w450 h410")
        WinSetRegion("0-0 w450 h410 r20-20", GuiSetting.Hwnd)
    } else {
        GuiSetting.Hide()
    }
}

; -- Change Log Gui --
ChangeLogGui() {
    static ChangeLogGuiShow := false

    if (!ChangeLogGuiShow) {
        global GuiChangeLog
        GuiChangeLog := Gui("-Caption +AlwaysOnTop")
        GuiChangeLog.BackColor := "000000" ; Black hex code
        static FirstLog  := 50
        static NormalLog := 40
        static DoubleLog := 75

        ; Title for Change Log GUI
        GuiChangeLog.SetFont("s25 bold cWhite", "Segoe UI")
        GuiChangeLog.Add("Text", "x0 y0 w350 Center", "Change Log V1.6")

        ; -- Change Logs --
        GuiChangeLog.SetFont("s30 bold cWhite", "Segoe UI")

        ; 1
        AddText("Improved gun swap macro", FirstLog)

        ; 2
        AddText("Slightly improved settings gui", DoubleLog)

        ; 3
        AddText("Modified help gui", DoubleLog)

        AddText(ChangeLogTextInput, YPosAdd) {
            GuiChangeLog.SetFont("s18 bold cWhite", "Segoe UI")
            GuiChangeLog.Add("Text", "x45 yp+" YPosAdd " w265 Center", ChangeLogTextInput)

            GuiChangeLog.SetFont("s20 bold cWhite", "Segoe UI")
            GuiChangeLog.Add("Text", "x10 yp w5", "•")
        }

        ; X button in Change Log GUI
        GuiChangeLog.SetFont("s13 bold cWhite", "Arial")
        GuiChangeLog.Add("Text", "x315 y0 w30 h20 Center BackgroundFF0000", "X").OnEvent("Click", (*) => HideChangeLog())

        ; function for hiding setting GUI
        HideChangeLog(*) {
            GuiChangeLog.Hide()
            global IsChangeLogVisible := false
        }

        ; Credit in Change Log GUI
        GuiChangeLog.SetFont("s10 cWhite", "Consolas")
        GuiChangeLog.Add("Text", "x0 y300 w350 Center", "Made By @Idkwhattonamethis223 On Youtube")

        ChangeLogGuiShow := true
    }

    global IsChangeLogVisible := !IsChangeLogVisible

    ; Shows/closes help GUI
    if (IsChangeLogVisible) {
        GuiChangeLog.Show("w430 h410")
        WinSetRegion("0-0 w430 h410 r20-20", GuiChangeLog.Hwnd)
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
}

; -- Reset Sprint Toggle --
SprintToggleReset() {
    global ShiftHolder := false
    global IsCrouching := false
    global IsChatting := false

    ShiftHolderStatus.Opt("BackgroundFF0000")
    ShiftHolderStatus.Redraw()

    Send "{LShift up}"
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
