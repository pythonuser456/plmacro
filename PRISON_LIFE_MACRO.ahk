; the code might not be the best

#Requires AutoHotkey v2.0
#SingleInstance Force
ProcessSetPriority "High"

; -- Variables --
ScriptActive := false
ShiftHolder := false
ShowUi := false
IsChatting := false
Slot1Bool := false
Slot2Bool := false
Slot3Bool := false
Slot4Bool := false
Slot5Bool := false
Slot6Bool := false
Slot7Bool := false
IsHelpVisible := false
IsSettingsVisible := false
IsCrouching := false
IsChatting := false
IsLagging := false
LagSwitchTL := 0
GuiThing := ""
GuiSetting := ""
GuiHelp := ""

Spin := 4000
BaseDPI := 800
BaseSens := 0.36


; -- Main GUI Call --
if not A_IsAdmin {
    try {
        Run('*RunAs "' . A_ScriptFullPath . '"')
        Sleep(3000)
    } catch {
        MsgBox("Admin privileges denied. This might make your experience worse.")
    }
}

MainGui()
OnMessage(0x0201, (*) => PostMessage(0xA1, 2,,, "A")) ; for gui drag

; -- Toggle LMB, R, T, F--
*$Alt:: {
    global ScriptActive := !ScriptActive
    
    StatusLabel.Text := ScriptActive ? "ON" : "OFF"
    StatusLabel.Opt(ScriptActive ? "Background00FF7F" : "BackgroundFF0000")
    StatusLabel.Redraw()

    if Slot7Bool
        SoundBeep(ScriptActive ? 550 : 400, 20)
}

#HotIf ScriptActive
; -- Reload All --
*$r:: {
    if (Slot1Bool) {
        Send "{Blind}1"
        Send "{Blind}r"
    }
    if (Slot2Bool) {
        Send "{Blind}2"
        Send "{Blind}r"
    }
    if (Slot3Bool) {
        Send "{Blind}3"
        Send "{Blind}r"
    }
    if (Slot4Bool) {
        Send "{Blind}4"
        Send "{Blind}r"
    }

    if Slot7Bool
        SoundBeep(550, 20)
}

; -- Blatant Gun Macro --
~$*LButton:: {
    DllCall("Winmm\timeBeginPeriod", "UInt", 1)
    while GetKeyState("LButton", "P")  {
        if (Slot1Bool) {
            Send "{Blind}1"
            DllCall("Sleep", "UInt", 5)
            Click
            DllCall("Sleep", "UInt", 5)
        }
        if (Slot2Bool) {
            Send "{Blind}2"
            DllCall("Sleep", "UInt", 5)
            Click
            DllCall("Sleep", "UInt", 5)
        }
        if (Slot3Bool) {
            Send "{Blind}3"
            DllCall("Sleep", "UInt", 5)
            Click
            DllCall("Sleep", "UInt", 5)
        }
        if (Slot4Bool) {
            Send "{Blind}4"
            DllCall("Sleep", "UInt", 5)
            Click
            DllCall("Sleep", "UInt", 5)
        }
    }
    DllCall("Winmm\timeEndPeriod", "UInt", 1)
}
#HotIf

; -- Lag Switcher --
#HotIf WinExist("ahk_exe clumsy.exe") && Slot6Bool && ScriptActive
$*t:: {
    SoundBeep(550, 20)

    global IsLagging := !IsLagging
    global LagSwitchTL
    
    SetControlDelay(50)

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
        
        SoundBeep(400, 20)
        KeyWait "t"
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
    KeyWait "t" 
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
        SoundBeep(400, 20)
    }
}

#HotIf ScriptActive
; -- Pressure Jump --
$*g:: {
    if (DPI_Input.Value == 0 or Sens_Input.Value == 0) {
        MsgBox("Please put your mouse DPI / Roblox Sensitivity in the settings")
        return
    }

    X := Round((Spin * BaseDPI * BaseSens) / (Number(DPI_Input.Value) * Number(Sens_Input.Value)))
    DllCall("Winmm\timeBeginPeriod", "UInt", 1)

    Send "{Blind}c"
    DllCall("Sleep", "UInt", 6)

    Send "{Space down}"
    DllCall("Sleep", "UInt", 60)
    Send "{Space up}"

    DllCall("Sleep", "UInt", 4)

    start := A_TickCount

    Loop {
        if (A_TickCount - start > 200)
            break
        DllCall("mouse_event", "UInt", 0x0001, "Int", X, "Int", 0, "UInt", 0, "UPtr", 0)

        DllCall("Sleep", "UInt", 4)
    }

    global IsCrouching := false
    DllCall("Winmm\timeEndPeriod", "UInt", 1)
}
#HotIf

; -- Shift Holder --
~$*LShift:: {
    if (!Slot5Bool or IsChatting or IsCrouching) {
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
#HotIf IsCrouching
*$c:: {
    global IsCrouching := false

    Send "{LShift up}"
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
    global ShiftHolderStatus, GuiThing, LagSwitchStatus

    ; black thing
    GuiThing := Gui("-Caption +AlwaysOnTop")
    GuiThing.BackColor := "000000" ; black hex code
    WinSetRegion("0-0 w270 h65 r15-15", GuiThing.Hwnd)

    ; shift holder gui
    GuiThing.SetFont("s7 bold cWhite", "Arial")
    ShiftHolderStatus := GuiThing.Add("Text", "x95 y0 w30 h15 Center 0x200 BackgroundFF0000 -0x100 0x1 Hidden", "SHIFT")

    ; Lag switch gui
    GuiThing.SetFont("s7 bold cWhite", "Arial")
    LagSwitchStatus := GuiThing.Add("Text", "x75 y0 w15 h15 Center 0x200 BackgroundFF0000 -0x100 0x1 Hidden", LagSwitchTL)

    ; title
    GuiThing.SetFont("s12 bold cWhite", "Segoe UI")
    GuiThing.Add("Text", "x75 y15 w150", "Prison Life Macro")

    ; On/Off button
    GuiThing.SetFont("s23 bold cWhite", "Arial")
    global StatusLabel := GuiThing.Add("Text", "x0 y0 w60 h50 0x200 BackgroundFF0000 -0x100 0x1", "OFF")

    ; X button
    GuiThing.SetFont("s10 bold cWhite", "Arial")
    GuiThing.Add("Text", "x195 y0 w20 h15 Center 0x200 BackgroundFF0000", "X").OnEvent("Click", (*) => StopMacro() )

    ; Help button
    GuiThing.SetFont("s8 bold cBlack", "Arial")
    GuiThing.Add("Text", "x145 y0 w30 h15 Center 0x200 BackgroundFFFFFF", "HELP").OnEvent("Click", (*) => HelpGui() )

    ; settings button
    GuiThing.SetFont("s8 cWhite", "Segoe UI Symbol")
    GuiThing.Add("Text", "x175 y0 w20 h15 Center 0x200 Background00008B", Chr(0x2699) ).OnEvent("Click", (*) => SettingsGui() ) ; setting symbol

    ; Credit
    GuiThing.SetFont("s5 bold cWhite", "Consolas")
    GuiThing.Add("Text", "x80 y45 w100", "Made By @Idkwhattonamethis223 On Youtube")

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
        GuiHelp.Add("Text", "x300 y0 w30 h20 Center BackgroundFF0000", "X").OnEvent("Click", (*) => HideHelp())

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
        GuiHelp.Add("Text", "xp yp+15 wp Center",  "R   = Shuffle Reload   ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", " T   = Lag Switch        ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", "    G   = Pressure Jump        ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", "F4  = Show/Minimize    ")
        GuiHelp.Add("Text", "xp yp+15 wp Center", "DEL = Close Macro      ")

        ; -- Extra Info --
        GuiHelp.SetFont("s15 bold cWhite", "Tahoma") 
        GuiHelp.Add("Text", "xp y180 wp Center", "Extra Info")

        GuiHelp.SetFont("s7 cWhite", "Consolas")
        GuiHelp.Add("Text", "xp yp+25 wp Center", "WEAPONS MUST BE IN SLOTS 1, 2, 3, 4")

        GuiHelp.Add("Text", "xp yp+20 wp Center", "You can also press shift once to sprint by`n toggling Press Shift Once in the settings")

        GuiHelp.Add("Text", "xp yp+30 wp Center", "When you toggle Press Shift Once and you`n want to chat, press enter no matter what `nhappens (like getting jumped) to make`n the sprint helper work again")

        GuiHelp.Add("Text", "xp yp+55 wp Center", "To actually use the very fast weapon `nswap macro, you need to toggle gun 1,`n gun 2, gun 3, and gun 4 in the settings `n depending on how many guns you have")

        GuiHelp.Add("Text", "xp yp+55 wp Center", "To use the lag switch, download `n clumsy 0.3 64 bit and open your `n clumsy and set your settings as Filtering: `n outbound and udp. Check the lag box and set it `n to 3000 ms delay. Check drop and throttle `n and change both of the chances to 100. And `n set throttle's timeframe ms to 1000")

        GuiHelp.Add("Text", "xp yp+85 wp Center", "To activate the pressure jump macro, `n you need to change DPI in settings to your `n mouse dpi and SENS with your roblox sensivity")

        ; Credit in help GUI
        GuiHelp.SetFont("s10 cWhite", "Consolas")
        GuiHelp.Add("Text", "xp yp+50 wp Center", "Made By @Idkwhattonamethis223 On Youtube")

        HelpGuiShow := 1 ; never make new help guis again
    }

    global IsHelpVisible := !IsHelpVisible

    ; Shows/closes help GUI
    if (IsHelpVisible) {
        GuiHelp.Show("w330 h640")
        WinSetRegion("0-0 w410 h650 r20-20", GuiHelp.Hwnd)
    } else {
        GuiHelp.Hide()
    }
}

; -- Settings GUI --
SettingsGui() {
    static SettingsGuiShow := 0

    if (SettingsGuiShow == 0) {
        global GuiSetting, DPI_Input, Sens_Input
        YPOS := 65
        global GuiSetting := Gui("-Caption +AlwaysOnTop")
        GuiSetting.BackColor := "000000" ; black hex code

        ; Title for help GUI
        GuiSetting.SetFont("s25 bold cWhite", "Segoe UI")
        GuiSetting.Add("Text", "x0 y0 w330 Center", "Macro Settings")

        ; -- Slot 1 --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 y60 w330",  "Gun 1")
        
        GuiSetting.Add("Text", "x250 y65 w27 h24 BackgroundFFFFFF")
        Slot1 := GuiSetting.Add("Text", "x252 y67 w23 h20 Background000000")
        Slot1.OnEvent("Click", (*) => SlotsClicked(1))
        
        ; -- Slot 2 --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330",  "Gun 2")
        
        GuiSetting.Add("Text", "x250 yp w27 h24 BackgroundFFFFFF")
        Slot2 := GuiSetting.Add("Text", "x252 yp+3 w23 h20 Background000000")
        Slot2.OnEvent("Click", (*) => SlotsClicked(2))

        ; -- Slot 3 --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330",  "Gun 3")
        
        GuiSetting.Add("Text", "x250 yp w27 h24 BackgroundFFFFFF")
        Slot3 := GuiSetting.Add("Text", "x252 yp+3 w23 h20 Background000000")
        Slot3.OnEvent("Click", (*) => SlotsClicked(3))

        ; -- Slot 4 --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330",  "Gun 4")

        GuiSetting.Add("Text", "x250 yp w27 h24 BackgroundFFFFFF")
        Slot4 := GuiSetting.Add("Text", "x252 yp+3 w23 h20 Background000000")
        Slot4.OnEvent("Click", (*) => SlotsClicked(4))

        ; -- Shift Option --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330",  "Press Shift Once")
        
        GuiSetting.Add("Text", "x250 yp w27 h24 BackgroundFFFFFF")
        Slot5 := GuiSetting.Add("Text", "x252 yp+3 w23 h20 Background000000")
        Slot5.OnEvent("Click", (*) => SlotsClicked(5))

        ; -- Lag Switch Option --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330",  "Lag Switch")

        GuiSetting.Add("Text", "x250 yp w27 h24 BackgroundFFFFFF")
        Slot6 := GuiSetting.Add("Text", "x252 yp+3 w23 h20 Background000000")
        Slot6.OnEvent("Click", (*) => SlotsClicked(6))

        ; -- Sound Beep Toggle --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+25 w330",  "Sound Beep Toggle")
        
        GuiSetting.Add("Text", "x250 yp w27 h24 BackgroundFFFFFF")
        Slot7 := GuiSetting.Add("Text", "x252 yp+3 w23 h20 Background000000")
        Slot7.OnEvent("Click", (*) => SlotsClicked(7))

        ; -- Pressure Jump --
        GuiSetting.SetFont("s15 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x60 yp+30 w330",  "Pressure Jump")

        GuiSetting.SetFont("s12 bold cBlack", "Consolas")
        DPI_Input := GuiSetting.AddEdit("x220 yp+3 w45 h20 0x200", 0)
        Sens_Input := GuiSetting.AddEdit("x275 yp w37 h20 0x200", 0)

        GuiSetting.SetFont("s12 bold cWhite", "Consolas")
        GuiSetting.Add("Text", "x225 yp+20 w330", "DPI")
        GuiSetting.Add("Text", "x275 yp w330", "SENS")

        ; X button in settings GUI
        GuiSetting.SetFont("s13 bold cWhite", "Arial")
        GuiSetting.Add("Text", "x300 y0 w30 h20 Center BackgroundFF0000", "X").OnEvent("Click", (*) => HideSetting())

        ; function for hiding setting GUI
        HideSetting(*) {
            GuiSetting.Hide()
            global IsSettingsVisible := false
        }

        ; function for toggle
        SlotsClicked(slot) {
            switch(slot) {
                case 1:
                    global Slot1Bool := !Slot1Bool
                    Slot1.Opt(Slot1Bool ? "Background00FF00" : "Background000000")
                    Slot1.Redraw
                case 2:
                    global Slot2Bool := !Slot2Bool
                    Slot2.Opt(Slot2Bool ? "Background00FF00" : "Background000000")
                    Slot2.Redraw
                case 3:
                    global Slot3Bool := !Slot3Bool
                    Slot3.Opt(Slot3Bool ? "Background00FF00" : "Background000000")
                    Slot3.Redraw
                case 4:
                    global Slot4Bool := !Slot4Bool
                    Slot4.Opt(Slot4Bool ? "Background00FF00" : "Background000000")
                    Slot4.Redraw
                case 5:
                    global Slot5Bool := !Slot5Bool
                    Slot5.Opt(Slot5Bool ? "Background00FF00" : "Background000000")
                    ShiftHolderStatus.Visible := (Slot5Bool ? true : false)
                    Slot5.Redraw
                    
                    if (!Slot5Bool && ShiftHolder) { ; if shift holder is still on but toggle is off, stop holding shift
                        global ShiftHolder := false
                        Send "{LShift up}"
                    }
                case 6:
                    TargetFolder := A_ScriptDir "\clumsy"
                    ZipPath      := A_ScriptDir "\clumsy.zip"

                    if (!FileExist(TargetFolder) && !FileExist(ZipPath)) {
                        TrayTip("Downloading Clumsy", "Macro Downloader")
                        try {
                            Download("https://github.com/jagt/clumsy/releases/download/0.3/clumsy-0.3-win64-a.zip", A_ScriptDir "\clumsy.zip")
                            MsgBox("Automated installation succeded (why would you delete clumsy). Extract the zipped folder")
                            return
                        } catch Error as err {
                            MsgBox("Automated installation failed (why would you delete clumsy). Install clumsy 0.3 from the official website`n`nError: " err.Message`n`n)
                            return
                        }
                    }
                    else if !FileExist(TargetFolder) {
                        MsgBox("Extract the zipped folder named clumsy")
                        return
                    }  
                    else if (!WinExist("ahk_exe clumsy.exe") && FileExist(TargetFolder)) { ; if clumsy isnt opened, msgbox would tell you to open clumsy manually
                        MsgBox("Open clumsy 0.3 and set up the settings manually (instructions in the big fat help button)")
                        return
                    }

                    global Slot6Bool := !Slot6Bool
                    Slot6.Opt(Slot6Bool ? "Background00FF00" : "Background000000")
                    LagSwitchStatus.Visible := (Slot6Bool ? true : false)
                    Slot6.Redraw
                case 7:
                    global Slot7Bool := !Slot7Bool
                    Slot7.Opt(Slot7Bool ? "Background00FF00" : "Background000000")
                    Slot7.Redraw
            }
        }
        

        ; Credit in settings GUI
        GuiSetting.SetFont("s10 cWhite", "Consolas")
        GuiSetting.Add("Text", "x0 y310 w330 Center", "Made By @Idkwhattonamethis223 On Youtube")

        SettingsGuiShow := 1 ; never make new help guis again
    }

    global IsSettingsVisible := !IsSettingsVisible

    ; Shows/closes help GUI
    if (IsSettingsVisible) {
        GuiSetting.Show("w330 h400")
        WinSetRegion("0-0 w410 h410 r20-20", GuiSetting.Hwnd)
    } else {
        GuiSetting.Hide()
    }
}
