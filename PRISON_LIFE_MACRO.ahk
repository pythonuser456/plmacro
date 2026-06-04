; the code might not be the best
; made by @Idkwhattonamethis223 on Youtube

#Requires AutoHotkey v2.0
#SingleInstance Force
ProcessSetPriority "High"
SetControlDelay(-1)

; -- Variables --
ScriptActive := false
ShiftHolder := false
ShowUi := false
IsChatting := false
Slot1Bool := false
Slot2Bool := false
Slot3Bool := false
IsHelpVisible := false
IsSettingsVisible := true
IsCrouching := false
IsChatting := false
IsLagging := false
LagSwitchTL := 0
GuiThing := ""
GuiSetting := ""
GuiHelp := ""
i := 0
GunAmountVar := 0
ClumsyIsOpen := false

Spin := 4000
BaseDPI := 800
BaseSens := 0.36

; -- Main GUI Call --
if not A_IsAdmin {
    try {
        ; Removed the dot (.) concatenation for clean v2 string handling
        Run('*RunAs "' A_ScriptFullPath '"')
        ExitApp() ; Immediately closes the non-admin version
    } catch as err { 
        MsgBox("Admin privileges denied. Background macros will fail while Roblox is open.") 
    }
}

MainGui()
SettingsGui()
OnMessage(0x0201, (*) => PostMessage(0xA1, 2,,, "A")) ; for gui drag

; -- Toggle LMB, R, T, G, O, P--
*$Alt:: {
    global ScriptActive := !ScriptActive
    
    StatusLabel.Text := ScriptActive ? "ON" : "OFF"
    StatusLabel.Opt(ScriptActive ? "Background00FF7F" : "BackgroundFF0000")
    StatusLabel.Redraw()

    if Slot3Bool
        SoundBeep(ScriptActive ? 550 : 400, 20)
}

#HotIf ScriptActive
; -- Reload All --
*$r:: {
    global i, Guns

    Loop GunAmountVar {
        i += 1

        Send "{Blind}{" i "}"
        DllCall("Sleep", "UInt", Number(ReloadDelay.Value))
        Send "{Blind}r"
    }
    i := 0

    if Slot3Bool
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

    DllCall("Winmm\timeBeginPeriod", "UInt", 1)
    while GetKeyState("LButton", "P")  {
        Loop GunAmountVar {
            i += 1

            if (i == 10) { ; if gun amount is 10, make i = 0 so ahk can swap to the 10th slot
                i := 0
            }

            Send "{Blind}{" i "}"
            DllCall("Sleep", "UInt", Number(ShootDelay.Value))
            Click
            DllCall("Sleep", "UInt", Number(ShootDelay.Value))
        }
        i := 0
    }
    DllCall("Winmm\timeEndPeriod", "UInt", 1)
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

    if Slot3Bool
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

    if Slot3Bool
        SoundBeep(550, 20)
}

; -- Lag Switcher --
#HotIf WinExist("ahk_exe clumsy.exe") && Slot2Bool && ScriptActive
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
        
        if Slot3Bool
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

    if Slot3Bool
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

        if Slot3Bool
            SoundBeep(400, 20)
    }
}

#HotIf ScriptActive
; -- Pressure Jump --
$*g:: {
    if Slot3Bool
        SoundBeep(550, 20)
    if (Sens_Input.Value == 0) {
        MsgBox("Put your Roblox Sensitivity in the settings")
        return
    }

    global Turn180Var := 1750.0 / Number(Sens_Input.Value)
    DllCall("Winmm\timeBeginPeriod", "UInt", 1)

    Send "{Blind}c"
    DllCall("Sleep", "UInt", 6)

    Send "{Space down}"
    DllCall("Sleep", "UInt", 60)
    Send "{Space up}"
    
    StartTime := A_TickCount 
    Loop {
        if (A_TickCount - StartTime > 200)
            break
        
        DllCall("user32\mouse_event", "UInt", 0x0001, "Int", Turn180Var, "Int", 0, "UInt", 0, "Ptr", 0)
    }

    global IsCrouching := false
    DllCall("Winmm\timeEndPeriod", "UInt", 1)
}

; -- No Clip --
$*b:: {
    DllCall("Winmm\timeBeginPeriod", "UInt", 1)

    global ShiftHolder := false
    global IsCrouching := !IsCrouching
    global IsChatting := false
    Send "{LShift up}"
    ShiftHolderStatus.Opt("BackgroundFF0000")
    ShiftHolderStatus.Redraw()

    Send "{Blind}c"

    DllCall("Sleep", "UInt", 25)

    freeze(1) ; starts freezing roblox

    DllCall("Sleep", "UInt", 750)

    freeze(2) ; stops freezing roblox

    DllCall("Winmm\timeEndPeriod", "UInt", 1)
}
freeze(FreezeChoice) {
    targetProcess := "RobloxPlayerBeta.exe"
    pid := ProcessExist(targetProcess)
    
    if (!pid) {
        ToolTip("Roblox not found")
        SetTimer(() => ToolTip(), -1500)
        return
    }
    
    switch(FreezeChoice) {
        case 1:
            ProcessSuspend(pid)
        case 2:
            ProcessResume(pid)
    }
    
    SetTimer(() => ToolTip(), -1500)
}
ProcessSuspend(pid) {
    targetHandle := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", 0, "UInt", pid, "Ptr")
    if (targetHandle) {
        DllCall("ntdll\NtSuspendProcess", "Ptr", targetHandle)
        DllCall("CloseHandle", "Ptr", targetHandle)
    }
}
ProcessResume(pid) {
    targetHandle := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", 0, "UInt", pid, "Ptr")
    if (targetHandle) {
        DllCall("ntdll\NtResumeProcess", "Ptr", targetHandle)
        DllCall("CloseHandle", "Ptr", targetHandle)
    }
}
#HotIf

; -- Shift Holder --
~$*LShift:: {
    if (!Slot1Bool or IsChatting or IsCrouching) {
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

#HotIf ShiftHolder
*$c:: {
    global ShiftHolder := false
    global IsCrouching := true
    ShiftHolderStatus.Opt("BackgroundFF0000")
    ShiftHolderStatus.Redraw()

    Send "{LShift up}"
    Send "{Blind}c"
}

#HotIf ShiftHolder or ScriptActive
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
*$Enter:: {
    global IsChatting := false
    
    Send("{Enter}")
}
~$*LButton:: {
    global IsChatting := false
}

#HotIf IsCrouching
*$c:: {
    global ShiftHolder := true

    Send "{Blind}c"

    SetTimer(ShiftWhenStanding, 64)
}
ShiftWhenStanding() {
    ShiftHolderStatus.Opt("Background00FF7F")
    ShiftHolderStatus.Redraw()

    Send "{LShift down}"
    global IsCrouching := false

    SetTimer(ShiftWhenStanding, 0)
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
$*Del:: {
    StopMacro()
}

; -- Function to kill the macro --
StopMacro() {
    Send "{LShift up}"
    Run "cmd.exe /c taskkill /f /im AutoHotkey64.exe", , "Hide"
    Run "cmd.exe /c taskkill /f /im AutoHotkey.exe", , "Hide"
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
    GuiThing.SetFont("s7 bold cWhite", "Arial")
    ShiftHolderStatus := GuiThing.Add("Text", "x95 y0 w30 h15 Center 0x200 BackgroundFF0000 -0x100 0x1 Hidden", "SHIFT")

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
    GuiThing.Add("Text", "x195 y0 w20 h15 Center 0x200 BackgroundFF0000", "X").OnEvent("Click", (*) => StopMacro() )

    ; Help button
    GuiThing.SetFont("s8 bold cBlack", "Arial")
    GuiThing.Add("Text", "x145 y0 w30 h15 Center 0x200 BackgroundFFFFFF", "HELP").OnEvent("Click", (*) => HelpGui() )

    ; Settings Button
    GuiThing.SetFont("s10 cWhite", "Segoe UI Symbol")
    GuiThing.Add("Text", "x175 y0 w20 h15 Center 0x200 Background00008B", Chr(0x2699) ).OnEvent("Click", (*) => SettingsGui() ) ; setting symbol
    
    ; Guns To Swap Status
    GuiThing.SetFont("s6 bold cWhite", "Arial")
    GuiThing.Add("Text", "x115 y39 w100 h15 Center 0x200", "Guns to swap:")
    GunsAmountStatus := GuiThing.Add("Text", "x200 y39 w10 h15 Center 0x200", 0)
    global GunsAmountStatus

    ; Credit
    GuiThing.SetFont("s3 bold cWhite", "Consolas")
    GuiThing.Add("Text", "x90 y35 w130", "Made By @Idkwhattonamethis223 On Youtube")

    GuiThing.Show("w260 h50") ; shows the ui
}

; -- Help GUI --
HelpGui() {
    global GuiHelp
    static HelpGuiShow := 0

    if (HelpGuiShow == 0) {
        global GuiHelp
        GuiHelp := Gui("-Caption +AlwaysOnTop")
        GuiHelp.BackColor := "000000" ; black hex code

        ; Title for help GUI
        GuiHelp.SetFont("s25 bold cWhite", "Segoe UI")
        GuiHelp.Add("Text", "x0 y0 w330 Center", "Macro Help")
    
        ; X button for help GUI
        GuiHelp.SetFont("s13 bold cWhite", "Arial")
        GuiHelp.Add("Text", "x305 y0 w30 h20 Center BackgroundFF0000", "X").OnEvent("Click", (*) => HideHelp())

        HideHelp(*) {
            GuiHelp.Hide()
            global IsHelpVisible := false
            global HelpXClosed := true
        }

        ; -- Keybinds Show --
        GuiHelp.SetFont("s15 bold cWhite", "Tahoma")
        GuiHelp.Add("Text", "x0 y50 w330 Center", "Keybinds")

        GuiHelp.SetFont("s11 bold cWhite", "Consolas")
        GuiHelp.Add("Text", "xp yp+25 w330 Center",  "  ALT = LMB, R, T, G toggle")
        GuiHelp.Add("Text", "xp yp+15 wp Center", "LMB = Laser people     ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", "R   = Shuffle Reload   ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", " T   = Lag Switch        ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", "    G   = Pressure Jump        ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", " B   = No Clip           ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", "F4  = Show/Minimize    ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", "DEL = Close Macro      ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", "     O/P = Increase/Decrease Gun `n        Amount")

        ; -- Extra Info --
        GuiHelp.SetFont("s15 bold cWhite", "Tahoma") 
        GuiHelp.Add("Text", "xp y230 wp Center", "Extra Info")

        GuiHelp.SetFont("s7 cWhite", "Consolas")

        GuiHelp.Add("Text", "xp yp+25 wp Center", "You can also press shift once to sprint by`n toggling Press Shift Once in the settings")

        GuiHelp.Add("Text", "xp yp+35 wp Center", "To use the very fast weapon `n swap macro, you need to type in how many `n guns you have in the settings or use `n the O/P keybinds")

        GuiHelp.Add("Text", "xp yp+55 wp Center", "To use the lag switch feature `n you have to wait until a window called clumsy pops up. `n If the auto configs fail, set clumsy's settings manually as Filtering: outbound and udp. Check the lag box and set 'Delay(ms)' to 5000. Check the drop box and set 'Chance(%)' to 100. And check the throttle box and set 'timeframe(ms)' to 1000 and 'Chance(%)' to 100")

        GuiHelp.Add("Text", "xp yp+90 wp Center", "To activate the pressure jump macro, `n you need to change DPI in settings to your `n mouse dpi and SENS with your roblox sensivity")

        GuiHelp.Add("Text", "xp yp+45 wp Center", "To no clip, you need to face a thin wall `n (around 0.9 studs) and press the no clip `n keybind (spencer macro utility isnt `n needed for this btw)")

        ; Credit in help GUI
        GuiHelp.SetFont("s10 cWhite", "Consolas")
        GuiHelp.Add("Text", "xp yp+50 wp Center", "Made By @Idkwhattonamethis223 On Youtube")

        HelpGuiShow := 1 ; never make new help guis again
    }

    global IsHelpVisible := !IsHelpVisible

    ; Shows/closes help GUI
    if (IsHelpVisible) {
        GuiHelp.Show("w350 h690")
        WinSetRegion("0-0 w415 h700 r20-20", GuiHelp.Hwnd)
    } else {
        GuiHelp.Hide()
    }
}

; -- Settings GUI --
SettingsGui() {
    static SettingsGuiShow := 0

    if (SettingsGuiShow == 0) {
        global GuiSetting, DPI_Input, Sens_Input, Guns, GunsAmountStatus, ShootDelay, GunAmountVar
        GuiSetting := Gui("-Caption +AlwaysOnTop")
        GuiSetting.BackColor := "000000" ; black hex code

        ; Title for help GUI
        GuiSetting.SetFont("s25 bold cWhite", "Segoe UI")
        GuiSetting.Add("Text", "x0 y0 w330 Center", "Macro Settings")
        
        ; -- Gun Amount Choose --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 y60 w330",  "Gun Amount")
        
        GuiSetting.SetFont("cBlack")
        Guns := GuiSetting.AddEdit("x269 yp+3 w25 h25 0x200 +Number", GunAmountVar)
        
        GunAmountVar := Guns.Value
        GunsAmountStatus.Value := GunAmountVar

        Guns.Redraw()
        GunsAmountStatus.Redraw()
        
        ; -- Shoot Delay --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330",  "Shoot Delay")

        GuiSetting.SetFont("s8 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "xp+125 yp+10 w330",  "(milisecond)")
        
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        ShootDelay := GuiSetting.AddEdit("x269 y93 w25 h25 0x200 +Number", 5)

        ; -- Reload Delay --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330",  "Reload Delay")

        GuiSetting.SetFont("s8 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "xp+135 yp+10 w330",  "(milisecond)")
        
        GuiSetting.SetFont("s15 bold cBlack", "Consolas")
        ReloadDelay := GuiSetting.AddEdit("x269 y121 w25 h25 0x200 +Number", 0)
        global ReloadDelay
        
        ; -- Shift Option --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+40 w330", "Press Shift Once")
        
        GuiSetting.Add("Text", "x268 yp w28 h25 BackgroundFFFFFF")
        Slot1 := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background000000")
        Slot1.OnEvent("Click", (*) => SlotsClicked(1))

        ; -- Lag Switch Option --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330",  "Lag Switch")

        GuiSetting.Add("Text", "x268 yp w28 h25 BackgroundFFFFFF")
        Slot2 := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background000000")
        Slot2.OnEvent("Click", (*) => SlotsClicked(2))

        ; -- Sound Beep Toggle --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330",  "Sound Beep Toggle")
        
        GuiSetting.Add("Text", "x268 yp w28 h25 BackgroundFFFFFF")
        Slot3 := GuiSetting.Add("Text", "xp+2 yp+2 w23 h20 Background000000")
        Slot3.OnEvent("Click", (*) => SlotsClicked(3))

        ; -- Pressure Jump --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+35 w330",  "Pressure Jump")

        GuiSetting.SetFont("s12 bold cBlack", "Consolas")
        Sens_Input := GuiSetting.AddEdit("x260 yp+3 w45 h20", 0)

        GuiSetting.SetFont("s12 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x225 yp+20 w330", "ROBLOX SENS")

        ; X button in settings GUI
        GuiSetting.SetFont("s13 bold cWhite", "Arial")
        GuiSetting.Add("Text", "x300 y0 w30 h20 Center BackgroundFF0000", "X").OnEvent("Click", (*) => HideSetting())

        ; function for hiding setting GUI
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
            switch(slot) {
                case 1:
                    global Slot1Bool := !Slot1Bool
                    Slot1.Opt(Slot1Bool ? "Background00FF00" : "Background000000")
                    ShiftHolderStatus.Visible := (Slot1Bool ? true : false)
                    Slot1.Redraw
                    
                    ; if shift holder is still on but toggle is off, stop holding shift
                    if (!Slot1Bool && ShiftHolder) {
                        global ShiftHolder := false
                        global IsCrouching := false
                        global IsChatting  := false

                        ShiftHolderStatus.Opt("BackgroundFF0000")
                        ShiftHolderStatus.Redraw()

                        Send "{LShift up}"
                    }
                case 2:
                    ZipPath      := A_ScriptDir "\clumsy-0.3-win64-a.zip"
                    TargetFolder := A_ScriptDir "\clumsy-0.3-win64-a"
                    ClumsyPath   := TargetFolder "\clumsy.exe"
                    FilterConfig := "outbound and udp"

                    if (Slot2Bool) {
                        if WinExist("ahk_exe clumsy.exe") {
                            ProcessClose("clumsy.exe")
                        }

                        global Slot2Bool := false
                        Slot2.Opt("Background000000")
                        LagSwitchStatus.Visible := false
                        Slot2.Redraw()
                        return
                    }

                    ; if clumsy isnt installed
                    if (!FileExist(TargetFolder) && !FileExist(ZipPath)) {
                        TrayTip("Downloading Clumsy (required file for lag switching)", "Macro Installer")
                        try {
                            Download("https://github.com/jagt/clumsy/releases/download/0.3/clumsy-0.3-win64-a.zip", ZipPath)
                            MsgBox("Automated installation success")
                        } catch Error as err {
                            MsgBox("Automated installation failed. Install clumsy-0.3-win64-a.zip bit from https://jagt.github.io/clumsy/download `n`n Error: " err.Message`n`n)
                            return
                        }
                    }

                    ; auto extract
                    if !FileExist(TargetFolder) {
                        TrayTip("Extracting Clumsy files", "Macro Installer")
                        try {
                            DirCreate(TargetFolder)
                            ShellObj := ComObject("Shell.Application")
                            ZipFolder := ShellObj.NameSpace(ZipPath)
                            DestFolder := ShellObj.NameSpace(TargetFolder)

                            if (ZipFolder && DestFolder) {
                                DestFolder.CopyHere(ZipFolder.Items, 4 | 16)
                                MsgBox("Extraction success. Make sure you're not touching your keyboard nor mouse for a few seconds")
                                Sleep(800)
                            }
                        } catch Error as err {
                            MsgBox("Extraction failed. Extract the file manually `n`nError:" err.Message)
                            return
                        }
                    }
                    if (!WinExist("ahk_exe clumsy.exe") && FileExist(ClumsyPath)) {
                        ProcessClose("clumsy.exe")
                        Sleep(200)

                        Run('*RunAs "' ClumsyPath '" --filter "' FilterConfig '" --lag on --lag-time 5000 --drop on --drop-chance 100 --throttle on --throttle-chance 100 --throttle-frame 1000')

                        ; turns off lag switch
                        WinWait("ahk_exe clumsy.exe")
                        Sleep(20)
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

                    global Slot2Bool := !Slot2Bool
                    Slot2.Opt(Slot2Bool ? "Background00FF00" : "Background000000")
                    LagSwitchStatus.Visible := (Slot2Bool ? true : false)
                    Slot2.Redraw
                case 3:
                    global Slot3Bool := !Slot3Bool
                    Slot3.Opt(Slot3Bool ? "Background00FF00" : "Background000000")
                    Slot3.Redraw
            }
        }
        
        ; Credit in settings GUI
        GuiSetting.SetFont("s10 cWhite", "Consolas")
        GuiSetting.Add("Text", "x0 y300 w330 Center", "Made By @Idkwhattonamethis223 On Youtube")

        SettingsGuiShow := 1 ; never make new help guis again
    }

    global IsSettingsVisible := !IsSettingsVisible
    GunAmountVar := Guns.Value
    GunsAmountStatus.Value := GunAmountVar

    Guns.Redraw()
    GunsAmountStatus.Redraw()

    ; Shows/closes help GUI
    if (IsSettingsVisible) {
        GuiSetting.Show("w330 h400")
        WinSetRegion("0-0 w410 h410 r20-20", GuiSetting.Hwnd)
    } else {
        GuiSetting.Hide()
    }
}
