#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

; Check if Tesseract OCR is installed
MsgBox, 4, Tesseract OCR Check, Is Tesseract OCR already installed on your system?`n`nThis script requires Tesseract OCR to function properly.
IfMsgBox No
{
    ; Check if tesocr.exe exists in script directory
    if FileExist(A_ScriptDir "\tesocr.exe")
    {
        MsgBox, 0, Installing Tesseract OCR, Running Tesseract OCR installer...`n`nPlease complete the installation, then restart this script.
        Run, %A_ScriptDir%\tesocr.exe
        ExitApp
    }
    else
    {
        MsgBox, 16, Error, tesocr.exe not found in script directory!`n`nPlease download and install Tesseract OCR manually, then restart this script.
        ExitApp
    }
}

#include findtext2.ahk

statPatterns := {}
statPatterns["VIT"] :="|<>*89$34.TKzvPxxvzjjvh6CoCiqrPOuvPxhhRRi6qppqrPPLjPNhiyxaKqPzzzzzjzzzzxs"
statPatterns["AGI"] :="|<Gambit>**50$27.07zs40hh0bzjixZhcJvBhffRhhfOhhhHRhhefBhipZhgozjzyV300gDk074"
statPatterns["STR"] :="|<Gambit>**50$35.0000TU0000h3zrtzPpMuSIItinPBarRirPRe3JeqfJyfRhKfhKnOhMuiKJSTRzjvU00Ek0000z01"
statPatterns["INT"] := "|<Gambit>**50$14.s3e0ezvhAPBirOhKfJepPhKTry"
statPatterns["WIS"] :="|<Gambit>**50$47.tns0C001KpE0I002evjbfvzpphltQRAxfPRgrNaeuqzRerRJJiCfJeeefThKfJJhirPhqedFJlsQRJHXiyTjivk"
statPatterns["DEX"] := "|<Gambit>**50$47.zU0701y11U0+02o2xjxrxzixBli6Ce5O/RfPgqioKvKrPhfcg7RUpPJHPxPTeqexrOqvJio6liaCfBDszrzrTu0000000g0000001l"
statPatterns["CRITPOWER"] := "|<Gambit>**50$38.c5qqzvODJhckqqpPPvhrRKqqnKBJZnmoyRzrbz000000000000000000000000000000000000000000003y00000Uk0000/pzizrmZlef7IjPfiin8CfJPhWyepK3Ec+hJjo+2vivh2Ulef7G"
statPatterns["CRITRATE"] :="|<Gambit>**50$41.kDlzU70kKW1U+2zxZxTrypF+/X67aqLqvPVRcUTqrSfFRgBVhKWhLPSuhZ/gqvJN+PZaAvyQRzzk"
statPatterns["atkspd"] :="|<>*89$33.zzzzzzPzVzzvTvrzy/jSowvPvyPPOzVrPP7zqvPPTSrPfPvqPR/jVowzzzyzzzzzrzU"
statPatterns["accuracy"] :="|<>*89$48.vzzzzzzzpzzzzzzzpttrOltipqqrNiqiirrrPyrpUrrrPkrpirrrPirpTKqrPgqvTNtsPmtvzzzzzzzvzzzzzzzrU"
statPatterns["MAcc"] :="|<>*89$33.zzzzzxxzrzzbDxTzwtzfnnejxRhhJzRjjejsBxxJzRjjhjrphhhiynnzzzzzw"
statPatterns["evasion"] :="|<>*89$37.TzzxzzzzzzzzxqD7QRCuvRhqNfxjqvRpksvRiurThirSvBqrPbSL7QRo"
statPatterns["movspd"] :="|<>*89$44.TTzzVzzXbzzrjzstlixvHmJPfjTnP5KvLsRqtJipzvRiJPhTSrPaqvjrgqthlvy7Hkzzzzzrzzzzzzxzy"
statPatterns["magicresist"] :="|<>*89$39.zTz0zzzzzvvzz/QzTQSCPPvvRivPz0vhzPTvj1lvPzSvzqPPvrRi/QzTQSDTzzzzz7zzzzzw"
statPatterns["mdef"] :="|<>*89$33.TTsDzlnzSzxCTvvX2fzTPhJTvvRefzTMBJTvvTfPzSvhPPsDXg"
statPatterns["castspd"] :="|<>*89$49.lzzyz3zzLTzzTSzzbr7X7jOSHzRirrwqlzyrvwCvQzsQRzvRiTPjqyxirLRavTSnPgT/XbkuS7zzzzzxzzzzzzzyzz"
statPatterns["pdef"] :="|<>*89$31.1z1zyDTjTyrjrr6/rvvRg7xxiqzyykPTzTPxjzjRqrrkT7Q"

statPatternsarrayforfindtext :="|<>*89$34.TKzvPxxvzjjvh6CoCiqrPOuvPxhhRRi6qppqrPPLjPNhiyxaKqPzzzzzjzzzzxs"
statPatternsarrayforfindtext .="|<Gambit>**50$27.07zs40hh0bzjixZhcJvBhffRhhfOhhhHRhhefBhipZhgozjzyV300gDk074"
statPatternsarrayforfindtext .="|<Gambit>**50$35.0000TU0000h3zrtzPpMuSIItinPBarRirPRe3JeqfJyfRhKfhKnOhMuiKJSTRzjvU00Ek0000z01"
statPatternsarrayforfindtext .= "|<Gambit>**50$14.s3e0ezvhAPBirOhKfJepPhKTry"
statPatternsarrayforfindtext .="|<Gambit>**50$47.tns0C001KpE0I002evjbfvzpphltQRAxfPRgrNaeuqzRerRJJiCfJeeefThKfJJhirPhqedFJlsQRJHXiyTjivk"
statPatternsarrayforfindtext .= "|<Gambit>**50$47.zU0701y11U0+02o2xjxrxzixBli6Ce5O/RfPgqioKvKrPhfcg7RUpPJHPxPTeqexrOqvJio6liaCfBDszrzrTu0000000g0000001l"
statPatternsarrayforfindtext .= "|<Gambit>**50$38.c5qqzvODJhckqqpPPvhrRKqqnKBJZnmoyRzrbz000000000000000000000000000000000000000000003y00000Uk0000/pzizrmZlef7IjPfiin8CfJPhWyepK3Ec+hJjo+2vivh2Ulef7G"
statPatternsarrayforfindtext .="|<Gambit>**50$41.kDlzU70kKW1U+2zxZxTrypF+/X67aqLqvPVRcUTqrSfFRgBVhKWhLPSuhZ/gqvJN+PZaAvyQRzzk"
statPatternsarrayforfindtext .="|<>*89$33.zzzzzzPzVzzvTvrzy/jSowvPvyPPOzVrPP7zqvPPTSrPfPvqPR/jVowzzzyzzzzzrzU"
statPatternsarrayforfindtext .="|<>*89$48.vzzzzzzzpzzzzzzzpttrOltipqqrNiqiirrrPyrpUrrrPkrpirrrPirpTKqrPgqvTNtsPmtvzzzzzzzvzzzzzzzrU"
statPatternsarrayforfindtext .="|<>*89$33.zzzzzxxzrzzbDxTzwtzfnnejxRhhJzRjjejsBxxJzRjjhjrphhhiynnzzzzzw"
statPatternsarrayforfindtext .="|<>*89$37.TzzxzzzzzzzzxqD7QRCuvRhqNfxjqvRpksvRiurThirSvBqrPbSL7QRo"
statPatternsarrayforfindtext .="|<>*89$44.TTzzVzzXbzzrjzstlixvHmJPfjTnP5KvLsRqtJipzvRiJPhTSrPaqvjrgqthlvy7Hkzzzzzrzzzzzzxzy"
statPatternsarrayforfindtext .="|<>*89$39.zTz0zzzzzvvzz/QzTQSCPPvvRivPz0vhzPTvj1lvPzSvzqPPvrRi/QzTQSDTzzzzz7zzzzzw"
statPatternsarrayforfindtext .="|<>*89$33.TTsDzlnzSzxCTvvX2fzTPhJTvvRefzTMBJTvvTfPzSvhPPsDXg"
statPatternsarrayforfindtext .="|<>*89$49.lzzyz3zzLTzzTSzzbr7X7jOSHzRirrwqlzyrvwCvQzsQRzvRiTPjqyxirLRavTSnPgT/XbkuS7zzzzzxzzzzzzzyzz"
statPatternsarrayforfindtext .="|<>*89$31.1z1zyDTjTyrjrr6/rvvRg7xxiqzyykPTzTPxjzjRqrrkT7Q"

numbers := "|<0>8DC63F@0.96$7.C8cA631UkMA54QU|<1>**50$6.7BNphx55555557U|<2>*79$9.zz3rRxzjxzTvyzjvyzUDzU|<3>8DC63F@0.96$7.C8cE88Q10EA74QU|<4>*75$9.zzrwzLuyrqxrSs1yzryzzU|<5>*73$9.zy1ryzjw7jTxzjxjivszzU|<6>*88$9.zz7rBxjx7bRxjhxjivszzU|<7>*90$9.zw1zTvyzrxzjxzjvzTvzzU|<8>*84$9.zz7rRxjivsyvjhxjivszzU|<9>8DC63F@0.96$7.C8cA631FbEA54wU"
FindText().PicLib(numbers, 1)

global iniFile := "Awakeningsettings.ini"
global searchAreaX1 := 0
global searchAreaY1 := 0
global searchAreaX2 := 0
global searchAreaY2 := 0
global searchAreaSet := false
global statThresholds := {}
global statValues := {}
global guiTransparency := 255
global inventoryX1 := 0
global inventoryY1 := 0
global inventoryX2 := 0
global inventoryY2 := 0
global inventoryAreaSet := false
global win1 := ""
global awakeningPaused := false
global awakeningRunning := false

LoadSettings()
CreateGUI()
return

LoadSettings() {
    global
    IniRead, searchAreaX1, %iniFile%, SearchArea, X1, 0
    IniRead, searchAreaY1, %iniFile%, SearchArea, Y1, 0
    IniRead, searchAreaX2, %iniFile%, SearchArea, X2, 0
    IniRead, searchAreaY2, %iniFile%, SearchArea, Y2, 0
    IniRead, inventoryX1, %iniFile%, InventoryArea, X1, 0
    IniRead, inventoryY1, %iniFile%, InventoryArea, Y1, 0
    IniRead, inventoryX2, %iniFile%, InventoryArea, X2, 0
    IniRead, inventoryY2, %iniFile%, InventoryArea, Y2, 0
    IniRead, win1, %iniFile%, Window, ID, 
    IniRead, guiTransparency, %iniFile%, GUI, Transparency, 255
    
    if (searchAreaX1 != 0 || searchAreaY1 != 0 || searchAreaX2 != 0 || searchAreaY2 != 0)
        searchAreaSet := true
    if (inventoryX1 != 0 || inventoryY1 != 0 || inventoryX2 != 0 || inventoryY2 != 0)
        inventoryAreaSet := true
    
    for statName in statPatterns {
        IniRead, threshold, %iniFile%, Thresholds, %statName%, 
        if (threshold != "ERROR")
            statThresholds[statName] := threshold
    }
}

SaveSettings() {
    global
    IniWrite, %searchAreaX1%, %iniFile%, SearchArea, X1
    IniWrite, %searchAreaY1%, %iniFile%, SearchArea, Y1
    IniWrite, %searchAreaX2%, %iniFile%, SearchArea, X2
    IniWrite, %searchAreaY2%, %iniFile%, SearchArea, Y2
    IniWrite, %inventoryX1%, %iniFile%, InventoryArea, X1
    IniWrite, %inventoryY1%, %iniFile%, InventoryArea, Y1
    IniWrite, %inventoryX2%, %iniFile%, InventoryArea, X2
    IniWrite, %inventoryY2%, %iniFile%, InventoryArea, Y2
    IniWrite, %win1%, %iniFile%, Window, ID
    IniWrite, %guiTransparency%, %iniFile%, GUI, Transparency
    
    for statName, threshold in statThresholds {
        if (threshold != "")
            IniWrite, %threshold%, %iniFile%, Thresholds, %statName%
    }
}

GetStatDisplayName(statName) {
    if (statName = "VIT")
        return "Vitality"
    else if (statName = "AGI")
        return "Agility"
    else if (statName = "STR")
        return "Strength"
    else if (statName = "INT")
        return "Intelligence"
    else if (statName = "WIS")
        return "Wisdom"
    else if (statName = "DEX")
        return "Dexterity"
    else if (statName = "CRITPOWER")
        return "Crit Power"
    else if (statName = "CRITRATE")
        return "Crit Rate"
    else if (statName = "atkspd")
        return "Attack Speed"
    else if (statName = "accuracy")
        return "Accuracy"
    else if (statName = "MAcc")
        return "Magic Acc"
    else if (statName = "evasion")
        return "Evasion"
    else if (statName = "movspd")
        return "Move Speed"
    else if (statName = "magicresist")
        return "Magic Resist"
    else if (statName = "mdef")
        return "Magic Def"
    else if (statName = "castspd")
        return "Cast Speed"
    else if (statName = "pdef")
        return "Physical Def"
    else
        return statName
}

CreateGUI() {
    global
    Gui, Color, Black
    Gui, Add, Text, x10 y10 w90 h15 cWhite, Stat
    Gui, Add, Text, x105 y10 w40 h15 cWhite, Min
    Gui, Add, Text, x150 y10 w60 h15 cWhite, Found
    Gui, Add, Text, x230 y10 w120 h15 cWhite, Accessory Awakening
    
    yPos := 30
    for statName in statPatterns {
        displayName := GetStatDisplayName(statName)
        Gui, Add, Text, x10 y%yPos% w90 h20 v%statName%Label cWhite, %displayName%
        Gui, Add, Edit, x105 y%yPos% w40 h20 v%statName%Threshold gThresholdChange
        Gui, Add, Text, x150 y%yPos% w60 h20 v%statName%Value cGreen, -
        
        if (statThresholds[statName] != "")
            GuiControl,, %statName%Threshold, % statThresholds[statName]
        
        yPos += 25
    }
    
    ; Add accessory awakening buttons in right column
    rightColY := 30
    Gui, Add, Button, x230 y%rightColY% w120 h25 gStartAccessoryAwaken, Start Accessory Awakening
    rightColY += 30
    Gui, Add, Button, x230 y%rightColY% w120 h25 gSetInventoryArea, Set Inventory Area
    rightColY += 30
    Gui, Add, Button, x230 y%rightColY% w120 h25 gAssignWindow, Assign Window
    rightColY += 30
    Gui, Add, Button, x230 y%rightColY% w55 h25 gPauseAwakening, Pause
    Gui, Add, Button, x295 y%rightColY% w55 h25 gPlayAwakening, Play
    
    Gui, Add, Text, x10 y%yPos% w340 h15 Center vAreaStatus cWhite, % searchAreaSet ? "Area: Set" : "Area: Not Set"
    yPos += 20
    Gui, Add, Button, x10 y%yPos% w35 h25 gSaveThresholds, Save
    Gui, Add, Button, x50 y%yPos% w35 h25 gLoadThresholds, Load
    Gui, Add, Button, x90 y%yPos% w35 h25 gResetThresholds, Reset
    Gui, Add, Button, x130 y%yPos% w40 h25 gSetSearchArea, Area
    Gui, Add, Button, x175 y%yPos% w35 h25 gClearSearchArea, Clear
    Gui, Add, Button, x215 y%yPos% w35 h25 gTestSearch, Test
    Gui, Add, Button, x255 y%yPos% w35 h25 gExitScript, Exit
    
    yPos += 30
    Gui, Add, Text, x10 y%yPos% w65 h20 cWhite, Transparency:
    Gui, Add, Slider, x85 y%yPos% w100 h20 vTransparencySlider gTransparencyChange Range50-255 TickInterval50, %guiTransparency%
    Gui, Add, Text, x190 y%yPos% w30 h20 vTransparencyText cWhite, %guiTransparency%
    
    guiHeight := yPos + 35
    Gui, +AlwaysOnTop -Caption
    Gui, Show, w360 h%guiHeight% y200, Stat Scanner
    WinSet, Transparent, %guiTransparency%, Stat Scanner
    ; Enable dragging the window from anywhere
OnMessage(0x201, "WM_LBUTTONDOWN")
return


}
; Function to allow dragging the window from anywhere
WM_LBUTTONDOWN() {
    PostMessage, 0xA1, 2
    return
}
ThresholdChange:
    Gui, Submit, NoHide
    ; Update all threshold values from GUI controls
    for statName in statPatterns {
        GuiControlGet, value,, %statName%Threshold
        statThresholds[statName] := value
    }
    SaveSettings()  ; Auto-save when threshold changes
return

SaveThresholds:
    for statName in statPatterns {
        GuiControlGet, value,, %statName%Threshold
        statThresholds[statName] := value
    }
    SaveSettings()
    ToolTip, Thresholds Saved!
    SetTimer, RemoveToolTip, 1000
return

LoadThresholds:
    LoadSettings()
    for statName in statPatterns {
        GuiControl,, %statName%Threshold, % statThresholds[statName]
    }
    ToolTip, Thresholds Loaded!
    SetTimer, RemoveToolTip, 1000
return

ResetThresholds:
    for statName in statPatterns {
        GuiControl,, %statName%Threshold,
        statThresholds[statName] := ""
    }
    ToolTip, Thresholds Reset!
    SetTimer, RemoveToolTip, 1000
return

TransparencyChange:
    Gui, Submit, NoHide
    guiTransparency := TransparencySlider
    GuiControl,, TransparencyText, %guiTransparency%
    WinSet, Transparent, %guiTransparency%, Stat Scanner
    SaveSettings()
return

ExitScript:
    SaveSettings()
    ExitApp
return

GuiClose:
    SaveSettings()
    ExitApp

SetSearchArea:
    Gui, Hide
    MsgBox, 4,, Click OK then drag to select search area
    IfMsgBox, Yes
    {
        Gui, 2:New, +AlwaysOnTop -Caption +ToolWindow +Border, Selection
        Gui, 2:Color, Red
        
        CoordMode, Mouse, Screen
        KeyWait, LButton, U
        KeyWait, LButton, D
        MouseGetPos, searchAreaX1, searchAreaY1
        
        Gui, 2:Show, x%searchAreaX1% y%searchAreaY1% w1 h1
        WinSet, Transparent, 128, Selection
        
        while GetKeyState("LButton", "P") {
            MouseGetPos, currentX, currentY
            boxX := searchAreaX1 < currentX ? searchAreaX1 : currentX
            boxY := searchAreaY1 < currentY ? searchAreaY1 : currentY
            boxW := Abs(currentX - searchAreaX1)
            boxH := Abs(currentY - searchAreaY1)
            Gui, 2:Show, x%boxX% y%boxY% w%boxW% h%boxH%
            Sleep, 10
        }
        
        MouseGetPos, searchAreaX2, searchAreaY2
        Gui, 2:Destroy
        
        if (searchAreaX1 > searchAreaX2) {
            temp := searchAreaX1
            searchAreaX1 := searchAreaX2
            searchAreaX2 := temp
        }
        if (searchAreaY1 > searchAreaY2) {
            temp := searchAreaY1
            searchAreaY1 := searchAreaY2
            searchAreaY2 := temp
        }
        
        searchAreaSet := true
        GuiControl,, AreaStatus, Area: Set
        SaveSettings()
    }
    Gui, 1:Show,, Stat Scanner
    WinSet, AlwaysOnTop, On, Stat Scanner
return

ClearSearchArea:
    searchAreaSet := false
    searchAreaX1 := 0
    searchAreaY1 := 0
    searchAreaX2 := 0
    searchAreaY2 := 0
    GuiControl,, AreaStatus, Area: Not Set
    SaveSettings()
return

TestSearch:
    UpdateStats()
return

UpdateStats() {
    global
    if (searchAreaSet) {
        searchX1 := searchAreaX1
        searchY1 := searchAreaY1
        searchX2 := searchAreaX2
        searchY2 := searchAreaY2
    } else {
        searchX1 := 0
        searchY1 := 0
        searchX2 := A_ScreenWidth
        searchY2 := A_ScreenHeight
    }
    
    results := {}
    
    ; Take screenshot once and reuse it
    if (ok := FindText(X, Y, searchX1, searchY1, searchX2, searchY2, 1, 0, statPatternsarrayforfindtext)) {
        if (ok.Length() >= 5) {
            foundStats := {}
            
            for statName, pattern in statPatterns {
                if (statOk := FindText(X, Y, searchX1, searchY1, searchX2, searchY2, 0, 0, pattern, 0)) {
                    foundStats[statName] := []
                    while (statOk.Length()) {
                        foundStats[statName].Push({x: statOk[1].x, y: statOk[1].y})
                        statOk.RemoveAt(1)
                    }
                }
            }
            
            for statName, locations in foundStats {
                statValues := []
                
                for index, location in locations {
                    X := location.x
                    Y := location.y
                    
                    if (statName = "STR") {
                        searchX1 := X - 70
                        searchY1 := Y + 28
                        searchX2 := X + 50  
                        searchY2 := Y + 52
                    } else if (statName = "VIT") {
                        searchX1 := X - 60
                        searchY1 := Y + 25
                        searchX2 := X + 60  
                        searchY2 := Y + 55
                    } else if (statName = "accuracy") {
                        searchX1 := X - 55
                        searchY1 := Y + 28
                        searchX2 := X + 55  
                        searchY2 := Y + 52
                    } else if (statName = "movspd") {
                        searchX1 := X - 65
                        searchY1 := Y + 26
                        searchX2 := X + 45  
                        searchY2 := Y + 54
                    } else if (statName = "AGI") {
                        searchX1 := X - 55
                        searchY1 := Y + 27
                        searchX2 := X + 55  
                        searchY2 := Y + 53
                    } else {
                        searchX1 := X - 50
                        searchY1 := Y + 30
                        searchX2 := X + 50  
                        searchY2 := Y + 50
                    }
                    
                    if (digitOk := FindText(NumX, NumY, searchX1, searchY1, searchX2, searchY2, 0, 0, FindText().PicN("0123456789"), 0)) {
                        if (ocr := FindText().OCR(digitOk, 5, 5)) {
                            cleanValue := RegExReplace(ocr.text, "[^0-9]", "")
                            if (cleanValue != "" && StrLen(cleanValue) <= 3) {
                                statValues.Push(cleanValue + 0)
                            }
                        }
                    }
                }
                
                if (statValues.Length() > 0) {
                    total := 0
                    for index, value in statValues {
                        total += value
                    }
                    results[statName] := total
                }
            }
        }
    }
    
    ; Update GUI with found values only if patterns were found
    if (ok && ok.Length() >= 5) {
        for statName in statPatterns {
            foundValue := results[statName] ? results[statName] : "-"
            GuiControl,, %statName%Value, %foundValue%
        }
    }
}



RemoveToolTip:
    ToolTip
    SetTimer, RemoveToolTip, Off
return

RemoveDebugTip:
    ToolTip
    SetTimer, RemoveDebugTip, Off
return

SetInventoryArea:
    Gui, Hide
    MsgBox, 4,, Click OK then drag to select inventory area
    IfMsgBox, Yes
    {
        Gui, 2:New, +AlwaysOnTop -Caption +ToolWindow +Border, Selection
        Gui, 2:Color, Blue
        
        CoordMode, Mouse, Screen
        KeyWait, LButton, U
        KeyWait, LButton, D
        MouseGetPos, inventoryX1, inventoryY1
        
        Gui, 2:Show, x%inventoryX1% y%inventoryY1% w1 h1
        WinSet, Transparent, 128, Selection
        
        while GetKeyState("LButton", "P") {
            MouseGetPos, currentX, currentY
            boxX := inventoryX1 < currentX ? inventoryX1 : currentX
            boxY := inventoryY1 < currentY ? inventoryY1 : currentY
            boxW := Abs(currentX - inventoryX1)
            boxH := Abs(currentY - inventoryY1)
            Gui, 2:Show, x%boxX% y%boxY% w%boxW% h%boxH%
            Sleep, 10
        }
        
        MouseGetPos, inventoryX2, inventoryY2
        Gui, 2:Destroy
        
        if (inventoryX1 > inventoryX2) {
            temp := inventoryX1
            inventoryX1 := inventoryX2
            inventoryX2 := temp
        }
        if (inventoryY1 > inventoryY2) {
            temp := inventoryY1
            inventoryY1 := inventoryY2
            inventoryY2 := temp
        }
        
        inventoryAreaSet := true
        SaveSettings()
        ToolTip, Inventory Area Set!
        SetTimer, RemoveToolTip, 1000
    }
    Gui, 1:Show,, Stat Scanner
return

AssignWindow:
    MsgBox, Right click on the game window to assign it
    KeyWait, RButton, D
    MouseGetPos,,, win1
    WinGetTitle, title, ahk_id %win1%
    SaveSettings()
    ToolTip, Window Assigned: %title%
    SetTimer, RemoveToolTip, 2000
return

PauseAwakening:
    awakeningPaused := true
return

PlayAwakening:
    awakeningPaused := false
return

StartAccessoryAwaken:
    if (!inventoryAreaSet) {
        MsgBox, Please set inventory area first!
        return
    }
    if (win1 = "") {
        MsgBox, Please assign window first!
        return
    }
    
    awakeningRunning := true
    awakeningPaused := false
    
    WinActivate, ahk_id %win1%
    Sleep, 1000
    
    Loop {
        if (!awakeningRunning)
            break
            
        while (awakeningPaused && awakeningRunning) {
            Sleep, 100
        }
        
        if (!awakeningRunning)
            break
        
        accessoryscroll := "|<>*103$26.lzw3zzw0jzw03zw00Tw007w0E1w0TUw0MC7EA1wk00Til3nHgFywt4TST1rzXowxsU"
        accessoryscroll .= "|<>*120$23.w0zz0Dzu1zyaTzkTzw1zzU0zw01zU03w0E7U3w8"
        accessoryscroll .= "|<>*112$26.zU1zzk3zzU3zxM7zsL7zkDzzk2zzk08"
        
        if (ok := FindText(X, Y, inventoryX1, inventoryY1, inventoryX2, inventoryY2, 0, 0, accessoryscroll)) {
            FindText().Click(X, Y, "L")
            Sleep, 50
            FindText().Click(X, Y, "L")
            Sleep, 100
            ControlSend,, {space}, ahk_id %win1%
            Sleep, 1500
        } else {
            continue
        }
        
        accessorystone := "|<>*101$26.zzzzzzzzzzxzzyyBzzU2TzsRhzsD2jw1s9z0Q3D072kl1koQ0CTr01bxq3NyBVyTXTzbszbsyD/S7X1aVks"
        accessorystone .= "|<>*124$23.wFsDsnUPU72r8D6s"
        accessorystone .= "|<>*110$26.zzrzzvsrzy09zzVqrzUw+zk7Ubw1kAs"
        
        if (ok := FindText(X, Y, inventoryX1, inventoryY1, inventoryX2, inventoryY2, 0, 0, accessorystone)) {
            FindText().Click(X, Y, "L")
            Sleep, 50
            FindText().Click(X, Y, "L")
            Sleep, 100
            ControlSend,, {space}, ahk_id %win1%
            Sleep, 3000
            
            UpdateStats()
        } else {
            continue
        }
        
        ; Check if any stats meet thresholds using the values just found
        statsFound := false
        for statName, threshold in statThresholds {
            ; Skip this stat if threshold is blank or empty
            if (threshold = "" || threshold = 0)
                continue
                
            GuiControlGet, foundValue,, %statName%Value
            if (foundValue != "-" && foundValue >= threshold) {
                statsFound := true
                break
            }
        }
        
        if (statsFound) {
            awakeningRunning := false
            awakeningPaused := true
            SoundBeep, 500
            MsgBox, Stats meeting requirements found! Awakening paused.
            break
        }
        
        Loop {
            if (!awakeningRunning)
                break
                
            if (searchAreaSet) {
                if (ok := FindText(X, Y, searchAreaX1, searchAreaY1, searchAreaX2, searchAreaY2, 0, 0, statPatternsarrayforfindtext)) {
                    if (ok.Length() < 5) {
                        break
                    }
                } else {
                    break
                }
            } else {
                break
            }
            
            Sleep, 500
        }
    }
return

f4::reload