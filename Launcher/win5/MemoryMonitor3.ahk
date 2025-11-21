#Persistent
#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory

; Get window ID from command line parameter
winId := A_Args[1]
if (winId = "") {
    MsgBox, No window ID provided. Exiting.
    ExitApp
}

guiTransparency := 112
monitorNum := 3  ; This is monitor 3

; Create a GUI for memory display
Gui, 1:color, black
Gui, 1:Add, Text, vMemoryInfo cWhite w120, Memory: 0 MB
Gui, 1:+AlwaysOnTop -Caption

; Position GUI at the bottom left corner of the selected window
WinGetPos, winX, winY, winWidth, winHeight, ahk_id %winId%
if (winX = "") {
    MsgBox, Cannot find window. Exiting.
    ExitApp
}

Gui, 1:Show, w140 h40 x%winX% y%winY%, Memory Monitor %monitorNum%
WinMove, Memory Monitor %monitorNum%,, %winX%, % winY + winHeight - 40
WinSet, Transparent, %guiTransparency%, Memory Monitor %monitorNum%

; Start monitoring
SetTimer, UpdateMemoryUsage, 50
return

UpdateMemoryUsage:
    ; Check if window still exists
    IfWinNotExist, ahk_id %winId%
    {
        ExitApp  ; Exit this monitor process if window is closed
    }
    
    ; Update position of GUI in case the window moved
    WinGetPos, winX, winY, winWidth, winHeight, ahk_id %winId%
    WinMove, Memory Monitor %monitorNum%,, %winX%, % winY + winHeight - 40

    ; Get memory usage
    WinGet, targetPID, PID, ahk_id %winId%
    if (targetPID = "") {
        GuiControl, 1:, MemoryInfo, Cannot get PID
        return
    }

    memUsage := GetProcessMemory(targetPID)
    GuiControl, 1:, MemoryInfo, Memory: %memUsage% MB
return

GetProcessMemory(pid) {
    ; Use a simpler approach with Process command
    Process, Exist, %pid%
    if (ErrorLevel != pid)
        return 0
        
    ; Use WMI to get memory info
    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId=" . pid)
        memory := process.WorkingSetSize
        
    if (memory = "")
        return 0
        
    ; Convert to MB
    memMB := Round(memory / 1048576, 2)  ; 1024*1024
    return memMB
}

Esc:: ExitApp  ; Press Esc to exit this monitor