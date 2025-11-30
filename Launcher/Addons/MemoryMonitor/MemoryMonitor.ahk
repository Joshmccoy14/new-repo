#Persistent
#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory

; Initialize variables
global guiTransparency := 112
global activeMonitors := 0
global maxMonitors := 8

; Create a GUI for instructions
Gui, Main:color, black
Gui, Main:Add, Text, cwhite, Memory Monitor - Instructions:
Gui, Main:Add, Text, cwhite, Click buttons 1-8 then left click to select windows `nto monitor. Press Esc to Exit.

; Add number buttons (1-8)
Gui, Main:Add, Button, x10 y80 w25 h25 gMonitorButton, 1
Gui, Main:Add, Button, x40 y80 w25 h25 gMonitorButton, 2
Gui, Main:Add, Button, x70 y80 w25 h25 gMonitorButton, 3
Gui, Main:Add, Button, x100 y80 w25 h25 gMonitorButton, 4
Gui, Main:Add, Button, x130 y80 w25 h25 gMonitorButton, 5
Gui, Main:Add, Button, x160 y80 w25 h25 gMonitorButton, 6
Gui, Main:Add, Button, x190 y80 w25 h25 gMonitorButton, 7
Gui, Main:Add, Button, x220 y80 w25 h25 gMonitorButton, 8

Gui, Main:+AlwaysOnTop -Caption
Gui, Main:Show, w260 h120, Memory Monitor Main
WinSet, Transparent, %guiTransparency%, Memory Monitor Main

; Enable dragging the window from anywhere
OnMessage(0x201, "WM_LBUTTONDOWN")
return

; Function to allow dragging the window from anywhere
WM_LBUTTONDOWN() {
    PostMessage, 0xA1, 2
    return
}

; Button handler for monitor selection
MonitorButton:
    monitorNum := A_GuiControl
    if (activeMonitors < maxMonitors) {
        GuiControl, Main:, MonitorStatus, Click on window %monitorNum% to monitor...
        KeyWait, LButton, D
        MouseGetPos,,, winId
        WinGetTitle, title, ahk_id %winId%
        
        ; Launch a new AHK process for this window
        Run, "%A_AhkPath%" "%A_ScriptDir%\monitors\MemoryMonitor%monitorNum%.ahk" "%winId%"
        
        activeMonitors++
        GuiControl, Main:, MonitorStatus, Monitoring %activeMonitors% window(s)
    } else {
        GuiControl, Main:, MonitorStatus, Maximum of %maxMonitors% windows reached
    }
return

Esc:: 
    ; Close all monitor processes
    Loop, 8 {
        Process, Close, MemoryMonitor%A_Index%.ahk
    }
    ;ExitApp
return