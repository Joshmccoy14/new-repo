#SingleInstance Force

; Include FindText library for screenshot functionality
#include findtext2.ahk

; Function to show message box positioned to the left of main GUI
ShowMsgLeft(options, title, text) {
    WinGetPos, guiX, guiY,,, Rupees Monitor
    msgX := guiX - 300
    if (msgX < 0)
        msgX := 0
    msgY := guiY
    
    Gui, 99:New, +AlwaysOnTop, %title%
    Gui, 99:Add, Text, x10 y10 w250, %text%
    Gui, 99:Add, Button, x100 y50 w60 h25 gMsgOK Default, OK
    Gui, 99:Show, x%msgX% y%msgY% w270 h85
    WinWaitClose, %title%
    return
    
    MsgOK:
    Gui, 99:Destroy
    return
}

; Configuration - Edit these values
regionX := 100
regionY := 100
regionW := 200
regionH := 50
ocrPath := "C:\Program Files\Tesseract-OCR\tesseract.exe"
isRunning := false
currentRupees := "0"
startTime := 0
startRupees := 0
rupeesPerHour := 0
guiTransparency := 255
settingsFile := A_ScriptDir "\rupeesperhour_settings.ini"
isHidden := false
lastValidRupees := 0
badReadingCount := 0
CompactLabelCreated := false
rupeesHourText := "0"
currentRupeesText := "0"

; Delete contents of out.txt on script start
outputFile := A_ScriptDir "\out.txt"
FileDelete, %outputFile%

; Load saved settings
LoadSettings()

; Update GUI status text with loaded settings
GuiControl,, StatusText, Selected Region: %regionX%`, %regionY%`, %regionW%`, %regionH%
 
; Create main GUI
Gui, Color, Black
Gui, Add, Text, x10 y10 w200 h20 cWhite, Rupees Per Hour Monitor
Gui, Add, Text, x10 y40 w100 h20 cWhite, Current Rupees:
Gui, Add, Text, x95 y40 w80 h20 vRupeesDisplay cWhite, %currentRupees%
Gui, Add, Text, x10 y60 w100 h20 cWhite, Rupees/Hour:
Gui, Add, Text, x85 y60 w80 h20 vRupeesHourDisplay cWhite, %rupeesPerHour%
Gui, Add, Text, x10 y80 w100 h20 cWhite, Session Gained:
Gui, Add, Text, x95 y80 w80 h20 vSessionGained cWhite, 0
Gui, Add, Text, x10 y100 w100 h20 cWhite, Runtime:
Gui, Add, Text, x85 y100 w80 h20 vRuntime cWhite, 00:00:00
Gui, Add, Button, x10 y120 w60 h30 gSelectArea vSelectAreaBtn, Select Area
Gui, Add, Button, x80 y120 w40 h30 gStartStop vStartStopBtn, Start
Gui, Add, Button, x130 y120 w40 h30 gReloadScript vReloadBtn, Reload
Gui, Add, Button, x180 y120 w35 h30 gExit vExitBtn, Exit
Gui, Add, Button, x220 y120 w35 h30 gToggleHide vHideBtn, Hide
Gui, Add, Text, x10 y160 w65 h20 cWhite, Transparency:
Gui, Add, Slider, X85 y160 w100 h20 vTransparencySlider gTransparencyChange Range10-255 TickInterval50, %guiTransparency%
Gui, Add, Text, x180 y160 w50 h20 vTransparencyText cWhite, %guiTransparency%
Gui, Add, Text, x10 y190 w240 h30 vStatusText cWhite, Selected Region: %regionX%`, %regionY%`, %regionW%`, %regionH%
Gui, +AlwaysOnTop -Caption
Gui, Show, w260 h230, Rupees Monitor
WinSet, Transparent, %guiTransparency%, Rupees Monitor

; Update status text with loaded settings after GUI is created
GuiControl,, StatusText, Selected Region: %regionX%`, %regionY%`, %regionW%`, %regionH%

; Enable dragging the window from anywhere
OnMessage(0x201, "WM_LBUTTONDOWN")
return

; Function to allow dragging the window from anywhere
WM_LBUTTONDOWN() {
    PostMessage, 0xA1, 2
    return
}

SelectArea:
    SetCaptureRegion()
    GuiControl,, StatusText, Region: %regionX%`, %regionY%`, %regionW%x%regionH%
    SaveSettings()
    ; Test the selected region
    result := ReadOCR()
    if (result != -1) {
        ShowMsgLeft(4160, "Test Result", "OCR read: " . result . " rupees from selected region.")
    } else {
        ShowMsgLeft(4112, "Test Failed", "Could not read rupees from selected region. Try selecting again.")
    }
return

ReloadScript:
    Reload
return

TransparencyChange:
    Gui, Submit, NoHide
    guiTransparency := TransparencySlider
    GuiControl,, TransparencyText, %guiTransparency%
    WinSet, Transparent, %guiTransparency%, Rupees Monitor
    SaveSettings()
return

ToggleHide:
    if (isHidden) {
        ; Switch from compact to full mode
        GuiControl, Hide, CompactLabel
        GuiControl, Show, RupeesDisplay
        GuiControl, Show, SelectAreaBtn
        GuiControl, Show, StartStopBtn
        GuiControl, Show, ReloadBtn
        GuiControl, Show, ExitBtn
        GuiControl, Show, TransparencySlider
        GuiControl, Show, TransparencyText
        GuiControl, Show, StatusText
        GuiControl, Show, Static1
        GuiControl, Show, Static2
        GuiControl, Show, Static3
        GuiControl, Show, Static4
        GuiControl, Move, RupeesDisplay, x95 y40 w80 h20
        GuiControl, Move, RupeesHourDisplay, x85 y60 w80 h20
        GuiControl, Move, HideBtn, x220 y90 w35 h30
        GuiControl,, RupeesDisplay, %currentRupeesText%
        GuiControl,, RupeesHourDisplay, %rupeesHourText%
        GuiControl,, HideBtn, Hide
        Gui, Show, w260 h200, Rupees Monitor
        isHidden := false
    } else {
        ; Switch from full to compact mode
        GuiControl, Hide, RupeesDisplay
        GuiControl, Hide, SelectAreaBtn
        GuiControl, Hide, StartStopBtn
        GuiControl, Hide, ReloadBtn
        GuiControl, Hide, ExitBtn
        GuiControl, Hide, TransparencySlider
        GuiControl, Hide, TransparencyText
        GuiControl, Hide, StatusText
        GuiControl, Hide, Static1
        GuiControl, Hide, Static2
        GuiControl, Hide, Static3
        GuiControl, Hide, Static4
        if (!CompactLabelCreated) {
            Gui, Add, Text, x10 y10 w40 h20 vCompactLabel cWhite, R/Hr:
            CompactLabelCreated := true
        } else {
            GuiControl, Show, CompactLabel
            GuiControl, Move, CompactLabel, x10 y10 w60 h20
        }
        GuiControl, Move, RupeesHourDisplay, x70 y10 w60 h20
        GuiControl, Move, HideBtn, x40 y30 w70 h20
        GuiControl, Show, RupeesHourDisplay
        GuiControl, Show, HideBtn
        GuiControl,, RupeesHourDisplay, %rupeesHourText%
        GuiControl,, HideBtn, Show
        Gui, Show, w148 h55, Rupees Monitor
        isHidden := true
    }
    WinSet, Transparent, %guiTransparency%, Rupees Monitor
return

StartStop:
    if (isRunning) {
        isRunning := false
        GuiControl,, StartStopBtn, Start
        SetTimer, MonitorRupees, Off
        ;MsgBox, Monitoring stopped
    } else {
        ; Test OCR first
        result := ReadOCR()
        if (result == -1) {
            ShowMsgLeft(4112, "Error", "Cannot read rupees from selected region. Please select the area first.")
            return
        }
        
        isRunning := true
        GuiControl,, StartStopBtn, Stop
        startTime := A_TickCount
        currentRupees := result
        startRupees := result
        rupeesPerHour := 0
        rupeesHourText := "0"
        currentRupeesText := RegExReplace(result, "(\d)(?=(\d{3})+$)", "$1,")
        GuiControl,, RupeesHourDisplay, %rupeesHourText%
        GuiControl,, RupeesDisplay, %currentRupeesText%
        SetTimer, MonitorRupees, 2000
        ;MsgBox, Monitoring started with initial value: %result% rupees
    }
return

MonitorRupees:
    result := ReadOCR()
    if (result != -1) {
        isValidReading := false
        if (result >= 0) {
            if (lastValidRupees == 0 || result >= lastValidRupees) {
                isValidReading := true
                badReadingCount := 0
            } else {
                badReadingCount++
                if (badReadingCount >= 3) {
                    isValidReading := true
                    badReadingCount := 0
                }
            }
        }
        
        if (isValidReading) {
            currentRupees := result
            lastValidRupees := result
            ; Add commas for readability
            currentRupeesText := RegExReplace(currentRupees, "(\d)(?=(\d{3})+$)", "$1,")
            if (!isHidden) {
                GuiControl,, RupeesDisplay, %currentRupeesText%
            }
            
            if (startTime > 0) {
                elapsedMinutes := (A_TickCount - startTime) / 60000
                if (elapsedMinutes >= 0.1) {
                    rupeesGained := currentRupees - startRupees
                    rupeesPerHour := Round(rupeesGained / elapsedMinutes * 60)
                    ; Add commas to rupees per hour
                    rupeesHourText := RegExReplace(rupeesPerHour, "(\d)(?=(\d{3})+$)", "$1,")
                    GuiControl,, RupeesHourDisplay, %rupeesHourText%
                    
                    ; Update session gained
                    sessionGainedText := RegExReplace(rupeesGained, "(\d)(?=(\d{3})+$)", "$1,")
                    GuiControl,, SessionGained, %sessionGainedText%
                    
                    ; Update runtime
                    hours := Floor(elapsedMinutes / 60)
                    minutes := Floor(Mod(elapsedMinutes, 60))
                    seconds := Floor(Mod(elapsedMinutes * 60, 60))
                    GuiControl,, Runtime, %hours%:%minutes%:%seconds%
                }
            }
        }
    }
return

Exit:
    ExitApp

; Function to let user select a region on screen
SetCaptureRegion() {
    global regionX, regionY, regionW, regionH
    
    ; Inform the user
    ShowMsgLeft(0, "Set Capture Region", "Click and drag to select the rupee total.")
    
    ; Create selection GUI
    Gui, 2:New, +AlwaysOnTop -Caption +ToolWindow +Border, Selection
    Gui, 2:Color, Red
    
    ; Wait for mouse button down
    CoordMode, Mouse, Screen
    ; Wait for any previous click to finish
    KeyWait, LButton, U
    KeyWait, LButton, D
    MouseGetPos, startX, startY
    
    ; Show initial selection box
    Gui, 2:Show, x%startX% y%startY% w1 h1
    WinSet, Transparent, 128, Selection
    
    ; Track mouse drag
    Loop {
        Sleep, 10
        if (!GetKeyState("LButton", "P"))
            break
            
        MouseGetPos, currentX, currentY
        w := Abs(currentX - startX)
        h := Abs(currentY - startY)
        x := Min(startX, currentX)
        y := Min(startY, currentY)
        
        ; Update selection box
        Gui, 2:Show, x%x% y%y% w%w% h%h% NoActivate
    }
    
    ; Calculate final region
    regionX := x
    regionY := y
    regionW := w
    regionH := h
    
    ; Hide selection GUI
    Gui, 2:Destroy
    
    ShowMsgLeft(0, "Region Set", "Region set to: x=" . regionX . ", y=" . regionY . ", w=" . regionW . ", h=" . regionH)
}
Screenshot(filename, x1, y1, x2, y2) {
    ; Calculate width and height
    w := x2 - x1
    h := y2 - y1
    
    ; Debug coordinates (comment out when working)
    ; MsgBox, Debug: x1=%x1%, y1=%y1%, x2=%x2%, y2=%y2%`nw=%w%, h=%h%
    
    ; Validate coordinates
    if (w <= 0 || h <= 0) {
        ShowMsgLeft(0, "Error", "Invalid coordinates: w=" . w . ", h=" . h)
        return false
    }
    
    ; Step 1: Take screenshot of entire screen first
    FindText().Screenshot()
    
    ; Step 2: Save the specific region
    result := FindText().SavePic(filename, x1, y1, x2, y2, 0)
    
    ; Check if file was actually created
    if (FileExist(filename)) {
        return true
    }
    
    ShowMsgLeft(0, "Error", "Failed to save screenshot - file not created: " . filename)
    return false
}
ReadOCR() {
    global regionX, regionY, regionW, regionH, ocrPath

    file := A_ScriptDir "\exp.bmp"
    outputFile := A_ScriptDir "\out"

    ; Validate region
    if (regionW <= 0 || regionH <= 0)
    {
        ShowMsgLeft(0, "Error", "Invalid capture region: width or height <= 0")
        return -1
    }

    ; Capture screenshot using built-in function
    CoordMode, Pixel, Screen
    
    ; Take the screenshot
    SendMode Input
    SetBatchLines, -1
    
    ; Capture the screen area
    if (!Screenshot(file, regionX, regionY, regionX + regionW, regionY + regionH))
    {
        ShowMsgLeft(0, "Error", "Screenshot failed")
        return -1
    }

    if !FileExist(file)
    {
        ShowMsgLeft(0, "Error", "Screenshot not saved: " . file)
        return -1
    }

    ; Run OCR
    RunWait, "%ocrPath%" "%file%" "%outputFile%" --oem 3 --psm 6, , Hide
    
    ; Check if output file was created
    if (!FileExist(outputFile ".txt")) {
        ShowMsgLeft(0, "Error", "OCR output file not created: " . outputFile . ".txt")
        return -1
    }
    
    FileRead, result, % outputFile ".txt"
    
    ; Clean up the result - extract only numbers
    result := RegExReplace(result, "[^\d]", "")
    
    if (!result) {
        return -1
    }

    return result + 0
}

LoadSettings() {
    global regionX, regionY, regionW, regionH, guiTransparency, settingsFile
    IniRead, regionX, %settingsFile%, Settings, regionX, 100
    IniRead, regionY, %settingsFile%, Settings, regionY, 100
    IniRead, regionW, %settingsFile%, Settings, regionW, 200
    IniRead, regionH, %settingsFile%, Settings, regionH, 50
    IniRead, guiTransparency, %settingsFile%, Settings, transparency, 255
}

SaveSettings() {
    global regionX, regionY, regionW, regionH, guiTransparency, settingsFile
    IniWrite, %regionX%, %settingsFile%, Settings, regionX
    IniWrite, %regionY%, %settingsFile%, Settings, regionY
    IniWrite, %regionW%, %settingsFile%, Settings, regionW
    IniWrite, %regionH%, %settingsFile%, Settings, regionH
    IniWrite, %guiTransparency%, %settingsFile%, Settings, transparency
}