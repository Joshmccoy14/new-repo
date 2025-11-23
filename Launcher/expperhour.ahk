#SingleInstance Force

; Include FindText library for screenshot functionality
#include findtext2.ahk

; Configuration - Edit these values
regionX := 100
regionY := 100
regionW := 200
regionH := 50
ocrPath := "C:\Program Files\Tesseract-OCR\tesseract.exe"
isRunning := false
currentExp := "0.0"
startTime := 0
startExp := 0
expPerHour := 0
guiTransparency := 255
settingsFile := A_ScriptDir "\expperhour_settings.ini"
isHidden := false
lastValidExp := 0
badReadingCount := 0
CompactLabelCreated := false
ETALabelCreated := false
expHourText := "0"  ; Store the text shown in ExpHourDisplay
currentExpText := "0.0%"  ; Store the text shown in ExpDisplay
etaText := "--:--"  ; Store the ETA to level

; Delete contents of out.txt on script start
outputFile := A_ScriptDir "\out.txt"
FileDelete, %outputFile%

; Load saved settings
LoadSettings()
 
; Create main GUI
Gui, Color, Black  ; Set background to black
Gui, Add, Text, x10 y10 w200 h20 cWhite, EXP Per Hour Monitor
Gui, Add, Text, x10 y40 w100 h20 cWhite, Current EXP:
Gui, Add, Text, x72 y40 w80 h20 vExpDisplay cWhite, %currentExp%`%
Gui, Add, Text, x10 y60 w100 h20 cWhite, EXP/Hour:
Gui, Add, Text, x63 y60 w80 h20 vExpHourDisplay cWhite, %expPerHour%
Gui, Add, Button, x10 y90 w60 h30 gSelectArea vSelectAreaBtn, Select Area
Gui, Add, Button, x80 y90 w40 h30 gStartStop vStartStopBtn, Start
Gui, Add, Button, x130 y90 w40 h30 gReloadScript vReloadBtn, Reload
Gui, Add, Button, x180 y90 w35 h30 gExit vExitBtn, Exit
Gui, Add, Button, x220 y90 w35 h30 gToggleHide vHideBtn, Hide
Gui, Add, Text, x10 y130 w65 h20 cWhite, Transparency:
Gui, Add, Slider, X85 y130 w100 h20 vTransparencySlider gTransparencyChange Range10-255 TickInterval50, %guiTransparency%
Gui, Add, Text, x180 y130 w50 h20 vTransparencyText cWhite, %guiTransparency%
Gui, Add, Text, x10 y160 w240 h30 vStatusText cWhite, Selected Region: %regionX%`, %regionY%`, %regionW%`, %regionH%
Gui, +AlwaysOnTop -Caption
Gui, Show, w260 h200, EXP Monitor
WinSet, Transparent, %guiTransparency%, EXP Monitor

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
return

ReloadScript:
    Reload
return

TransparencyChange:
    Gui, Submit, NoHide
    guiTransparency := TransparencySlider
    GuiControl,, TransparencyText, %guiTransparency%
    WinSet, Transparent, %guiTransparency%, EXP Monitor
    SaveSettings()
return

ToggleHide:
    if (isHidden) {
        ; Switch from compact to full mode
        
        ; Hide compact mode controls
        GuiControl, Hide, CompactLabel
        GuiControl, Hide, ETALabel
        GuiControl, Hide, ETADisplay
        
        ; Show all controls for full mode
        GuiControl, Show, ExpDisplay
        GuiControl, Show, SelectAreaBtn
        GuiControl, Show, StartStopBtn
        GuiControl, Show, ReloadBtn
        GuiControl, Show, ExitBtn
        GuiControl, Show, TransparencySlider
        GuiControl, Show, TransparencyText
        GuiControl, Show, StatusText
        
        ; Show all text labels
        GuiControl, Show, Static1  ; Title
        GuiControl, Show, Static2  ; Current EXP label
        GuiControl, Show, Static3  ; EXP/Hour label
        GuiControl, Show, Static4  ; Transparency label
        
        ; Restore positions
        GuiControl, Move, ExpDisplay, x72 y40 w80 h20
        GuiControl, Move, ExpHourDisplay, x63 y60 w80 h20
        GuiControl, Move, HideBtn, x220 y90 w35 h30
        
        ; Update text values
        GuiControl,, ExpDisplay, %currentExpText%
        GuiControl,, ExpHourDisplay, %expHourText%
        GuiControl,, HideBtn, Hide
        
        ; Resize window
        Gui, Show, w260 h200, EXP Monitor (0.06)
        isHidden := false
    } else {
        ; Switch from full to compact mode
        
        ; Hide most controls
        GuiControl, Hide, ExpDisplay
        GuiControl, Hide, SelectAreaBtn
        GuiControl, Hide, StartStopBtn
        GuiControl, Hide, ReloadBtn
        GuiControl, Hide, ExitBtn
        GuiControl, Hide, TransparencySlider
        GuiControl, Hide, TransparencyText
        GuiControl, Hide, StatusText
        
        ; Hide all text labels
        GuiControl, Hide, Static1  ; Title
        GuiControl, Hide, Static2  ; Current EXP label
        GuiControl, Hide, Static3  ; EXP/Hour label
        GuiControl, Hide, Static4  ; Transparency label
        
        ; Create or show compact label
        if (!CompactLabelCreated) {
            Gui, Add, Text, x10 y10 w60 h20 vCompactLabel cWhite, EXP/Hr:
            CompactLabelCreated := true
        } else {
            GuiControl, Show, CompactLabel
            GuiControl, Move, CompactLabel, x10 y10 w60 h20
        }
        
        ; Create or show ETA label
        if (!ETALabelCreated) {
            Gui, Add, Text, x10 y30 w60 h20 vETALabel cWhite, ETA:
            Gui, Add, Text, x70 y30 w60 h20 vETADisplay cWhite, %etaText%
            ETALabelCreated := true
        } else {
            GuiControl, Show, ETALabel
            GuiControl, Show, ETADisplay
            GuiControl, Move, ETALabel, x10 y30 w60 h20
            GuiControl, Move, ETADisplay, x70 y30 w60 h20
        }
        
        ; Position compact mode controls
        GuiControl, Move, ExpHourDisplay, x70 y10 w60 h20
        GuiControl, Move, HideBtn, x40 y50 w70 h20
        
        ; Show necessary controls
        GuiControl, Show, ExpHourDisplay
        GuiControl, Show, HideBtn
        
        ; Update text
        GuiControl,, ExpHourDisplay, %expHourText%
        GuiControl,, HideBtn, Show
        
        ; Resize window
        Gui, Show, w148 h75, EXP Monitor (0.03)
        isHidden := true
    }
    WinSet, Transparent, %guiTransparency%, EXP Monitor
return

StartStop:
    if (isRunning) {
        isRunning := false
        GuiControl,, StartStopBtn, Start
        SetTimer, MonitorExp, Off
    } else {
        isRunning := true
        GuiControl,, StartStopBtn, Stop
        startTime := A_TickCount
        ; Get current exp value first
        result := ReadOCR()
        if (result != -1) {
            currentExp := result
            startExp := currentExp
        } else {
            startExp := 0
        }
        expPerHour := 0  ; Reset EXP/hr to 0 when starting
        expHourText := "0"  ; Reset stored text
        etaText := "--:--"  ; Reset ETA text
        currentExpText := Format("{:.2f}%", currentExp)  ; Format to 2 decimal places with %
        GuiControl,, ExpHourDisplay, %expHourText%
        GuiControl,, ExpDisplay, %currentExpText%
        GuiControl,, ETADisplay, %etaText%
        SetTimer, MonitorExp, 2000  ; Check every 2 seconds
    }
return

MonitorExp:
    result := ReadOCR()
    if (result != -1) {
        ; Validate the reading - filter out obviously wrong values
        isValidReading := false
        
        ; Check if reading is within reasonable bounds (0-100 for percentage)
        if (result >= 0 && result <= 100) {
            ; Check if change from last valid reading is reasonable (max 10% change)
            if (lastValidExp == 0 || Abs(result - lastValidExp) <= 10) {
                isValidReading := true
                badReadingCount := 0
            } else {
                badReadingCount++
                ; If we get multiple bad readings in a row, maybe accept larger changes
                if (badReadingCount >= 3) {
                    isValidReading := true
                    badReadingCount := 0
                }
            }
        }
        
        ; Only update if reading seems valid
        if (isValidReading) {
            ; Check for level up (when exp goes from high to low)
            if (lastValidExp > 90 && result < 10) {
                ; Level up detected - reset counters
                startTime := A_TickCount
                startExp := result
                expPerHour := 0
                expHourText := "0"
                etaText := "--:--"
                GuiControl,, ExpHourDisplay, %expHourText%
                GuiControl,, ETADisplay, %etaText%
            }
            
            currentExp := result
            lastValidExp := result
            
            ; Update the correct display based on GUI mode
            currentExpText := Format("{:.2f}%", currentExp)  ; Format to 2 decimal places with %
            if (!isHidden) {
                GuiControl,, ExpDisplay, %currentExpText%  ; Update current EXP in normal mode
            }
            
            ; Calculate EXP per hour (wait at least 30 seconds for accurate reading)
            if (startTime > 0) {
                elapsedMinutes := (A_TickCount - startTime) / 60000
                if (elapsedMinutes >= 0.5) {  ; Wait at least 30 seconds before calculating
                    expGained := currentExp - startExp
                    if (expGained > 0) {  ; Only calculate if exp has increased
                        expPerHour := Round(expGained / elapsedMinutes * 60, 2)
                        expHourText := Format("{:.2f}", expPerHour)  ; Format to 2 decimal places without 000%
                        GuiControl,, ExpHourDisplay, %expHourText%
                        
                        ; Calculate ETA to level (assuming 100% is level)
                        if (expPerHour > 0) {
                            remainingExp := 100 - currentExp
                            hoursToLevel := remainingExp / expPerHour
                            minutesToLevel := hoursToLevel * 60
                            
                            ; Format as HH:MM
                            hours := Floor(minutesToLevel / 60)
                            minutes := Round(Mod(minutesToLevel, 60))
                            etaText := Format("{:02d}:{:02d}", hours, minutes)
                            
                            ; Update ETA display if in compact mode
                            GuiControl,, ETADisplay, %etaText%
                        } else {
                            etaText := "--:--"
                            GuiControl,, ETADisplay, %etaText%
                        }
                    } else if (elapsedMinutes >= 1) {  ; After 1 minute, show 0 if no gain
                        expPerHour := 0
                        expHourText := "0"
                        etaText := "--:--"
                        GuiControl,, ExpHourDisplay, %expHourText%
                        GuiControl,, ETADisplay, %etaText%
                    }
                } else {
                    ; Show "calculating..." during first 30 seconds
                    expHourText := "Calc..."
                    etaText := "--:--"
                    GuiControl,, ExpHourDisplay, %expHourText%
                    GuiControl,, ETADisplay, %etaText%
                }
            }
        }
        ; If reading is invalid, just ignore it and keep previous values
    }
return

Exit:
    ExitApp

GuiClose:
    ExitApp

ReadOCR() {
    global regionX, regionY, regionW, regionH, ocrPath

    file := A_ScriptDir "\exp.bmp"
    outputFile := A_ScriptDir "\out"

    ; Validate region
    if (regionW <= 0 || regionH <= 0)
    {
        MsgBox, Invalid capture region: width or height <= 0
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
        MsgBox, Screenshot failed
        return -1
    }

    if !FileExist(file)
    {
        MsgBox, Screenshot not saved: %file%
        return -1
    }

    ; Run OCR with better settings for single numbers
    ocrCommand := """" ocrPath """ """ file """ """ outputFile """ --oem 3 --psm 8 -c tessedit_char_whitelist=0123456789."
    
    RunWait, % ocrCommand,, Hide
    
    ; Check if output file was created
    if (!FileExist(outputFile ".txt")) {
        MsgBox, OCR output file not created: %outputFile%.txt
        return -1
    }
    
    FileRead, result, % outputFile ".txt"
    
    ; Clean up the result - extract only numbers and decimal points
    result := RegExReplace(result, "[^\d\.]", "")
    
    if (!result) {
        ;MsgBox, No numeric data found in OCR result
        return -1
    }

    return result + 0.0
}

; Function to let user select a region on screen
SetCaptureRegion() {
    global regionX, regionY, regionW, regionH
    
    ; Inform the user
    MsgBox, 0, Set Capture Region, Click and drag to select the EXP percentage.
    
    ; Create selection GUI
    Gui, 2:New, +AlwaysOnTop -Caption +ToolWindow +Border, Selection
    Gui, 2:Color, Red
    
    ; Wait for mouse button down
    CoordMode, Mouse, Screen
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
    
    MsgBox, Region set to: x=%regionX%, y=%regionY%, w=%regionW%, h=%regionH%
}

; Screenshot function using FindText
Screenshot(filename, x1, y1, x2, y2) {
    ; Calculate width and height
    w := x2 - x1
    h := y2 - y1
    
    ; Debug coordinates (comment out when working)
    ; MsgBox, Debug: x1=%x1%, y1=%y1%, x2=%x2%, y2=%y2%`nw=%w%, h=%h%
    
    ; Validate coordinates
    if (w <= 0 || h <= 0) {
        MsgBox, Invalid coordinates: w=%w%, h=%h%
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
    
    MsgBox, Failed to save screenshot - file not created: %filename%
    return false
}

; Save settings to INI file
SaveSettings() {
    global regionX, regionY, regionW, regionH, guiTransparency, settingsFile
    
    IniWrite, %regionX%, %settingsFile%, Region, X
    IniWrite, %regionY%, %settingsFile%, Region, Y
    IniWrite, %regionW%, %settingsFile%, Region, W
    IniWrite, %regionH%, %settingsFile%, Region, H
    IniWrite, %guiTransparency%, %settingsFile%, GUI, Transparency
}

; Load settings from INI file
LoadSettings() {
    global regionX, regionY, regionW, regionH, guiTransparency, settingsFile
    
    IniRead, regionX, %settingsFile%, Region, X, %regionX%
    IniRead, regionY, %settingsFile%, Region, Y, %regionY%
    IniRead, regionW, %settingsFile%, Region, W, %regionW%
    IniRead, regionH, %settingsFile%, Region, H, %regionH%
    IniRead, guiTransparency, %settingsFile%, GUI, Transparency, %guiTransparency%
    
    ; Ensure transparency is within valid range
    if (guiTransparency < 10)
        guiTransparency := 10
    if (guiTransparency > 255)
        guiTransparency := 255
}
