#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
#include findtext2.ahk
global AccountData := []
global SettingsFile := A_ScriptDir . "\accounts.ini"
global ThumbnailData := []  ; Store thumbnail info for each client
global thumbnailIsOpen := false
global thumbnailGuiHandle := 0
global UpdateURL := "https://raw.githubusercontent.com/Joshmccoy14/new-repo/main/"
BaseDir := A_ScriptDir

LoadAccounts()
DetectExistingClients()
ShowMainGui()
Return

DetectExistingClients() {
    global win1, win2, win3, win4, win5, win6, win7, win8
    
    ; Initialize all to empty
    win1 := ""
    win2 := ""
    win3 := ""
    win4 := ""
    win5 := ""
    win6 := ""
    win7 := ""
    win8 := ""
    
    ; Search for existing windows with titles win1-win8
    Loop, 8 {
        windowTitle := "win" . A_Index
        if (WinExist(windowTitle)) {
            WinGet, winID, ID, %windowTitle%
            if (A_Index = 1)
                win1 := winID
            else if (A_Index = 2)
                win2 := winID
            else if (A_Index = 3)
                win3 := winID
            else if (A_Index = 4)
                win4 := winID
            else if (A_Index = 5)
                win5 := winID
            else if (A_Index = 6)
                win6 := winID
            else if (A_Index = 7)
                win7 := winID
            else if (A_Index = 8)
                win8 := winID
        }
    }
}

LoadAccounts() {
    global AccountData, SettingsFile
    Loop, 8 {
        IniRead, user, %SettingsFile%, Account%A_Index%, Username, Username
        IniRead, pass, %SettingsFile%, Account%A_Index%, Password, 
        IniRead, enabled, %SettingsFile%, Account%A_Index%, Enabled, 0
        IniRead, autoScript, %SettingsFile%, Account%A_Index%, AutoScript, 0
        AccountData.Push({Username: user, Password: pass, Enabled: enabled, AutoScript: autoScript})
    }
}

SaveAccounts() {
    global AccountData, SettingsFile
    Loop, 8 {
        IniWrite, % AccountData[A_Index].Username, %SettingsFile%, Account%A_Index%, Username
        IniWrite, % AccountData[A_Index].Password, %SettingsFile%, Account%A_Index%, Password
        IniWrite, % AccountData[A_Index].Enabled, %SettingsFile%, Account%A_Index%, Enabled
        IniWrite, % AccountData[A_Index].AutoScript, %SettingsFile%, Account%A_Index%, AutoScript
    }
}

ShowMainGui() {
    global LauncherPath, Check1, Check2, Check3, Check4, Check5, Check6, Check7, Check8
    global User1, User2, User3, User4, User5, User6, User7, User8
    global Pass1, Pass2, Pass3, Pass4, Pass5, Pass6, Pass7, Pass8
    global Auto1, Auto2, Auto3, Auto4, Auto5, Auto6, Auto7, Auto8
    
    Gui, Main:New
    Gui, Main:Font, s10 Bold
    Gui, Add, Text, x20 y15, Rappelz Multi-Client Launcher
    Gui, Main:Font
    
    Gui, Add, GroupBox, x10 y40 w460 h60, Launcher Settings
    Gui, Add, Text, x20 y60, Launcher Path:
    IniRead, LauncherPath, %SettingsFile%, Settings, LauncherPath, D:\Games\Rappelz_Gambit\_launcher.exe
    Gui, Add, Edit, x110 y57 w280 vLauncherPath, %LauncherPath%
    Gui, Add, Button, x400 y56 w60 gBrowseLauncher, Browse
    
    Gui, Add, GroupBox, x10 y110 w460 h280, Account Configuration
    Gui, Main:Font, s8 Bold
    Gui, Add, Text, x25 y130, Launch
    Gui, Add, Text, x75 y130, Window
    Gui, Add, Text, x140 y130, Username
    Gui, Add, Text, x270 y130, Password
    Gui, Add, Text, x400 y130, Nexus
    Gui, Main:Font
    
    yPos := 150
    Loop, 8 {
        checked := AccountData[A_Index].Enabled ? "Checked" : ""
        autoChecked := AccountData[A_Index].AutoScript ? "Checked" : ""
        winLabel := "win" . A_Index
        Gui, Add, Checkbox, x30 y%yPos% vCheck%A_Index% %checked%
        Gui, Add, Text, x80 y%yPos% w40, %winLabel%
        Gui, Add, Edit, x130 y%yPos% w120 vUser%A_Index%, % AccountData[A_Index].Username
        Gui, Add, Edit, x260 y%yPos% w120 vPass%A_Index% Password, % AccountData[A_Index].Password
        Gui, Add, Checkbox, x405 y%yPos% vAuto%A_Index% %autoChecked%
        yPos += 30
    }
    
    Gui, Add, GroupBox, x10 y400 w460 h110, Actions
    Gui, Add, Button, x20 y420 w135 h25 gSaveSettings, Save Settings
    Gui, Add, Button, x165 y420 w135 h25 gLaunchClients, Launch Clients
    Gui, Add, Button, x310 y420 w150 h25 gKillAll, Kill All Clients
    Gui, Add, Button, x310 y450 w150 h25 gCheckForUpdates, Check for Updates
    Gui, Add, Button, x20 y450 w135 h25 gShowThumbnailView, Show Thumbnail View
    Gui, Add, Button, x165 y450 w135 h25 gStartNexus, Start Nexus
    
    Gui, Show, w480 h525, Rappelz Multi-Client Launcher
}

BrowseLauncher:
FileSelectFile, SelectedFile, 3, , Select Launcher, Executable (*.exe)
if (SelectedFile != "")
    GuiControl,, LauncherPath, %SelectedFile%
Return

SaveSettings:
Gui, Submit, NoHide
IniWrite, %LauncherPath%, %SettingsFile%, Settings, LauncherPath
Loop, 8 {
    GuiControlGet, checked,, Check%A_Index%
    GuiControlGet, user,, User%A_Index%
    GuiControlGet, pass,, Pass%A_Index%
    GuiControlGet, autoScript,, Auto%A_Index%
    AccountData[A_Index].Username := user
    AccountData[A_Index].Password := pass
    AccountData[A_Index].Enabled := checked
    AccountData[A_Index].AutoScript := autoScript
}
SaveAccounts()
MsgBox, Settings saved!
Return

LaunchClients:
Gui, Submit, NoHide
IniWrite, %LauncherPath%, %SettingsFile%, Settings, LauncherPath

selectedCount := 0
Loop, 8 {
    GuiControlGet, checked,, Check%A_Index%
    GuiControlGet, user,, User%A_Index%
    GuiControlGet, pass,, Pass%A_Index%
    GuiControlGet, autoScript,, Auto%A_Index%
    AccountData[A_Index].Username := user
    AccountData[A_Index].Password := pass
    AccountData[A_Index].Enabled := checked
    AccountData[A_Index].AutoScript := autoScript
    if (checked)
        selectedCount++
}

if (selectedCount = 0) {
    MsgBox, Please select at least one account
    Return
}

SaveAccounts()
Gui, Destroy

selectedAccounts := []
Loop, 8 {
    if (AccountData[A_Index].Enabled)
        selectedAccounts.Push(A_Index)
}

existingClients := []
WinGet, existingId, List, ahk_exe sframe.exe
Loop, %existingId% {
    existingClients.Push(existingId%A_Index%)
}

Loop, %selectedCount% {
    Run, "%LauncherPath%"
    Sleep, 5000
    
    Loop, 3 {
        ControlClick, x969 y714, ahk_class #32770
        Sleep, 500
    }
    
    WinWaitClose, ahk_class #32770, , 10
}

timeoutStart := A_TickCount
newClients := []
Loop {
    WinGet, id, List, ahk_exe sframe.exe
    newClients := []
    Loop, %id% {
        winID := id%A_Index%
        isExisting := false
        for idx, existingWin in existingClients {
            if (existingWin = winID) {
                isExisting := true
                break
            }
        }
        if (!isExisting)
            newClients.Push(winID)
    }
    
    if (newClients.MaxIndex() >= selectedCount)
        break
    
    if (A_TickCount - timeoutStart > 180000) {
        foundCount := newClients.MaxIndex()
        MsgBox, Timeout! Only found %foundCount% of %selectedCount% new clients
        ShowMainGui()
        Return
    }
    Sleep, 500
}

Sleep, 3000

newClientCount := newClients.MaxIndex()
if (newClientCount < selectedCount) {
    MsgBox, Error: Expected %selectedCount% new clients but only found %newClientCount%
    ShowMainGui()
    Return
}

Loop, %selectedCount% {
    accountNum := selectedAccounts[A_Index]
    winID := newClients[A_Index]
    
    if (!winID) {
        MsgBox, Error: Failed to get window ID for account %accountNum%
        ShowMainGui()
        Return
    }
    
    if (accountNum = 1)
        win1 := winID
    else if (accountNum = 2)
        win2 := winID
    else if (accountNum = 3)
        win3 := winID
    else if (accountNum = 4)
        win4 := winID
    else if (accountNum = 5)
        win5 := winID
    else if (accountNum = 6)
        win6 := winID
    else if (accountNum = 7)
        win7 := winID
    else if (accountNum = 8)
        win8 := winID
}

Loop, %selectedCount% {
    accountNum := selectedAccounts[A_Index]
    
    if (accountNum = 1) {
        WinSetTitle, ahk_id %win1%, , win1
        WinMove, ahk_id %win1%, , 0, 0
        Loop, 3
            ControlSend, , {Escape}, ahk_id %win1%
    }
    else if (accountNum = 2) {
        WinSetTitle, ahk_id %win2%, , win2
        WinMove, ahk_id %win2%, , 0, 0
        Loop, 3
            ControlSend, , {Escape}, ahk_id %win2%
    }
    else if (accountNum = 3) {
        WinSetTitle, ahk_id %win3%, , win3
        WinMove, ahk_id %win3%, , 0, 0
        Loop, 3
            ControlSend, , {Escape}, ahk_id %win3%
    }
    else if (accountNum = 4) {
        WinSetTitle, ahk_id %win4%, , win4
        WinMove, ahk_id %win4%, , 0, 0
        Loop, 3
            ControlSend, , {Escape}, ahk_id %win4%
    }
    else if (accountNum = 5) {
        WinSetTitle, ahk_id %win5%, , win5
        WinMove, ahk_id %win5%, , 0, 0
        Loop, 3
            ControlSend, , {Escape}, ahk_id %win5%
    }
    else if (accountNum = 6) {
        WinSetTitle, ahk_id %win6%, , win6
        WinMove, ahk_id %win6%, , 0, 0
        Loop, 3
            ControlSend, , {Escape}, ahk_id %win6%
    }
    else if (accountNum = 7) {
        WinSetTitle, ahk_id %win7%, , win7
        WinMove, ahk_id %win7%, , 0, 0
        Loop, 3
            ControlSend, , {Escape}, ahk_id %win7%
    }
    else if (accountNum = 8) {
        WinSetTitle, ahk_id %win8%, , win8
        WinMove, ahk_id %win8%, , 0, 0
        Loop, 3
            ControlSend, , {Escape}, ahk_id %win8%
    }
}

Sleep, 2000

Loop, %selectedCount% {
    accountNum := selectedAccounts[A_Index]
    username := AccountData[accountNum].Username
    password := AccountData[accountNum].Password
    
    if (accountNum = 1) {
        WinActivate, ahk_id %win1%
        Sleep, 200
        Click, 504, 537
        Sleep, 200
        SendInput, {Text}%username%
        Sleep, 200
        Send, {Tab}
        Sleep, 200
        SendInput, {Text}%password%
        Sleep, 200
        Loop, 3 {
            Click, 574, 600
            Sleep, 200
        }
    }
    else if (accountNum = 2) {
        WinActivate, ahk_id %win2%
        Sleep, 200
        Click, 504, 537
        Sleep, 200
        SendInput, {Text}%username%
        Sleep, 200
        Send, {Tab}
        Sleep, 200
        SendInput, {Text}%password%
        Sleep, 200
        Loop, 3 {
            Click, 574, 600
            Sleep, 200
        }
    }
    else if (accountNum = 3) {
        WinActivate, ahk_id %win3%
        Sleep, 200
        Click, 504, 537
        Sleep, 200
        SendInput, {Text}%username%
        Sleep, 200
        Send, {Tab}
        Sleep, 200
        SendInput, {Text}%password%
        Sleep, 200
        Loop, 3 {
            Click, 574, 600
            Sleep, 200
        }
    }
    else if (accountNum = 4) {
        WinActivate, ahk_id %win4%
        Sleep, 200
        Click, 504, 537
        Sleep, 200
        SendInput, {Text}%username%
        Sleep, 200
        Send, {Tab}
        Sleep, 200
        SendInput, {Text}%password%
        Sleep, 200
        Loop, 3 {
            Click, 574, 600
            Sleep, 200
        }
    }
    else if (accountNum = 5) {
        WinActivate, ahk_id %win5%
        Sleep, 200
        Click, 504, 537
        Sleep, 200
        SendInput, {Text}%username%
        Sleep, 200
        Send, {Tab}
        Sleep, 200
        SendInput, {Text}%password%
        Sleep, 200
        Loop, 3 {
            Click, 574, 600
            Sleep, 200
        }
    }
    else if (accountNum = 6) {
        WinActivate, ahk_id %win6%
        Sleep, 200
        Click, 504, 537
        Sleep, 200
        SendInput, {Text}%username%
        Sleep, 200
        Send, {Tab}
        Sleep, 200
        SendInput, {Text}%password%
        Sleep, 200
        Loop, 3 {
            Click, 574, 600
            Sleep, 200
        }
    }
    else if (accountNum = 7) {
        WinActivate, ahk_id %win7%
        Sleep, 200
        Click, 504, 537
        Sleep, 200
        SendInput, {Text}%username%
        Sleep, 200
        Send, {Tab}
        Sleep, 200
        SendInput, {Text}%password%
        Sleep, 200
        Loop, 3 {
            Click, 574, 600
            Sleep, 200
        }
    }
    else if (accountNum = 8) {
        WinActivate, ahk_id %win8%
        Sleep, 200
        Click, 504, 537
        Sleep, 200
        SendInput, {Text}%username%
        Sleep, 200
        Send, {Tab}
        Sleep, 200
        SendInput, {Text}%password%
        Sleep, 200
        Loop, 3 {
            Click, 574, 600
            Sleep, 200
        }
    }
}

Sleep, 500

endTime := A_TickCount + 20000
Loop {
    if (A_TickCount >= endTime)
        break
    
    Loop, %selectedCount% {
        accountNum := selectedAccounts[A_Index]
        
        if (accountNum = 1) {
            PostMessage, 0x100, 0x0D, 0x001C0001, , ahk_id %win1%
            Sleep, 50
            PostMessage, 0x101, 0x0D, 0xC01C0001, , ahk_id %win1%
        }
        else if (accountNum = 2) {
            PostMessage, 0x100, 0x0D, 0x001C0001, , ahk_id %win2%
            Sleep, 50
            PostMessage, 0x101, 0x0D, 0xC01C0001, , ahk_id %win2%
        }
        else if (accountNum = 3) {
            PostMessage, 0x100, 0x0D, 0x001C0001, , ahk_id %win3%
            Sleep, 50
            PostMessage, 0x101, 0x0D, 0xC01C0001, , ahk_id %win3%
        }
        else if (accountNum = 4) {
            PostMessage, 0x100, 0x0D, 0x001C0001, , ahk_id %win4%
            Sleep, 50
            PostMessage, 0x101, 0x0D, 0xC01C0001, , ahk_id %win4%
        }
        else if (accountNum = 5) {
            PostMessage, 0x100, 0x0D, 0x001C0001, , ahk_id %win5%
            Sleep, 50
            PostMessage, 0x101, 0x0D, 0xC01C0001, , ahk_id %win5%
        }
        else if (accountNum = 6) {
            PostMessage, 0x100, 0x0D, 0x001C0001, , ahk_id %win6%
            Sleep, 50
            PostMessage, 0x101, 0x0D, 0xC01C0001, , ahk_id %win6%
        }
        else if (accountNum = 7) {
            PostMessage, 0x100, 0x0D, 0x001C0001, , ahk_id %win7%
            Sleep, 50
            PostMessage, 0x101, 0x0D, 0xC01C0001, , ahk_id %win7%
        }
        else if (accountNum = 8) {
            PostMessage, 0x100, 0x0D, 0x001C0001, , ahk_id %win8%
            Sleep, 50
            PostMessage, 0x101, 0x0D, 0xC01C0001, , ahk_id %win8%
        }
    }
    Sleep, 250
}

MsgBox, Done! Launched %selectedCount% clients

Loop, %selectedCount% {
    accountNum := selectedAccounts[A_Index]
    if (AccountData[accountNum].AutoScript) {
        scriptPath := A_ScriptDir . "\launcher\win" . accountNum . "\Rappelz Automation Nexus.ahk"
        if (FileExist(scriptPath)) {
            Run, "%scriptPath%"
        }
    }
}

ShowMainGui()
Return

ShowThumbnailView:
    global win1, win2, win3, win4, win5, win6, win7, win8
    global ThumbnailData, thumbnailIsOpen, thumbnailGuiHandle
    
    ; Toggle: if thumbnail is already open, close it
    if (thumbnailIsOpen) {
        Gosub, ThumbnailGuiClose
        return
    }
    
    ; Collect all active game windows
    activeWindows := []
    activeCount := 0
    Loop, 8 {
        winVar := win%A_Index%
        if (winVar) {
            if (WinExist("ahk_id " . winVar)) {
                activeCount++
                activeWindows[activeCount] := {id: winVar, num: A_Index, title: "win" . A_Index}
            }
        }
    }
    
    if (activeCount = 0) {
        MsgBox, No active game clients found! Please launch clients first.
        return
    }
    
    ; Configuration
    thumbWidth := 320
    thumbHeight := 240
    spacing := 10
    
    ; Calculate total width
    totalWidth := (thumbWidth * activeCount) + (spacing * (activeCount + 1))
    totalHeight := thumbHeight + (spacing * 2) + 30  ; Extra space for labels
    
    ; Store configuration globally for resize
    global thumbCount := activeCount
    global baseThumbWidth := thumbWidth
    global baseThumbHeight := thumbHeight
    global thumbSpacing := spacing
    
    ; Create GUI
    Gui, Thumbnail:New, +AlwaysOnTop +Resize
    Gui, Thumbnail:Color, 202020
    
    ; Create thumbnail controls for each window
    ThumbnailData := []
    xPos := spacing
    
    Loop, %activeCount% {
        index := A_Index
        winData := activeWindows[index]
        
        ; Add label with unique variable name for moving later
        labelText := winData.title
        Gui, Add, Text, x%xPos% y%spacing% w%thumbWidth% Center cWhite BackgroundTrans vStatic%index%, %labelText%
        
        ; Add clickable area for thumbnail
        yPos := spacing + 20
        Gui, Add, Text, x%xPos% y%yPos% w%thumbWidth% h%thumbHeight% vThumb%index% gThumbnailClick Background000000 +Border
        
        ; Store data
        ThumbnailData[index] := {}
        ThumbnailData[index].sourceWindow := winData.id
        ThumbnailData[index].clientNum := winData.num
        ThumbnailData[index].controlName := "Thumb" . index
        ThumbnailData[index].xPos := xPos
        ThumbnailData[index].yPos := yPos
        ThumbnailData[index].width := thumbWidth
        ThumbnailData[index].height := thumbHeight
        ThumbnailData[index].thumbnailHandle := 0
        
        xPos += thumbWidth + spacing
    }
    
    Gui, Thumbnail:Show, w%totalWidth% h%totalHeight%, Game Thumbnails
    Gui, Thumbnail:+LastFound
    thumbnailGuiHandle := WinExist()
    
    Sleep, 200
    
    ; Register all thumbnails - each to the main GUI window
    Loop, %activeCount% {
        index := A_Index
        thumbData := ThumbnailData[index]
        controlName := thumbData.controlName
        
        GuiControlGet, hControl, Hwnd, %controlName%
        
        ; Register thumbnail to the GUI window (not the control)
        hThumbnail := 0
        result := DllCall("dwmapi\DwmRegisterThumbnail", "Ptr", thumbnailGuiHandle, "Ptr", thumbData.sourceWindow, "Ptr*", hThumbnail)
        
        if (result = 0 && hThumbnail) {
            ThumbnailData[index].thumbnailHandle := hThumbnail
            ThumbnailData[index].controlHandle := hControl
        } else {
            MsgBox, Failed to register thumbnail %index%! Error: %result%
        }
    }
    
    thumbnailIsOpen := true
    
    ; Update all thumbnails
    Gosub, UpdateAllThumbnails
    
    ; Set timer to keep updating
    SetTimer, UpdateAllThumbnails, 100
return

ThumbnailGuiSize:
    global ThumbnailData, thumbnailGuiHandle, thumbCount, baseThumbWidth, baseThumbHeight, thumbSpacing
    
    ; Get current GUI client area size
    Gui, Thumbnail:+LastFound
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetClientRect", "Ptr", WinExist(), "Ptr", &RECT)
    clientWidth := NumGet(RECT, 8, "Int")
    clientHeight := NumGet(RECT, 12, "Int")
    
    if (!thumbCount || thumbCount = 0)
        return
    
    ; Calculate new thumbnail dimensions based on window size
    spacing := thumbSpacing
    labelHeight := 30
    
    ; Calculate available space
    availableWidth := clientWidth - (spacing * (thumbCount + 1))
    availableHeight := clientHeight - (spacing * 2) - labelHeight
    
    ; Calculate new thumbnail size (divide width equally among thumbnails)
    newThumbWidth := Floor(availableWidth / thumbCount)
    newThumbHeight := availableHeight
    
    ; Update stored dimensions and positions in ThumbnailData
    xPos := spacing
    Loop, %thumbCount% {
        index := A_Index
        thumbData := ThumbnailData[index]
        
        ; Update dimensions
        ThumbnailData[index].width := newThumbWidth
        ThumbnailData[index].height := newThumbHeight
        ThumbnailData[index].xPos := xPos
        ThumbnailData[index].yPos := spacing + 20
        
        ; Move the control
        controlName := thumbData.controlName
        yPos := spacing + 20
        GuiControl, Move, %controlName%, x%xPos% y%yPos% w%newThumbWidth% h%newThumbHeight%
        
        ; Move the label too
        labelY := spacing
        GuiControl, Move, Static%index%, x%xPos% y%labelY% w%newThumbWidth%
        
        xPos += newThumbWidth + spacing
    }
    
    ; Update all thumbnails with new dimensions
    Gosub, UpdateAllThumbnails
return

UpdateAllThumbnails:
    global ThumbnailData
    
    thumbCount := ThumbnailData.MaxIndex()
    if (!thumbCount)
        return
    
    Loop, %thumbCount% {
        index := A_Index
        thumbData := ThumbnailData[index]
        
        if (!thumbData.thumbnailHandle)
            continue
        
        ; Get source window size
        VarSetCapacity(RECT, 16, 0)
        DllCall("GetWindowRect", "Ptr", thumbData.sourceWindow, "Ptr", &RECT)
        srcWidth := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
        srcHeight := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")
        
        ; Calculate destination rectangle position (relative to GUI client area)
        destLeft := thumbData.xPos
        destTop := thumbData.yPos
        destRight := destLeft + thumbData.width
        destBottom := destTop + thumbData.height
        
        ; Set thumbnail properties with correct destination coordinates
        VarSetCapacity(DWM_THUMBNAIL_PROPERTIES, 40, 0)
        NumPut(0x1F, DWM_THUMBNAIL_PROPERTIES, 0, "UInt")  ; dwFlags (all flags)
        NumPut(destLeft, DWM_THUMBNAIL_PROPERTIES, 4, "Int")      ; rcDestination.left
        NumPut(destTop, DWM_THUMBNAIL_PROPERTIES, 8, "Int")       ; rcDestination.top
        NumPut(destRight, DWM_THUMBNAIL_PROPERTIES, 12, "Int")    ; rcDestination.right
        NumPut(destBottom, DWM_THUMBNAIL_PROPERTIES, 16, "Int")   ; rcDestination.bottom
        NumPut(0, DWM_THUMBNAIL_PROPERTIES, 20, "Int")            ; rcSource.left
        NumPut(0, DWM_THUMBNAIL_PROPERTIES, 24, "Int")            ; rcSource.top
        NumPut(srcWidth, DWM_THUMBNAIL_PROPERTIES, 28, "Int")     ; rcSource.right
        NumPut(srcHeight, DWM_THUMBNAIL_PROPERTIES, 32, "Int")    ; rcSource.bottom
        NumPut(255, DWM_THUMBNAIL_PROPERTIES, 36, "UChar")        ; opacity
        NumPut(1, DWM_THUMBNAIL_PROPERTIES, 37, "UChar")          ; fVisible
        NumPut(0, DWM_THUMBNAIL_PROPERTIES, 38, "UChar")          ; fSourceClientAreaOnly
        
        DllCall("dwmapi\DwmUpdateThumbnailProperties", "Ptr", thumbData.thumbnailHandle, "Ptr", &DWM_THUMBNAIL_PROPERTIES)
    }
return

ThumbnailClick:
    global ThumbnailData, win1, win2, win3, win4, win5, win6, win7, win8
    
    ; Get which thumbnail was clicked
    clickedControl := A_GuiControl
    
    thumbCount := ThumbnailData.MaxIndex()
    
    ; Find the corresponding window
    Loop, %thumbCount% {
        index := A_Index
        thumbData := ThumbnailData[index]
        
        if (thumbData.controlName = clickedControl) {
            ; Activate the corresponding game window
            clientNum := thumbData.clientNum
            targetWindow := win%clientNum%
            
            if (WinExist("ahk_id " . targetWindow)) {
                WinActivate, ahk_id %targetWindow%
                WinRestore, ahk_id %targetWindow%
            } else {
                MsgBox, Client %clientNum% window no longer exists!
            }
            break
        }
    }
return

ThumbnailGuiClose:
    global ThumbnailData, thumbnailIsOpen
    
    SetTimer, UpdateAllThumbnails, Off
    
    thumbCount := ThumbnailData.MaxIndex()
    
    ; Unregister all thumbnails
    Loop, %thumbCount% {
        index := A_Index
        thumbData := ThumbnailData[index]
        
        if (thumbData.thumbnailHandle) {
            DllCall("dwmapi\DwmUnregisterThumbnail", "Ptr", thumbData.thumbnailHandle)
        }
    }
    
    ThumbnailData := []
    thumbnailIsOpen := false
    Gui, Thumbnail:Destroy
return

StartNexus:
Gui, Submit, NoHide
Loop, 8 {
    GuiControlGet, autoScript,, Auto%A_Index%
    if (autoScript) {
        scriptPath := A_ScriptDir . "\launcher\win" . A_Index . "\Rappelz Automation Nexus.ahk"
        if (FileExist(scriptPath)) {
            Run, "%scriptPath%"
        }
    }
}
MsgBox, Started Nexus for selected windows
Return



KillAll:
Loop {
    Process, Close, sframe.exe
    Process, Exist, sframe.exe
    if (!ErrorLevel)
        break
}
MsgBox, All Rappelz clients closed
Return

updatecheck:
CheckForUpdates()
Reload
Return

CheckForUpdates() {
    global UpdateURL
    FileRead, LocalVersion, version.txt
    LocalVersion := Trim(LocalVersion)
    
    VersionURL := UpdateURL . "version.txt"
    RemoteVersion := HttpGet(VersionURL)
    if (RemoteVersion = "") {
        MsgBox, 16, Update Error, Could not check for updates.
        return
    }
    RemoteVersion := Trim(RemoteVersion)
    
    if (RemoteVersion != LocalVersion) {
        MsgBox, 4, Update Available, New version %RemoteVersion% available!`nCurrent: %LocalVersion%`n`nDownload update?
        IfMsgBox Yes
            DownloadUpdate(RemoteVersion)
    } else {
        MsgBox, 64, Up to Date, You have the latest version (%LocalVersion%)
    }
}

DownloadUpdate(NewVersion) {
    Progress, 0, Downloading repository..., Updating
    ZipURL := "https://github.com/Joshmccoy14/new-repo/archive/refs/heads/main.zip"
    ZipFile := A_Temp . "\repo.zip"
    ExtractPath := A_Temp . "\repo_extract"
    
    FileCreateDir, %A_ScriptDir%\backups
    FileCopy, %A_ScriptDir%\*.*, %A_ScriptDir%\backups\, 1
    
    UrlDownloadToFile, %ZipURL%, %ZipFile%
    if ErrorLevel {
        Progress, Off
        MsgBox, 16, Error, Failed to download update.
        return
    }
    
    FileRemoveDir, %ExtractPath%, 1
    FileCreateDir, %ExtractPath%
    
    ComObjCreate("Shell.Application").NameSpace(ExtractPath).CopyHere(ComObjCreate("Shell.Application").NameSpace(ZipFile).Items, 4|16)
    Sleep, 2000
    
    Loop, Files, %ExtractPath%\new-repo-main\*.*, FDR
    {
        RelPath := StrReplace(A_LoopFileFullPath, ExtractPath . "\new-repo-main\")
        DestPath := A_ScriptDir . "\" . RelPath
        if (A_LoopFileAttrib ~= "D")
            FileCreateDir, %DestPath%
        else
            FileCopy, %A_LoopFileFullPath%, %DestPath%, 1
    }
    
    FileDelete, %ZipFile%
    FileRemoveDir, %ExtractPath%, 1
    
    FileDelete, version.txt
    FileAppend, %NewVersion%, version.txt
    Progress, Off
    MsgBox, 64, Update Complete, Update installed successfully!`n`nRestarting the launcher.
    reload
}

HttpGet(URL) {
    WinHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WinHttp.Open("GET", URL)
    WinHttp.Send()
    if (WinHttp.Status = 200)
        return WinHttp.ResponseText
    return ""
}

CheckForUpdates()
ExitApp


GuiClose:
ExitApp
