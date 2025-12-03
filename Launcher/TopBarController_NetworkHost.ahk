#NoEnv
#SingleInstance Force
SetBatchLines, -1
SendMode Input
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
;***************************************************************************************************
;#Include gdip.ahk ; <----------- GDIP LIB
;#Include buttons.ahk ; <---------- HButton class
;***************************************************************************************************
#Include findtext2.ahk
#SingleInstance, Force
Gdip_Startup()
; ==========================================
; GLOBALS
; ==========================================
global SelectedWindow := "win1"
global NexusPIDs := {}
global ServerPort := 12345
global Clients := []
global ClientInfo := {}  ; Stores {socket: {type: "nexus" or "topbar", ip: "...", name: "..."}}
global ConnectMode := false
global ConnectIP := ""
global ConnectPort := 12345
global ConnectedToMaster := false
global MasterSocket := -1
global BtnServerToggle
global ServerStatus
global ClientCount
global SettingsHwnd
global NetWin1, NetWin2, NetWin3, NetWin4, NetWin5, NetWin6, NetWin7, NetWin8
global WinLabel1, WinLabel2, WinLabel3, WinLabel4, WinLabel5, WinLabel6, WinLabel7, WinLabel8
global LogoText, NexusMasterText
global TopBarHideBtn, ActBarHideBtn
global CommandDropdown
global UtilityScriptDropdown
global ThumbnailData := []
global thumbnailsVisible := false
global actBarGuiHandle := 0
global actBarLocked := true
global lastMemoryCheck := {}
global RAMStatusText
global RAMClearingEnabled := true
global MaxRAMValue := 500
global SettingsGuiVisible := false
global ServerListening := false
global TopBarVisible := true
global ActBarVisible := true
global SelectAllState := false
global SelectedClients := ""
global ClientSelectorList := ""
global ClientSelectorVisible := false
global ButtonTextColor := "0xFF00FF00"
global LogoTextColor := "Gray"
global CheckboxTextColor := "Lime"
global BarBackgroundColor := "0x1E1E1E"
global lastActiveWinNum := 0
global RemoteClients := {}  ; Track clients from connected TopBar: {"ClientName": true}

; Navigation text patterns for coordinate reading
global NavText := "|<0>*95$5.W1nbCQtoTzz"
NavText .= "|<1>*87$5.zzyEtnbCQUz"
NavText .= "|<2>*95$5.zA7jQvivkTz"
NavText .= "|<3>*95$5.zy8DSnXri1z"
NavText .= "|<4>*95$6.zzztldNN0tttzU"
NavText .= "|<5>*95$5.z01nVtvr0zz"
NavText .= "|<6>*95$6.zzlVDT1RQQBVzU"
NavText .= "|<7>*95$4.zk3gqPBry"
NavText .= "|<8>*95$7.lmPhq31i7/g6"
NavText .= "|<9>*95$5.0tnUGxkDzzz"

; Screen dimensions for GUI positioning
SysGet, ScreenWidth, 78
SysGet, ScreenHeight, 79

; ==========================================
; AUTO-EXECUTE
; ==========================================
LoadSettings()
CreateTopBarGUI()
CreateActivationBar()
SetTimer, AutoRefreshPIDs, 500
SetTimer, UpdateActivationBar, 250
; Auto-start network server
SetTimer, AutoStartServer, -1000
SetTimer, MonitorAndClearRAM, 5000
return

; ==========================================
; SETTINGS PERSISTENCE
; ==========================================
LoadSettings() {
    global RAMClearingEnabled, MaxRAMValue, ServerPort, ButtonTextColor, LogoTextColor, CheckboxTextColor, BarBackgroundColor, ConnectMode, ConnectIP, ConnectPort

    settingsFile := A_ScriptDir "\Settings.ini"

    ; Load RAM Clearing Enabled (default: true/1)
    IniRead, ramEnabled, %settingsFile%, Settings, RAMClearingEnabled, 1
    RAMClearingEnabled := ramEnabled

    ; Load Max RAM Value (default: 500)
    IniRead, maxRAM, %settingsFile%, Settings, MaxRAMValue, 500
    MaxRAMValue := maxRAM

    ; Load Server Port (default: 12345)
    IniRead, port, %settingsFile%, Settings, ServerPort, 12345
    ServerPort := port

    ; Load Connect Mode (default: 0/false)
    IniRead, connectMode, %settingsFile%, Settings, ConnectMode, 0
    ConnectMode := connectMode

    ; Load Connect IP (default: blank)
    IniRead, connectIP, %settingsFile%, Settings, ConnectIP, %A_Space%
    ConnectIP := connectIP

    ; Load Connect Port (default: 12345)
    IniRead, connectPort, %settingsFile%, Settings, ConnectPort, 12345
    ConnectPort := connectPort

    ; Load Button Text Color (default: green)
    IniRead, btnColor, %settingsFile%, Settings, ButtonTextColor, 0xFF00FF00
    ButtonTextColor := btnColor

    ; Load Logo Text Color (default: Gray)
    IniRead, logoColor, %settingsFile%, Settings, LogoTextColor, Gray
    LogoTextColor := logoColor

    ; Load Checkbox Text Color (default: Lime)
    IniRead, checkboxColor, %settingsFile%, Settings, CheckboxTextColor, Lime
    CheckboxTextColor := checkboxColor

    ; Load Bar Background Color (default: 0x1E1E1E)
    IniRead, barBgColor, %settingsFile%, Settings, BarBackgroundColor, 0x1E1E1E
    BarBackgroundColor := barBgColor
}

SaveSettingsToFile() {
    global RAMClearingEnabled, MaxRAMValue, ServerPort, ButtonTextColor, LogoTextColor, CheckboxTextColor, BarBackgroundColor

    settingsFile := A_ScriptDir "\Settings.ini"

    IniWrite, %RAMClearingEnabled%, %settingsFile%, Settings, RAMClearingEnabled
    IniWrite, %MaxRAMValue%, %settingsFile%, Settings, MaxRAMValue
    IniWrite, %ServerPort%, %settingsFile%, Settings, ServerPort
    IniWrite, %ButtonTextColor%, %settingsFile%, Settings, ButtonTextColor
    IniWrite, %LogoTextColor%, %settingsFile%, Settings, LogoTextColor
    IniWrite, %CheckboxTextColor%, %settingsFile%, Settings, CheckboxTextColor
    IniWrite, %BarBackgroundColor%, %settingsFile%, Settings, BarBackgroundColor
}

; ==========================================
; GUI CREATION
; ==========================================
CreateTopBarGUI() {
    global ScreenWidth, SelectedWindow

    ; Create the top bar GUI
    Gui, TopBar:New, +AlwaysOnTop +ToolWindow -Caption
    Gui, TopBar:Color, %BarBackgroundColor%
    Gui, TopBar:+HwndTopBarHwnd

    ; Setup custom button theme
    Theme1 := HBCustomButton()
    GuiButtonType1.SetSessionDefaults( Theme1.All , Theme1.Default , Theme1.Hover , Theme1.Pressed )

    ; 1. Hide Bar
    TopBarHideBtn := New HButton( { Owner: TopBarHwnd , X: 5 , Y: 3 , W: 70 , H: 24 , Text: "Hide Bar" , Label: "ToggleBarVisibility" } )

    ; 1.5 Logo Text
    global TopBarLogoText
    colorHex := GetTextColorHex(LogoTextColor)
    Gui, TopBar:Font, s9 c%colorHex% Bold, Segoe UI
    Gui, TopBar:Add, Text, x90 y7 w150 h16 vTopBarLogoText, Rappelz Nexus Master

    ; 2. Nexus Button (shifted right to make room for logo)
    New HButton( { Owner: TopBarHwnd , X: 235 , Y: 3 , W: 60 , H: 24 , Text: "Nexus" , Label: "NexusMenu" } )

    ; 3. Client Launcher (shifted right)
    New HButton( { Owner: TopBarHwnd , X: 300 , Y: 3 , W: 85 , H: 24 , Text: "Launcher" , Label: "ToggleLauncherGui" } )

    ; 4. Commands Dropdown (shifted right)
    Gui, TopBar:Font, s8, Segoe UI
    Gui, TopBar:Add, DropDownList, x390 y3 w160 h200 vCommandDropdown gOnCommandSelect, Buff All||Come To Me|AutoFollow Toggle|Start Healing|Stop Healing|Start DPS|Stop DPS|Character Select BD5|Get Coords|HV Out|Load Path for All Clients|Setup DPS Navigation|Start Travel|Stop Travel

    ; 5. Execute button - opens client selector popup
    New HButton( { Owner: TopBarHwnd , X: 555 , Y: 3 , W: 70 , H: 24 , Text: "Execute" , Label: "ShowClientSelector" } )

    ; 6. Server Status
    Gui, TopBar:Font, s8 cWhite, Segoe UI
    Gui, TopBar:Add, Text, x635 y7 w90 h16 vServerStatus, Listening: Off

    ; 7. Client Count
    Gui, TopBar:Add, Text, x730 y7 w65 h16 vClientCount, 0 Clients
    
    ; 7b. Client List Info Button
    New HButton( { Owner: TopBarHwnd , X: 795 , Y: 3 , W: 20 , H: 24 , Text: "?" , Label: "ShowClientListPopup" } )

    ; 8. RAM Status indicator
    Gui, TopBar:Font, s8 cLime Bold, Segoe UI
    Gui, TopBar:Add, Text, x820 y7 w200 h16 vRAMStatusText,

    ; 9. Shutdown Button (far right)
    New HButton( { Owner: TopBarHwnd , X: 975 , Y: 3 , W: 75 , H: 24 , Text: "Shutdown" , Label: "ShutdownAll" } )

    ; Show the GUI (back to original compact size)
    Gui, TopBar:Show, x0 y0 w1055 h27, Rappelz Network Controller
}

; ==========================================
; ACTIVATION BAR GUI
; ==========================================
CreateActivationBar() {
    global ActBtn1, ActBtn2, ActBtn3, ActBtn4, ActBtn5, ActBtn6, ActBtn7, ActBtn8
    ; Create activation bar at bottom of screen
    Gui, ActBar:New, +AlwaysOnTop +ToolWindow -Caption
    Gui, ActBar:Color, %BarBackgroundColor%
    Gui, ActBar:+HwndActBarHwnd

    ; Setup custom button theme
    Theme1 := HBCustomButton()
    GuiButtonType1.SetSessionDefaults( Theme1.All , Theme1.Default , Theme1.Hover , Theme1.Pressed )

    ; Hide Bar button
    ActBarHideBtn := New HButton( { Owner: ActBarHwnd , X: 0 , Y: 3 , W: 70 , H: 24 , Text: "Hide Bar" , Label: "ToggleActBarVisibility" } )

    ; Lock/Unlock button
    New HButton( { Owner: ActBarHwnd , X: 70 , Y: 3 , W: 70 , H: 24 , Text: "Locked" , Label: "ToggleActBarLock" } )

    ; Settings button
    New HButton( { Owner: ActBarHwnd , X: 140 , Y: 3 , W: 70 , H: 24 , Text: "Settings" , Label: "OpenSettings" } )

    ; Window activation buttons
    ActBtn1 := New HButton( { Owner: ActBarHwnd , X: 220 , Y: 3 , W: 60 , H: 24 , Text: "Win1" , Label: "ActivateWin1" } )
    ActBtn2 := New HButton( { Owner: ActBarHwnd , X: 280 , Y: 3 , W: 60 , H: 24 , Text: "Win2" , Label: "ActivateWin2" } )
    ActBtn3 := New HButton( { Owner: ActBarHwnd , X: 360 , Y: 3 , W: 60 , H: 24 , Text: "Win3" , Label: "ActivateWin3" } )
    ActBtn4 := New HButton( { Owner: ActBarHwnd , X: 420 , Y: 3 , W: 60 , H: 24 , Text: "Win4" , Label: "ActivateWin4" } )
    ActBtn5 := New HButton( { Owner: ActBarHwnd , X: 480 , Y: 3 , W: 60 , H: 24 , Text: "Win5" , Label: "ActivateWin5" } )
    ActBtn6 := New HButton( { Owner: ActBarHwnd , X: 540 , Y: 3 , W: 60 , H: 24 , Text: "Win6" , Label: "ActivateWin6" } )
    ActBtn7 := New HButton( { Owner: ActBarHwnd , X: 600 , Y: 3 , W: 60 , H: 24 , Text: "Win7" , Label: "ActivateWin7" } )
    ActBtn8 := New HButton( { Owner: ActBarHwnd , X: 660 , Y: 3 , W: 60 , H: 24 , Text: "Win8" , Label: "ActivateWin8" } )

    ; Hide all buttons initially
    Loop, 8 {
        GuiControl, ActBar:Hide, % ActBtn%A_Index%
    }

    ; Show Thumbnails button
    New HButton( { Owner: ActBarHwnd , X: 725 , Y: 3 , W: 90 , H: 24 , Text: "Thumbnails" , Label: "ToggleThumbnails" } )

    ; Reset Position button
    New HButton( { Owner: ActBarHwnd , X: 820 , Y: 3 , W: 80 , H: 24 , Text: "Reset Bar" , Label: "ResetActBarPosition" } )

    ; Logo/placeholder in remaining space
    logoPath := A_ScriptDir "\logo.png"
    if (FileExist(logoPath)) {
        Gui, ActBar:Add, Picture, x962 y0 w60 h30 +0xE, %logoPath%
    } else {
        ; Show placeholder text if logo not found
        logoColorHex := GetTextColorHex(LogoTextColor)
        Gui, ActBar:Font, s7 c%logoColorHex%, Segoe UI
        Gui, ActBar:Add, Text, x955 y7 w73 h16 Center vLogoText, LOGO
    }

    ; Show at y=794
    Gui, ActBar:Show, x0 y794 w1028 h30, Window Activator
    Gui, ActBar:+LastFound
    global actBarGuiHandle
    actBarGuiHandle := WinExist()

    ; Enable dragging when unlocked
    OnMessage(0x201, "ActBarWM_LBUTTONDOWN")
}
HBCustomButton(){
    global ButtonTextColor, BarBackgroundColor
    ; (Removed: local MyButtonDesign)
    MyButtonDesign := {}
    MyButtonDesign.All := {}
    MyButtonDesign.Default := {}
    MyButtonDesign.Hover := {}
    MyButtonDesign.Pressed := {}
    ;********************************
    ;All
    bgColor := "0xFF" . SubStr(BarBackgroundColor, 3)
    MyButtonDesign.All.W := 60 , MyButtonDesign.All.H := 24 , MyButtonDesign.All.Text := "Nexus" , MyButtonDesign.All.BackgroundColor := bgColor
    ;********************************
    ;Default
    MyButtonDesign.Default.W := 60 , MyButtonDesign.Default.H := 24 , MyButtonDesign.Default.Text := "Nexus" , MyButtonDesign.Default.Font := "Arial" , MyButtonDesign.Default.FontOptions := " Bold Center vCenter " , MyButtonDesign.Default.FontSize := "12" , MyButtonDesign.Default.H := "0x0002112F" , MyButtonDesign.Default.TextBottomColor2 := "0x0002112F" , MyButtonDesign.Default.TextTopColor1 := ButtonTextColor , MyButtonDesign.Default.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Default.TextOffsetX := "0" , MyButtonDesign.Default.TextOffsetY := "0" , MyButtonDesign.Default.TextOffsetW := "0" , MyButtonDesign.Default.TextOffsetH := "0" , MyButtonDesign.Default.BackgroundColor := bgColor , MyButtonDesign.Default.ButtonOuterBorderColor := "0xFF161B1F" , MyButtonDesign.Default.ButtonCenterBorderColor := "0xFF262B2F" , MyButtonDesign.Default.ButtonInnerBorderColor1 := "0xFF3F444A" , MyButtonDesign.Default.ButtonInnerBorderColor2 := "0xFF24292D" , MyButtonDesign.Default.ButtonMainColor1 := "0xFF272C32" , MyButtonDesign.Default.ButtonMainColor2 := "0xFF272C32" , MyButtonDesign.Default.ButtonAddGlossy := "1" , MyButtonDesign.Default.GlossTopColor := "0x11FFFFFF" , MyButtonDesign.Default.GlossTopAccentColor := "05FFFFFF" , MyButtonDesign.Default.GlossBottomColor := "33000000"
    ;********************************
    ;Hover
    MyButtonDesign.Hover.W := 60 , MyButtonDesign.Hover.H := 24 , MyButtonDesign.Hover.Text := "Nexus" , MyButtonDesign.Hover.Font := "Arial" , MyButtonDesign.Hover.FontOptions := " Bold Center vCenter " , MyButtonDesign.Hover.FontSize := "12" , MyButtonDesign.Hover.H := "0x0002112F" , MyButtonDesign.Hover.TextBottomColor2 := "0x0002112F" , MyButtonDesign.Hover.TextTopColor1 := ButtonTextColor , MyButtonDesign.Hover.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Hover.TextOffsetX := "0" , MyButtonDesign.Hover.TextOffsetY := "0" , MyButtonDesign.Hover.TextOffsetW := "0" , MyButtonDesign.Hover.TextOffsetH := "0" , MyButtonDesign.Hover.BackgroundColor := bgColor , MyButtonDesign.Hover.ButtonOuterBorderColor := "0xFF161B1F" , MyButtonDesign.Hover.ButtonCenterBorderColor := "0xFF262B2F" , MyButtonDesign.Hover.ButtonInnerBorderColor1 := "0xFF3F444A" , MyButtonDesign.Hover.ButtonInnerBorderColor2 := "0xFF24292D" , MyButtonDesign.Hover.ButtonMainColor1 := "0xFF373C42" , MyButtonDesign.Hover.ButtonMainColor2 := "0xFF373C42" , MyButtonDesign.Hover.ButtonAddGlossy := "1" , MyButtonDesign.Hover.GlossTopColor := "0x11FFFFFF" , MyButtonDesign.Hover.GlossTopAccentColor := "05FFFFFF" , MyButtonDesign.Hover.GlossBottomColor := "33000000"
    ;********************************
    ;Pressed
    MyButtonDesign.Pressed.W := 60 , MyButtonDesign.Pressed.H := 24 , MyButtonDesign.Pressed.Text := "Nexus" , MyButtonDesign.Pressed.Font := "Arial" , MyButtonDesign.Pressed.FontOptions := " Bold Center vCenter " , MyButtonDesign.Pressed.FontSize := "12" , MyButtonDesign.Pressed.H := "0x0002112F" , MyButtonDesign.Pressed.TextBottomColor2 := "0x0002112F" , MyButtonDesign.Pressed.TextTopColor1 := ButtonTextColor , MyButtonDesign.Pressed.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Pressed.TextOffsetX := "0" , MyButtonDesign.Pressed.TextOffsetY := "0" , MyButtonDesign.Pressed.TextOffsetW := "0" , MyButtonDesign.Pressed.TextOffsetH := "0" , MyButtonDesign.Pressed.BackgroundColor := bgColor , MyButtonDesign.Pressed.ButtonOuterBorderColor := "0xFF62666a" , MyButtonDesign.Pressed.ButtonCenterBorderColor := "0xFF262B2F" , MyButtonDesign.Pressed.ButtonInnerBorderColor1 := "0xFF151A20" , MyButtonDesign.Pressed.ButtonInnerBorderColor2 := "0xFF151A20" , MyButtonDesign.Pressed.ButtonMainColor1 := "0xFF12161a" , MyButtonDesign.Pressed.ButtonMainColor2 := "0xFF33383E" , MyButtonDesign.Pressed.ButtonAddGlossy := "0" , MyButtonDesign.Pressed.GlossTopColor := "0x11FFFFFF" , MyButtonDesign.Pressed.GlossTopAccentColor := "05FFFFFF" , MyButtonDesign.Pressed.GlossBottomColor := "33000000"
    ;********************************

    return MyButtonDesign
}
UpdateActivationBar:
    global ActBtn1, ActBtn2, ActBtn3, ActBtn4, ActBtn5, ActBtn6, ActBtn7, ActBtn8, lastActiveWinNum

    ; Track which game window is currently ACTIVE (foreground)
    activeWinNum := 0
    Loop, 8 {
        winName := "win" . A_Index
        btnHwnd := ActBtn%A_Index%

        ; Check if game window exists
        SetTitleMatchMode, 3
        WinGet, gameWinID, ID, %winName%
        
        if (gameWinID) {
            GuiControl, ActBar:Show, % btnHwnd
            
            ; Check if THIS specific window is the active one
            if WinActive("ahk_id " . gameWinID) {
                Gui, ActBar:Show, NoActivate
                ; This is the active window
                activeWinNum := A_Index
            }
        } else {
            GuiControl, ActBar:Hide, % btnHwnd
        }
    }

    ; Check if TopBar or ActBar is active - if so, preserve the last state
    WinGet, activeID, ID, A
    WinGetClass, activeClass, ahk_id %activeID%
    WinGetTitle, activeTitle, ahk_id %activeID%
    
    ; Check if it's one of our GUI windows
    isOurGUI := (InStr(activeTitle, "Rappelz Network Controller") 
                || InStr(activeTitle, "Window Activator") 
                || InStr(activeTitle, "NexusSelector")
                || (activeClass = "AutoHotkeyGUI" && (activeID = A_ScriptHwnd || InStr(activeTitle, "Rappelz"))))

    ; Manage positions based on active window
    if (isOurGUI) {
        ; Our GUI is active - keep current Nexus state (do nothing)
    } else if (activeWinNum > 0 && activeWinNum != lastActiveWinNum) {
        ; A game window is active and different from last - show its Nexus
        ManageNexusPositions(activeWinNum)
        lastActiveWinNum := activeWinNum
    } else if (activeWinNum = 0 && lastActiveWinNum != 0) {
        ; Some other window is active (not game, not our GUIs) - hide all Nexus
        ManageNexusPositions(0)
        lastActiveWinNum := 0
    }
return

; Function to manage Nexus window positions
ManageNexusPositions(activeWinNum) {
    SetTitleMatchMode, 3
    
    ; Move all Nexus windows off-screen first
    Loop, 8 {
        winName := "win" . A_Index
        StringUpper, upperWindow, winName
        nexusTitle := "Rappelz Automation Nexus " . upperWindow
        
        nexusWinID := WinExist(nexusTitle)
        if (nexusWinID) {
            WinGetPos, currentX, , , , ahk_id %nexusWinID%
            ; Only move if not already off-screen
            if (currentX > -5000) {
                WinMove, ahk_id %nexusWinID%, , -10000, 100
            }
        }
    }
    
    ; If we have an active game window, bring its corresponding Nexus on-screen
    if (activeWinNum > 0) {
        winName := "win" . activeWinNum
        StringUpper, upperWindow, winName
        nexusTitle := "Rappelz Automation Nexus " . upperWindow
        
        nexusWinID := WinExist(nexusTitle)
        if (nexusWinID) {
            ; Check if we have a saved position
            IniRead, savedX, NexusPositions.ini, %winName%, X, 1024
            IniRead, savedY, NexusPositions.ini, %winName%, Y, 30
            
            ; Get current position to avoid unnecessary moves
            WinGetPos, currentX, , , , ahk_id %nexusWinID%
            if (currentX != savedX) {
                WinMove, ahk_id %nexusWinID%, , %savedX%, %savedY%
            }
        }
    }
}

; Window activation handlers
ActivateWin1:
    ActivateNexusWindow("win1")
return

ActivateWin2:
    ActivateNexusWindow("win2")
return

ActivateWin3:
    ActivateNexusWindow("win3")
return

ActivateWin4:
    ActivateNexusWindow("win4")
return

ActivateWin5:
    ActivateNexusWindow("win5")
return

ActivateWin6:
    ActivateNexusWindow("win6")
return

ActivateWin7:
    ActivateNexusWindow("win7")
return

ActivateWin8:
    ActivateNexusWindow("win8")
return

ActivateNexusWindow(winName) {
    global NexusPIDs

    ; Activate the game client window only
    SetTitleMatchMode, 3 ; Exact match
    WinGet, gameWinID, ID, %winName%
    if (gameWinID) {
        ; Disable AlwaysOnTop on game window
        WinSet, AlwaysOnTop, Off, ahk_id %gameWinID%
        WinActivate, ahk_id %gameWinID%
    }
}

ToggleActBarVisibility:
    global SettingsGuiVisible, ActBarVisible, thumbnailsVisible, ActBarHwnd, ActBarHideBtn, ActBarMinBtn

    if (SettingsGuiVisible) {
        Gui, Settings:Destroy
        SettingsGuiVisible := false
    }
    ActBarVisible := !ActBarVisible
    If (ActBarVisible) {
        Gui, ActBar:Show, x0 y794 w1028 h30
        if (ActBarMinBtn)
            GuiControl, ActBar:Hide, % ActBarMinBtn
        if (ActBarHideBtn)
            GuiControl, ActBar:Show, % ActBarHideBtn
    } Else {
        if (thumbnailsVisible) {
            Gosub, HideThumbnails
        }
        Gui, ActBar:Show, x0 y794 w30 h30
        if (ActBarHideBtn)
            GuiControl, ActBar:Hide, % ActBarHideBtn
        if (!ActBarMinBtn) {
            Theme1 := HBCustomButton()
            GuiButtonType1.SetSessionDefaults( Theme1.All , Theme1.Default , Theme1.Hover , Theme1.Pressed )
            ActBarMinBtn := New HButton( { Owner: ActBarHwnd , X: 5 , Y: 3 , W: 20 , H: 24 , Text: "[-]" , Label: "ToggleActBarVisibility" } )
        } else {
            GuiControl, ActBar:Show, % ActBarMinBtn
        }
    }
return

ToggleActBarLock:
    global actBarLocked
    actBarLocked := !actBarLocked
    if (actBarLocked) {
        GuiControl, ActBar:, BtnActBarLock, Locked
    } else {
        GuiControl, ActBar:, BtnActBarLock, Unlocked
    }
return

ActBarWM_LBUTTONDOWN() {
    global actBarLocked
    ; Only allow dragging if unlocked
    if (!actBarLocked) {
        PostMessage, 0xA1, 2 ; WM_NCLBUTTONDOWN, HTCAPTION
    }
}

ResetActBarPosition:
    global thumbnailsVisible

    ; Move all game windows to 0,0
    SetTitleMatchMode, 3 ; Exact match
    Loop, 8 {
        winName := "win" . A_Index
        WinGet, gameWinID, ID, %winName%
        if (gameWinID) {
            WinMove, ahk_id %gameWinID%, , 0, 0
        }
    }

    ; Calculate current height based on thumbnail visibility
    if (thumbnailsVisible) {
        ; Get current thumbnail count to calculate proper height
        global ThumbnailData
        activeCount := ThumbnailData.Length()
        if (activeCount > 0) {
            rows := Ceil(activeCount / 4.0)
            totalHeight := 35 + (rows * (150 + 20 + 5))
            maxHeight := 234
            if (totalHeight > maxHeight)
                totalHeight := maxHeight
            Gui, ActBar:Show, x0 y794 w1028 h%totalHeight%
        } else {
            Gui, ActBar:Show, x0 y794 w1028 h30
        }
    } else {
        Gui, ActBar:Show, x0 y794 w1028 h30
    }
return

ToggleThumbnails:
    global thumbnailsVisible
    if (thumbnailsVisible) {
        Gosub, HideThumbnails
    } else {
        Gosub, ShowThumbnails
    }
return

ShowThumbnails:
    global ThumbnailData, thumbnailsVisible, actBarGuiHandle, NexusPIDs

    ; Collect all active game windows
    activeWindows := []
    Loop, 8 {
        winName := "win" . A_Index
        SetTitleMatchMode, 3
        WinGet, gameWinID, ID, %winName%
        if (gameWinID && WinExist("ahk_id " . gameWinID)) {
            activeWindows.Push({id: gameWinID, num: A_Index, title: winName})
        }
    }

    if (activeWindows.Length() = 0) {
        MsgBox, No active game clients found!
        return
    }

    ; Configuration
    thumbWidth := 200
    thumbHeight := 150
    spacing := 5
    startY := 35 ; Below the main bar

    activeCount := activeWindows.Length()

    ; Calculate layout: 4 per row
    columns := 4
    rows := Ceil(activeCount / 4.0)

    ; Calculate total height needed
    totalHeight := startY + (rows * (thumbHeight + 20 + spacing))

    ; Cap at y1028 (794 + 234 = 1028)
    maxHeight := 234
    if (totalHeight > maxHeight)
        totalHeight := maxHeight

    ; Expand bar downward from y794
    Gui, ActBar:Show, x0 y794 w1028 h%totalHeight%

    ; Create or show thumbnail controls
    ThumbnailData := []

    Loop, % activeCount {
        index := A_Index
        winData := activeWindows[index]

        ; Calculate position (4 per row)
        col := Mod(index - 1, 4)
        row := Floor((index - 1) / 4)

        xPos := 10 + (col * (thumbWidth + spacing))
        yPos := startY + (row * (thumbHeight + 20 + spacing))
        labelY := yPos + thumbHeight + 2 ; Position label below thumbnail

        ; Check if controls already exist
        GuiControlGet, existingControl, ActBar:Hwnd, Thumb%index%

        if (ErrorLevel) {
            ; Controls don't exist, create them
            labelText := winData.title
            Gui, ActBar:Add, Text, x%xPos% y%yPos% w%thumbWidth% h%thumbHeight% vThumb%index% gThumbnailClick Background000000 +Border
            Gui, ActBar:Add, Text, x%xPos% y%labelY% w%thumbWidth% Center cWhite BackgroundTrans vThumbLabel%index%, %labelText%
        } else {
            ; Controls exist, just show and reposition them
            GuiControl, ActBar:Show, Thumb%index%
            GuiControl, ActBar:Show, ThumbLabel%index%
            GuiControl, ActBar:Move, Thumb%index%, x%xPos% y%yPos% w%thumbWidth% h%thumbHeight%
            GuiControl, ActBar:Move, ThumbLabel%index%, x%xPos% y%labelY% w%thumbWidth%
        }

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
    }

    Sleep, 100

    ; Register all thumbnails
    Loop, % activeCount {
        index := A_Index
        thumbData := ThumbnailData[index]
        controlName := thumbData.controlName

        GuiControlGet, hControl, Hwnd, %controlName%

        ; Register thumbnail to the GUI window
        hThumbnail := 0
        result := DllCall("dwmapi\DwmRegisterThumbnail", "Ptr", actBarGuiHandle, "Ptr", thumbData.sourceWindow, "Ptr*", hThumbnail)

        if (result = 0 && hThumbnail) {
            ThumbnailData[index].thumbnailHandle := hThumbnail
            ThumbnailData[index].controlHandle := hControl
        }
    }

    thumbnailsVisible := true
    GuiControl, ActBar:, BtnThumbnails, Hide Thumbnails

    ; Update all thumbnails
    Gosub, UpdateThumbnails

    ; Set timer to keep updating
    SetTimer, UpdateThumbnails, 100
return

HideThumbnails:
    global ThumbnailData, thumbnailsVisible

    SetTimer, UpdateThumbnails, Off

    thumbCount := ThumbnailData.MaxIndex()
    if (!thumbCount)
        thumbCount := ThumbnailData.Length()

    ; Unregister all thumbnails
    Loop, % thumbCount {
        index := A_Index
        if (ThumbnailData[index].thumbnailHandle) {
            DllCall("dwmapi\DwmUnregisterThumbnail", "Ptr", ThumbnailData[index].thumbnailHandle)
        }

        ; Hide controls
        GuiControl, ActBar:Hide, Thumb%index%
        GuiControl, ActBar:Hide, ThumbLabel%index%
    }

    ThumbnailData := []
    thumbnailsVisible := false
    GuiControl, ActBar:, BtnThumbnails, Show Thumbnails

    ; Restore original bar size
    Gui, ActBar:Show, x0 y794 w1028 h30
return

UpdateThumbnails:
    global ThumbnailData

    thumbCount := ThumbnailData.MaxIndex()
    if (!thumbCount)
        thumbCount := ThumbnailData.Length()
    if (!thumbCount)
        return

    Loop, % thumbCount {
        index := A_Index
        thumbData := ThumbnailData[index]

        if (!thumbData.thumbnailHandle)
            continue

        ; Get source window size
        VarSetCapacity(RECT, 16, 0)
        DllCall("GetWindowRect", "Ptr", thumbData.sourceWindow, "Ptr", &RECT)
        srcWidth := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
        srcHeight := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")

        ; Calculate destination rectangle position
        destLeft := thumbData.xPos
        destTop := thumbData.yPos
        destRight := destLeft + thumbData.width
        destBottom := destTop + thumbData.height

        ; Set thumbnail properties
        VarSetCapacity(DWM_THUMBNAIL_PROPERTIES, 40, 0)
        NumPut(0x1F, DWM_THUMBNAIL_PROPERTIES, 0, "UInt")
        NumPut(destLeft, DWM_THUMBNAIL_PROPERTIES, 4, "Int")
        NumPut(destTop, DWM_THUMBNAIL_PROPERTIES, 8, "Int")
        NumPut(destRight, DWM_THUMBNAIL_PROPERTIES, 12, "Int")
        NumPut(destBottom, DWM_THUMBNAIL_PROPERTIES, 16, "Int")
        NumPut(0, DWM_THUMBNAIL_PROPERTIES, 20, "Int")
        NumPut(0, DWM_THUMBNAIL_PROPERTIES, 24, "Int")
        NumPut(srcWidth, DWM_THUMBNAIL_PROPERTIES, 28, "Int")
        NumPut(srcHeight, DWM_THUMBNAIL_PROPERTIES, 32, "Int")
        NumPut(255, DWM_THUMBNAIL_PROPERTIES, 36, "UChar")
        NumPut(1, DWM_THUMBNAIL_PROPERTIES, 37, "UChar")
        NumPut(0, DWM_THUMBNAIL_PROPERTIES, 38, "UChar")

        DllCall("dwmapi\DwmUpdateThumbnailProperties", "Ptr", thumbData.thumbnailHandle, "Ptr", &DWM_THUMBNAIL_PROPERTIES)
    }
return

ThumbnailClick:
    global ThumbnailData

    ; Get which thumbnail was clicked
    clickedControl := A_GuiControl

    thumbCount := ThumbnailData.MaxIndex()
    if (!thumbCount)
        thumbCount := ThumbnailData.Length()

    ; Find the corresponding window
    Loop, % thumbCount {
        index := A_Index
        thumbData := ThumbnailData[index]

        if (thumbData.controlName = clickedControl) {
            ; Activate the game window using existing function
            winName := "win" . thumbData.clientNum
            ActivateNexusWindow(winName)
            break
        }
    }
return

; ==========================================
; AUTO-START SERVER
; ==========================================
AutoStartServer:
    global ServerPort, ServerListening
    If (i := AHKsock_Listen(ServerPort, "ServerEvents")) {
        MsgBox, ERROR: Auto-start server failed with code %i%`nErrorLevel: %ErrorLevel%
    } Else {
        ServerListening := true
        GuiControl, TopBar:, BtnServerToggle, Stop Svr
        GuiControl, Settings:, BtnServerToggle, Stop Server
        GuiControl, TopBar:, ServerStatus, Listening: On
    }
return

; ==========================================
; GUI BUTTON HANDLERS
; ==========================================
ToggleBarVisibility:
    global NexusWindowSelectorVisible, TopBarVisible, TopBarHwnd, TopBarHideBtn, MinBtn, ClientSelectorVisible, ClientListPopupVisible

    TopBarVisible := !TopBarVisible
    If (TopBarVisible) {
        Gui, TopBar:Show, x0 y0 w1027 h27
        if (MinBtn)
            GuiControl, TopBar:Hide, % MinBtn
        if (TopBarHideBtn)
            GuiControl, TopBar:Show, % TopBarHideBtn
    } Else {
        Gui, TopBar:Show, x0 y0 w30 h27
        if (TopBarHideBtn)
            GuiControl, TopBar:Hide, % TopBarHideBtn
        if (!MinBtn) {
            Theme1 := HBCustomButton()
            GuiButtonType1.SetSessionDefaults( Theme1.All , Theme1.Default , Theme1.Hover , Theme1.Pressed )
            MinBtn := New HButton( { Owner: TopBarHwnd , X: 5 , Y: 3 , W: 20 , H: 24 , Text: "[-]" , Label: "ToggleBarVisibility" } )
        } else {
            GuiControl, TopBar:Show, % MinBtn
        }
        ; Close all popups when hiding the bar
        if (NexusWindowSelectorVisible) {
            Gui, NexusSelector:Destroy
            NexusWindowSelectorVisible := false
        }
        if (ClientSelectorVisible) {
            Gui, ClientSelector:Destroy
            ClientSelectorVisible := false
        }
        Gui, ClientListPopup:Destroy
        ClientListPopupVisible := false
    }
return

OnWindowSelect:
    Gui, TopBar:Submit, NoHide
return

NexusMenu:
    ; Create or show a custom Nexus Window Selector GUI instead of a menu
    global NexusWindowSelectorVisible
    if (NexusWindowSelectorVisible) {
        Gui, NexusSelector:Destroy
        NexusWindowSelectorVisible := false
        return
    }

    ; Get the position of the Nexus button in the TopBar GUI
    GuiControlGet, nexusBtnPos, TopBar:Pos, Button3
    Gui, TopBar:+LastFound
    hwnd := WinExist()
    WinGetPos, guiX, guiY,,, ahk_id %hwnd%
    menuX := guiX + nexusBtnPosX - 590
    menuY := guiY + nexusBtnPosY + nexusBtnPosH + 2

    ; Build the Nexus Selector GUI
    Gui, NexusSelector:New, +AlwaysOnTop +ToolWindow -Caption
    Gui, NexusSelector:Color, %BarBackgroundColor%
    Gui, NexusSelector:+HwndNexusSelectorHwnd
    Gui, NexusSelector:Font, s9 cWhite, Segoe UI
    Gui, NexusSelector:Add, Text, x0 y8 w140 h20 Center, Nexus Macros

    Theme1 := HBCustomButton()
    GuiButtonType1.SetSessionDefaults( Theme1.All , Theme1.Default , Theme1.Hover , Theme1.Pressed )

    y := 35
    Loop, 8 {
        btnText := "Win" . A_Index
        btnLabelName := "NexusSelectorBtn" . A_Index
        btnObj := {Owner: NexusSelectorHwnd, X: 10, Y: y, W: 120, H: 28, Text: btnText, Label: btnLabelName}
        New HButton(btnObj)
        y += 32
    }
    hideObj := {Owner: NexusSelectorHwnd, X: 10, Y: y, W: 120, H: 28, Text: "Hide All", Label: "HideAllNexusBtn"}
    New HButton(hideObj)

    totalH := y + 38
    Gui, NexusSelector:Show, x200 y27 w140 h329, NexusSelector
    NexusWindowSelectorVisible := true
return

NexusSelectorBtn1:
NexusSelectorBtn2:
NexusSelectorBtn3:
NexusSelectorBtn4:
NexusSelectorBtn5:
NexusSelectorBtn6:
NexusSelectorBtn7:
NexusSelectorBtn8:
    ; Extract the number from the label, supports single or double digits
    if (RegExMatch(A_ThisLabel, "NexusSelectorBtn(\d+)", m))
        winNum := m1
    else
        winNum := SubStr(A_ThisLabel, -1)
    winName := "win" . winNum
    StringUpper, upperWindow, winName
    nexusTitle := "Rappelz Automation Nexus " . upperWindow
    SetTitleMatchMode, 3
    if WinExist(nexusTitle) {
        ShowNexusWindow(winName)
    } else {
        LaunchNexusWindow(winName)
    }
    Gui, NexusSelector:Destroy
    NexusWindowSelectorVisible := false
return
 
HideAllNexusBtn:
    Gosub, HideAllNexus
    Gui, NexusSelector:Destroy
    NexusWindowSelectorVisible := false
return

NexusSelectorGuiClose:
    NexusWindowSelectorVisible := false
    Gui, NexusSelector:Destroy
return

LaunchNexusWindow(winName) {
    global NexusPIDs
    StringUpper, upperWindow, winName
    scriptPath := A_ScriptDir "\" winName "\Rappelz Automation Nexus " upperWindow ".ahk"

    If !FileExist(scriptPath) {
        MsgBox, Script not found: %scriptPath%
        return
    }

    SetTimer, AutoRefreshPIDs, Off
    Run, %scriptPath%
    Sleep, 500

    attempts := 0
    thisPID := ""
    while (thisPID = "" && attempts < 3) {
        DetectRunningNexusScripts()
        thisPID := NexusPIDs[winName]
        If (thisPID = "") {
            Sleep, 300
            attempts++
        }
    }

    If (thisPID != "") {
        DetectHiddenWindows, On
        nexusWinID := WinExist("ahk_pid " thisPID)
        If (nexusWinID) {
            WinMove, ahk_id %nexusWinID%, , 1024, 30
        }
        DetectHiddenWindows, Off
    }
    SetTimer, AutoRefreshPIDs, 500
}

ShowNexusWindow(winName) {
    StringUpper, upperWindow, winName
    nexusTitle := "Rappelz Automation Nexus " . upperWindow
    SetTitleMatchMode, 3

    nexusWinID := WinExist(nexusTitle)
    if (!nexusWinID)
        return

    WinGetPos, winX, , , , ahk_id %nexusWinID%

    if (winX < -5000) {
        IniRead, savedX, NexusPositions.ini, %winName%, X, 1024
        IniRead, savedY, NexusPositions.ini, %winName%, Y, 30
        WinMove, ahk_id %nexusWinID%, , %savedX%, %savedY%
        WinActivate, ahk_id %nexusWinID%
    }
}

HideAllNexus:
    Loop, 8 {
        winName := "win" . A_Index
        StringUpper, upperWindow, winName
        nexusTitle := "Rappelz Automation Nexus " . upperWindow
        SetTitleMatchMode, 3

        nexusWinID := WinExist(nexusTitle)
        if (nexusWinID) {
            WinGetPos, winX, winY, , , ahk_id %nexusWinID%
            if (winX >= -5000) {
                IniWrite, %winX%, NexusPositions.ini, %winName%, X
                IniWrite, %winY%, NexusPositions.ini, %winName%, Y
                WinMove, ahk_id %nexusWinID%, , -10000, %winY%
            }
        }
    }
return

ToggleLauncherGui:
    Gui, TopBar:Submit, NoHide

    launcherTitle := "Rappelz Multi-Client Launcher"

    ; Check if launcher window exists - try multiple methods
    DetectHiddenWindows, On
    SetTitleMatchMode, 2 ; Contains
    launcherID := WinExist(launcherTitle)

    If (!launcherID) {
        ; Try with class
        launcherID := WinExist(launcherTitle " ahk_class AutoHotkeyGUI")
    }

    If (launcherID) {
        ; Window exists, toggle visibility
        isVisible := DllCall("IsWindowVisible", "Ptr", launcherID)
        If (isVisible) {
            WinHide, ahk_id %launcherID%
        } Else {
            WinShow, ahk_id %launcherID%
            WinActivate, ahk_id %launcherID%
        }
    } Else {
        ; Launcher not found, launch it
        launcherPath := A_ScriptDir "\..\RappelzMultiClientLauncher.ahk"
        if (FileExist(launcherPath)) {
            Run, %launcherPath%
            Sleep, 1000 ; Wait for it to load
            ; Show and activate it
            DetectHiddenWindows, On
            launcherID := WinExist(launcherTitle)
            if (launcherID) {
                WinShow, ahk_id %launcherID%
                WinActivate, ahk_id %launcherID%
            }
        } else {
            MsgBox, Launcher file not found: %launcherPath%
        }
    }
    DetectHiddenWindows, Off
    SetTitleMatchMode, 1 ; Reset to default
return

ToggleServer:
    global ServerListening, ServerPort
    Gui, TopBar:Submit, NoHide
    Gui, Settings:Submit, NoHide

    If (!ServerListening) {
        ; Start listening
        If (i := AHKsock_Listen(ServerPort, "ServerEvents")) {
            MsgBox, ERROR: Failed to start server (code %i%)
        } Else {
            ServerListening := true
            GuiControl, TopBar:, BtnServerToggle, Stop Svr
            GuiControl, TopBar:, ServerStatus, Listening: On
            UpdateSettingsButtons()
        }
    } Else {
        ; Stop listening
        AHKsock_Listen(ServerPort, False)
        ServerListening := false
        GuiControl, TopBar:, BtnServerToggle, Start Svr
        GuiControl, TopBar:, ServerStatus, Listening: Off
        UpdateSettingsButtons()
    }
return

UpdateSettingsButtons() {
    global ServerListening, ConnectedToMaster, SettingsHwnd
    
    ; Destroy existing HButtons by destroying and recreating the Settings window
    ; This is simpler than trying to track individual button references
    Gui, Settings:Destroy
    Gosub, OpenSettings
}

ToggleConnect:
    global ConnectedToMaster, MasterSocket, ConnectIP, ConnectPort
    Gui, Settings:Submit, NoHide
    
    ; Save settings to INI
    settingsFile := A_ScriptDir "\Settings.ini"
    IniWrite, %ConnectIP%, %settingsFile%, Settings, ConnectIP
    IniWrite, %ConnectPort%, %settingsFile%, Settings, ConnectPort

    If (ConnectedToMaster) {
        ; Disconnect from master
        If (MasterSocket != -1) {
            AHKsock_Close(MasterSocket)
        }
        ConnectedToMaster := false
        MasterSocket := -1
        
        MsgBox, Disconnected from master TopBar
        UpdateSettingsButtons()
    } Else {
        ; Connect to master TopBar
        If (ConnectIP = "" || ConnectPort = "") {
            MsgBox, Please enter a valid IP and Port
            Return
        }
        
        ; Attempt connection
        If (i := AHKsock_Connect(ConnectIP, ConnectPort, "ClientEvents")) {
            MsgBox, ERROR: Failed to connect to %ConnectIP%:%ConnectPort% (code %i%)
        } Else {
            ; Connection initiated, wait for result in ClientEvents
            MsgBox, Connecting to %ConnectIP%:%ConnectPort%...
        }
    }
return

ShowConnectionInfo:
    MsgBox, 0, Connection Information, Server is LAN only unless you configure port forwarding in your router.`n`nTo allow internet access:`n1. Configure port forwarding in your router`n2. Forward the server port to this PC's local IP`n3. Share your Public IP and Port with friends
return

ClientEvents(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0) {
    global MasterSocket, ConnectedToMaster
    Static recvBuffer := ""
    
    If (sEvent = "CONNECTED") {
        ; Successfully connected to master TopBar
        MasterSocket := iSocket
        ConnectedToMaster := true
        
        ; Debug logging
        logFile := A_ScriptDir . "\topbar_debug.log"
        FileAppend, %A_Now% - ClientEvents: CONNECTED to master. Socket=%iSocket%`n, %logFile%
        
        ; Use a timer to send handshake after socket is fully ready (like Nexus does)
        SetTimer, SendTopBarHandshake, -250
        
        MsgBox, Connected to master TopBar
        UpdateSettingsButtons()
        
    }Else If (sEvent = "DISCONNECTED") {
        ; Disconnected from master
        MasterSocket := -1
        ConnectedToMaster := false
        RemoteClients := {}  ; Clear remote clients
        
        MsgBox, Disconnected from master TopBar
        UpdateSettingsButtons()
        
    } Else If (sEvent = "RECEIVED") {
        ; Received message from connected TopBar
        data := StrGet(&bData, iLength, "CP0")
        data := StrReplace(data, "`n", "")
        data := StrReplace(data, "`r", "")
        
        If (data != "") {
            ; Debug: Log received data
            logFile := A_ScriptDir . "\topbar_debug.log"
            FileAppend, %A_Now% - ClientEvents RECEIVED: "%data%"`n, %logFile%
            
            ; Check if this is a client list message
            If (SubStr(data, 1, 12) = "CLIENT_LIST:") {
                ; Parse client list: CLIENT_LIST:name1,name2,name3
                clientListData := SubStr(data, 13)
                FileAppend, %A_Now% - Processing CLIENT_LIST: "%clientListData%"`n, %logFile%
                UpdateRemoteClientList(clientListData, iSocket)
            }
            ; Check if this is a request for our client list
            Else If (data = "REQUEST_CLIENT_LIST") {
                SendClientListToRemote(iSocket)
            }
            ; Check if this is a targeted command: TARGET:ClientName:COMMAND
            Else If (SubStr(data, 1, 7) = "TARGET:") {
                targetData := SubStr(data, 8)
                colonPos := InStr(targetData, ":")
                If (colonPos > 0) {
                    targetName := SubStr(targetData, 1, colonPos - 1)
                    actualCommand := SubStr(targetData, colonPos + 1)
                    ; Send to the specific local client
                    SendCommandToNamedClient(targetName, actualCommand)
                }
            }
            ; Otherwise relay to all local Nexus clients
            Else {
                SendCommandToNexusClients(data)
            }
        }
    }
}

; ==========================================
; SEND TOPBAR HANDSHAKE (Timer Label)
; ==========================================
SendTopBarHandshake:
    Global MasterSocket
    logFile := A_ScriptDir . "\topbar_debug.log"
    
    ; Send handshake to identify as TopBar with unique identifier
    topBarID := A_ComputerName . ":" . A_IPAddress1
    If (topBarID = ":" || topBarID = "") {
        topBarID := "TopBar-" . A_TickCount
    }
    handshake := "HANDSHAKE:TOPBAR:" . topBarID . "`n"
    FileAppend, %A_Now% - Sending handshake: "%handshake%"`n, %logFile%
    
    bufferSize := StrPut(handshake, "CP0")
    VarSetCapacity(buffer, bufferSize)
    StrPut(handshake, &buffer, "CP0")
    sendResult := AHKsock_Send(MasterSocket, &buffer, bufferSize - 1)
    FileAppend, %A_Now% - AHKsock_Send result: %sendResult%`n, %logFile%
    
    ; Send request for client list
    Sleep, 100
    requestMsg := "REQUEST_CLIENT_LIST`n"
    bufferSize2 := StrPut(requestMsg, "CP0")
    VarSetCapacity(buffer2, bufferSize2)
    StrPut(requestMsg, &buffer2, "CP0")
    AHKsock_Send(MasterSocket, &buffer2, bufferSize2 - 1)
    
    ; Send our client list to the master
    Sleep, 100
    SendClientListToRemote(MasterSocket)
Return

; ==========================================
; COMMAND EXECUTION
; ==========================================
OnCommandSelect:
return

ShowClientSelector:
    Global Clients, ClientInfo, ClientSelectorVisible
    
    ; If selector is already open, close it
    If (ClientSelectorVisible) {
        Gui, ClientSelector:Destroy
        ClientSelectorVisible := false
        Return
    }
    
    ; Check if we have any clients
    If (Clients.MaxIndex() = "" || Clients.MaxIndex() = 0) {
        MsgBox, No clients connected!
        Return
    }
    
    ; Get TopBar position to place popup below it
    Gui, TopBar:+LastFound
    WinGetPos, topBarX, topBarY, topBarW, topBarH, ahk_id %TopBarHwnd%
    
    ; Create popup selector
    Gui, ClientSelector:Destroy
    Gui, ClientSelector:+AlwaysOnTop -Caption +ToolWindow
    Gui, ClientSelector:+HwndClientSelectorHwnd
    Gui, ClientSelector:Color, %BarBackgroundColor%
    Gui, ClientSelector:Font, s9 cWhite, Segoe UI
    
    Gui, ClientSelector:Add, Text, x10 y10 w200 h20, Select clients to send command:
    
    ; Add checkbox for each connected client (local and remote)
    yPos := 35
    clientIndex := 0
    
    ; First, add local clients from Clients array (only Nexus clients, skip TopBars)
    For index, socket in Clients {
        If (ClientInfo.HasKey(socket)) {
            clientType := ClientInfo[socket].type
            ; Skip TopBar connections, only show Nexus clients
            If (clientType = "topbar") {
                continue
            }
        }
        
        clientIndex++
        If (ClientInfo.HasKey(socket)) {
            clientName := ClientInfo[socket].HasKey("name") ? ClientInfo[socket].name : ""
            If (clientName != "" && clientName != " ") {
                displayName := clientName
            } Else {
                displayName := "Unknown"
            }
        } Else {
            displayName := "Pending..."
        }
        
        Gui, ClientSelector:Add, Checkbox, x10 y%yPos% w200 h20 vClientCheck%clientIndex%, %displayName%
        yPos += 25
    }
    
    ; Then, add remote clients (negative socket IDs in ClientInfo)
    For socket, info in ClientInfo {
        If (socket < 0) {  ; Remote client
            clientIndex++
            clientName := info.HasKey("name") ? info.name : ""
            If (clientName != "" && clientName != " ") {
                displayName := clientName . " [Remote]"
            } Else {
                displayName := "Unknown [Remote]"
            }
            
            Gui, ClientSelector:Add, Checkbox, x10 y%yPos% w200 h20 vClientCheck%clientIndex%, %displayName%
            yPos += 25
        }
    }
    
    ; Add HButtons below checkboxes
    buttonY := yPos + 5
    
    Theme1 := HBCustomButton()
    GuiButtonType1.SetSessionDefaults( Theme1.All , Theme1.Default , Theme1.Hover , Theme1.Pressed )
    
    New HButton( { Owner: ClientSelectorHwnd , X: 10 , Y: buttonY , W: 95 , H: 25 , Text: "Select All" , Label: "ClientSelectorSelectAll" } )
    New HButton( { Owner: ClientSelectorHwnd , X: 115 , Y: buttonY , W: 95 , H: 25 , Text: "Send" , Label: "ClientSelectorSend" } )
    
    cancelButtonY := buttonY + 30
    New HButton( { Owner: ClientSelectorHwnd , X: 10 , Y: cancelButtonY , W: 200 , H: 25 , Text: "Cancel" , Label: "ClientSelectorCancel" } )
    
    ; Calculate total height
    totalHeight := cancelButtonY + 35
    
    ; Position popup below Execute button
    popupX := topBarX + 400
    popupY := topBarY + topBarH
    Gui, ClientSelector:Show, x%popupX% y%popupY% w220 h%totalHeight%, Select Clients
    ClientSelectorVisible := true
Return

ClientSelectorSelectAll:
    Global Clients, ClientInfo
    
    ; Count total checkboxes (local Nexus clients + remote clients, skip TopBars)
    totalClients := 0
    For index, socket in Clients {
        If (ClientInfo.HasKey(socket)) {
            clientType := ClientInfo[socket].type
            If (clientType = "topbar") {
                continue
            }
        }
        totalClients++
    }
    For socket, info in ClientInfo {
        If (socket < 0) {  ; Remote client
            totalClients++
        }
    }
    
    ; Check if all are selected
    allSelected := true
    Loop, %totalClients%
    {
        GuiControlGet, isChecked, ClientSelector:, ClientCheck%A_Index%
        If (!isChecked) {
            allSelected := false
            Break
        }
    }
    
    ; If all selected, deselect all. Otherwise select all
    newState := allSelected ? 0 : 1
    Loop, %totalClients%
        GuiControl, ClientSelector:, ClientCheck%A_Index%, %newState%
Return

ClientSelectorSend:
    Global Clients, ClientInfo, ClientSelectorList, ClientSelectorVisible
    
    Gui, ClientSelector:Submit, NoHide
    
    ; Build list of selected clients (with their display names including [Remote] suffix)
    ClientSelectorList := ""
    clientIndex := 0
    
    ; Process local clients (only Nexus clients, skip TopBars)
    For index, socket in Clients {
        If (ClientInfo.HasKey(socket)) {
            clientType := ClientInfo[socket].type
            ; Skip TopBar connections
            If (clientType = "topbar") {
                continue
            }
        }
        
        clientIndex++
        GuiControlGet, isChecked, ClientSelector:, ClientCheck%clientIndex%
        
        If (isChecked) {
            If (ClientInfo.HasKey(socket)) {
                clientName := ClientInfo[socket].HasKey("name") ? ClientInfo[socket].name : ""
                If (clientName != "" && clientName != " ") {
                    ClientSelectorList .= clientName . "`n"
                } Else {
                    ClientSelectorList .= "Unknown`n"
                }
            }
        }
    }
    
    ; Process remote clients
    For socket, info in ClientInfo {
        If (socket < 0) {  ; Remote client
            clientIndex++
            GuiControlGet, isChecked, ClientSelector:, ClientCheck%clientIndex%
            
            If (isChecked) {
                clientName := info.HasKey("name") ? info.name : ""
                If (clientName != "" && clientName != " ") {
                    ClientSelectorList .= clientName . " [Remote]`n"
                } Else {
                    ClientSelectorList .= "Unknown [Remote]`n"
                }
            }
        }
    }
    
    Gui, ClientSelector:Destroy
    ClientSelectorVisible := false
    
    ; Now execute the command with selected clients
    Gosub, ExecuteCommand
Return

ClientSelectorCancel:
    Global ClientSelectorVisible
    Gui, ClientSelector:Destroy
    ClientSelectorVisible := false
Return

ExecuteCommand:
    Gui, TopBar:Submit, NoHide

    ; Map dropdown selection to network command
    If (CommandDropdown = "AutoFollow Toggle")
        command := "AUTOFOLLOW"
    Else If (CommandDropdown = "Character Select BD5")
        command := "CHARSELECT"
    Else If (CommandDropdown = "Get Coords") {
        ; Get Coords needs to be done sequentially, one window at a time
        ExecuteGetCoordsSequential()
        return
    }
    Else If (CommandDropdown = "Get Coords") {
        ; Get Coords needs to be done sequentially, one window at a time
        ExecuteGetCoordsSequential()
        return
    }
    Else If (CommandDropdown = "Buff All") {
        ; Buff All needs to be done sequentially, one window at a time
        ExecuteBuffSequential()
        return
    } Else If (CommandDropdown = "Come To Me") {
        ; Capture coordinates from screen
        coordX := ""
        coordY := ""
        GetCurrentCoordinatesFromScreen(coordX, coordY)
        
        If (coordX != "" && coordY != "") {
            ; Send navigate command with coordinates
            command := "NAVIGATETO:" . coordX . "|" . coordY
            ToolTip, Come To Me: X:%coordX% Y:%coordY%
            SetTimer, RemoveToolTip, -2000
        } Else {
            MsgBox, Could not capture coordinates from screen! Make sure a Rappelz window is visible.
            return
        }
    } Else If (CommandDropdown = "Load Path for All Clients") {
        ; Prompt user to select a path file
        FileSelectFile, selectedPath, 3, , Select a path file to load on all clients, INI Files (*.ini)
        If (ErrorLevel || selectedPath = "") {
            MsgBox, No file selected. Operation cancelled.
            Return
        }
        ; Read the entire file content
        FileRead, pathContent, %selectedPath%
        If (ErrorLevel) {
            MsgBox, Failed to read the selected file.
            Return
        }
        ; Encode the path content to send it (replace newlines with special marker)
        pathContent := StrReplace(pathContent, "`n", "<NL>")
        pathContent := StrReplace(pathContent, "`r", "")
        command := "LOADPATH:" . pathContent
    }
    Else If (CommandDropdown = "Start Healing")
        command := "STARTHEALING"
    Else If (CommandDropdown = "Stop Healing")
        command := "STOPHEALING"
    Else If (CommandDropdown = "Start DPS")
        command := "STARTDPS"
    Else If (CommandDropdown = "Stop DPS")
        command := "STOPDPS"
    Else If (CommandDropdown = "Setup DPS Navigation") {
        ; Prompt user for radius
        InputBox, radius, DPS Navigation Radius, Enter the radius for DPS Navigation (default: 100):, , 300, 130, , , , , 100
        If (ErrorLevel) {
            ; User cancelled
            return
        }
        ; Validate input
        If (radius = "" || radius < 1) {
            MsgBox, Invalid radius value! Using default of 100.
            radius := 100
        }
        
        ; Capture coordinates from screen
        coordX := ""
        coordY := ""
        GetCurrentCoordinatesFromScreen(coordX, coordY)
        
        If (coordX != "" && coordY != "") {
            ; Send command with coordinates and radius
            command := "SETUPDPSNAV:" . coordX . "|" . coordY . "|" . radius
            ToolTip, DPS Nav setup: X:%coordX% Y:%coordY% Radius:%radius%
            SetTimer, RemoveToolTip, -2000
        } Else {
            MsgBox, Could not capture coordinates from screen! Make sure a Rappelz window is visible.
            return
        }
    }
    Else If (CommandDropdown = "HV Out")
        command := "HVOUT"
    Else If (CommandDropdown = "Start Travel")
        command := "STARTTRAVEL"
    Else If (CommandDropdown = "Stop Travel")
        command := "STOPTRAVEL"
    Else 
        return ; Unknown command

    SendNetworkCommand(command)
return

SendNetworkCommand(command) {
    Global Clients, ClientInfo, ClientSelectorList
    
    ; Get selected clients from the popup selector
    selectedItems := ClientSelectorList
    
    ; If nothing selected, show error
    If (selectedItems = "") {
        MsgBox, Please select at least one client from the list
        return
    }
    
    ; Build array of selected client names
    selectedNames := []
    Loop, Parse, selectedItems, `n
    {
        If (A_LoopField != "")
            selectedNames.Push(A_LoopField)
    }
    
    If (selectedNames.MaxIndex() = "" || selectedNames.MaxIndex() = 0) {
        MsgBox, Please select at least one client
        return
    }

    ; Find the sockets for the selected client names and track remote clients
    targetSockets := []
    remoteTargets := []
    
    logFile := A_ScriptDir . "\topbar_debug.log"
    FileAppend, %A_Now% - SendNetworkCommand: Processing selected clients`n, %logFile%
    
    For idx, selectedName in selectedNames {
        FileAppend, %A_Now% -   Selected: "%selectedName%"`n, %logFile%
        ; Check if this is a remote client
        If (InStr(selectedName, "[Remote]")) {
            ; Extract client name (remove " [Remote]" suffix)
            clientName := StrReplace(selectedName, " [Remote]", "")
            FileAppend, %A_Now% -     Identified as REMOTE client: "%clientName%"`n, %logFile%
            remoteTargets.Push(clientName)
        } Else {
            ; Local client - extract name and find socket
            clientName := StrReplace(selectedName, " [Local]", "")
            FileAppend, %A_Now% -     Identified as LOCAL client: "%clientName%"`n, %logFile%
            For index, socket in Clients {
                If (ClientInfo.HasKey(socket)) {
                    socketClientName := ClientInfo[socket].HasKey("name") ? ClientInfo[socket].name : ""
                    If (socketClientName = clientName) {
                        FileAppend, %A_Now% -     Found local socket: %socket%`n, %logFile%
                        targetSockets.Push(socket)
                        Break
                    }
                }
            }
        }
    }
    
    ; Send command to local sockets
    If (targetSockets.MaxIndex() != "" && targetSockets.MaxIndex() > 0) {
        localCount := targetSockets.MaxIndex()
        FileAppend, %A_Now% - Sending to %localCount% local sockets`n, %logFile%
        message := command . "`n"
        bufferSize := StrPut(message, "CP0")
        
        For index, socket in targetSockets {
            FileAppend, %A_Now% -   Sending "%command%" to local socket %socket%`n, %logFile%
            VarSetCapacity(msgBuffer, bufferSize)
            StrPut(message, &msgBuffer, "CP0")
            AHKsock_Send(socket, &msgBuffer, bufferSize - 1)
        }
    }
    
    ; Send commands to remote clients via connected TopBar
    If (remoteTargets.MaxIndex() != "" && remoteTargets.MaxIndex() > 0) {
        remoteCount := remoteTargets.MaxIndex()
        FileAppend, %A_Now% - Sending to %remoteCount% remote clients via SendCommandToRemoteClients`n, %logFile%
        SendCommandToRemoteClients(remoteTargets, command)
    }
}

ExecuteBuffSequential() {
    Global Clients, ClientInfo, ClientSelectorList
    
    ; Get selected clients from the popup selector
    selectedItems := ClientSelectorList
    
    If (selectedItems = "") {
        MsgBox, Please select at least one client from the list
        return
    }
    
    ; Build array of selected client names and their sockets
    ; Separate local and remote clients
    targetSockets := []
    remoteTargets := []
    
    Loop, Parse, selectedItems, `n
    {
        If (A_LoopField != "") {
            selectedName := A_LoopField
            
            ; Check if this is a remote client
            If (InStr(selectedName, "[Remote]")) {
                ; Extract client name (remove " [Remote]" suffix)
                clientName := StrReplace(selectedName, " [Remote]", "")
                remoteTargets.Push(clientName)
            } Else {
                ; Local client - extract name and find socket
                clientName := StrReplace(selectedName, " [Local]", "")
                For index, socket in Clients {
                    If (ClientInfo.HasKey(socket)) {
                        socketClientName := ClientInfo[socket].HasKey("name") ? ClientInfo[socket].name : ""
                        If (socketClientName = clientName) {
                            targetSockets.Push(socket)
                            Break
                        }
                    }
                }
            }
        }
    }

    localCount := targetSockets.MaxIndex()
    remoteCount := remoteTargets.MaxIndex()
    If (localCount = "" || localCount = 0) {
        localCount := 0
    }
    If (remoteCount = "" || remoteCount = 0) {
        remoteCount := 0
    }
    
    logFile := A_ScriptDir . "\topbar_debug.log"
    FileAppend, %A_Now% - ExecuteBuffSequential: localCount=%localCount% remoteCount=%remoteCount%`n, %logFile%
    
    If (localCount = 0 && remoteCount = 0) {
        MsgBox, Could not find any valid clients
        return
    }

    ; Ask once for chat buffs
    useChatBuffs := 0
    chatBuffCommands := ""
    MsgBox, 4, Chat Buffs, Do you want to activate chat buffs?
    IfMsgBox Yes
    {
        useChatBuffs := 1
        ; Get chat buff commands
        InputBox, firstCommand, Chat Buff Command, Enter first chat command:, , 300, 120, , , , , /info
        if (!ErrorLevel && firstCommand != "") {
            chatBuffCommands := firstCommand
            
            ; Ask for more commands
            Loop {
                MsgBox, 4, More Commands?, Do you want to add another chat buff command?
                IfMsgBox No
                    break
                InputBox, nextCommand, Chat Buff Command, Enter next chat command:, , 300, 120
                if (ErrorLevel || nextCommand = "")
                    break
                chatBuffCommands .= "," . nextCommand
            }
        } else {
            useChatBuffs := 0
        }
    }

    ; Ask once for pet buffs
    usePetBuffs := 0
    MsgBox, 4, Pet Buffs, Do you want to activate both pet buffs (DT and Gnoll)?
    IfMsgBox Yes
    {
        usePetBuffs := 1
    }

    ; Send BUFF command to each LOCAL socket sequentially with parameters
    For index, socket in targetSockets {
        ; Format: BUFF:chatBuffs|petBuffs|commands
        buffCmd := "BUFF:" . useChatBuffs . "|" . usePetBuffs . "|" . chatBuffCommands
        message := buffCmd . "`n"
        bufferSize := StrPut(message, "CP0")
        VarSetCapacity(msgBuffer, bufferSize)
        StrPut(message, &msgBuffer, "CP0")
        AHKsock_Send(socket, &msgBuffer, bufferSize - 1)

        ; Wait between commands to allow each window to process
        Sleep, 60000
    }
    
    ; Send BUFF command to REMOTE clients via their TopBar
    If (remoteCount > 0) {
        buffCmd := "BUFF:" . useChatBuffs . "|" . usePetBuffs . "|" . chatBuffCommands
        SendCommandToRemoteClients(remoteTargets, buffCmd)
    }
}
ExecuteGetCoordsSequential() {
    Global Clients, ClientInfo, ClientSelectorList, RemoteClients
    
    ; Get selected clients from the popup selector
    selectedItems := ClientSelectorList
    
    ; If nothing selected, show error
    If (selectedItems = "") {
        MsgBox, Please select at least one client from the list
        return
    }
    
    ; Build array of selected client names
    selectedNames := []
    Loop, Parse, selectedItems, `n
    {
        If (A_LoopField != "")
            selectedNames.Push(A_LoopField)
    }
    
    If (selectedNames.MaxIndex() = "" || selectedNames.MaxIndex() = 0) {
        MsgBox, Please select at least one client
        return
    }

    ; Separate local and remote clients
    targetSockets := []
    remoteTargets := []
    
    Loop, Parse, selectedItems, `n
    {
        If (A_LoopField != "") {
            selectedName := A_LoopField
            
            ; Check if this is a remote client
            If (InStr(selectedName, "[Remote]")) {
                ; Extract client name (remove " [Remote]" suffix)
                clientName := StrReplace(selectedName, " [Remote]", "")
                remoteTargets.Push(clientName)
            } Else {
                ; Local client - extract name and find socket
                clientName := StrReplace(selectedName, " [Local]", "")
                For index, socket in Clients {
                    If (ClientInfo.HasKey(socket)) {
                        socketClientName := ClientInfo[socket].HasKey("name") ? ClientInfo[socket].name : ""
                        If (socketClientName = clientName) {
                            targetSockets.Push(socket)
                            Break
                        }
                    }
                }
            }
        }
    }

    localCount := targetSockets.MaxIndex()
    remoteCount := remoteTargets.MaxIndex()
    If (localCount = "" || localCount = 0) {
        localCount := 0
    }
    If (remoteCount = "" || remoteCount = 0) {
        remoteCount := 0
    }
    
    If (localCount = 0 && remoteCount = 0) {
        MsgBox, Could not find any valid clients
        return
    }

    ; First, capture coordinates from the screen
    coordX := ""
    coordY := ""
    GetCurrentCoordinatesFromScreen(coordX, coordY)

    ; Send GETCOORDS to each LOCAL socket sequentially
    For index, socket in targetSockets {
        message := "GETCOORDS`n"
        bufferSize := StrPut(message, "CP0")
        VarSetCapacity(msgBuffer, bufferSize)
        StrPut(message, &msgBuffer, "CP0")
        AHKsock_Send(socket, &msgBuffer, bufferSize - 1)

        ; Wait between commands to allow each window to process
        Sleep, 1000
    }
    
    ; Send GETCOORDS to REMOTE clients
    If (remoteCount > 0) {
        SendCommandToRemoteClients(remoteTargets, "GETCOORDS")
        ; Wait for remote clients to process
        Sleep, 1000
    }

    ; If we successfully captured coordinates, send them to all selected clients
    If (coordX != "" && coordY != "") {
        coordCmd := "SETCOORDS:" coordX "|" coordY
        message := coordCmd . "`n"
        bufferSize := StrPut(message, "CP0")
        
        ; Send to local clients
        For index, socket in targetSockets {
            VarSetCapacity(msgBuffer, bufferSize)
            StrPut(message, &msgBuffer, "CP0")
            AHKsock_Send(socket, &msgBuffer, bufferSize - 1)
        }
        
        ; Send to remote clients
        If (remoteCount > 0) {
            SendCommandToRemoteClients(remoteTargets, coordCmd)
        }
        
        ToolTip, Coordinates X:%coordX% Y:%coordY% sent to selected clients
        SetTimer, RemoveToolTip, -2000
    } Else {
        ToolTip, Could not capture coordinates from screen
        SetTimer, RemoveToolTip, -2000
    }
}

; ==========================================
; COORDINATE CAPTURE FUNCTION
; ==========================================
GetCurrentCoordinatesFromScreen(ByRef outX, ByRef outY) {
    global NavText
    outX := ""
    outY := ""

    ; Try to find any visible game window
    gameWindow := 0
    
    ; First try by exact title match (win1-win8)
    SetTitleMatchMode, 3
    Loop, 8 {
        WinGet, hwnd, ID, win%A_Index%
        if (hwnd) {
            ; Check if window is visible
            WinGet, winStyle, Style, ahk_id %hwnd%
            if (winStyle & 0x10000000) {  ; WS_VISIBLE
                gameWindow := hwnd
                break
            }
        }
    }
    
    ; If not found, try by window class
    if (!gameWindow) {
        WinGet, gameWindows, List, ahk_class Rappelz
        if (gameWindows > 0) {
            gameWindow := gameWindows1
        }
    }
    
    if (!gameWindow) {
        ; No game window found
        return
    }
    
    ; Use the found window
    WinGetPos, winX, winY,,, ahk_id %gameWindow%
    
    ; Define search area for coordinates (top-right of game window)
    searchX1 := winX + 835
    searchY1 := winY + 30
    searchX2 := winX + 1019
    searchY2 := winY + 48

    if (ok := FindText(x, y, searchX1, searchY1, searchX2, searchY2, 0, 0, NavText)) {
        results := []
        for i, v in ok {
            results.Push({x: v.x, id: v.id})
        }

        ; Sort results by x position (left to right)
        Loop % results.Length() - 1 {
            i := A_Index
            Loop % results.Length() - i {
                j := A_Index + i
                if (results[i].x > results[j].x) {
                    temp := results[i]
                    results[i] := results[j]
                    results[j] := temp
                }
            }
        }

        coordX := ""
        coordY := ""
        spaceFound := false

        ; Parse the digits - X coordinate first, then space, then Y coordinate
        for i, v in results {
            if (i > 1) {
                prevX := results[i-1].x
                gap := v.x - prevX
                if (gap > 9 && !spaceFound) {
                    spaceFound := true
                }
            }

            if (!spaceFound) {
                coordX .= v.id
            } else {
                coordY .= v.id
            }
        }

        outX := coordX + 0
        outY := coordY + 0
    }
}

RemoveToolTip:
    ToolTip
return

; ==========================================
; PID AUTO-REFRESH
; ==========================================
AutoRefreshPIDs:
    DetectRunningNexusScripts()
return

DetectRunningNexusScripts() {
    global NexusPIDs

    Loop, 8 {
        winFolder := "win" A_Index
        folderPath := A_ScriptDir "\" winFolder

        ; Clear old PID first
        NexusPIDs[winFolder] := ""

        ; Look for AutoHotkey processes
        for proc in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name='AutoHotkey.exe' OR Name='AutoHotkeyU64.exe' OR Name='AutoHotkeyU32.exe'") {
            cmdLine := proc.CommandLine
            ; Check if this process is running the Nexus script from this window's folder
            If (InStr(cmdLine, folderPath) && InStr(cmdLine, "Rappelz Automation Nexus.ahk")) {
                NexusPIDs[winFolder] := proc.ProcessId
                break
            }
        }
    }
}

; ==========================================
; NETWORK SERVER FUNCTIONS
; ==========================================
ServerEvents(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, iLength = 0) {
    Global Clients, ClientInfo

    ; Debug: Log all events to file
    logFile := A_ScriptDir . "\topbar_debug.log"
    FileAppend, %A_Now% - ServerEvent: %sEvent% Socket: %iSocket%`n, %logFile%

    If (sEvent = "ACCEPTED") {
        ; A client connected
        alreadyExists := False
        For index, socket in Clients {
            If (socket = iSocket) {
                alreadyExists := True
                Break
            }
        }

        If (!alreadyExists) {
            Clients.Push(iSocket)
            ClientInfo[iSocket] := {type: "unknown", ip: sAddr}
            ; Count clients for debug
            clientsCount := 0
            For idx, sock in Clients {
                clientsCount++
            }
            FileAppend, %A_Now% - ACCEPTED: Added socket %iSocket% to Clients array. Clients now has %clientsCount% sockets`n, %logFile%
            UpdateClientCount()
        } Else {
            FileAppend, %A_Now% - ACCEPTED: Socket %iSocket% already exists in Clients`n, %logFile%
        }

    } Else If (sEvent = "DISCONNECTED") {
        ; Client disconnected
        For index, socket in Clients {
            If (socket = iSocket) {
                Clients.RemoveAt(index)
                ClientInfo.Delete(iSocket)
                UpdateClientCount()
                Break
            }
        }

    } Else If (sEvent = "RECEIVED") {
        ; Received data from client
        data := StrGet(&bData, iLength, "CP0")
        
        ; Debug: Log raw data to file
        FileAppend, %A_Now% - RECEIVED data (length %iLength%): "%data%"`n, %logFile%
        
        data := StrReplace(data, "`n", "")
        data := StrReplace(data, "`r", "")

        FileAppend, %A_Now% - Processing data: "%data%"`n, %logFile%

        If (data != "") {
            ; Check if this is a handshake message (format: HANDSHAKE:TYPE or HANDSHAKE:TYPE:NAME)
            If (SubStr(data, 1, 10) = "HANDSHAKE:") {
                handshakeData := SubStr(data, 11)
                colonPos := InStr(handshakeData, ":")
                
                If (colonPos > 0) {
                    ; Has name: HANDSHAKE:TYPE:NAME
                    clientType := SubStr(handshakeData, 1, colonPos - 1)
                    clientName := SubStr(handshakeData, colonPos + 1)
                } Else {
                    ; No name: HANDSHAKE:TYPE
                    clientType := handshakeData
                    clientName := ""
                }
                
                ; Debug: Log parsed handshake
                logFile := A_ScriptDir . "\topbar_debug.log"
                FileAppend, %A_Now% - Handshake parsed - Type: %clientType% Name: "%clientName%"`n, %logFile%
                
                If (clientType = "TOPBAR" || clientType = "NEXUS") {
                    If (!ClientInfo.HasKey(iSocket)) {
                        ClientInfo[iSocket] := {}
                    }
                    StringLower, clientTypeLower, clientType
                    ClientInfo[iSocket].type := clientTypeLower
                    ClientInfo[iSocket].name := clientName
                    UpdateConnectedClientsList()
                    
                    ; If another TopBar connected, send our client list immediately
                    If (clientType = "TOPBAR") {
                        SendClientListToRemote(iSocket)
                    }
                }
                Return
            }
            
            ; Check if this is a CLIENT_LIST message from a connected TopBar
            If (SubStr(data, 1, 12) = "CLIENT_LIST:") {
                clientListData := SubStr(data, 13)
                logFile := A_ScriptDir . "\topbar_debug.log"
                FileAppend, %A_Now% - ServerEvents: Processing CLIENT_LIST from socket %iSocket%: "%clientListData%"`n, %logFile%
                UpdateRemoteClientList(clientListData, iSocket)
                Return
            }
            
            ; Check if this is a REQUEST_CLIENT_LIST message
            If (data = "REQUEST_CLIENT_LIST") {
                SendClientListToRemote(iSocket)
                Return
            }
            
            ; Check if this is a targeted command: TARGET:ClientName:COMMAND
            If (SubStr(data, 1, 7) = "TARGET:") {
                targetData := SubStr(data, 8)
                colonPos := InStr(targetData, ":")
                If (colonPos > 0) {
                    targetName := SubStr(targetData, 1, colonPos - 1)
                    actualCommand := SubStr(targetData, colonPos + 1)
                    logFile := A_ScriptDir . "\topbar_debug.log"
                    FileAppend, %A_Now% - ServerEvent: Received TARGET command for "%targetName%": "%actualCommand%"`n, %logFile%
                    ; Send to the specific local client
                    SendCommandToNamedClient(targetName, actualCommand)
                }
                Return
            }

            ; Check if sender is a TopBar - if so, relay to all Nexus clients
            If (ClientInfo.HasKey(iSocket) && ClientInfo[iSocket].type = "topbar") {
                ; Relay to all Nexus clients only
                SendCommandToNexusClients(data)
            } Else {
                ; From Nexus client - broadcast to all other clients EXCEPT sender
                SendCommandToAll(data, iSocket)
            }
        }
    } Else {
        ; Log unknown events
        logFile := A_ScriptDir . "\topbar_debug.log"
        FileAppend, %A_Now% - Unknown event: %sEvent%`n, %logFile%
    }
}

UpdateClientCount() {
    Global Clients
    count := Clients.Length()

    ; Set color to green if 1+ clients, white if 0
    If (count > 0) {
        Gui, TopBar:Font, cLime
        GuiControl, TopBar:Font, ClientCount
        GuiControl, TopBar:, ClientCount, %count% Client(s)
    } Else {
        Gui, TopBar:Font, cWhite
        GuiControl, TopBar:Font, ClientCount
        GuiControl, TopBar:, ClientCount, %count% Client(s)
    }
    
    UpdateConnectedClientsList()
}

UpdateConnectedClientsList() {
    ; This function is kept for compatibility but no longer updates GUI
    ; Client list is now shown via ShowClientListPopup
    
    ; If we're connected to another TopBar, send them our updated client list
    Global MasterSocket, ConnectedToMaster, Clients, ClientInfo
    
    ; Debug: Log state
    logFile := A_ScriptDir . "\topbar_debug.log"
    FileAppend, %A_Now% - UpdateConnectedClientsList called. ConnectedToMaster=%ConnectedToMaster% MasterSocket=%MasterSocket%`n, %logFile%
    
    If (ConnectedToMaster && MasterSocket != -1) {
        SendClientListToRemote(MasterSocket)
    }
    
    ; Also send to any TopBar clients connected to us
    For index, socket in Clients {
        If (ClientInfo.HasKey(socket) && ClientInfo[socket].type = "topbar") {
            SendClientListToRemote(socket)
        }
    }
    
    Return
}

ShowClientListPopup:
    Global Clients, ClientInfo, TopBarHwnd, ClientListPopupVisible
    
    ClientListPopupVisible := true
    
    ; Build client list
    clientList := ""
    
    ; Show local clients
    For index, socket in Clients {
        If (ClientInfo.HasKey(socket)) {
            clientType := ClientInfo[socket].type
            clientName := ClientInfo[socket].HasKey("name") ? ClientInfo[socket].name : ""
            
            If (clientName != "" && clientName != " ") {
                clientList .= clientName . " (" . clientType . ")`n"
            } Else {
                clientList .= "Unknown (" . clientType . ")`n"
            }
        } Else {
            clientList .= "Pending...`n"
        }
    }
    
    ; Show remote clients (negative socket IDs)
    For socket, info in ClientInfo {
        If (socket < 0) {  ; Remote client
            clientType := info.type
            clientName := info.HasKey("name") ? info.name : ""
            
            If (clientName != "" && clientName != " ") {
                clientList .= clientName . " (" . clientType . ")`n"
            }
        }
    }
    
    If (clientList = "") {
        clientList := "No clients connected"
    }
    
    ; Get TopBar position
    WinGetPos, topBarX, topBarY, topBarW, topBarH, ahk_id %TopBarHwnd%
    
    ; Create popup
    Gui, ClientListPopup:Destroy
    Gui, ClientListPopup:+AlwaysOnTop +ToolWindow -Caption +Border
    Gui, ClientListPopup:+HwndClientListPopupHwnd
    Gui, ClientListPopup:Color, %BarBackgroundColor%
    Gui, ClientListPopup:Font, s9 cWhite, Segoe UI
    
    Gui, ClientListPopup:Add, Text, x10 y10 w200 h20, Connected Clients:
    Gui, ClientListPopup:Add, Edit, x10 y35 w200 h120 ReadOnly, %clientList%
    
    Theme1 := HBCustomButton()
    GuiButtonType1.SetSessionDefaults( Theme1.All , Theme1.Default , Theme1.Hover , Theme1.Pressed )
    New HButton( { Owner: ClientListPopupHwnd , X: 10 , Y: 160 , W: 200 , H: 25 , Text: "Close" , Label: "CloseClientListPopup" } )
    
    ; Position popup below the ? button
    popupX := topBarX + 640
    popupY := topBarY + topBarH
    Gui, ClientListPopup:Show, x%popupX% y%popupY% w220 h195, Connected Clients
Return

CloseClientListPopup:
    Global ClientListPopupVisible
    Gui, ClientListPopup:Destroy
    ClientListPopupVisible := false
Return

ShutdownAll:
    MsgBox, 4, Shutdown All, Are you sure you want to shutdown all clients and close the launcher?
    IfMsgBox, No
        Return
    
    ; Close all SFrame.exe windows using the same method as MultiLaunch
    DetectHiddenWindows, Off
    WinGet, sframe_count, list, ahk_class SFRAME
    Loop, %sframe_count%
    {
        this_id := sframe_count%A_Index%
        WinClose, ahk_id %this_id%
    }
    
    ; Wait a moment for graceful close
    Sleep, 1000
    
    ; Force kill any remaining SFrame processes
    WinGet, sframe_count2, list, ahk_class SFRAME
    Loop, %sframe_count2%
    {
        this_id := sframe_count2%A_Index%
        WinKill, ahk_id %this_id%
    }
    
    ; Kill SFrame.exe process directly
    Loop 20 {
        Process, Close, SFrame.exe
        Sleep, 200
        Process, Exist, SFrame.exe
        If (!ErrorLevel)
            Break
    }
    
    ; Kill all Nexus client processes (win1-win8)
    nexusScripts := ["Rappelz Automation Nexus win1.ahk", "Rappelz Automation Nexus win2.ahk", "Rappelz Automation Nexus win3.ahk", "Rappelz Automation Nexus win4.ahk", "Rappelz Automation Nexus win5.ahk", "Rappelz Automation Nexus win6.ahk", "Rappelz Automation Nexus win7.ahk", "Rappelz Automation Nexus win8.ahk"]
    
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    For index, scriptName in nexusScripts {
        WinClose, %scriptName% ahk_class AutoHotkey
        WinKill, %scriptName% ahk_class AutoHotkey
    }
    
    ; Wait for scripts to close
    Sleep, 500
    
    ; Close MultiLaunch GUI
    DetectHiddenWindows, Off
    WinClose, Rappelz Multi-Client Launcher ahk_class AutoHotkeyGUI
    Sleep, 200
    WinKill, Rappelz Multi-Client Launcher ahk_class AutoHotkeyGUI
    
    ; Force kill MultiLaunch process
    Process, Close, MultiLaunch.exe
    Process, Close, MultiLaunch.ahk
    
    ; Close network connections
    AHKsock_Close()
    
    ; Exit this script
    ExitApp
Return

SendCommandToAll(command, excludeSocket := "") {
    Global Clients, MasterSocket, ConnectedToMaster

    ; If connected to master TopBar, send to master instead
    If (ConnectedToMaster && MasterSocket != -1) {
        message := command . "`n"
        bufferSize := StrPut(message, "CP0")
        VarSetCapacity(msgBuffer, bufferSize)
        StrPut(message, &msgBuffer, "CP0")
        AHKsock_Send(MasterSocket, &msgBuffer, bufferSize - 1)
        Return
    }

    If (Clients.MaxIndex() = "" || Clients.MaxIndex() = 0) {
        return
    }

    message := command . "`n"
    bufferSize := StrPut(message, "CP0")

    For index, socket in Clients {
        If (excludeSocket != "" && socket = excludeSocket)
            Continue

        VarSetCapacity(msgBuffer, bufferSize)
        StrPut(message, &msgBuffer, "CP0")
        AHKsock_Send(socket, &msgBuffer, bufferSize - 1)
    }
}

SendCommandToNexusClients(command) {
    Global Clients, ClientInfo

    If (Clients.MaxIndex() = "" || Clients.MaxIndex() = 0) {
        return
    }

    message := command . "`n"
    bufferSize := StrPut(message, "CP0")

    For index, socket in Clients {
        ; Only send to Nexus clients
        If (ClientInfo.HasKey(socket) && ClientInfo[socket].type = "nexus") {
            VarSetCapacity(msgBuffer, bufferSize)
            StrPut(message, &msgBuffer, "CP0")
            AHKsock_Send(socket, &msgBuffer, bufferSize - 1)
        }
    }
}

; Send command to a specific client by name (for remote targeting)
SendCommandToNamedClient(clientName, command) {
    Global Clients, ClientInfo
    
    For index, socket in Clients {
        If (ClientInfo.HasKey(socket) && ClientInfo[socket].type = "nexus") {
            socketClientName := ClientInfo[socket].HasKey("name") ? ClientInfo[socket].name : ""
            If (socketClientName = clientName) {
                message := command . "`n"
                bufferSize := StrPut(message, "CP0")
                VarSetCapacity(msgBuffer, bufferSize)
                StrPut(message, &msgBuffer, "CP0")
                AHKsock_Send(socket, &msgBuffer, bufferSize - 1)
                Return
            }
        }
    }
}

; Send commands to remote clients via connected TopBar
SendCommandToRemoteClients(clientNames, command) {
    Global MasterSocket, ConnectedToMaster, ClientInfo
    
    logFile := A_ScriptDir . "\topbar_debug.log"
    clientCount := clientNames.MaxIndex()
    FileAppend, %A_Now% - SendCommandToRemoteClients called. Command="%command%"`n, %logFile%
    FileAppend, %A_Now% - ClientNames count: %clientCount%`n, %logFile%
    For idx, name in clientNames {
        FileAppend, %A_Now% -   Client %idx%: "%name%"`n, %logFile%
    }
    
    FileAppend, %A_Now% - Current state: ConnectedToMaster=%ConnectedToMaster% MasterSocket=%MasterSocket%`n, %logFile%
    
    ; Determine if we're acting as client or server
    ; Client mode: use MasterSocket
    ; Server mode: find the TopBar socket that owns these remote clients
    
    If (ConnectedToMaster && MasterSocket != -1) {
        ; Client mode - send to master TopBar
        FileAppend, %A_Now% - Running in CLIENT mode. MasterSocket=%MasterSocket%`n, %logFile%
        For index, clientName in clientNames {
            targetMsg := "TARGET:" . clientName . ":" . command . "`n"
            FileAppend, %A_Now% - Sending to master: "%targetMsg%" via socket %MasterSocket%`n, %logFile%
            bufferSize := StrPut(targetMsg, "CP0")
            VarSetCapacity(msgBuffer, bufferSize)
            StrPut(targetMsg, &msgBuffer, "CP0")
            sendResult := AHKsock_Send(MasterSocket, &msgBuffer, bufferSize - 1)
            FileAppend, %A_Now% - AHKsock_Send result: %sendResult%`n, %logFile%
        }
    } Else {
        ; Server mode - find source TopBar sockets for these remote clients
        FileAppend, %A_Now% - Running in SERVER mode. ConnectedToMaster=%ConnectedToMaster% MasterSocket=%MasterSocket%`n, %logFile%
        
        targetSockets := {}
        For index, clientName in clientNames {
            FileAppend, %A_Now% - Looking for remote client: "%clientName%"`n, %logFile%
            ; Find the remote client's source socket
            found := false
            For socket, info in ClientInfo {
                If (socket < 0 && info.HasKey("name") && info.name = clientName) {
                    FileAppend, %A_Now% -   Found socket %socket% for "%clientName%"`n, %logFile%
                    If (info.HasKey("sourceSocket")) {
                        sourceSocket := info.sourceSocket
                        FileAppend, %A_Now% -   SourceSocket: %sourceSocket%`n, %logFile%
                        If (!targetSockets.HasKey(sourceSocket)) {
                            targetSockets[sourceSocket] := []
                        }
                        targetSockets[sourceSocket].Push(clientName)
                        found := true
                    } Else {
                        FileAppend, %A_Now% -   ERROR: No sourceSocket field!`n, %logFile%
                    }
                    Break
                }
            }
            If (!found) {
                FileAppend, %A_Now% -   ERROR: Client "%clientName%" not found in ClientInfo!`n, %logFile%
            }
        }
        
        ; Send TARGET commands to each source TopBar socket
        socketsCount := 0
        For sourceSocket, names in targetSockets {
            socketsCount++
        }
        FileAppend, %A_Now% - Sending to %socketsCount% target sockets`n, %logFile%
        For sourceSocket, names in targetSockets {
            FileAppend, %A_Now% - Sending to sourceSocket %sourceSocket%:`n, %logFile%
            For index, clientName in names {
                targetMsg := "TARGET:" . clientName . ":" . command . "`n"
                FileAppend, %A_Now% -   Sending: "%targetMsg%"`n, %logFile%
                bufferSize := StrPut(targetMsg, "CP0")
                VarSetCapacity(msgBuffer, bufferSize)
                StrPut(targetMsg, &msgBuffer, "CP0")
                AHKsock_Send(sourceSocket, &msgBuffer, bufferSize - 1)
            }
        }
    }
}

; Update the remote clients list when receiving from connected TopBar
UpdateRemoteClientList(clientListData, sourceSocket) {
    Global RemoteClients, ClientInfo
    
    logFile := A_ScriptDir . "\topbar_debug.log"
    FileAppend, %A_Now% - UpdateRemoteClientList called with: "%clientListData%" from socket %sourceSocket%`n, %logFile%
    
    ; Clear existing remote clients from THIS TopBar (same sourceSocket)
    ; Remote clients have negative socket IDs to distinguish them
    For socket, info in ClientInfo {
        If (socket < 0 && info.HasKey("sourceSocket") && info.sourceSocket = sourceSocket) {
            ClientInfo.Delete(socket)
        }
    }
    
    ; Clear existing remote clients
    RemoteClients := {}
    
    ; Parse comma-separated list and add to ClientInfo
    If (clientListData != "") {
        remoteSocketID := -1000  ; Start with negative ID
        Loop, Parse, clientListData, `,
        {
            If (A_LoopField != "") {
                RemoteClients[A_LoopField] := true
                ; Add to ClientInfo so it shows in the client list
                ; CRITICAL: Store sourceSocket so we know which TopBar owns this client
                ClientInfo[remoteSocketID] := {type: "remote-nexus", name: A_LoopField, ip: "remote", sourceSocket: sourceSocket}
                FileAppend, %A_Now% - Added remote client: Socket=%remoteSocketID% Name="%A_LoopField%" SourceSocket=%sourceSocket%`n, %logFile%
                remoteSocketID--
            }
        }
    }
    
    ; Count ClientInfo entries for debug
    clientInfoCount := 0
    For socket, info in ClientInfo {
        clientInfoCount++
    }
    FileAppend, %A_Now% - UpdateRemoteClientList complete. ClientInfo now has %clientInfoCount% entries`n, %logFile%
    
    ; Note: We don't call UpdateClientCount() here to avoid infinite loop
    ; The remote client list will be visible when clicking the ? button
}

; Send our client list to a connected TopBar
SendClientListToRemote(targetSocket) {
    Global Clients, ClientInfo
    
    logFile := A_ScriptDir . "\topbar_debug.log"
    
    ; Debug: Log Clients array
    clientsCount := 0
    For index, socket in Clients {
        clientsCount++
    }
    FileAppend, %A_Now% - SendClientListToRemote: Clients array has %clientsCount% sockets`n, %logFile%
    
    ; Build comma-separated list of our Nexus client names
    clientList := ""
    For index, socket in Clients {
        ; Debug each socket
        hasKey := ClientInfo.HasKey(socket)
        If (hasKey) {
            socketType := ClientInfo[socket].type
            socketName := ClientInfo[socket].HasKey("name") ? ClientInfo[socket].name : ""
            FileAppend, %A_Now% -   Socket %socket%: type="%socketType%" name="%socketName%"`n, %logFile%
        } Else {
            FileAppend, %A_Now% -   Socket %socket%: NOT IN ClientInfo`n, %logFile%
        }
        
        If (ClientInfo.HasKey(socket) && ClientInfo[socket].type = "nexus") {
            clientName := ClientInfo[socket].HasKey("name") ? ClientInfo[socket].name : ""
            If (clientName != "") {
                If (clientList != "")
                    clientList .= ","
                clientList .= clientName
            }
        }
    }
    
    ; Debug: Log what we're sending
    FileAppend, %A_Now% - Sending CLIENT_LIST to socket %targetSocket%: "%clientList%"`n, %logFile%
    
    ; Send CLIENT_LIST message
    message := "CLIENT_LIST:" . clientList . "`n"
    bufferSize := StrPut(message, "CP0")
    VarSetCapacity(msgBuffer, bufferSize)
    StrPut(message, &msgBuffer, "CP0")
    AHKsock_Send(targetSocket, &msgBuffer, bufferSize - 1)
}

; ==========================================
; EXIT HANDLER
; ==========================================
GuiClose:
TopBarGuiClose:
    AHKsock_Close()
ExitApp
return

; ==========================================
; AHKSOCK LIBRARY - Complete Winsock Implementation
; ==========================================
/*! TheGood
    AHKsock - A simple AHK implementation of Winsock.
    http://www.autohotkey.com/forum/viewtopic.php?p=355775
    Last updated: January 19, 2011
    
FUNCTION LIST:

________________________________________
AHKsock_Listen(sPort, sFunction = False)

Tells AHKsock to listen on the port in sPort, and call the function in sFunction when events occur. If sPort is a port on
which AHKsock is already listening, the action taken depends on sFunction:
    - If sFunction is False, AHKsock will stop listening on the port in sPort.
    - If sFunction is "()", AHKsock will return the name of the current function AHKsock calls when
      a client connects on the port in sPort.
    - If sFunction is a valid function, AHKsock will set that function as the new function to call
      when a client connects on the port in sPort.

Returns blank on success. On failure, it returns one of the following positive integer:
    2: sFunction is not a valid function.
    3: The WSAStartup() call failed. The error is in ErrorLevel.
    4: The Winsock DLL does not support version 2.2.
    5: The getaddrinfo() call failed. The error is in ErrorLevel.
    6: The socket() call failed. The error is in ErrorLevel.
    7: The bind() call failed. The error is in ErrorLevel.
    8: The WSAAsyncSelect() call failed. The error is in ErrorLevel.
    9: The listen() call failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

See the section titled "STRUCTURE OF THE EVENT-HANDLING FUNCTION AND MORE INFO ABOUT SOCKETS" for more info about how the
function in sFunction interacts with AHKsock.

________________________________________
AHKsock_Connect(sName, sPort, sFunction)

Tells AHKsock to connect to the hostname or IP address in sName on the port in sPort, and call the function in sFunction
when events occur.

Although the function will return right away, the connection attempt will still be in progress. Once the connection attempt
is over, successful or not, sFunction will receive the CONNECTED event. Note that it is important that once AHKsock_Connect
returns, the current thread must stay (or soon after must become) interruptible so that sFunction can be called once the
connection attempt is over.

AHKsock_Connect can only be called again once the previous connection attempt is over. To check if AHKsock_Connect is ready
to make another connection attempt, you may keep polling it by calling AHKsock_Connect(0,0,0) until it returns False.

Returns blank on success. On failure, it returns one of the following positive integer:
    1: AHKsock_Connect is still processing a connection attempt. ErrorLevel contains the name and the port of that
       connection attempt, separated by a tab.
    2: sFunction is not a valid function.
    3: The WSAStartup() call failed. The error is in ErrorLevel.
    4: The Winsock DLL does not support version 2.2.
    5: The getaddrinfo() call failed. The error is in ErrorLevel.
    6: The socket() call failed. The error is in ErrorLevel.
    7: The WSAAsyncSelect() call failed. The error is in ErrorLevel.
    8: The connect() call failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

See the section titled "STRUCTURE OF THE EVENT-HANDLING FUNCTION AND MORE INFO ABOUT SOCKETS" for more info about how the
function in sFunction interacts with AHKsock.
-+
_______________________________________
AHKsock_Send(iSocket, ptrData, iLength)

Sends the data of length iLength to which ptrData points to the connected socket in iSocket.

Returns the number of bytes sent on success. This can be less than the number requested to be sent in the iLength parameter,
i.e. between 1 and iLength. This would occur if no buffer space is available within the transport system to hold the data to
be transmitted, in which case the number of bytes sent can be between 1 and the requested length, depending on buffer
availability on both the client and server computers. On failure, it returns one of the following negative integer:
    -1: WSAStartup hasn't been called yet.
    -2: Received WSAEWOULDBLOCK. This means that calling send() would have blocked the thread.
    -3: The send() call failed. The error is in ErrorLevel.
    -4: The socket specified in iSocket is not a valid socket. This means either that the socket in iSocket hasn't been
        created using AHKsock_Connect or AHKsock_Listen, or that the socket has already been destroyed.
    -5: The socket specified in iSocket is not cleared for sending. You haven't waited for the SEND event before calling,
        either ever, or not since you last received WSAEWOULDBLOCK.

You may start sending data to the connected socket in iSocket only after the socket's associated function receives the first
SEND event. Upon receiving the event, you may keep calling AHKsock_Send to send data until you receive the error -2, at
which point you must wait once again until you receive another SEND event before sending more data. Not waiting for the SEND
event results in receiving error -5 when calling AHKsock_Send.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

____________________________________________
AHKsock_ForceSend(iSocket, ptrData, iLength)

This function is exactly the same as AHKsock_Send, but with three differences:
    - If only part of the data could be sent, it will automatically keep trying to send the remaining part.
    - If it receives WSAEWOULDBLOCK, it will wait for the socket's SEND event and try sending the data again.
    - If the data buffer to send is larger than the socket's send buffer size, it will automatically send the data in
      smaller chunks in order to avoid a performance hit. See http://support.microsoft.com/kb/823764 for more info.

Therefore, AHKsock_ForceSend will return only when all the data has been sent. Because this function relies on waiting for
the socket's SEND event before continuing to send data, it cannot be called in a critical thread. Also, for the same reason,
it cannot be called from a socket's associated function (not specifically iSocket's associated function, but any socket's
associated function).

Another limitation to consider when choosing between AHKsock_Send and AHKsock_ForceSend is that AHKsock_ForceSend will not
return until all the data has been sent (unless an error occurs). Although the script will still be responsive (new threads
will still be able to launch), the thread from which it was called will not resume until it returns. Therefore, if sending
a large amount of data, you should either use AHKsock_Send, or use AHKsock_ForceSend by feeding it smaller pieces of the
data, allowing you to update the GUI if necessary (e.g. a progress bar).

Returns blank on success, which means that all the data to which ptrData points of length iLength has been sent. On failure,
it returns one of the following negative integer:
    -1: WSAStartup hasn't been called yet.
    -3: The send() call failed. The error is in ErrorLevel.
    -4: The socket specified in iSocket is not a valid socket. This means either that the socket in iSocket hasn't been
        created using AHKsock_Connect or AHKsock_Listen, or that the socket has already been destroyed.
    -5: The current thread is critical.
    -6: The getsockopt() call failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

____________________________________________
AHKsock_Close(iSocket = -1, iTimeout = 5000)

Closes the socket in iSocket. If no socket is specified, AHKsock_Close will close all the sockets on record, as well as
terminate use of the Winsock 2 DLL (by calling WSACleanup). If graceful shutdown cannot be attained after the timeout
specified in iTimeout (in milliseconds), it will perform a hard shutdown before calling WSACleanup to free resources. See
the section titled "NOTES ON CLOSING SOCKETS AND AHKsock_Close" for more information.

Returns blank on success. On failure, it returns one of the following positive integer:
    1: The shutdown() call failed. The error is in ErrorLevel. AHKsock_Close forcefully closed the socket and freed the
       associated resources.

Note that when AHKsock_Close is called with no socket specified, it will never return an error.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

___________________________________________________________
AHKsock_GetAddrInfo(sHostName, ByRef sIPList, bOne = False)

Retrieves the list of IP addresses that correspond to the hostname in sHostName. The list is contained in sIPList, delimited
by newline characters. If bOne is True, only one IP (the first one) will be returned.

Returns blank on success. On failure, it returns one of the following positive integer:
    1: The WSAStartup() call failed. The error is in ErrorLevel.
    2: The Winsock DLL does not support version 2.2.
    3: Received WSAHOST_NOT_FOUND. No such host is known.
    4: The getaddrinfo() call failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

_________________________________________________________________________
AHKsock_GetNameInfo(sIP, ByRef sHostName, sPort = 0, ByRef sService = "")

Retrieves the hostname that corresponds to the IP address in sIP. If a port in sPort is supplied, it also retrieves the
service that corresponds to the port in sPort.

Returns blank on success. On failure, it returns on of the following positive integer:
    1: The WSAStartup() call failed. The error is in ErrorLevel.
    2: The Winsock DLL does not support version 2.2.
    3: The IP address supplied in sIP is invalid.
    4: The getnameinfo() call failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

______________________________________________
AHKsock_SockOpt(iSocket, sOption, iValue = -1)

Retrieves or sets a socket option. Supported options are:
    SO_KEEPALIVE: Enable/Disable sending keep-alives. iValue must be True/False to enable/disable. Disabled by default.
    SO_SNDBUF:    Total buffer space reserved for sends. Set iValue to 0 to completely disable the buffer. Default is 8 KB.
    SO_RCVBUF:    Total buffer space reserved for receives. Default is 8 KB.
    TCP_NODELAY:  Enable/Disable the Nagle algorithm for send coalescing. Set iValue to True to disable the Nagle algorithm,
                  set iValue to False to enable the Nagle algorithm, which is the default.

It is usually best to leave these options to their default (especially the Nagle algorithm). Only change them if you
understand the consequences. See MSDN for more information on those options.

If iValue is specified, it sets the option to iValue and returns blank on success. If iValue is left as -1, it returns the
value of the option specified. On failure, it returns one of the following negative integer:
    -1: The getsockopt() failed. The error is in ErrorLevel.
    -2: The setsockopt() failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

_______________________________________
AHKsock_Settings(sSetting, sValue = "")

Changes the AHKsock setting in sSetting to sValue. If sValue is blank, the current value for that setting is returned. If
sValue is the word "Reset", the setting is restored to its default value. The possible settings are:
    Message: Determines the Windows message numbers used to monitor network events. The message number in iMessage and the
             next number will be used. Default value is 0x8000. For example, calling AHKsock_Settings("Message", 0x8005)
             will cause AHKsock to use 0x8005 and 0x8006 to monitor network events.
    Buffer:  Determines the size of the buffer (in bytes) used when receiving data. This is thus the maximum size of bData
             when the RECEIVED event is raised. If the data received is more than the buffer size, multiple recv() calls
             (and thus multiple RECEIVED events) will be needed. Note that you shouldn't use this setting as a means of
             delimiting frames. See the "NOTES ON RECEIVING AND SENDING DATA" section for more information about receiving
             and sending data. Default value is 64 KB, which is the maximum for TCP.

If you do call AHKsock_Settings to change the values from their default ones, it is best to do so at the beginning of the
script. The message number used cannot be changed as long as there are active connections.

______________________________________
AHKsock_ErrorHandler(sFunction = """")

Sets the function in sFunction to be the new error handler. If sFunction is left at its default value, it returns the name
of the current error handling function.

An error-handling function is optional, but may be useful when troubleshooting applications. The function will be called
anytime there is an error that arises in a thread which wasn't called by the user but by the receival of a Windows message
which was registered using OnMessage.

The function in sFunction must be of the following format:
MyErrorHandler(iError, iSocket)

The possible values for iError are:
     1: The connect() call failed. The error is in ErrorLevel.
     2: The WSAAsyncSelect() call failed. The error is in ErrorLevel.
     3: The socket() call failed. The error is in ErrorLevel.
     4: The WSAAsyncSelect() call failed. The error is in ErrorLevel.
     5: The connect() call failed. The error is in ErrorLevel.
     6: FD_READ event received with an error. The error is in ErrorLevel. The socket is in iSocket.
     7: The recv() call failed. The error is in ErrorLevel. The socket is in iSocket.
     8: FD_WRITE event received with an error. The error is in ErrorLevel. The socket is in iSocket.
     9: FD_ACCEPT event received with an error. The error is in ErrorLevel. The socket is in iSocket.
    10: The accept() call failed. The error is in ErrorLevel. The listening socket is in iSocket.
    11: The WSAAsyncSelect() call failed. The error is in ErrorLevel. The listening socket is in iSocket.
    12: The listen() call failed. The error is in ErrorLevel. The listening socket is in iSocket.
    13: The shutdown() call failed. The error is in ErrorLevel. The socket is in iSocket.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

__________________________________________________________________
NOTES ON SOCKETS AND THE STRUCTURE OF THE EVENT-HANDLING FUNCTION:

The functions used in the sFunction parameter of AHKsock_Listen and AHKsock_Connect must be of the following format:

MyFunction(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, bDataLength = 0)

The variable sEvent contains the event for which MyFunction was called. The event raised is associated with one and only one
socket; the one in iSocket. The meaning of the possible events that can occur depend on the type of socket involved. AHKsock
deals with three different types of sockets:
    - Listening sockets: These sockets are created by a call to AHKsock_Listen. All they do is wait for clients to request
      a connection. These sockets will never appear as the iSocket parameter because requests for connections are
      immediately accepted, and MyFunction immediately receives the ACCEPTED event with iSocket set to the accepted socket.
    - Accepted sockets: These sockets are created once a listening socket receives an incoming connection attempt from a
      client and accepts it. They are thus the sockets that servers use to communicate with clients.
    - Connected sockets: These sockets are created by a successful call to AHKsock_Connect. These are the sockets that
      clients use to communicate with servers.

More info about sockets:
    - You may have multiple client sockets connecting to the same listening socket (ie. on the same port).
    - You may have multiple listening sockets for different ports.
    - You cannot have more than one listening socket for the same port (or you will receive a bind() error).
    - Every single connection between a client and a server will have its own client socket on the client side, and its own
      server (accepted) socket on the server side.

For all of the events that the event-handling function receives,
    - sEvent contains the event that occurred (as described below),
    - iSocket contains the socket on which the event occurred,
    - sName contains a value which depends on the type of socket in iSocket:
        - If the socket is an accepted socket, sName is empty.
        - If the socket is a connected socket, sName is the same value as the sName parameter that was used when
          AHKsock_Connect was called to create the socket. Since AHKsock_Connect accepts both hostnames and IP addresses,
          sName may contain either.
    - sAddr contains the IP address of the socket's endpoint (i.e. the peer's IP address). This means that if the socket in
      iSocket is an accepted socket, sAddr contains the IP address of the client. Conversely, if it is a connected socket,
      sAddr contains the server's IP.
    - sPort contains the server port on which the connection was accepted.

Obviously, if your script only calls AHKsock_Listen (acting as a server) or AHKsock_Connect (acting as a client) you don't
need to check if the socket in iSocket is an accepted socket or a connected socket, since it can only be one or the other.
But if you do call both AHKsock_Listen and AHKsock_Connect with both of them using the same function (e.g. MyFunction), then
you will need to check what type of socket iSocket is by checking the sName parameter.

Of course, it would be easier to simply have two different functions, for example, MyFunction1 and MyFunction2, with one
handling the server part and the other handling the client part so that you don't need to check what type of socket iSocket
is when each function is called. However, this might not be necessary if both server and client are "symmetrical" (i.e. the
conversation doesn't actually change whether or not we're on the server side or the client side). See Example 3 for an
example of this, where only one function is used for both server and client sockets.

The variable sEvent can be one of the following values if iSocket is an accepted socket:
    sEvent =      Event Description:
    ACCEPTED      A client connection was accepted (see the "Listening sockets" section above for more details).
    CONNECTED     <Does not occur on accepted sockets>
    DISCONNECTED  The client disconnected (see AHKsock_Close for more details).
    SEND          You may now send data to the client (see AHKsock_Send for more details).
    RECEIVED      You received data from the client. The data received is in bData and the length is in bDataLength.
    SENDLAST      The client is disconnecting. This is your last chance to send data to it. Once this function returns,
                  disconnection will occur. This event only occurs on the side which did not initiate shutdown (see
                  AHKsock_Close for more details).

The variable sEvent can be one of the following values if iSocket is a connected socket:
    sEvent =      Event Description:
    ACCEPTED      <Does not occur on connected sockets>
    CONNECTED     The connection attempt initiated by calling AHKsock_Connect has completed (see AHKsock_Connect for more
                  details). If it was successful, iSocket will equal the client socket. If it failed, iSocket will equal -1.
                  To get the error code that the failure returned, set an error handling function with AHKsock_ErrorHandler,
                  and read ErrorLevel when iError is equal to 1.
    DISCONNECTED  The server disconnected (see AHKsock_Close for more details).
    SEND          You may now send data to the server (see AHKsock_Send for more details).
    RECEIVED      You received data from the server. The data received is in bData and the length is in bDataLength.
    SENDLAST      The server is disconnecting. This is your last chance to send data to it. Once this function returns,
                  disconnection will occur. This event only occurs on the side which did not initiate shutdown (see 
                  AHKsock_Close for more details).

More information: The event-handling functions described in here are always called with the Critical setting on. This is
necessary in order to ensure proper processing of messages. Note that as long as the event-handling function does not
return, AHKsock cannot process other network messages. Although messages are buffered, smooth operation might suffer when
letting the function run for longer than it should.

___________________________________________
NOTES ON CLOSING SOCKETS AND AHKsock_Close:

There are a few things to note about the AHKsock_Close function. The most important one is this: because the OnExit
subroutine cannot be made interruptible if running due to a call to Exit/ExitApp, AHKsock_Close will not be able to execute
a graceful shutdown if it is called from there. 

A graceful shutdown refers to the proper way of closing a TCP connection. It consists of an exchange of special TCP messages
between the two endpoints to acknowledge that the connection is about to close. It also fires the SENDLAST event in the
socket's associated function to notify that this is the last chance it will have to send data before disconnection. Note
that listening sockets cannot (and therefore do not need to) be gracefully shutdown as it is not an end-to-end connection.
(In practice, you will never have to manually call AHKsock_Close on a listening socket because you do not have access to
them. The socket is closed when you stop listening by calling AHKsock_Listen with no specified value for the second
parameter.)

In order to allow the socket(s) connection(s) to gracefully shutdown (which is always preferable), AHKsock_Close must be
called in a thread which is, or can be made, interruptible. If it is called with a specified socket in iSocket, it will
initiate a graceful shutdown for that socket alone. If it is called with no socket specified, it will initiate a graceful
shutdown for all connected/accepted sockets, and once done, deregister itself from the Windows Sockets implementation and
allow the implementation to free any resources allocated for Winsock (by calling WSACleanup). In that case, if any
subsequent AHKsock function is called, Winsock will automatically be restarted.

Therefore, before exiting your application, AHKsock_Close must be called at least once with no socket specified in order to
free Winsock resources. This can be done in the OnExit subroutine, either if you do not wish to perform a graceful shutdown
(which is not recommended), or if you have already gracefully shutdown all the sockets individually before calling
Exit/ExitApp. Of course, it doesn't have to be done in the OnExit subroutine and can be done anytime before (which is the
recommended method because AHKsock will automatically gracefully shutdown all the sockets on record).

This behaviour has a few repercussions on your application's design. If the only way for the user to terminate your
application is through AHK's default Exit menu item in the tray menu, then upon selecting the Exit menu item, the OnExit sub
will fire, and your application will not have a chance to gracefully shutdown connected sockets. One way around this is to
add your own menu item which will in turn call AHKsock_Close with no socket specified before calling ExitApp to enter the
OnExit sub. See AHKsock Example 1 for an example of this.

This is how the graceful shutdown process occurs between two connected peers:
    a> Once one of the peers (it may be the server of the client) is done sending all its data, it calls AHKsock_Close to
       shutdown the socket. (It is not a good idea to have the last peer receiving data call AHKsock_Close. This will result
       in AHKsock_Send errors on the other peer if more data needs to be sent.) In the next steps, we refer to the peer that
       first calls AHKsock_Close as the invoker, and the other peer simply as the peer.
    b> The peer receives the invoker's intention to close the connection and is given one last chance to send any remaining
       data. This is when the peer's socket's associated function receives the SENDLAST event.
    c> Once the peer is done sending any remaining data (if any), it also calls AHKsock_Close on that same socket to shut it
       down, and then close the socket for good. This happens once the peer's function that received the SENDLAST event
       returns from the event. At this point, the peer's socket's associated function receives the DISCONNECTED event.
    d> This happens in parallel with c>. After the invoker receives the peer's final data (if any), as well as notice that
       the peer has also called AHKsock_Close on the socket, the invoker finally also closes the socket for good. At this
       point, the socket's associated function also receives the DISCONNECTED event.

When AHKsock_Close is called with no socket specified, this process occurs (in parallel) for every connected socket on
record.

____________________________________
NOTES ON RECEIVING AND SENDING DATA:

It's important to understand that AHKsock uses the TCP protocol, which is a stream protocol. This means that the data
received comes as a stream, with no apparent boundaries (i.e. frames or packets). For example, if a peer sends you a string,
it's possible that half the string is received in one RECEIVED event and the other half is received in the next. Of course,
the smaller the string, the less likely this happens. Conversely, the larger the string, the more likely this will occur.

Similarly, calling AHKsock_Send will not necessarily send the data right away. If multiple AHKsock_Send calls are issued,
Winsock might, under certain conditions, wait and accumulate data to send before sending it all at once. This process is
called coalescing. For example, if you send two strings to your peer by using two individual AHKsock_Send calls, the peer
will not necessarily receive two consecutive RECEIVED events for each string, but might instead receive both strings through
a single RECEIVED event.

One efficient method of receiving data as frames is to use length-prefixing. Length-prefixing means that before sending a
frame of variable length to your peer, you first tell it how many bytes will be in the frame. This way, your peer can
divide the received data into frames that can be individually processed. If it received less than a frame, it can store the
received data and wait for the remaining data to arrive before processing the completed frame with the length specified.
This technique is used in in AHKsock Example 3, where peers send each other strings by first declaring how long the string
will be (see the StreamProcessor function of Example 3).

____________________________________
NOTES ON TESTING A STREAM PROCESSOR:

As you write applications that use length-prefixing as described above, you might find it hard to test their ability to
properly cut up and/or put together the data into frames when testing them on the same machine or on a LAN (because the
latency is too low and it is thus harder to stress the connection).

In this case, what you can do to properly test them is to uncomment the comment block in AHKsock_Send, which will sometimes
purposely fail to send part of the data requested. This will allow you to simulate what could happen on a connection going
through the Internet. You may change the probability of failure by changing the number in the If statement.

If your application can still work after uncommenting the block, then it is a sign that it is properly handling frames split
across multiple RECEIVED events. This would also demonstrate your application's ability to cope with partially sent data.
*/

/****************\
 Main functions  |
*/

AHKsock_Listen(sPort, sFunction = False) {

    ;Check if there is already a socket listening on this port
    If (sktListen := AHKsock_Sockets("GetSocketFromNamePort", A_Space, sPort)) {

        ;Check if we're stopping the listening
        If Not sFunction {
            AHKsock_Close(sktListen) ;Close the socket

            ;Check if we're retrieving the current function
        } Else If (sFunction = "()") {
            Return AHKsock_Sockets("GetFunction", sktListen)

            ;Check if it's a different function
        } Else If (sFunction <> AHKsock_Sockets("GetFunction", sktListen))
        AHKsock_Sockets("SetFunction", sktListen, sFunction) ;Update it

        Return ;We're done
    }

    ;Make sure we even have a function
    If Not IsFunc(sFunction)
        Return 2 ;sFunction is not a valid function.

    ;Make sure Winsock has been started up
    If (i := AHKsock_Startup())
        Return (i = 1) ? 3 ;The WSAStartup() call failed. The error is in ErrorLevel.
    : 4 ;The Winsock DLL does not support version 2.2.

    ;Resolve the local address and port to be used by the server
    VarSetCapacity(aiHints, 16 + 4 * A_PtrSize, 0)
    NumPut(1, aiHints, 0, "Int") ;ai_flags = AI_PASSIVE
    NumPut(2, aiHints, 4, "Int") ;ai_family = AF_INET
    NumPut(1, aiHints, 8, "Int") ;ai_socktype = SOCK_STREAM
    NumPut(6, aiHints, 12, "Int") ;ai_protocol = IPPROTO_TCP
    iResult := DllCall("Ws2_32\GetAddrInfo", "Ptr", 0, "Ptr", &sPort, "Ptr", &aiHints, "Ptr*", aiResult)
    If (iResult != 0) Or ErrorLevel { ;Check for error
        ErrorLevel := ErrorLevel ? ErrorLevel : iResult
        Return 5 ;The getaddrinfo() call failed. The error is in ErrorLevel.
    }

    sktListen := -1 ;INVALID_SOCKET
    sktListen := DllCall("Ws2_32\socket", "Int", NumGet(aiResult+0, 04, "Int")
    , "Int", NumGet(aiResult+0, 08, "Int")
    , "Int", NumGet(aiResult+0, 12, "Int"), "Ptr")
    If (sktListen = -1) Or ErrorLevel { ;Check for INVALID_SOCKET
        sErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
        DllCall("Ws2_32\FreeAddrInfo", "Ptr", aiResult)
        ErrorLevel := sErrorLevel
        Return 6 ;The socket() call failed. The error is in ErrorLevel.
    }

    ;Setup the TCP listening socket
    iResult := DllCall("Ws2_32\bind", "Ptr", sktListen, "Ptr", NumGet(aiResult+0, 16 + 2 * A_PtrSize), "Int", NumGet(aiResult+0, 16, "Ptr"))
    If (iResult = -1) Or ErrorLevel { ;Check for SOCKET_ERROR
        sErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
        DllCall("Ws2_32\closesocket", "Ptr", sktListen)
        DllCall("Ws2_32\FreeAddrInfo", "Ptr", aiResult)
        ErrorLevel := sErrorLevel
        Return 7 ;The bind() call failed. The error is in ErrorLevel.
    }

    DllCall("Ws2_32\FreeAddrInfo", "Ptr", aiResult)

    ;Add socket to array with A_Space for Name and IP to indicate that it's a listening socket
    AHKsock_Sockets("Add", sktListen, A_Space, A_Space, sPort, sFunction)

    ;We must now actually register the socket
    If AHKsock_RegisterAsyncSelect(sktListen) {
        sErrorLevel := ErrorLevel
        DllCall("Ws2_32\closesocket", "Ptr", sktListen)
        AHKsock_Sockets("Delete", sktListen) ;Remove from array
        ErrorLevel := sErrorLevel
        Return 8 ;The WSAAsyncSelect() call failed. The error is in ErrorLevel.
    }

    ;Start listening for incoming connections
    iResult := DllCall("Ws2_32\listen", "Ptr", sktListen, "Int", 0x7FFFFFFF) ;SOMAXCONN
    If (iResult = -1) Or ErrorLevel { ;Check for SOCKET_ERROR
        sErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
        DllCall("Ws2_32\closesocket", "Ptr", sktListen)
        AHKsock_Sockets("Delete", sktListen) ;Remove from array
        ErrorLevel := sErrorLevel
        Return 9 ;The listen() call failed. The error is in ErrorLevel.
    }
}

AHKsock_Connect(sName, sPort, sFunction) {
    Static aiResult, iPointer, bProcessing, iMessage
    Static sCurName, sCurPort, sCurFunction, sktConnect

    ;Check if it's just to inquire whether or not a call is possible
    If (Not sName And Not sPort And Not sFunction)
        Return bProcessing

    ;Check if we're busy
    If bProcessing And (sFunction != iMessage) {
        ErrorLevel := sCurName A_Tab sCurPort
        Return 1 ;AHKsock_Connect is still processing a connection attempt. ErrorLevel contains the name and the port,
        ;delimited by a tab.
    } Else If bProcessing { ;sFunction = iMessage. The connect operation has finished.

        ;Check if it was successful
        If (i := sPort >> 16) {

            ;Close the socket that failed
            DllCall("Ws2_32\closesocket", "Ptr", sktConnect)

            ;Get the next pointer. ai_next
            iPointer := NumGet(iPointer+0, 16 + 3 * A_PtrSize)

            ;Check if we reached the end of the linked structs
            If (iPointer = 0) {

                ;We can now free the chain of addrinfo structs
                DllCall("Ws2_32\FreeAddrInfo", "Ptr", aiResult)

                ;This is to ensure that the user can call AHKsock_Connect() right away upon receiving the message.
                bProcessing := False

                ;Raise an error (can't use Return 1 because we were called asynchronously)
                ErrorLevel := i
                AHKsock_RaiseError(1) ;The connect() call failed. The error is in ErrorLevel.

                ;Call the function to signal that connection failed
                If IsFunc(sCurFunction)
                    %sCurFunction%("CONNECTED", -1, sCurName, 0, sCurPort)

                Return
            }

        } Else { ;Successful connection!

            ;Get the IP we successfully connected to
            sIP := DllCall("Ws2_32\inet_ntoa", "UInt", NumGet(NumGet(iPointer+0, 16 + 2 * A_PtrSize)+4, 0, "UInt"), "AStr")

            ;We can now free the chain of ADDRINFO structs
            DllCall("Ws2_32\FreeAddrInfo", "Ptr", aiResult)

            ;Add socket to array
            AHKsock_Sockets("Add", sktConnect, sCurName, sIP, sCurPort, sCurFunction)

            ;This is to ensure that the user can call AHKsock_Connect() right away upon receiving the message.
            bProcessing := False

            ;Do this small bit in Critical so that AHKsock_AsyncSelect doesn't receive
            ;any FD messages before we call the user function
            Critical

            ;We must now actually register the socket
            If AHKsock_RegisterAsyncSelect(sktConnect) {
                sErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
                DllCall("Ws2_32\closesocket", "Ptr", sktConnect)
                AHKsock_Sockets("Delete", sktConnect) ;Remove from array
                ErrorLevel := sErrorLevel
                AHKsock_RaiseError(2) ;The WSAAsyncSelect() call failed. The error is in ErrorLevel.

                If IsFunc(sCurFunction) ;Call the function to signal that connection failed
                    %sCurFunction%("CONNECTED", -1, sCurName, 0, sCurPort)

            } Else If IsFunc(sCurFunction) ;Call the function to signal that connection was successful
            %sCurFunction%("CONNECTED", sktConnect, sCurName, sIP, sCurPort)

            Return
        }

    } Else { ;We were called

        ;Make sure we even have a function
        If Not IsFunc(sFunction)
            Return 2 ;sFunction is not a valid function.

        bProcessing := True ;Block future calls to AHKsock_Connect() until we're done

        ;Keep the values
        sCurName := sName
        sCurPort := sPort
        sCurFunction := sFunction

        ;Make sure Winsock has been started up
        If (i := AHKsock_Startup()) {
            bProcessing := False
            Return (i = 1) ? 3 ;The WSAStartup() call failed. The error is in ErrorLevel.
            : 4 ;The Winsock DLL does not support version 2.2.
        }

        ;Resolve the server address and port    
        VarSetCapacity(aiHints, 16 + 4 * A_PtrSize, 0)
        NumPut(2, aiHints, 4, "Int") ;ai_family = AF_INET
        NumPut(1, aiHints, 8, "Int") ;ai_socktype = SOCK_STREAM
        NumPut(6, aiHints, 12, "Int") ;ai_protocol = IPPROTO_TCP
        iResult := DllCall("Ws2_32\GetAddrInfo", "Ptr", &sName, "Ptr", &sPort, "Ptr", &aiHints, "Ptr*", aiResult)
        If (iResult != 0) Or ErrorLevel { ;Check for error
            ErrorLevel := ErrorLevel ? ErrorLevel : iResult
            bProcessing := False
            Return 5 ;The getaddrinfo() call failed. The error is in ErrorLevel.
        }

        ;Start with the first struct
        iPointer := aiResult
    }

    ;Create a SOCKET for connecting to server
    sktConnect := DllCall("Ws2_32\socket", "Int", NumGet(iPointer+0, 04, "Int")
    , "Int", NumGet(iPointer+0, 08, "Int")
    , "Int", NumGet(iPointer+0, 12, "Int"), "Ptr")
    If (sktConnect = 0xFFFFFFFF) Or ErrorLevel { ;Check for INVALID_SOCKET
        sErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
        DllCall("Ws2_32\FreeAddrInfo", "Ptr", aiResult)
        bProcessing := False
        ErrorLevel := sErrorLevel
        If (sFunction = iMessage) { ;Check if we were called asynchronously
            AHKsock_RaiseError(3) ;The socket() call failed. The error is in ErrorLevel.

            ;Call the function to signal that connection failed
            If IsFunc(sCurFunction)
                %sCurFunction%("CONNECTED", -1)
        }
        Return 6 ;The socket() call failed. The error is in ErrorLevel.
    }

    ;Register the socket to know when the connect() function is done. FD_CONNECT = 16
    iMessage := AHKsock_Settings("Message") + 1
    If AHKsock_RegisterAsyncSelect(sktConnect, 16, "AHKsock_Connect", iMessage) {
        sErrorLevel := ErrorLevel
        DllCall("Ws2_32\FreeAddrInfo", "Ptr", aiResult)
        DllCall("Ws2_32\closesocket", "Ptr", sktConnect)
        bProcessing := False
        ErrorLevel := sErrorLevel
        If (sFunction = iMessage) { ;Check if we were called asynchronously
            AHKsock_RaiseError(4) ;The WSAAsyncSelect() call failed. The error is in ErrorLevel.

            ;Call the function to signal that connection failed
            If IsFunc(sCurFunction)
                %sCurFunction%("CONNECTED", -1)
        }
        Return 7 ;The WSAAsyncSelect() call failed. The error is in ErrorLevel.
    }

    ;Connect to server (the connect() call also implicitly binds the socket to any host address and any port)
    iResult := DllCall("Ws2_32\connect", "Ptr", sktConnect, "Ptr", NumGet(iPointer+0, 16 + 2 * A_PtrSize), "Int", NumGet(iPointer+0, 16))
    If ErrorLevel Or ((iResult = -1) And (AHKsock_LastError() != 10035)) { ;Check for any error other than WSAEWOULDBLOCK
        sErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
        DllCall("Ws2_32\FreeAddrInfo", "Ptr", aiResult)
        DllCall("Ws2_32\closesocket", "Ptr", sktConnect)
        bProcessing := False
        ErrorLevel := sErrorLevel
        If (sFunction = iMessage) { ;Check if we were called asynchronously
            AHKsock_RaiseError(5) ;The connect() call failed. The error is in ErrorLevel.

            ;Call the function to signal that connection failed
            If IsFunc(sCurFunction)
                %sCurFunction%("CONNECTED", -1)
        }
        Return 8 ;The connect() call failed. The error is in ErrorLevel.
    }
}

AHKsock_Send(iSocket, ptrData = 0, iLength = 0) {

    ;Make sure the socket is on record. Fail-safe
    If Not AHKsock_Sockets("Index", iSocket)
        Return -4 ;The socket specified in iSocket is not a recognized socket.

    ;Make sure Winsock has been started up
    If Not AHKsock_Startup(1)
        Return -1 ;WSAStartup hasn't been called yet.

    ;Make sure the socket is cleared for sending
    If Not AHKsock_Sockets("GetSend", iSocket)
        Return -5 ;The socket specified in iSocket is not cleared for sending.

    /*! Uncomment this block to simulate the possibility of an incomplete send()
    Random, iRand, 1, 100
    If (iRand <= 30) { ;Probability of failure of 30%
        Random, iRand, 1, iLength - 1 ;Randomize how much of the data will not be sent
        iLength -= iRand
    }
    */

    iSendResult := DllCall("Ws2_32\send", "Ptr", iSocket, "Ptr", ptrData, "Int", iLength, "Int", 0)
    If (iSendResult = -1) And ((iErr := AHKsock_LastError()) = 10035) { ;Check specifically for WSAEWOULDBLOCK
        AHKsock_Sockets("SetSend", iSocket, False) ;Update socket's send status
        Return -2 ;Calling send() would have blocked the thread. Try again once you get the proper update.
    } Else If (iSendResult = -1) Or ErrorLevel {
        ErrorLevel := ErrorLevel ? ErrorLevel : iErr
        Return -3 ;The send() call failed. The error is in ErrorLevel.
    } Else Return iSendResult ;The send() operation was successful
}

AHKsock_ForceSend(iSocket, ptrData, iLength) {

    ;Make sure Winsock has been started up
    If Not AHKsock_Startup(1)
        Return -1 ;WSAStartup hasn't been called yet

    ;Make sure the socket is on record. Fail-safe
    If Not AHKsock_Sockets("Index", iSocket)
        Return -4

    ;Make sure that we're not in Critical, or we won't be able to wait for FD_WRITE messages
    If A_IsCritical
        Return -5

    ;Extra precaution to make sure FD_WRITE messages can make it
    Thread, Priority, 0

    ;We need to make sure not to fill up the send buffer in one call, or we'll get a performance hit.
    ;http://support.microsoft.com/kb/823764

    ;Get the socket's send buffer size
    If ((iMaxChunk := AHKsock_SockOpt(iSocket, "SO_SNDBUF")) = -1)
        Return -6

    ;Check if we'll be sending in chunks or not
    If (iMaxChunk <= 1) {

        ;We'll be sending as much as possible everytime!

        Loop { ;Keep sending the data until we're done or until an error occurs

            ;Wait until we can send data (ie. when FD_WRITE arrives)
            While Not AHKsock_Sockets("GetSend", iSocket)
                Sleep -1

            Loop { ;Keep sending the data until we get WSAEWOULDBLOCK or until an error occurs
                If ((iSendResult := AHKsock_Send(iSocket, ptrData, iLength)) < 0) {
                    If (iSendResult = -2) ;Check specifically for WSAEWOULDBLOCK
                        Break ;Calling send() would have blocked the thread. Break the loop and we'll try again after we
                    ;receive FD_WRITE
                    Else Return iSendResult ;Something bad happened with AHKsock_Send. Return the same value we got.
                } Else {

                    ;AHKsock_Send was able to send bytes. Let's check if it sent only part of what we requested
                    If (iSendResult < iLength) ;Move the offset up by what we were able to send
                        ptrData += iSendResult, iLength -= iSendResult
                    Else Return ;We're done sending all the data
                    }
            }
        }
    } Else {

        ;We'll be sending in chunks of just under the send buffer size to avoid the performance hit

        iMaxChunk -= 1 ;Reduce by 1 to be smaller than the send buffer
        Loop { ;Keep sending the data until we're done or until an error occurs

            ;Wait until we can send data (ie. when FD_WRITE arrives)
            While Not AHKsock_Sockets("GetSend", iSocket)
                Sleep -1

            ;Check if we have less than the max chunk to send
            If (iLength < iMaxChunk) {

                Loop { ;Keep sending the data until we get WSAEWOULDBLOCK or until an error occurs
                    ;Send using the traditional offset method
                    If ((iSendResult := AHKsock_Send(iSocket, ptrData, iLength)) < 0) {
                        If (iSendResult = -2) ;Check specifically for WSAEWOULDBLOCK
                            Break ;Calling send() would have blocked the thread. Break the loop and we'll try again after we
                        ;receive FD_WRITE
                        Else Return iSendResult ;Something bad happened with AHKsock_Send. Return the same value we got.
                    } Else {

                        ;AHKsock_Send was able to send bytes. Let's check if it sent only part of what we requested
                        If (iSendResult < iLength) ;Move the offset up by what we were able to send
                            ptrData += iSendResult, iLength -= iSendResult
                        Else Return ;We're done sending all the data
                        }
                }
            } Else {

                ;Send up to max chunk
                If ((iSendResult := AHKsock_Send(iSocket, ptrData, iMaxChunk)) < 0) {
                    If (iSendResult = -2) ;Check specifically for WSAEWOULDBLOCK
                        Continue ;Calling send() would have blocked the thread. Continue the loop and we'll try again after
                    ;we receive FD_WRITE
                    Else Return iSendResult ;Something bad happened with AHKsock_Send. Return the same value we got.
                    } Else ptrData += iSendResult, iLength -= iSendResult ;Move up offset by updating the pointer and length
            }
        }
    }
}

AHKsock_Close(iSocket = -1, iTimeout = 5000) {

    ;Make sure Winsock has been started up
    If Not AHKsock_Startup(1)
        Return ;There's nothing to close

    If (iSocket = -1) { ;We need to close all the sockets

        ;Check if we even have sockets to close
        If Not AHKsock_Sockets() {
            DllCall("Ws2_32\WSACleanup")
            AHKsock_Startup(2) ;Reset the value to show that we've turned off Winsock
            Return ;We're done!
        }

        ;Take the current time (needed for time-outing)
        iStartClose := A_TickCount

        Loop % AHKsock_Sockets() ;Close all sockets and cleanup
            AHKsock_ShutdownSocket(AHKsock_Sockets("GetSocketFromIndex", A_Index))

        ;Check if we're in the OnExit subroutine
        If Not A_ExitReason {

            A_IsCriticalOld := A_IsCritical

            ;Make sure we can still receive FD_CLOSE msgs
            Critical, Off
            Thread, Priority, 0

            ;We can try a graceful shutdown or wait for a timeout
            While (AHKsock_Sockets()) And (A_TickCount - iStartClose < iTimeout)
                Sleep, -1

            ;Restore previous Critical
            Critical, %A_IsCriticalOld%
        }

        /*! Used for debugging purposes only
        If (i := AHKsock_Sockets()) {
            If (i = 1)
                OutputDebug, % "Cleaning up now, with the socket " AHKsock_Sockets("GetSocketFromIndex", 1) " remaining..."
            Else {
                OutputDebug, % "Cleaning up now, with the following sockets remaining:"
                Loop % AHKsock_Sockets() {
                    OutputDebug, % AHKsock_Sockets("GetSocketFromIndex", A_Index)
                }
            }
        }
        */

        DllCall("Ws2_32\WSACleanup")
        AHKsock_Startup(2) ;Reset the value to show that we've turned off Winsock

        ;Close only one socket
    } Else If AHKsock_ShutdownSocket(iSocket) ;Error-checking
Return 1 ;The shutdown() call failed. The error is in ErrorLevel.
}

AHKsock_GetAddrInfo(sHostName, ByRef sIPList, bOne = False) {

    ;Make sure Winsock has been started up
    If (i := AHKsock_Startup())
        Return i ;Return the same error (error 1 and 2)

    ;Resolve the address and port    
    VarSetCapacity(aiHints, 16 + 4 * A_PtrSize, 0)
    NumPut(2, aiHints, 4, "Int") ;ai_family = AF_INET
    NumPut(1, aiHints, 8, "Int") ;ai_socktype = SOCK_STREAM
    NumPut(6, aiHints, 12, "Int") ;ai_protocol = IPPROTO_TCP
    iResult := DllCall("Ws2_32\GetAddrInfo", "Ptr", &sHostName, "Ptr", 0, "Ptr", &aiHints, "Ptr*", aiResult)
    If (iResult = 11001) ;Check specifically for WSAHOST_NOT_FOUND since it's the most common error
        Return 3 ;Received WSAHOST_NOT_FOUND. No such host is known.
    Else If (iResult != 0) Or ErrorLevel { ;Check for any other error
        ErrorLevel := ErrorLevel ? ErrorLevel : iResult
        Return 4 ;The getaddrinfo() call failed. The error is in ErrorLevel.
    }

    If bOne
        sIPList := DllCall("Ws2_32\inet_ntoa", "UInt", NumGet(NumGet(aiResult+0, 16 + 2 * A_PtrSize)+4, 0, "UInt"), "AStr")
    Else {

        ;Start with the first addrinfo struct
        iPointer := aiResult, sIPList := ""
        While iPointer {
            s := DllCall("Ws2_32\inet_ntoa", "UInt", NumGet(NumGet(iPointer+0, 16 + 2 * A_PtrSize)+4, 0, "UInt"), "AStr")
            iPointer := NumGet(iPointer+0, 16 + 3 * A_PtrSize) ;Go to the next addrinfo struct
            sIPList .= s (iPointer ? "`n" : "") ;Add newline only if it's not the last one
        }
    }

    ;We're done
    DllCall("Ws2_32\FreeAddrInfo", "Ptr", aiResult)
}

AHKsock_GetNameInfo(sIP, ByRef sHostName, sPort = 0, ByRef sService = "") {

    ;Make sure Winsock has been started up
    If (i := AHKsock_Startup())
        Return i ;Return the same error (error 1 and 2)

    ;Translate to IN_ADDR
    iIP := DllCall("Ws2_32\inet_addr", "AStr", sIP, "UInt")
    If (iIP = 0 Or iIP = 0xFFFFFFFF) ;Check for INADDR_NONE or INADDR_ANY
        Return 3 ;The IP address supplied in sIP is invalid.

    ;Construct a sockaddr struct
    VarSetCapacity(tSockAddr, 16, 0)
    NumPut(2, tSockAddr, 0, "Short") ;ai_family = AF_INET
    NumPut(iIP, tSockAddr, 4, "UInt") ;Put in the IN_ADDR

    ;Fill in the port field if we're also looking up the service name
    If sPort ;Translate to network byte order
        NumPut(DllCall("Ws2_32\htons", "UShort", sPort, "UShort"), tSockAddr, 2, "UShort")

    ;Prep vars
    VarSetCapacity(sHostName, 1025 * 2, 0) ;NI_MAXHOST
    If sPort
        VarSetCapacity(sService, 32 * 2, 0) ;NI_MAXSERV

    iResult := DllCall("Ws2_32\GetNameInfoW", "Ptr", &tSockAddr, "Int", 16, "Str", sHostName, "UInt", 1025 * 2
    , sPort ? "Str" : "UInt", sPort ? sService : 0, "UInt", 32 * 2, "Int", 0)
    If (iResult != 0) Or ErrorLevel {
        ErrorLevel := ErrorLevel ? ErrorLevel : DllCall("Ws2_32\WSAGetLastError")
        Return 4 ;The getnameinfo() call failed. The error is in ErrorLevel.
    }
}

AHKsock_SockOpt(iSocket, sOption, iValue = -1) {

    ;Prep variable
    VarSetCapacity(iOptVal, iOptValLength := 4, 0)
    If (iValue <> -1)
        NumPut(iValue, iOptVal, 0, "UInt")

    If (sOption = "SO_KEEPALIVE") {
        intLevel := 0xFFFF ;SOL_SOCKET
        intOptName := 0x0008 ;SO_KEEPALIVE
    } Else If (sOption = "SO_SNDBUF") {
        intLevel := 0xFFFF ;SOL_SOCKET
        intOptName := 0x1001 ;SO_SNDBUF
    } Else If (sOption = "SO_RCVBUF") {
        intLevel := 0xFFFF ;SOL_SOCKET
        intOptName := 0x1002 ;SO_SNDBUF
    } Else If (sOption = "TCP_NODELAY") {
        intLevel := 6 ;IPPROTO_TCP
        intOptName := 0x0001 ;TCP_NODELAY
    }

    ;Check if we're getting or setting
    If (iValue = -1) {
        iResult := DllCall("Ws2_32\getsockopt", "Ptr", iSocket, "Int", intLevel, "Int", intOptName
        , "UInt*", iOptVal, "Int*", iOptValLength)
        If (iResult = -1) Or ErrorLevel { ;Check for SOCKET_ERROR
            ErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
            Return -1
        } Else Return iOptVal
    } Else {
        iResult := DllCall("Ws2_32\setsockopt", "Ptr", iSocket, "Int", intLevel, "Int", intOptName
        , "Ptr", &iOptVal, "Int", iOptValLength)
        If (iResult = -1) Or ErrorLevel { ;Check for SOCKET_ERROR
            ErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
            Return -2
        }
    }
}

/*******************\
 Support functions  |
*/

AHKsock_Startup(iMode = 0) {
    Static bAlreadyStarted

    /*
    iMode = 0 ;Turns on WSAStartup()
    iMode = 1 ;Returns whether or not WSAStartup has been called
    iMode = 2 ;Resets the static variable to force another call next time iMode = 0
    */

    If (iMode = 2)
        bAlreadyStarted := False
    Else If (iMode = 1)
        Return bAlreadyStarted
    Else If Not bAlreadyStarted { ;iMode = 0. Call the function only if it hasn't already been called.

        ;Start it up - request version 2.2
        VarSetCapacity(wsaData, A_PtrSize = 4 ? 400 : 408, 0)
        iResult := DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", &wsaData)
        If (iResult != 0) Or ErrorLevel {
            ErrorLevel := ErrorLevel ? ErrorLevel : iResult
            Return 1
        }

        ;Make sure the Winsock DLL supports at least version 2.2
        If (NumGet(wsaData, 2, "UShort") < 0x0202) {
            DllCall("Ws2_32\WSACleanup") ;Abort
            ErrorLevel := "The Winsock DLL does not support version 2.2."
            Return 2
        }

        bAlreadyStarted := True
    }
}

AHKsock_ShutdownSocket(iSocket) {

    ;Check if it's a listening socket
    sName := AHKsock_Sockets("GetName", iSocket)
    If (sName != A_Space) { ;It's not a listening socket. Shutdown send operations.
        iResult := DllCall("Ws2_32\shutdown", "Ptr", iSocket, "Int", 1) ;SD_SEND
        If (iResult = -1) Or ErrorLevel {
            sErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
            DllCall("Ws2_32\closesocket", "Ptr", iSocket)
            AHKsock_Sockets("Delete", iSocket)
            ErrorLevel := sErrorLevel
            Return 1
        }

        ;Mark it
        AHKsock_Sockets("SetShutdown", iSocket)

    } Else {
        DllCall("Ws2_32\closesocket", "Ptr", iSocket) ;It's only a listening socket
        AHKsock_Sockets("Delete", iSocket) ;Remove it from the array
    }
}

/***********************\
 AsyncSelect functions  |
*/
;FD_READ | FD_WRITE | FD_ACCEPT | FD_CLOSE
AHKsock_RegisterAsyncSelect(iSocket, fFlags = 43, sFunction = "AHKsock_AsyncSelect", iMsg = 0) {
    Static hwnd := False

    If Not hwnd { ;Use the main AHK window
        A_DetectHiddenWindowsOld := A_DetectHiddenWindows
        DetectHiddenWindows, On
        WinGet, hwnd, ID, % "ahk_pid " DllCall("GetCurrentProcessId") " ahk_class AutoHotkey"
        DetectHiddenWindows, %A_DetectHiddenWindowsOld%
    }

    iMsg := iMsg ? iMsg : AHKsock_Settings("Message")
    If (OnMessage(iMsg) <> sFunction)
        OnMessage(iMsg, sFunction)

    iResult := DllCall("Ws2_32\WSAAsyncSelect", "Ptr", iSocket, "Ptr", hwnd, "UInt", iMsg, "Int", fFlags)
    If (iResult = -1) Or ErrorLevel { ;Check for SOCKET_ERROR
        ErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
        Return 1
    }
}

AHKsock_AsyncSelect(wParam, lParam) {
    Critical ;So that messages are buffered

    ;wParam parameter identifies the socket on which a network event has occurred
    ;The low word of lParam specifies the network event that has occurred.
    ;The high word of lParam contains any error code

    ;Make sure the socket is on record. Fail-safe
    If Not AHKsock_Sockets("Index", wParam)
        Return

    iEvent := lParam & 0xFFFF, iErrorCode := lParam >> 16

    /*! Used for debugging purposes
    OutputDebug, % "AsyncSelect - A network event " iEvent " has occurred on socket " wParam
    If iErrorCode
        OutputDebug, % "AsyncSelect - Error code = " iErrorCode
    */

    If (iEvent = 1) { ;FD_READ

        ;Check for error
        If iErrorCode { ;WSAENETDOWN is the only possible
            ErrorLevel := iErrorCode
            ;FD_READ event received with an error. The error is in ErrorLevel. The socket is in iSocket.
            AHKsock_RaiseError(6, wParam)
            Return
        }

        VarSetCapacity(bufReceived, bufReceivedLength := AHKsock_Settings("Buffer"), 0)
        iResult := DllCall("Ws2_32\recv", "UInt", wParam, "Ptr", &bufReceived, "Int", bufReceivedLength, "Int", 0)
        If (iResult > 0) { ;We received data!
            VarSetCapacity(bufReceived, -1) ;Update the internal length

            ;Get associated function and call it
            If IsFunc(sFunc := AHKsock_Sockets("GetFunction", wParam))
                %sFunc%("RECEIVED", wParam, AHKsock_Sockets("GetName", wParam)
            , AHKsock_Sockets("GetAddr", wParam)
            , AHKsock_Sockets("GetPort", wParam), bufReceived, iResult)

            ;Check for error other than WSAEWOULDBLOCK
        } Else If ErrorLevel Or ((iResult = -1) And Not ((iErrorCode := AHKsock_LastError()) = 10035)) {
            ErrorLevel := ErrorLevel ? ErrorLevel : iErrorCode
            AHKsock_RaiseError(7, wParam) ;The recv() call failed. The error is in ErrorLevel. The socket is in iSocket.
            iResult = -1 ;So that if it's a spoofed call from FD_CLOSE, we exit the loop and close the socket
        }

        ;Here, we bother with returning a value in case it's a spoofed call from FD_CLOSE
        Return iResult

    } Else If (iEvent = 2) { ;FD_WRITE

        ;Check for error
        If iErrorCode { ;WSAENETDOWN is the only possible
            ErrorLevel := iErrorCode
            ;FD_WRITE event received with an error. The error is in ErrorLevel. The socket is in iSocket.
            AHKsock_RaiseError(8, wParam)
            Return
        }

        ;Update socket's setting
        AHKsock_Sockets("SetSend", wParam, True)

        ;Make sure the socket isn't already shut down
        If Not AHKsock_Sockets("GetShutdown", wParam)
            If IsFunc(sFunc := AHKsock_Sockets("GetFunction", wParam))
            %sFunc%("SEND", wParam, AHKsock_Sockets("GetName", wParam)
        , AHKsock_Sockets("GetAddr", wParam)
        , AHKsock_Sockets("GetPort", wParam))

    } Else If (iEvent = 8) { ;FD_ACCEPT

        ;Check for error
        If iErrorCode { ;WSAENETDOWN is the only possible
            ErrorLevel := iErrorCode
            ;FD_ACCEPT event received with an error. The error is in ErrorLevel. The socket is in iSocket.
            AHKsock_RaiseError(9, wParam)
            Return
        }

        ;We need to accept the connection
        VarSetCapacity(tSockAddr, tSockAddrLength := 16, 0)
        sktClient := DllCall("Ws2_32\accept", "Ptr", wParam, "Ptr", &tSockAddr, "Int*", tSockAddrLength)
        If (sktClient = -1) And ((iErrorCode := AHKsock_LastError()) = 10035) ;Check specifically for WSAEWOULDBLOCK
            Return ;We'll be called again next time we can retry accept()
        Else If (sktClient = -1) Or ErrorLevel { ;Check for INVALID_SOCKET
            ErrorLevel := ErrorLevel ? ErrorLevel : iErrorCode
            ;The accept() call failed. The error is in ErrorLevel. The listening socket is in iSocket.
            AHKsock_RaiseError(10, wParam)
            Return
        }

        ;Add to array
        sName := ""
        sAddr := DllCall("Ws2_32\inet_ntoa", "UInt", NumGet(tSockAddr, 4, "UInt"), "AStr")
        sPort := AHKsock_Sockets("GetPort", wParam)
        sFunc := AHKsock_Sockets("GetFunction", wParam)
        AHKsock_Sockets("Add", sktClient, sName, sAddr, sPort, sFunc)

        ;Go back to listening
        iResult := DllCall("Ws2_32\listen", "Ptr", wParam, "Int", 0x7FFFFFFF) ;SOMAXCONN       
        If (iResult = -1) Or ErrorLevel { ;Check for SOCKET_ERROR
            sErrorLevel := ErrorLevel ? ErrorLevel : AHKsock_LastError()
            DllCall("Ws2_32\closesocket", "Ptr", wParam)
            AHKsock_Sockets("Delete", wParam) ;Remove from array
            ErrorLevel := sErrorLevel
            ;The listen() call failed. The error is in ErrorLevel. The listening socket is in iSocket.
            AHKsock_RaiseError(12, wParam)
            Return
        }

        ;Get associated function and call it
        If IsFunc(sFunc)
            %sFunc%("ACCEPTED", sktClient, sName, sAddr, sPort)

    } Else If (iEvent = 32) { ;FD_CLOSE

        ;Keep receiving data before closing the socket by spoofing an FD_READ event to call recv()
        While (AHKsock_AsyncSelect(wParam, 1) > 0)
            Sleep, -1

        ;Check if we initiated it
        If Not AHKsock_Sockets("GetShutdown", wParam) {

            ;Last chance to send data. Get associated function and call it.
            If IsFunc(sFunc := AHKsock_Sockets("GetFunction", wParam))
                %sFunc%("SENDLAST", wParam, AHKsock_Sockets("GetName", wParam)
            , AHKsock_Sockets("GetAddr", wParam)
            , AHKsock_Sockets("GetPort", wParam))

            ;Shutdown the socket. This is to attempt a graceful shutdown
            If AHKsock_ShutdownSocket(wParam) {
                ;The shutdown() call failed. The error is in ErrorLevel. The socket is in iSocket.
                AHKsock_RaiseError(13, wParam)
                Return
            }
        }

        ;We just have to close the socket then
        DllCall("Ws2_32\closesocket", "Ptr", wParam)

        ;Get associated data before deleting
        sFunc := AHKsock_Sockets("GetFunction", wParam)
        sName := AHKsock_Sockets("GetName", wParam)
        sAddr := AHKsock_Sockets("GetAddr", wParam)
        sPort := AHKsock_Sockets("GetPort", wParam)

        ;We can remove it from the array
        AHKsock_Sockets("Delete", wParam)

        If IsFunc(sFunc)
            %sFunc%("DISCONNECTED", wParam, sName, sAddr, sPort)
    }
}

/******************\
 Array controller  |
*/

AHKsock_Sockets(sAction = "Count", iSocket = "", sName = "", sAddr = "", sPort = "", sFunction = "") {
    Static
    Static aSockets0 := 0
    Static iLastSocket := 0xFFFFFFFF ;Cache to lessen index lookups on the same socket
    Local i, ret, A_IsCriticalOld

    A_IsCriticalOld := A_IsCritical
    Critical

    If (sAction = "Count") {
        ret := aSockets0

    } Else If (sAction = "Add") {
        aSockets0 += 1 ;Expand array
        aSockets%aSockets0%_Sock := iSocket
        aSockets%aSockets0%_Name := sName
        aSockets%aSockets0%_Addr := sAddr
        aSockets%aSockets0%_Port := sPort
        aSockets%aSockets0%_Func := sFunction
        aSockets%aSockets0%_Shutdown := False
        aSockets%aSockets0%_Send := False

    } Else If (sAction = "Delete") {

        ;First we need the index
        i := (iSocket = iLastSocket) ;Check cache
        ? iLastSocketIndex
        : AHKsock_Sockets("Index", iSocket)

        If i {
            iLastSocket := 0xFFFF ;Clear cache
            If (i < aSockets0) { ;Let the last item overwrite this one
                aSockets%i%_Sock := aSockets%aSockets0%_Sock
                aSockets%i%_Name := aSockets%aSockets0%_Name
                aSockets%i%_Addr := aSockets%aSockets0%_Addr
                aSockets%i%_Port := aSockets%aSockets0%_Port
                aSockets%i%_Func := aSockets%aSockets0%_Func
                aSockets%i%_Shutdown := aSockets%aSockets0%_Shutdown
                aSockets%i%_Send := aSockets%aSockets0%_Send

            }
            aSockets0 -= 1 ;Remove element
        }

    } Else If (sAction = "GetName") {
        i := (iSocket = iLastSocket) ;Check cache
        ? iLastSocketIndex
        : AHKsock_Sockets("Index", iSocket)
        ret := aSockets%i%_Name

    } Else If (sAction = "GetAddr") {
        i := (iSocket = iLastSocket) ;Check cache
        ? iLastSocketIndex
        : AHKsock_Sockets("Index", iSocket)
        ret := aSockets%i%_Addr

    } Else If (sAction = "GetPort") {
        i := (iSocket = iLastSocket) ;Check cache
        ? iLastSocketIndex
        : AHKsock_Sockets("Index", iSocket)
        ret := aSockets%i%_Port

    } Else If (sAction = "GetFunction") {
        i := (iSocket = iLastSocket) ;Check cache
        ? iLastSocketIndex
        : AHKsock_Sockets("Index", iSocket)
        ret := aSockets%i%_Func

    } Else If (sAction = "SetFunction") {
        i := (iSocket = iLastSocket) ;Check cache
        ? iLastSocketIndex
        : AHKsock_Sockets("Index", iSocket)
        aSockets%i%_Func := sName

    } Else If (sAction = "GetSend") {
        i := (iSocket = iLastSocket) ;Check cache
        ? iLastSocketIndex
        : AHKsock_Sockets("Index", iSocket)
        ret := aSockets%i%_Send

    } Else If (sAction = "SetSend") {
        i := (iSocket = iLastSocket) ;Check cache
        ? iLastSocketIndex
        : AHKsock_Sockets("Index", iSocket)
        aSockets%i%_Send := sName

    } Else If (sAction = "GetShutdown") {
        i := (iSocket = iLastSocket) ;Check cache
        ? iLastSocketIndex
        : AHKsock_Sockets("Index", iSocket)
        ret := aSockets%i%_Shutdown

    } Else If (sAction = "SetShutdown") {
        i := (iSocket = iLastSocket) ;Check cache
        ? iLastSocketIndex
        : AHKsock_Sockets("Index", iSocket)
        aSockets%i%_Shutdown := True

    } Else If (sAction = "GetSocketFromNamePort") {
        Loop % aSockets0 {
            If (aSockets%A_Index%_Name = iSocket)
            And (aSockets%A_Index%_Port = sName) {
                ret := aSockets%A_Index%_Sock
                Break
            }
        }

    } Else If (sAction = "GetSocketFromIndex") {
        ret := aSockets%iSocket%_Sock

    } Else If (sAction = "Index") {
        Loop % aSockets0 {
            If (aSockets%A_Index%_Sock = iSocket) {
                iLastSocketIndex := A_Index, iLastSocket := iSocket
                ret := A_Index
                Break
            }
        }
    }

    ;Restore old Critical setting
    Critical %A_IsCriticalOld%
Return ret
}

/*****************\
 Error Functions  |
*/

AHKsock_LastError() {
Return DllCall("Ws2_32\WSAGetLastError")
}

AHKsock_ErrorHandler(sFunction = """") {
    Static sCurrentFunction
    If (sFunction = """")
        Return sCurrentFunction
    Else sCurrentFunction := sFunction
    }

AHKsock_RaiseError(iError, iSocket = -1) {
    If IsFunc(sFunc := AHKsock_ErrorHandler())
        %sFunc%(iError, iSocket)
}

/*******************\
 Settings Function  |
*/

AHKsock_Settings(sSetting, sValue = "") {
    Static iMessage := 0x8000
    Static iBuffer := 65536

    If (sSetting = "Message") {
        If Not sValue
            Return iMessage
        Else iMessage := (sValue = "Reset") ? 0x8000 : sValue
    } Else If (sSetting = "Buffer") {
        If Not sValue
            Return iBuffer
        Else iBuffer := (sValue = "Reset") ? 65536 : sValue
        }
}
; ==========================================
AHKsock_Close()
ExitApp
/*! TheGood
    AHKsock - A simple AHK implementation of Winsock.
    http://www.autohotkey.com/forum/viewtopic.php?p=355775
    Last updated: January 19, 2011
    
FUNCTION LIST:

________________________________________
AHKsock_Listen(sPort, sFunction = False)

Tells AHKsock to listen on the port in sPort, and call the function in sFunction when events occur. If sPort is a port on
which AHKsock is already listening, the action taken depends on sFunction:
    - If sFunction is False, AHKsock will stop listening on the port in sPort.
    - If sFunction is "()", AHKsock will return the name of the current function AHKsock calls when
      a client connects on the port in sPort.
    - If sFunction is a valid function, AHKsock will set that function as the new function to call
      when a client connects on the port in sPort.

Returns blank on success. On failure, it returns one of the following positive integer:
    2: sFunction is not a valid function.
    3: The WSAStartup() call failed. The error is in ErrorLevel.
    4: The Winsock DLL does not support version 2.2.
    5: The getaddrinfo() call failed. The error is in ErrorLevel.
    6: The socket() call failed. The error is in ErrorLevel.
    7: The bind() call failed. The error is in ErrorLevel.
    8: The WSAAsyncSelect() call failed. The error is in ErrorLevel.
    9: The listen() call failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

See the section titled "STRUCTURE OF THE EVENT-HANDLING FUNCTION AND MORE INFO ABOUT SOCKETS" for more info about how the
function in sFunction interacts with AHKsock.

________________________________________
AHKsock_Connect(sName, sPort, sFunction)

Tells AHKsock to connect to the hostname or IP address in sName on the port in sPort, and call the function in sFunction
when events occur.

Although the function will return right away, the connection attempt will still be in progress. Once the connection attempt
is over, successful or not, sFunction will receive the CONNECTED event. Note that it is important that once AHKsock_Connect
returns, the current thread must stay (or soon after must become) interruptible so that sFunction can be called once the
connection attempt is over.

AHKsock_Connect can only be called again once the previous connection attempt is over. To check if AHKsock_Connect is ready
to make another connection attempt, you may keep polling it by calling AHKsock_Connect(0,0,0) until it returns False.

Returns blank on success. On failure, it returns one of the following positive integer:
    1: AHKsock_Connect is still processing a connection attempt. ErrorLevel contains the name and the port of that
       connection attempt, separated by a tab.
    2: sFunction is not a valid function.
    3: The WSAStartup() call failed. The error is in ErrorLevel.
    4: The Winsock DLL does not support version 2.2.
    5: The getaddrinfo() call failed. The error is in ErrorLevel.
    6: The socket() call failed. The error is in ErrorLevel.
    7: The WSAAsyncSelect() call failed. The error is in ErrorLevel.
    8: The connect() call failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

See the section titled "STRUCTURE OF THE EVENT-HANDLING FUNCTION AND MORE INFO ABOUT SOCKETS" for more info about how the
function in sFunction interacts with AHKsock.
-+
_______________________________________
AHKsock_Send(iSocket, ptrData, iLength)

Sends the data of length iLength to which ptrData points to the connected socket in iSocket.

Returns the number of bytes sent on success. This can be less than the number requested to be sent in the iLength parameter,
i.e. between 1 and iLength. This would occur if no buffer space is available within the transport system to hold the data to
be transmitted, in which case the number of bytes sent can be between 1 and the requested length, depending on buffer
availability on both the client and server computers. On failure, it returns one of the following negative integer:
    -1: WSAStartup hasn't been called yet.
    -2: Received WSAEWOULDBLOCK. This means that calling send() would have blocked the thread.
    -3: The send() call failed. The error is in ErrorLevel.
    -4: The socket specified in iSocket is not a valid socket. This means either that the socket in iSocket hasn't been
        created using AHKsock_Connect or AHKsock_Listen, or that the socket has already been destroyed.
    -5: The socket specified in iSocket is not cleared for sending. You haven't waited for the SEND event before calling,
        either ever, or not since you last received WSAEWOULDBLOCK.

You may start sending data to the connected socket in iSocket only after the socket's associated function receives the first
SEND event. Upon receiving the event, you may keep calling AHKsock_Send to send data until you receive the error -2, at
which point you must wait once again until you receive another SEND event before sending more data. Not waiting for the SEND
event results in receiving error -5 when calling AHKsock_Send.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

____________________________________________
AHKsock_ForceSend(iSocket, ptrData, iLength)

This function is exactly the same as AHKsock_Send, but with three differences:
    - If only part of the data could be sent, it will automatically keep trying to send the remaining part.
    - If it receives WSAEWOULDBLOCK, it will wait for the socket's SEND event and try sending the data again.
    - If the data buffer to send is larger than the socket's send buffer size, it will automatically send the data in
      smaller chunks in order to avoid a performance hit. See http://support.microsoft.com/kb/823764 for more info.

Therefore, AHKsock_ForceSend will return only when all the data has been sent. Because this function relies on waiting for
the socket's SEND event before continuing to send data, it cannot be called in a critical thread. Also, for the same reason,
it cannot be called from a socket's associated function (not specifically iSocket's associated function, but any socket's
associated function).

Another limitation to consider when choosing between AHKsock_Send and AHKsock_ForceSend is that AHKsock_ForceSend will not
return until all the data has been sent (unless an error occurs). Although the script will still be responsive (new threads
will still be able to launch), the thread from which it was called will not resume until it returns. Therefore, if sending
a large amount of data, you should either use AHKsock_Send, or use AHKsock_ForceSend by feeding it smaller pieces of the
data, allowing you to update the GUI if necessary (e.g. a progress bar).

Returns blank on success, which means that all the data to which ptrData points of length iLength has been sent. On failure,
it returns one of the following negative integer:
    -1: WSAStartup hasn't been called yet.
    -3: The send() call failed. The error is in ErrorLevel.
    -4: The socket specified in iSocket is not a valid socket. This means either that the socket in iSocket hasn't been
        created using AHKsock_Connect or AHKsock_Listen, or that the socket has already been destroyed.
    -5: The current thread is critical.
    -6: The getsockopt() call failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

____________________________________________
AHKsock_Close(iSocket = -1, iTimeout = 5000)

Closes the socket in iSocket. If no socket is specified, AHKsock_Close will close all the sockets on record, as well as
terminate use of the Winsock 2 DLL (by calling WSACleanup). If graceful shutdown cannot be attained after the timeout
specified in iTimeout (in milliseconds), it will perform a hard shutdown before calling WSACleanup to free resources. See
the section titled "NOTES ON CLOSING SOCKETS AND AHKsock_Close" for more information.

Returns blank on success. On failure, it returns one of the following positive integer:
    1: The shutdown() call failed. The error is in ErrorLevel. AHKsock_Close forcefully closed the socket and freed the
       associated resources.

Note that when AHKsock_Close is called with no socket specified, it will never return an error.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

___________________________________________________________
AHKsock_GetAddrInfo(sHostName, ByRef sIPList, bOne = False)

Retrieves the list of IP addresses that correspond to the hostname in sHostName. The list is contained in sIPList, delimited
by newline characters. If bOne is True, only one IP (the first one) will be returned.

Returns blank on success. On failure, it returns one of the following positive integer:
    1: The WSAStartup() call failed. The error is in ErrorLevel.
    2: The Winsock DLL does not support version 2.2.
    3: Received WSAHOST_NOT_FOUND. No such host is known.
    4: The getaddrinfo() call failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

_________________________________________________________________________
AHKsock_GetNameInfo(sIP, ByRef sHostName, sPort = 0, ByRef sService = "")

Retrieves the hostname that corresponds to the IP address in sIP. If a port in sPort is supplied, it also retrieves the
service that corresponds to the port in sPort.

Returns blank on success. On failure, it returns on of the following positive integer:
    1: The WSAStartup() call failed. The error is in ErrorLevel.
    2: The Winsock DLL does not support version 2.2.
    3: The IP address supplied in sIP is invalid.
    4: The getnameinfo() call failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

______________________________________________
AHKsock_SockOpt(iSocket, sOption, iValue = -1)

Retrieves or sets a socket option. Supported options are:
    SO_KEEPALIVE: Enable/Disable sending keep-alives. iValue must be True/False to enable/disable. Disabled by default.
    SO_SNDBUF:    Total buffer space reserved for sends. Set iValue to 0 to completely disable the buffer. Default is 8 KB.
    SO_RCVBUF:    Total buffer space reserved for receives. Default is 8 KB.
    TCP_NODELAY:  Enable/Disable the Nagle algorithm for send coalescing. Set iValue to True to disable the Nagle algorithm,
                  set iValue to False to enable the Nagle algorithm, which is the default.

It is usually best to leave these options to their default (especially the Nagle algorithm). Only change them if you
understand the consequences. See MSDN for more information on those options.

If iValue is specified, it sets the option to iValue and returns blank on success. If iValue is left as -1, it returns the
value of the option specified. On failure, it returns one of the following negative integer:
    -1: The getsockopt() failed. The error is in ErrorLevel.
    -2: The setsockopt() failed. The error is in ErrorLevel.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

_______________________________________
AHKsock_Settings(sSetting, sValue = "")

Changes the AHKsock setting in sSetting to sValue. If sValue is blank, the current value for that setting is returned. If
sValue is the word "Reset", the setting is restored to its default value. The possible settings are:
    Message: Determines the Windows message numbers used to monitor network events. The message number in iMessage and the
             next number will be used. Default value is 0x8000. For example, calling AHKsock_Settings("Message", 0x8005)
             will cause AHKsock to use 0x8005 and 0x8006 to monitor network events.
    Buffer:  Determines the size of the buffer (in bytes) used when receiving data. This is thus the maximum size of bData
             when the RECEIVED event is raised. If the data received is more than the buffer size, multiple recv() calls
             (and thus multiple RECEIVED events) will be needed. Note that you shouldn't use this setting as a means of
             delimiting frames. See the "NOTES ON RECEIVING AND SENDING DATA" section for more information about receiving
             and sending data. Default value is 64 KB, which is the maximum for TCP.

If you do call AHKsock_Settings to change the values from their default ones, it is best to do so at the beginning of the
script. The message number used cannot be changed as long as there are active connections.

______________________________________
AHKsock_ErrorHandler(sFunction = """")

Sets the function in sFunction to be the new error handler. If sFunction is left at its default value, it returns the name
of the current error handling function.

An error-handling function is optional, but may be useful when troubleshooting applications. The function will be called
anytime there is an error that arises in a thread which wasn't called by the user but by the receival of a Windows message
which was registered using OnMessage.

The function in sFunction must be of the following format:
MyErrorHandler(iError, iSocket)

The possible values for iError are:
     1: The connect() call failed. The error is in ErrorLevel.
     2: The WSAAsyncSelect() call failed. The error is in ErrorLevel.
     3: The socket() call failed. The error is in ErrorLevel.
     4: The WSAAsyncSelect() call failed. The error is in ErrorLevel.
     5: The connect() call failed. The error is in ErrorLevel.
     6: FD_READ event received with an error. The error is in ErrorLevel. The socket is in iSocket.
     7: The recv() call failed. The error is in ErrorLevel. The socket is in iSocket.
     8: FD_WRITE event received with an error. The error is in ErrorLevel. The socket is in iSocket.
     9: FD_ACCEPT event received with an error. The error is in ErrorLevel. The socket is in iSocket.
    10: The accept() call failed. The error is in ErrorLevel. The listening socket is in iSocket.
    11: The WSAAsyncSelect() call failed. The error is in ErrorLevel. The listening socket is in iSocket.
    12: The listen() call failed. The error is in ErrorLevel. The listening socket is in iSocket.
    13: The shutdown() call failed. The error is in ErrorLevel. The socket is in iSocket.

For the failures which affect ErrorLevel, ErrorLevel will contain either the reason the DllCall itself failed (ie. -1, -2,
An, etc... as laid out in the AHK docs for DllCall) or the Windows Sockets Error Code as defined at:
http://msdn.microsoft.com/en-us/library/ms740668

__________________________________________________________________
NOTES ON SOCKETS AND THE STRUCTURE OF THE EVENT-HANDLING FUNCTION:

The functions used in the sFunction parameter of AHKsock_Listen and AHKsock_Connect must be of the following format:

MyFunction(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bData = 0, bDataLength = 0)

The variable sEvent contains the event for which MyFunction was called. The event raised is associated with one and only one
socket; the one in iSocket. The meaning of the possible events that can occur depend on the type of socket involved. AHKsock
deals with three different types of sockets:
    - Listening sockets: These sockets are created by a call to AHKsock_Listen. All they do is wait for clients to request
      a connection. These sockets will never appear as the iSocket parameter because requests for connections are
      immediately accepted, and MyFunction immediately receives the ACCEPTED event with iSocket set to the accepted socket.
    - Accepted sockets: These sockets are created once a listening socket receives an incoming connection attempt from a
      client and accepts it. They are thus the sockets that servers use to communicate with clients.
    - Connected sockets: These sockets are created by a successful call to AHKsock_Connect. These are the sockets that
      clients use to communicate with servers.

More info about sockets:
    - You may have multiple client sockets connecting to the same listening socket (ie. on the same port).
    - You may have multiple listening sockets for different ports.
    - You cannot have more than one listening socket for the same port (or you will receive a bind() error).
    - Every single connection between a client and a server will have its own client socket on the client side, and its own
      server (accepted) socket on the server side.

For all of the events that the event-handling function receives,
    - sEvent contains the event that occurred (as described below),
    - iSocket contains the socket on which the event occurred,
    - sName contains a value which depends on the type of socket in iSocket:
        - If the socket is an accepted socket, sName is empty.
        - If the socket is a connected socket, sName is the same value as the sName parameter that was used when
          AHKsock_Connect was called to create the socket. Since AHKsock_Connect accepts both hostnames and IP addresses,
          sName may contain either.
    - sAddr contains the IP address of the socket's endpoint (i.e. the peer's IP address). This means that if the socket in
      iSocket is an accepted socket, sAddr contains the IP address of the client. Conversely, if it is a connected socket,
      sAddr contains the server's IP.
    - sPort contains the server port on which the connection was accepted.

Obviously, if your script only calls AHKsock_Listen (acting as a server) or AHKsock_Connect (acting as a client) you don't
need to check if the socket in iSocket is an accepted socket or a connected socket, since it can only be one or the other.
But if you do call both AHKsock_Listen and AHKsock_Connect with both of them using the same function (e.g. MyFunction), then
you will need to check what type of socket iSocket is by checking the sName parameter.

Of course, it would be easier to simply have two different functions, for example, MyFunction1 and MyFunction2, with one
handling the server part and the other handling the client part so that you don't need to check what type of socket iSocket
is when each function is called. However, this might not be necessary if both server and client are "symmetrical" (i.e. the
conversation doesn't actually change whether or not we're on the server side or the client side). See Example 3 for an
example of this, where only one function is used for both server and client sockets.

The variable sEvent can be one of the following values if iSocket is an accepted socket:
    sEvent =      Event Description:
    ACCEPTED      A client connection was accepted (see the "Listening sockets" section above for more details).
    CONNECTED     <Does not occur on accepted sockets>
    DISCONNECTED  The client disconnected (see AHKsock_Close for more details).
    SEND          You may now send data to the client (see AHKsock_Send for more details).
    RECEIVED      You received data from the client. The data received is in bData and the length is in bDataLength.
    SENDLAST      The client is disconnecting. This is your last chance to send data to it. Once this function returns,
                  disconnection will occur. This event only occurs on the side which did not initiate shutdown (see
                  AHKsock_Close for more details).

The variable sEvent can be one of the following values if iSocket is a connected socket:
    sEvent =      Event Description:
    ACCEPTED      <Does not occur on connected sockets>
    CONNECTED     The connection attempt initiated by calling AHKsock_Connect has completed (see AHKsock_Connect for more
                  details). If it was successful, iSocket will equal the client socket. If it failed, iSocket will equal -1.
                  To get the error code that the failure returned, set an error handling function with AHKsock_ErrorHandler,
                  and read ErrorLevel when iError is equal to 1.
    DISCONNECTED  The server disconnected (see AHKsock_Close for more details).
    SEND          You may now send data to the server (see AHKsock_Send for more details).
    RECEIVED      You received data from the server. The data received is in bData and the length is in bDataLength.
    SENDLAST      The server is disconnecting. This is your last chance to send data to it. Once this function returns,
                  disconnection will occur. This event only occurs on the side which did not initiate shutdown (see 
                  AHKsock_Close for more details).

More information: The event-handling functions described in here are always called with the Critical setting on. This is
necessary in order to ensure proper processing of messages. Note that as long as the event-handling function does not
return, AHKsock cannot process other network messages. Although messages are buffered, smooth operation might suffer when
letting the function run for longer than it should.

___________________________________________
NOTES ON CLOSING SOCKETS AND AHKsock_Close:

There are a few things to note about the AHKsock_Close function. The most important one is this: because the OnExit
subroutine cannot be made interruptible if running due to a call to Exit/ExitApp, AHKsock_Close will not be able to execute
a graceful shutdown if it is called from there. 

A graceful shutdown refers to the proper way of closing a TCP connection. It consists of an exchange of special TCP messages
between the two endpoints to acknowledge that the connection is about to close. It also fires the SENDLAST event in the
socket's associated function to notify that this is the last chance it will have to send data before disconnection. Note
that listening sockets cannot (and therefore do not need to) be gracefully shutdown as it is not an end-to-end connection.
(In practice, you will never have to manually call AHKsock_Close on a listening socket because you do not have access to
them. The socket is closed when you stop listening by calling AHKsock_Listen with no specified value for the second
parameter.)

In order to allow the socket(s) connection(s) to gracefully shutdown (which is always preferable), AHKsock_Close must be
called in a thread which is, or can be made, interruptible. If it is called with a specified socket in iSocket, it will
initiate a graceful shutdown for that socket alone. If it is called with no socket specified, it will initiate a graceful
shutdown for all connected/accepted sockets, and once done, deregister itself from the Windows Sockets implementation and
allow the implementation to free any resources allocated for Winsock (by calling WSACleanup). In that case, if any
subsequent AHKsock function is called, Winsock will automatically be restarted.

Therefore, before exiting your application, AHKsock_Close must be called at least once with no socket specified in order to
free Winsock resources. This can be done in the OnExit subroutine, either if you do not wish to perform a graceful shutdown
(which is not recommended), or if you have already gracefully shutdown all the sockets individually before calling
Exit/ExitApp. Of course, it doesn't have to be done in the OnExit subroutine and can be done anytime before (which is the
recommended method because AHKsock will automatically gracefully shutdown all the sockets on record).

This behaviour has a few repercussions on your application's design. If the only way for the user to terminate your
application is through AHK's default Exit menu item in the tray menu, then upon selecting the Exit menu item, the OnExit sub
will fire, and your application will not have a chance to gracefully shutdown connected sockets. One way around this is to
add your own menu item which will in turn call AHKsock_Close with no socket specified before calling ExitApp to enter the
OnExit sub. See AHKsock Example 1 for an example of this.

This is how the graceful shutdown process occurs between two connected peers:
    a> Once one of the peers (it may be the server of the client) is done sending all its data, it calls AHKsock_Close to
       shutdown the socket. (It is not a good idea to have the last peer receiving data call AHKsock_Close. This will result
       in AHKsock_Send errors on the other peer if more data needs to be sent.) In the next steps, we refer to the peer that
       first calls AHKsock_Close as the invoker, and the other peer simply as the peer.
    b> The peer receives the invoker's intention to close the connection and is given one last chance to send any remaining
       data. This is when the peer's socket's associated function receives the SENDLAST event.
    c> Once the peer is done sending any remaining data (if any), it also calls AHKsock_Close on that same socket to shut it
       down, and then close the socket for good. This happens once the peer's function that received the SENDLAST event
       returns from the event. At this point, the peer's socket's associated function receives the DISCONNECTED event.
    d> This happens in parallel with c>. After the invoker receives the peer's final data (if any), as well as notice that
       the peer has also called AHKsock_Close on the socket, the invoker finally also closes the socket for good. At this
       point, the socket's associated function also receives the DISCONNECTED event.

When AHKsock_Close is called with no socket specified, this process occurs (in parallel) for every connected socket on
record.

____________________________________
NOTES ON RECEIVING AND SENDING DATA:

It's important to understand that AHKsock uses the TCP protocol, which is a stream protocol. This means that the data
received comes as a stream, with no apparent boundaries (i.e. frames or packets). For example, if a peer sends you a string,
it's possible that half the string is received in one RECEIVED event and the other half is received in the next. Of course,
the smaller the string, the less likely this happens. Conversely, the larger the string, the more likely this will occur.

Similarly, calling AHKsock_Send will not necessarily send the data right away. If multiple AHKsock_Send calls are issued,
Winsock might, under certain conditions, wait and accumulate data to send before sending it all at once. This process is
called coalescing. For example, if you send two strings to your peer by using two individual AHKsock_Send calls, the peer
will not necessarily receive two consecutive RECEIVED events for each string, but might instead receive both strings through
a single RECEIVED event.

One efficient method of receiving data as frames is to use length-prefixing. Length-prefixing means that before sending a
frame of variable length to your peer, you first tell it how many bytes will be in the frame. This way, your peer can
divide the received data into frames that can be individually processed. If it received less than a frame, it can store the
received data and wait for the remaining data to arrive before processing the completed frame with the length specified.
This technique is used in in AHKsock Example 3, where peers send each other strings by first declaring how long the string
will be (see the StreamProcessor function of Example 3).

____________________________________
NOTES ON TESTING A STREAM PROCESSOR:

As you write applications that use length-prefixing as described above, you might find it hard to test their ability to
properly cut up and/or put together the data into frames when testing them on the same machine or on a LAN (because the
latency is too low and it is thus harder to stress the connection).

In this case, what you can do to properly test them is to uncomment the comment block in AHKsock_Send, which will sometimes
purposely fail to send part of the data requested. This will allow you to simulate what could happen on a connection going
through the Internet. You may change the probability of failure by changing the number in the If statement.

If your application can still work after uncommenting the block, then it is a sign that it is properly handling frames split
across multiple RECEIVED events. This would also demonstrate your application's ability to cope with partially sent data.
*/

; ==========================================
; RAM MONITORING FUNCTIONS
; ==========================================
MonitorAndClearRAM:
    Loop, 8
    {
        windowName := "win" . A_Index
        CheckAndClearMemory(windowName)
    }
return

CheckAndClearMemory(windowName)
{
    global lastMemoryCheck, RAMClearingEnabled, MaxRAMValue

    if (!RAMClearingEnabled)
        return

    WinGet, pid, PID, %windowName%
    if (!pid)
        return

    currentMem := GetProcessMemoryMB(pid)
    if (currentMem >= MaxRAMValue)
    {
        ClearProcessMemory(pid, windowName, currentMem)
        lastMemoryCheck[windowName] := A_TickCount
    }
}

GetProcessMemoryMB(pid)
{
    for proc in ComObjGet("winmgmts:").ExecQuery("SELECT WorkingSetSize FROM Win32_Process WHERE ProcessId=" . pid)
        return Round(proc.WorkingSetSize / 1024 / 1024, 2)
return 0
}

ClearProcessMemory(pid, windowName, memBefore)
{
    hProcess := DllCall("OpenProcess", "UInt", 0x0400 | 0x0100, "Int", 0, "UInt", pid, "Ptr")
    if (hProcess)
    {
        DllCall("kernel32\SetProcessWorkingSetSize", "Ptr", hProcess, "Ptr", -1, "Ptr", -1)
        DllCall("CloseHandle", "Ptr", hProcess)

        Sleep, 100
        memAfter := GetProcessMemoryMB(pid)
        memFreed := memBefore - memAfter

        ; Update GUI text in green
        GuiControl, TopBar:Font, RAMStatusText
        Gui, TopBar:Font, s8 cLime Bold, Segoe UI
        GuiControl, TopBar:Font, RAMStatusText
        GuiControl, TopBar:, RAMStatusText, % "RAM Cleared"

        SetTimer, ResetRAMStatusColor, -5000
    }
}

ResetRAMStatusColor:
    Gui, TopBar:Font, s8 c0x2D2D30, Segoe UI
    GuiControl, TopBar:Font, RAMStatusText
    GuiControl, TopBar:, RAMStatusText,
return

; ==========================================
; SETTINGS GUI
; ==========================================
OpenSettings:
    global SettingsGuiVisible, RAMClearingEnabled, MaxRAMValue, ServerPort, ServerListening

    if (SettingsGuiVisible) {
        Gui, Settings:Destroy
        SettingsGuiVisible := false
        return
    }

    ; Create Settings GUI
    Gui, Settings:New, +AlwaysOnTop +ToolWindow -caption
    Gui, Settings:Color, 0x1E1E1E
    Gui, Settings:+HwndSettingsHwnd
    Gui, Settings:Font, s9 cWhite, Segoe UI

    Theme1 := HBCustomButton()
    GuiButtonType1.SetSessionDefaults( Theme1.All , Theme1.Default , Theme1.Hover , Theme1.Pressed )

    ; ===== LEFT COLUMN =====
    
    ; Network Settings GroupBox
    Gui, Settings:Font, s8 cWhite, Segoe UI
    Gui, Settings:Add, GroupBox, x5 y5 w210 h180, Server Settings

    Gui, Settings:Font, s9 cWhite, Segoe UI
    Gui, Settings:Add, Text, x15 y25 w90 h20, Server Port:
    Gui, Settings:Font, s9 cBlack, Segoe UI
    Gui, Settings:Add, Edit, x110 y22 w100 h22 vServerPort, %ServerPort%

    ; Server Toggle Button
    If ServerListening
        New HButton( { Owner: SettingsHwnd , X: 15 , Y: 50 , W: 190 , H: 24 , Text: "Stop Server" , Label: "ToggleServer" } )
    Else
        New HButton( { Owner: SettingsHwnd , X: 15 , Y: 50 , W: 190 , H: 24 , Text: "Start Server" , Label: "ToggleServer" } )

    ; Connection Info
    Gui, Settings:Font, s8 cLime, Segoe UI
    Gui, Settings:Add, Text, x15 y80 w190 h15, Connection Information:
    
    Gui, Settings:Font, s8 cWhite, Segoe UI
    Gui, Settings:Add, Text, x15 y100 w80 h15, Public IP:
    Gui, Settings:Font, s8 cYellow, Segoe UI
    Gui, Settings:Add, Text, x95 y100 w110 h15 vPublicIPText, Checking...
    
    Gui, Settings:Font, s8 cWhite, Segoe UI
    Gui, Settings:Add, Text, x15 y120 w80 h15, Port:
    Gui, Settings:Font, s8 cYellow, Segoe UI
    Gui, Settings:Add, Text, x95 y120 w110 h15 vPortText, %ServerPort%
    
    ; Info button for connection instructions
    New HButton( { Owner: SettingsHwnd , X: 15 , Y: 145 , W: 190 , H: 30 , Text: "Connection Info (?)" , Label: "ShowConnectionInfo" } )

    ; RAM Settings GroupBox
    Gui, Settings:Font, s8 cWhite, Segoe UI
    Gui, Settings:Add, GroupBox, x5 y190 w210 h80, RAM Settings

    ; RAM Clearing Toggle
    If RAMClearingEnabled
        Gui, Settings:Add, Checkbox, x15 y210 w190 h20 vRAMClearingEnabled gToggleRAMClearing Checked, Enable RAM Clearing
    Else
        Gui, Settings:Add, Checkbox, x15 y210 w190 h20 vRAMClearingEnabled gToggleRAMClearing, Enable RAM Clearing

    ; Max RAM (MB):
    Gui, Settings:Font, s9 cWhite, Segoe UI
    Gui, Settings:Add, Text, x15 y235 w90 h20, Max RAM (MB):
    Gui, Settings:Font, s9 cBlack, Segoe UI
    Gui, Settings:Add, Edit, x110 y232 w78 h22 vMaxRAMValue, %MaxRAMValue%

    New HButton( { Owner: SettingsHwnd , X: 190 , Y: 232 , W: 10 , H: 11 , Text: "▲" , Label: "IncreaseRAM" } )
    New HButton( { Owner: SettingsHwnd , X: 190 , Y: 243 , W: 10 , H: 11 , Text: "▼" , Label: "DecreaseRAM" } )

    ; Addon Scripts GroupBox
    Gui, Settings:Font, s9 cWhite, Segoe UI
    Gui, Settings:Add, GroupBox, x5 y275 w210 h70, Addon Scripts

    UtilityScriptDropdownList := ""
    UtilityScriptPaths := {}
    scripts := GetAddonScripts()
    for i, script in scripts {
        UtilityScriptDropdownList .= script.display "|"
        UtilityScriptPaths[script.display] := script.full
    }
    UtilityScriptDropdownList := RTrim(UtilityScriptDropdownList, "|")
    Gui, Settings:Add, DropDownList, x15 y295 w150 h120 vUtilityScriptDropdown, %UtilityScriptDropdownList%||
    New HButton( { Owner: SettingsHwnd , X: 170 , Y: 295 , W: 40 , H: 24 , Text: "Start" , Label: "LaunchUtilityScript" } )

    ; ===== RIGHT COLUMN =====

    ; Connect Settings GroupBox
    Gui, Settings:Font, s8 cWhite, Segoe UI
    Gui, Settings:Add, GroupBox, x220 y5 w210 h180, Client Connect Settings

    Gui, Settings:Font, s9 cWhite, Segoe UI
    Gui, Settings:Add, Text, x230 y25 w90 h20, Remote IP:
    Gui, Settings:Font, s9 cBlack, Segoe UI
    Gui, Settings:Add, Edit, x325 y22 w100 h22 vConnectIP, %ConnectIP%

    Gui, Settings:Font, s9 cWhite, Segoe UI
    Gui, Settings:Add, Text, x230 y50 w90 h20, Remote Port:
    Gui, Settings:Font, s9 cBlack, Segoe UI
    Gui, Settings:Add, Edit, x325 y47 w100 h22 vConnectPort, %ConnectPort%

    ; Connect Toggle Button
    If ConnectedToMaster
        New HButton( { Owner: SettingsHwnd , X: 230 , Y: 80 , W: 190 , H: 24 , Text: "Disconnect" , Label: "ToggleConnect" } )
    Else
        New HButton( { Owner: SettingsHwnd , X: 230 , Y: 80 , W: 190 , H: 24 , Text: "Connect" , Label: "ToggleConnect" } )

    ; Connection Status
    Gui, Settings:Font, s8 cWhite, Segoe UI
    Gui, Settings:Add, Text, x230 y110 w60 h15, Status:
    If ConnectedToMaster {
        Gui, Settings:Font, s8 cLime, Segoe UI
        Gui, Settings:Add, Text, x290 y110 w130 h15 vConnectStatusText, Connected
    } Else {
        Gui, Settings:Font, s8 cRed, Segoe UI
        Gui, Settings:Add, Text, x290 y110 w130 h15 vConnectStatusText, Disconnected
    }

    Gui, Settings:Font, s7 cYellow, Segoe UI
    Gui, Settings:Add, Text, x230 y135 w190 h45, Note: Connect to another TopBar to relay commands across networks.

    ; Appearance Settings GroupBox
    Gui, Settings:Font, s8 cWhite, Segoe UI
    Gui, Settings:Add, GroupBox, x220 y190 w210 h155, Appearance

    ; Button Color
    Gui, Settings:Font, s8 cWhite, Segoe UI
    Gui, Settings:Add, Text, x230 y210 w80 h20, Button Color:
    Gui, Settings:Font, s9 cWhite, Segoe UI
    Gui, Settings:Add, DropDownList, x230 y225 w130 h100 vButtonColorChoice, Green||Lime|Red|Blue|Yellow|Cyan|Magenta|White|Orange|Purple|Pink|Silver
    New HButton( { Owner: SettingsHwnd , X: 365 , Y: 225 , W: 55 , H: 24 , Text: "Apply" , Label: "ApplyButtonColor" } )

    ; Logo Color
    Gui, Settings:Font, s8 cWhite, Segoe UI
    Gui, Settings:Add, Text, x230 y255 w80 h20, Logo Color:
    Gui, Settings:Font, s9 cWhite, Segoe UI
    Gui, Settings:Add, DropDownList, x230 y270 w130 h100 vLogoColorChoice, Gray||Green|Lime|Red|Blue|Yellow|Cyan|Magenta|White|Orange|Purple|Pink|Silver
    New HButton( { Owner: SettingsHwnd , X: 365 , Y: 270 , W: 55 , H: 24 , Text: "Apply" , Label: "ApplyLogoColor" } )

    ; Bar Color
    Gui, Settings:Font, s8 cWhite, Segoe UI
    Gui, Settings:Add, Text, x230 y300 w80 h20, Bar Color:
    Gui, Settings:Font, s9 cWhite, Segoe UI
    Gui, Settings:Add, DropDownList, x230 y315 w130 h100 vBarColorChoice, Dark Gray||Black|Charcoal|Slate Gray|Dark Blue|Navy Blue|Midnight Blue
    New HButton( { Owner: SettingsHwnd , X: 365 , Y: 315 , W: 55 , H: 24 , Text: "Apply" , Label: "ApplyBarColor" } )

    ; Show GUI
    global actBarGuiHandle
    WinGetPos, actBarX, actBarY, actBarW, actBarH, ahk_id %actBarGuiHandle%
    settingsOffsetX := -295
    settingsOffsetY := 0

    settingsW := 440
    settingsH := 350
    settingsX := actBarX + (actBarW // 2) - (settingsW // 2) + settingsOffsetX
    settingsY := actBarY - settingsH + settingsOffsetY
    if (settingsX < 0)
        settingsX := 0
    if (settingsY < 0)
        settingsY := 0
    Gui, Settings:Show, x%settingsX% y%settingsY% w%settingsW% h%settingsH%, Settings
    SettingsGuiVisible := true
    
    ; Fetch public IP asynchronously
    SetTimer, FetchPublicIP, -100
return

FetchPublicIP:
    publicIP := GetPublicIPAddress()
    GuiControl, Settings:, PublicIPText, %publicIP%
return

SettingsGuiClose:
SettingsGuiEscape:
    global SettingsGuiVisible, MaxRAMValue, ServerPort
    Gui, Settings:Submit, NoHide
    ; Validate and save settings when closing
    if (MaxRAMValue < 100)
        MaxRAMValue := 100
    if (MaxRAMValue > 10000)
        MaxRAMValue := 10000
    SaveSettingsToFile()
    Gui, Settings:Destroy
    SettingsGuiVisible := false
return

ToggleRAMClearing:
    global RAMClearingEnabled
    Gui, Settings:Submit, NoHide
    SaveSettingsToFile()
return

IncreaseRAM:
    global MaxRAMValue
    Gui, Settings:Submit, NoHide
    MaxRAMValue += 50
    if (MaxRAMValue > 10000)
        MaxRAMValue := 10000
    GuiControl, Settings:, MaxRAMValue, %MaxRAMValue%
    SaveSettingsToFile()
return

DecreaseRAM:
    global MaxRAMValue
    Gui, Settings:Submit, NoHide
    MaxRAMValue -= 50
    if (MaxRAMValue < 100)
        MaxRAMValue := 100
    GuiControl, Settings:, MaxRAMValue, %MaxRAMValue%
    SaveSettingsToFile()
return

SaveMaxRAM:
    global MaxRAMValue
    Gui, Settings:Submit, NoHide
    ; Ensure it's a valid number
    if (MaxRAMValue < 100)
        MaxRAMValue := 100
    if (MaxRAMValue > 10000)
        MaxRAMValue := 10000
    GuiControl, Settings:, MaxRAMValue, %MaxRAMValue%
    SaveSettingsToFile()
return

SaveServerPort:
    global ServerPort
    Gui, Settings:Submit, NoHide
    ; Update the global port variable
    GuiControl, TopBar:, ServerPort, %ServerPort%
    SaveSettingsToFile()
return

LaunchUtilityScript:
    Gui, Settings:Submit, NoHide
    selectedScript := UtilityScriptDropdown

    ; Dynamically get the latest list of addon scripts
    scripts := GetAddonScripts()
    scriptPath := ""
    for i, script in scripts {
        if (script.display = selectedScript) {
            scriptPath := script.full
            break
        }
    }

    if (!scriptPath || !FileExist(scriptPath)) {
        MsgBox, Script not found: %scriptPath%
        return
    }
    Run, %scriptPath%
return

GetAddonScripts() {
    scripts := []
    Loop, Files, % A_ScriptDir "\addons\*.*", R
    {
        if (A_LoopFileExt = "ahk" || A_LoopFileExt = "exe") {
            scripts.Push({display: A_LoopFileName, full: A_LoopFileFullPath})
        }
    }
return scripts
}

GetLocalIPAddress() {
    ; Get local IP address using ipconfig command
    RunWait, %ComSpec% /c ipconfig | findstr /i "IPv4" > %A_Temp%\ip.txt, , Hide
    FileRead, ipOutput, %A_Temp%\ip.txt
    FileDelete, %A_Temp%\ip.txt
    
    ; Parse the IP from the output (format: "   IPv4 Address. . . . . . . . . . . : 192.168.1.100")
    if (RegExMatch(ipOutput, "(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})", ip)) {
        return ip
    }
    
    return "Not Found"
}

GetPublicIPAddress() {
    ; Fetch public IP from whatismyip.com
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    try {
        whr.Open("GET", "https://ipv4.icanhazip.com", false)
        whr.SetRequestHeader("User-Agent", "Mozilla/5.0")
        whr.Send()
        publicIP := whr.ResponseText
        ; Trim whitespace/newlines
        publicIP := RegExReplace(publicIP, "[\r\n\s]+", "")
        return publicIP
    } catch {
        return "Failed to fetch"
    }
}

ChangeButtonColor:
return

GetColorHex(colorName) {
    colors := {"Green": "0xFF00FF00", "Lime": "0xFF00FF00", "Red": "0xFFFF0000", "Blue": "0xFF0000FF", "Yellow": "0xFFFFFF00", "Cyan": "0xFF00FFFF", "Magenta": "0xFFFF00FF", "White": "0xFFFFFFFF", "Orange": "0xFFFFA500", "Purple": "0xFF800080", "Pink": "0xFFFFC0CB", "Silver": "0xFFC0C0C0", "Aqua": "0xFF00FFFF", "Fuchsia": "0xFFFF00FF", "Navy": "0xFF000080", "Teal": "0xFF008080", "Maroon": "0xFF800000", "Olive": "0xFF808000", "Black": "0xFF000000", "Gray": "0xFF808080", "Crimson": "0xFFDC143C", "Gold": "0xFFFFD700", "Indigo": "0xFF4B0082", "Coral": "0xFFFF7F50", "Salmon": "0xFFFA8072", "Violet": "0xFFEE82EE", "Turquoise": "0xFF40E0D0", "Khaki": "0xFFF0E68C", "Plum": "0xFFDDA0DD", "Orchid": "0xFFDA70D6", "Tan": "0xFFD2B48C", "Chocolate": "0xFFD2691E", "Peru": "0xFFCD853F", "Sienna": "0xFFA0522D", "Tomato": "0xFFFF6347", "SkyBlue": "0xFF87CEEB", "SteelBlue": "0xFF4682B4", "SlateBlue": "0xFF6A5ACD", "RoyalBlue": "0xFF4169E1", "DodgerBlue": "0xFF1E90FF", "DeepPink": "0xFFFF1493", "HotPink": "0xFFFF69B4", "LightPink": "0xFFFFB6C1", "PaleGreen": "0xFF98FB98", "LightGreen": "0xFF90EE90", "SpringGreen": "0xFF00FF7F", "SeaGreen": "0xFF2E8B57", "ForestGreen": "0xFF228B22", "DarkGreen": "0xFF006400", "YellowGreen": "0xFF9ACD32", "OliveDrab": "0xFF6B8E23", "Chartreuse": "0xFF7FFF00", "GreenYellow": "0xFFADFF2F", "LawnGreen": "0xFF7CFC00", "MediumSpringGreen": "0xFF00FA9A"}
return colors.HasKey(colorName) ? colors[colorName] : "0xFF00FF00"
}

ApplyButtonColor:
    global ButtonTextColor
    Gui, Settings:Submit, NoHide
    ButtonTextColor := GetColorHex(ButtonColorChoice)
    SaveSettingsToFile()
    MsgBox, Button color saved! Please restart the script to apply the new button color.`n`n(Button colors require restart due to custom rendering)
return

ApplyLogoColor:
    global LogoTextColor
    Gui, Settings:Submit, NoHide
    LogoTextColor := LogoColorChoice
    SaveSettingsToFile()

    ; Apply color immediately to logo text and Nexus Master text
    colorHex := GetTextColorHex(LogoTextColor)
    Gui, ActBar:Font, s7 c%colorHex%, Segoe UI
    GuiControl, ActBar:Font, LogoText
    Gui, TopBar:Font, s9 c%colorHex% Bold, Segoe UI
    GuiControl, TopBar:Font, TopBarLogoText

    MsgBox, Logo color changed!
return

GetTextColorHex(colorName) {
    colors := {"Green": "008000", "Lime": "00FF00", "Red": "FF0000", "Blue": "0000FF", "Yellow": "FFFF00", "Cyan": "00FFFF", "Magenta": "FF00FF", "White": "FFFFFF", "Orange": "FFA500", "Purple": "800080", "Pink": "FFC0CB", "Silver": "C0C0C0", "Aqua": "00FFFF", "Fuchsia": "FF00FF", "Navy": "000080", "Teal": "008080", "Maroon": "800000", "Olive": "808000", "Black": "000000", "Gray": "808080", "Crimson": "DC143C", "Gold": "FFD700", "Indigo": "4B0082", "Coral": "FF7F50", "Salmon": "FA8072", "Violet": "EE82EE", "Turquoise": "40E0D0", "Khaki": "F0E68C", "Plum": "DDA0DD", "Orchid": "DA70D6", "Tan": "D2B48C", "Chocolate": "D2691E", "Peru": "CD853F", "Sienna": "A0522D", "Tomato": "FF6347", "SkyBlue": "87CEEB", "SteelBlue": "4682B4", "SlateBlue": "6A5ACD", "RoyalBlue": "4169E1", "DodgerBlue": "1E90FF", "DeepPink": "FF1493", "HotPink": "FF69B4", "LightPink": "FFB6C1", "PaleGreen": "98FB98", "LightGreen": "90EE90", "SpringGreen": "00FF7F", "SeaGreen": "2E8B57", "ForestGreen": "228B22", "DarkGreen": "006400", "YellowGreen": "9ACD32", "OliveDrab": "6B8E23", "Chartreuse": "7FFF00", "GreenYellow": "ADFF2F", "LawnGreen": "7CFC00", "MediumSpringGreen": "00FA9A"}
return colors.HasKey(colorName) ? colors[colorName] : "00FF00"
}

ApplyCheckboxColor:
    global CheckboxTextColor
    Gui, Settings:Submit, NoHide
    CheckboxTextColor := CheckboxColorChoice
    SaveSettingsToFile()

    ; Apply color immediately to text labels
    colorHex := GetTextColorHex(CheckboxTextColor)
    Gui, TopBar:Font, s8 c%colorHex%, Segoe UI
    Loop, 8 {
        GuiControl, TopBar:Font, WinLabel%A_Index%
    }

    MsgBox, Checkbox text color changed!
return

GetBarColorHex(colorName) {
    colors := {"Dark Gray": "0x1E1E1E", "Black": "0x000000", "Charcoal": "0x36454F", "Slate Gray": "0x2F4F4F", "Dark Blue": "0x00008B", "Navy Blue": "0x000080", "Midnight Blue": "0x191970", "Dark Teal": "0x008080", "Dark Cyan": "0x008B8B", "Dark Green": "0x006400", "Forest Green": "0x228B22", "Dark Olive": "0x556B2F", "Dark Red": "0x8B0000", "Maroon": "0x800000", "Dark Purple": "0x301934", "Indigo": "0x4B0082", "Dark Magenta": "0x8B008B", "Brown": "0x654321", "Saddle Brown": "0x8B4513", "Chocolate": "0x3E2723", "Dark Orange": "0x8B4000", "Dark Slate Blue": "0x483D8B", "Dark Slate Gray": "0x2F4F4F", "Dim Gray": "0x696969", "Steel Blue": "0x4682B4", "Dark Sea Green": "0x2F4F3F"}
return colors.HasKey(colorName) ? colors[colorName] : "0x1E1E1E"
}

ApplyBarColor:
    global BarBackgroundColor
    Gui, Settings:Submit, NoHide
    BarBackgroundColor := GetBarColorHex(BarColorChoice)
    SaveSettingsToFile()
    MsgBox, Bar color saved! Please restart the script to apply the new bar color.`n`n(Bar colors require restart due to GUI rendering)
return
; Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11
;
;#####################################################################################
;#####################################################################################
; STATUS ENUMERATION
; Return values for functions specified to have status enumerated return type
;#####################################################################################
;
; Ok =						= 0
; GenericError				= 1
; InvalidParameter			= 2
; OutOfMemory				= 3
; ObjectBusy				= 4
; InsufficientBuffer		= 5
; NotImplemented			= 6
; Win32Error				= 7
; WrongState				= 8
; Aborted					= 9
; FileNotFound				= 10
; ValueOverflow				= 11
; AccessDenied				= 12
; UnknownImageFormat		= 13
; FontFamilyNotFound		= 14
; FontStyleNotFound			= 15
; NotTrueTypeFont			= 16
; UnsupportedGdiplusVersion	= 17
; GdiplusNotInitialized		= 18
; PropertyNotFound			= 19
; PropertyNotSupported		= 20
; ProfileNotFound			= 21
;
;#####################################################################################
;#####################################################################################
; FUNCTIONS
;#####################################################################################
;
; UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
; BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
; StretchBlt(dDC, dx, dy, dw, dh, sDC, sx, sy, sw, sh, Raster="")
; SetImage(hwnd, hBitmap)
; Gdip_BitmapFromScreen(Screen=0, Raster="")
; CreateRectF(ByRef RectF, x, y, w, h)
; CreateSizeF(ByRef SizeF, w, h)
; CreateDIBSection
;
;#####################################################################################

; Function:     			UpdateLayeredWindow
; Description:  			Updates a layered window with the handle to the DC of a gdi bitmap
; 
; hwnd        				Handle of the layered window to update
; hdc           			Handle to the DC of the GDI bitmap to update the window with
; Layeredx      			x position to place the window
; Layeredy      			y position to place the window
; Layeredw      			Width of the window
; Layeredh      			Height of the window
; Alpha         			Default = 255 : The transparency (0-255) to set the window transparency
;
; return      				If the function succeeds, the return value is nonzero
;
; notes						If x or y omitted, then layered window will use its current coordinates
;							If w or h omitted then current width and height will be used

UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
{
    if ((x != "") && (y != ""))
        VarSetCapacity(pt, 8), NumPut(x, pt, 0), NumPut(y, pt, 4)

    if (w = "") ||(h = "")
        WinGetPos,,, w, h, ahk_id %hwnd%

return DllCall("UpdateLayeredWindow", "uint", hwnd, "uint", 0, "uint", ((x = "") && (y = "")) ? 0 : &pt
, "int64*", w|h<<32, "uint", hdc, "int64*", 0, "uint", 0, "uint*", Alpha<<16|1<<24, "uint", 2)
}

;#####################################################################################

; Function				BitBlt
; Description			The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle 
;						of pixels from the specified source device context into a destination device context.
;
; dDC					handle to destination DC
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of the area to copy
; dh					height of the area to copy
; sDC					handle to source DC
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; Raster				raster operation code
;
; return				If the function succeeds, the return value is nonzero
;
; notes					If no raster operation is specified, then SRCCOPY is used, which copies the source directly to the destination rectangle
;
; BLACKNESS				= 0x00000042
; NOTSRCERASE			= 0x001100A6
; NOTSRCCOPY			= 0x00330008
; SRCERASE				= 0x00440328
; DSTINVERT				= 0x00550009
; PATINVERT				= 0x005A0049
; SRCINVERT				= 0x00660046
; SRCAND				= 0x008800C6
; MERGEPAINT			= 0x00BB0226
; MERGECOPY				= 0x00C000CA
; SRCCOPY				= 0x00CC0020
; SRCPAINT				= 0x00EE0086
; PATCOPY				= 0x00F00021
; PATPAINT				= 0x00FB0A09
; WHITENESS				= 0x00FF0062
; CAPTUREBLT			= 0x40000000
; NOMIRRORBITMAP		= 0x80000000

BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
{
return DllCall("gdi32\BitBlt", "uint", dDC, "int", dx, "int", dy, "int", dw, "int", dh
, "uint", sDC, "int", sx, "int", sy, "uint", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function				StretchBlt
; Description			The StretchBlt function copies a bitmap from a source rectangle into a destination rectangle, 
;						stretching or compressing the bitmap to fit the dimensions of the destination rectangle, if necessary.
;						The system stretches or compresses the bitmap according to the stretching mode currently set in the destination device context.
;
; ddc					handle to destination DC
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of destination rectangle
; dh					height of destination rectangle
; sdc					handle to source DC
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source rectangle
; sh					height of source rectangle
; Raster				raster operation code
;
; return				If the function succeeds, the return value is nonzero
;
; notes					If no raster operation is specified, then SRCCOPY is used. It uses the same raster operations as BitBlt		

StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster="")
{
return DllCall("gdi32\StretchBlt", "uint", ddc, "int", dx, "int", dy, "int", dw, "int", dh
, "uint", sdc, "int", sx, "int", sy, "int", sw, "int", sh, "uint", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function				SetStretchBltMode
; Description			The SetStretchBltMode function sets the bitmap stretching mode in the specified device context
;
; hdc					handle to the DC
; iStretchMode			The stretching mode, describing how the target will be stretched
;
; return				If the function succeeds, the return value is the previous stretching mode. If it fails it will return 0
;
; STRETCH_ANDSCANS 		= 0x01
; STRETCH_ORSCANS 		= 0x02
; STRETCH_DELETESCANS 	= 0x03
; STRETCH_HALFTONE 		= 0x04

SetStretchBltMode(hdc, iStretchMode=4)
{
return DllCall("gdi32\SetStretchBltMode", "uint", hdc, "int", iStretchMode)
}

;#####################################################################################

; Function				SetImage
; Description			Associates a new image with a static control
;
; hwnd					handle of the control to update
; hBitmap				a gdi bitmap to associate the static control with
;
; return				If the function succeeds, the return value is nonzero

SetImage(hwnd, hBitmap)
{
    SendMessage, 0x172, 0x0, hBitmap,, ahk_id %hwnd%
    E := ErrorLevel
    DeleteObject(E)
return E
}

;#####################################################################################

; Function				SetSysColorToControl
; Description			Sets a solid colour to a control
;
; hwnd					handle of the control to update
; SysColor				A system colour to set to the control
;
; return				If the function succeeds, the return value is zero
;
; notes					A control must have the 0xE style set to it so it is recognised as a bitmap
;						By default SysColor=15 is used which is COLOR_3DFACE. This is the standard background for a control
;
; COLOR_3DDKSHADOW				= 21
; COLOR_3DFACE					= 15
; COLOR_3DHIGHLIGHT				= 20
; COLOR_3DHILIGHT				= 20
; COLOR_3DLIGHT					= 22
; COLOR_3DSHADOW				= 16
; COLOR_ACTIVEBORDER			= 10
; COLOR_ACTIVECAPTION			= 2
; COLOR_APPWORKSPACE			= 12
; COLOR_BACKGROUND				= 1
; COLOR_BTNFACE					= 15
; COLOR_BTNHIGHLIGHT			= 20
; COLOR_BTNHILIGHT				= 20
; COLOR_BTNSHADOW				= 16
; COLOR_BTNTEXT					= 18
; COLOR_CAPTIONTEXT				= 9
; COLOR_DESKTOP					= 1
; COLOR_GRADIENTACTIVECAPTION	= 27
; COLOR_GRADIENTINACTIVECAPTION	= 28
; COLOR_GRAYTEXT				= 17
; COLOR_HIGHLIGHT				= 13
; COLOR_HIGHLIGHTTEXT			= 14
; COLOR_HOTLIGHT				= 26
; COLOR_INACTIVEBORDER			= 11
; COLOR_INACTIVECAPTION			= 3
; COLOR_INACTIVECAPTIONTEXT		= 19
; COLOR_INFOBK					= 24
; COLOR_INFOTEXT				= 23
; COLOR_MENU					= 4
; COLOR_MENUHILIGHT				= 29
; COLOR_MENUBAR					= 30
; COLOR_MENUTEXT				= 7
; COLOR_SCROLLBAR				= 0
; COLOR_WINDOW					= 5
; COLOR_WINDOWFRAME				= 6
; COLOR_WINDOWTEXT				= 8

SetSysColorToControl(hwnd, SysColor=15)
{
    WinGetPos,,, w, h, ahk_id %hwnd%
    bc := DllCall("GetSysColor", "Int", SysColor)
    pBrushClear := Gdip_BrushCreateSolid(0xff000000 | (bc >> 16 | bc & 0xff00 | (bc & 0xff) << 16))
    pBitmap := Gdip_CreateBitmap(w, h), G := Gdip_GraphicsFromImage(pBitmap)
    Gdip_FillRectangle(G, pBrushClear, 0, 0, w, h)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)
    Gdip_DeleteBrush(pBrushClear)
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
return 0
}

;#####################################################################################

; Function				Gdip_BitmapFromScreen
; Description			Gets a gdi+ bitmap from the screen
;
; Screen				0 = All screens
;						Any numerical value = Just that screen
;						x|y|w|h = Take specific coordinates with a width and height
; Raster				raster operation code
;
; return      			If the function succeeds, the return value is a pointer to a gdi+ bitmap
;						-1:		one or more of x,y,w,h not passed properly
;
; notes					If no raster operation is specified, then SRCCOPY is used to the returned bitmap

Gdip_BitmapFromScreen(Screen=0, Raster="")
{
    if (Screen = 0)
    {
        Sysget, x, 76
        Sysget, y, 77	
        Sysget, w, 78
        Sysget, h, 79
    }
    else if (SubStr(Screen, 1, 5) = "hwnd:")
    {
        Screen := SubStr(Screen, 6)
        if !WinExist( "ahk_id " Screen)
            return -2
        WinGetPos,,, w, h, ahk_id %Screen%
        x := y := 0
        hhdc := GetDCEx(Screen, 3)
    }
    else if (Screen&1 != "")
    {
        Sysget, M, Monitor, %Screen%
        x := MLeft, y := MTop, w := MRight-MLeft, h := MBottom-MTop
    }
    else
    {
        StringSplit, S, Screen, |
        x := S1, y := S2, w := S3, h := S4
    }

    if (x = "") || (y = "") || (w = "") || (h = "")
        return -1

    chdc := CreateCompatibleDC(), hbm := CreateDIBSection(w, h, chdc), obm := SelectObject(chdc, hbm), hhdc := hhdc ? hhdc : GetDC()
    BitBlt(chdc, 0, 0, w, h, hhdc, x, y, Raster)
    ReleaseDC(hhdc)

    pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
    SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
return pBitmap
}

;#####################################################################################

; Function				Gdip_BitmapFromHWND
; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap from it
;
; hwnd					handle to the window to get a bitmap from
;
; return				If the function succeeds, the return value is a pointer to a gdi+ bitmap
;
; notes					Window must not be not minimised in order to get a handle to it's client area

Gdip_BitmapFromHWND(hwnd)
{
    WinGetPos,,, Width, Height, ahk_id %hwnd%
    hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
    PrintWindow(hwnd, hdc)
    pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
    SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
return pBitmap
}

;#####################################################################################

; Function    			CreateRectF
; Description			Creates a RectF object, containing a the coordinates and dimensions of a rectangle
;
; RectF       			Name to call the RectF object
; x            			x-coordinate of the upper left corner of the rectangle
; y            			y-coordinate of the upper left corner of the rectangle
; w            			Width of the rectangle
; h            			Height of the rectangle
;
; return      			No return value

CreateRectF(ByRef RectF, x, y, w, h)
{
    VarSetCapacity(RectF, 16)
    NumPut(x, RectF, 0, "float"), NumPut(y, RectF, 4, "float"), NumPut(w, RectF, 8, "float"), NumPut(h, RectF, 12, "float")
}

;#####################################################################################

; Function    			CreateRect
; Description			Creates a Rect object, containing a the coordinates and dimensions of a rectangle
;
; RectF       			Name to call the RectF object
; x            			x-coordinate of the upper left corner of the rectangle
; y            			y-coordinate of the upper left corner of the rectangle
; w            			Width of the rectangle
; h            			Height of the rectangle
;
; return      			No return value

CreateRect(ByRef Rect, x, y, w, h)
{
    VarSetCapacity(Rect, 16)
    NumPut(x, Rect, 0, "uint"), NumPut(y, Rect, 4, "uint"), NumPut(w, Rect, 8, "uint"), NumPut(h, Rect, 12, "uint")
}
;#####################################################################################

; Function		    	CreateSizeF
; Description			Creates a SizeF object, containing an 2 values
;
; SizeF         		Name to call the SizeF object
; w            			w-value for the SizeF object
; h            			h-value for the SizeF object
;
; return      			No Return value

CreateSizeF(ByRef SizeF, w, h)
{
    VarSetCapacity(SizeF, 8)
    NumPut(w, SizeF, 0, "float"), NumPut(h, SizeF, 4, "float") 
}
;#####################################################################################

; Function		    	CreatePointF
; Description			Creates a SizeF object, containing an 2 values
;
; SizeF         		Name to call the SizeF object
; w            			w-value for the SizeF object
; h            			h-value for the SizeF object
;
; return      			No Return value

CreatePointF(ByRef PointF, x, y)
{
    VarSetCapacity(PointF, 8)
    NumPut(x, PointF, 0, "float"), NumPut(y, PointF, 4, "float") 
}
;#####################################################################################

; Function				CreateDIBSection
; Description			The CreateDIBSection function creates a DIB (Device Independent Bitmap) that applications can write to directly
;
; w						width of the bitmap to create
; h						height of the bitmap to create
; hdc					a handle to the device context to use the palette from
; bpp					bits per pixel (32 = ARGB)
; ppvBits				A pointer to a variable that receives a pointer to the location of the DIB bit values
;
; return				returns a DIB. A gdi bitmap
;
; notes					ppvBits will receive the location of the pixels in the DIB

CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
{
    hdc2 := hdc ? hdc : GetDC()
    VarSetCapacity(bi, 40, 0)
    NumPut(w, bi, 4), NumPut(h, bi, 8), NumPut(40, bi, 0), NumPut(1, bi, 12, "ushort"), NumPut(0, bi, 16), NumPut(bpp, bi, 14, "ushort")
    hbm := DllCall("CreateDIBSection", "uint" , hdc2, "uint" , &bi, "uint" , 0, "uint*", ppvBits, "uint" , 0, "uint" , 0)

    if !hdc
        ReleaseDC(hdc2)
return hbm
}

;#####################################################################################

; Function				PrintWindow
; Description			The PrintWindow function copies a visual window into the specified device context (DC), typically a printer DC
;
; hwnd					A handle to the window that will be copied
; hdc					A handle to the device context
; Flags					Drawing options
;
; return				If the function succeeds, it returns a nonzero value
;
; PW_CLIENTONLY			= 1

PrintWindow(hwnd, hdc, Flags=0)
{
return DllCall("PrintWindow", "uint", hwnd, "uint", hdc, "uint", Flags)
}

;#####################################################################################

; Function				DestroyIcon
; Description			Destroys an icon and frees any memory the icon occupied
;
; hIcon					Handle to the icon to be destroyed. The icon must not be in use
;
; return				If the function succeeds, the return value is nonzero

DestroyIcon(hIcon)
{
return DllCall("DestroyIcon", "uint", hIcon)
}

;#####################################################################################

PaintDesktop(hdc)
{
return DllCall("PaintDesktop", "uint", hdc)
}

;#####################################################################################

CreateCompatibleBitmap(hdc, w, h)
{
return DllCall("gdi32\CreateCompatibleBitmap", "uint", hdc, "int", w, "int", h)
}

;#####################################################################################

; Function				CreateCompatibleDC
; Description			This function creates a memory device context (DC) compatible with the specified device
;
; hdc					Handle to an existing device context					
;
; return				returns the handle to a device context or 0 on failure
;
; notes					If this handle is 0 (by default), the function creates a memory device context compatible with the application's current screen

CreateCompatibleDC(hdc=0)
{
return DllCall("CreateCompatibleDC", "uint", hdc)
}

;#####################################################################################

; Function				SelectObject
; Description			The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type
;
; hdc					Handle to a DC
; hgdiobj				A handle to the object to be selected into the DC
;
; return				If the selected object is not a region and the function succeeds, the return value is a handle to the object being replaced
;
; notes					The specified object must have been created by using one of the following functions
;						Bitmap - CreateBitmap, CreateBitmapIndirect, CreateCompatibleBitmap, CreateDIBitmap, CreateDIBSection (A single bitmap cannot be selected into more than one DC at the same time)
;						Brush - CreateBrushIndirect, CreateDIBPatternBrush, CreateDIBPatternBrushPt, CreateHatchBrush, CreatePatternBrush, CreateSolidBrush
;						Font - CreateFont, CreateFontIndirect
;						Pen - CreatePen, CreatePenIndirect
;						Region - CombineRgn, CreateEllipticRgn, CreateEllipticRgnIndirect, CreatePolygonRgn, CreateRectRgn, CreateRectRgnIndirect
;
; notes					If the selected object is a region and the function succeeds, the return value is one of the following value
;
; SIMPLEREGION			= 2 Region consists of a single rectangle
; COMPLEXREGION			= 3 Region consists of more than one rectangle
; NULLREGION			= 1 Region is empty

SelectObject(hdc, hgdiobj)
{
return DllCall("SelectObject", "uint", hdc, "uint", hgdiobj)
}

;#####################################################################################

; Function				DeleteObject
; Description			This function deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object
;						After the object is deleted, the specified handle is no longer valid
;
; hObject				Handle to a logical pen, brush, font, bitmap, region, or palette to delete
;
; return				Nonzero indicates success. Zero indicates that the specified handle is not valid or that the handle is currently selected into a device context

DeleteObject(hObject)
{
return DllCall("DeleteObject", "uint", hObject)
}

;#####################################################################################

; Function				GetDC
; Description			This function retrieves a handle to a display device context (DC) for the client area of the specified window.
;						The display device context can be used in subsequent graphics display interface (GDI) functions to draw in the client area of the window. 
;
; hwnd					Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen					
;
; return				The handle the device context for the specified window's client area indicates success. NULL indicates failure

GetDC(hwnd=0)
{
return DllCall("GetDC", "uint", hwnd)
}

;#####################################################################################

; DCX_CACHE = 0x2
; DCX_CLIPCHILDREN = 0x8
; DCX_CLIPSIBLINGS = 0x10
; DCX_EXCLUDERGN = 0x40
; DCX_EXCLUDEUPDATE = 0x100
; DCX_INTERSECTRGN = 0x80
; DCX_INTERSECTUPDATE = 0x200
; DCX_LOCKWINDOWUPDATE = 0x400
; DCX_NORECOMPUTE = 0x100000
; DCX_NORESETATTRS = 0x4
; DCX_PARENTCLIP = 0x20
; DCX_VALIDATE = 0x200000
; DCX_WINDOW = 0x1

GetDCEx(hwnd, flags=0, hrgnClip=0)
{
return DllCall("GetDCEx", "uint", hwnd, "uint", hrgnClip, "int", flags)
}

;#####################################################################################

; Function				ReleaseDC
; Description			This function releases a device context (DC), freeing it for use by other applications. The effect of ReleaseDC depends on the type of device context
;
; hdc					Handle to the device context to be released
; hwnd					Handle to the window whose device context is to be released
;
; return				1 = released
;						0 = not released
;
; notes					The application must call the ReleaseDC function for each call to the GetWindowDC function and for each call to the GetDC function that retrieves a common device context
;						An application cannot use the ReleaseDC function to release a device context that was created by calling the CreateDC function; instead, it must use the DeleteDC function. 

ReleaseDC(hdc, hwnd=0)
{
return DllCall("ReleaseDC", "uint", hwnd, "uint", hdc)
}

;#####################################################################################

; Function				DeleteDC
; Description			The DeleteDC function deletes the specified device context (DC)
;
; hdc					A handle to the device context
;
; return				If the function succeeds, the return value is nonzero
;
; notes					An application must not delete a DC whose handle was obtained by calling the GetDC function. Instead, it must call the ReleaseDC function to free the DC

DeleteDC(hdc)
{
return DllCall("DeleteDC", "uint", hdc)
}
;#####################################################################################

; Function				Gdip_LibraryVersion
; Description			Get the current library version
;
; return				the library version
;
; notes					This is useful for non compiled programs to ensure that a person doesn't run an old version when testing your scripts

Gdip_LibraryVersion()
{
return 1.45
}

;#####################################################################################

; Function:    			Gdip_BitmapFromBRA
; Description: 			Gets a pointer to a gdi+ bitmap from a BRA file
;
; BRAFromMemIn			The variable for a BRA file read to memory
; File					The name of the file, or its number that you would like (This depends on alternate parameter)
; Alternate				Changes whether the File parameter is the file name or its number
;
; return      			If the function succeeds, the return value is a pointer to a gdi+ bitmap
;						-1 = The BRA variable is empty
;						-2 = The BRA has an incorrect header
;						-3 = The BRA has information missing
;						-4 = Could not find file inside the BRA

Gdip_BitmapFromBRA(ByRef BRAFromMemIn, File, Alternate=0)
{
    if !BRAFromMemIn
        return -1
    Loop, Parse, BRAFromMemIn, `n
    {
        if (A_Index = 1)
        {
            StringSplit, Header, A_LoopField, |
            if (Header0 != 4 || Header2 != "BRA!")
                return -2
        }
        else if (A_Index = 2)
        {
            StringSplit, Info, A_LoopField, |
            if (Info0 != 3)
                return -3
        }
        else
            break
    }
    if !Alternate
        StringReplace, File, File, \, \\, All
    RegExMatch(BRAFromMemIn, "mi`n)^" (Alternate ? File "\|.+?\|(\d+)\|(\d+)" : "\d+\|" File "\|(\d+)\|(\d+)") "$", FileInfo)
    if !FileInfo
        return -4

    hData := DllCall("GlobalAlloc", "uint", 2, "uint", FileInfo2)
    pData := DllCall("GlobalLock", "uint", hData)
    DllCall("RtlMoveMemory", "uint", pData, "uint", &BRAFromMemIn+Info2+FileInfo1, "uint", FileInfo2)
    DllCall("GlobalUnlock", "uint", hData)
    DllCall("ole32\CreateStreamOnHGlobal", "uint", hData, "int", 1, "uint*", pStream)
    DllCall("gdiplus\GdipCreateBitmapFromStream", "uint", pStream, "uint*", pBitmap)
    DllCall(NumGet(NumGet(1*pStream)+8), "uint", pStream)
return pBitmap
}

;#####################################################################################

; Function				Gdip_DrawRectangle
; Description			This function uses a pen to draw the outline of a rectangle into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rectangle
; y						y-coordinate of the top left of the rectangle
; w						width of the rectanlge
; h						height of the rectangle
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
{
return DllCall("gdiplus\GdipDrawRectangle", "uint", pGraphics, "uint", pPen, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function				Gdip_DrawRoundedRectangle
; Description			This function uses a pen to draw the outline of a rounded rectangle into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rounded rectangle
; y						y-coordinate of the top left of the rounded rectangle
; w						width of the rectanlge
; h						height of the rectangle
; r						radius of the rounded corners
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
{
    Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
    E := Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
    Gdip_ResetClip(pGraphics)
    Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
    Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
    Gdip_DrawEllipse(pGraphics, pPen, x, y, 2*r, 2*r)
    Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y, 2*r, 2*r)
    Gdip_DrawEllipse(pGraphics, pPen, x, y+h-(2*r), 2*r, 2*r)
    Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
    Gdip_ResetClip(pGraphics)
return E
}

;#####################################################################################

; Function				Gdip_DrawEllipse
; Description			This function uses a pen to draw the outline of an ellipse into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rectangle the ellipse will be drawn into
; y						y-coordinate of the top left of the rectangle the ellipse will be drawn into
; w						width of the ellipse
; h						height of the ellipse
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
{
return DllCall("gdiplus\GdipDrawEllipse", "uint", pGraphics, "uint", pPen, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function				Gdip_DrawBezier
; Description			This function uses a pen to draw the outline of a bezier (a weighted curve) into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x1					x-coordinate of the start of the bezier
; y1					y-coordinate of the start of the bezier
; x2					x-coordinate of the first arc of the bezier
; y2					y-coordinate of the first arc of the bezier
; x3					x-coordinate of the second arc of the bezier
; y3					y-coordinate of the second arc of the bezier
; x4					x-coordinate of the end of the bezier
; y4					y-coordinate of the end of the bezier
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
{
return DllCall("gdiplus\GdipDrawBezier", "uint", pgraphics, "uint", pPen
, "float", x1, "float", y1, "float", x2, "float", y2
, "float", x3, "float", y3, "float", x4, "float", y4)
}

;#####################################################################################

; Function				Gdip_DrawArc
; Description			This function uses a pen to draw the outline of an arc into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the start of the arc
; y						y-coordinate of the start of the arc
; w						width of the arc
; h						height of the arc
; StartAngle			specifies the angle between the x-axis and the starting point of the arc
; SweepAngle			specifies the angle between the starting and ending points of the arc
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
return DllCall("gdiplus\GdipDrawArc", "uint", pGraphics, "uint", pPen, "float", x
, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_DrawPie
; Description			This function uses a pen to draw the outline of a pie into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the start of the pie
; y						y-coordinate of the start of the pie
; w						width of the pie
; h						height of the pie
; StartAngle			specifies the angle between the x-axis and the starting point of the pie
; SweepAngle			specifies the angle between the starting and ending points of the pie
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
return DllCall("gdiplus\GdipDrawPie", "uint", pGraphics, "uint", pPen, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_DrawLine
; Description			This function uses a pen to draw a line into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x1					x-coordinate of the start of the line
; y1					y-coordinate of the start of the line
; x2					x-coordinate of the end of the line
; y2					y-coordinate of the end of the line
;
; return				status enumeration. 0 = success		

Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
{
return DllCall("gdiplus\GdipDrawLine", "uint", pGraphics, "uint", pPen
, "float", x1, "float", y1, "float", x2, "float", y2)
}

;#####################################################################################

; Function				Gdip_DrawLines
; Description			This function uses a pen to draw a series of joined lines into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; Points				the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return				status enumeration. 0 = success				

Gdip_DrawLines(pGraphics, pPen, Points)
{
    StringSplit, Points, Points, |
    VarSetCapacity(PointF, 8*Points0) 
    Loop, %Points0%
    {
        StringSplit, Coord, Points%A_Index%, `,
        NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
    }
return DllCall("gdiplus\GdipDrawLines", "uint", pGraphics, "uint", pPen, "uint", &PointF, "int", Points0)
}

;#####################################################################################

; Function				Gdip_FillRectangle
; Description			This function uses a brush to fill a rectangle in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the rectangle
; y						y-coordinate of the top left of the rectangle
; w						width of the rectanlge
; h						height of the rectangle
;
; return				status enumeration. 0 = success

Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
{
return DllCall("gdiplus\GdipFillRectangle", "uint", pGraphics, "int", pBrush
, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function				Gdip_FillRoundedRectangle
; Description			This function uses a brush to fill a rounded rectangle in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the rounded rectangle
; y						y-coordinate of the top left of the rounded rectangle
; w						width of the rectanlge
; h						height of the rectangle
; r						radius of the rounded corners
;
; return				status enumeration. 0 = success

Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
{
    Region := Gdip_GetClipRegion(pGraphics)
    Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
    E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
    Gdip_SetClipRegion(pGraphics, Region, 0)
    Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
    Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
    Gdip_FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
    Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y, 2*r, 2*r)
    Gdip_FillEllipse(pGraphics, pBrush, x, y+h-(2*r), 2*r, 2*r)
    Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
    Gdip_SetClipRegion(pGraphics, Region, 0)
    Gdip_DeleteRegion(Region)
return E
}

;#####################################################################################

; Function				Gdip_FillPolygon
; Description			This function uses a brush to fill a polygon in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Points				the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return				status enumeration. 0 = success
;
; notes					Alternate will fill the polygon as a whole, wheras winding will fill each new "segment"
; Alternate 			= 0
; Winding 				= 1

Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode=0)
{
    StringSplit, Points, Points, |
    VarSetCapacity(PointF, 8*Points0) 
    Loop, %Points0%
    {
        StringSplit, Coord, Points%A_Index%, `,
        NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
    } 
return DllCall("gdiplus\GdipFillPolygon", "uint", pGraphics, "uint", pBrush, "uint", &PointF, "int", Points0, "int", FillMode)
}

;#####################################################################################

; Function				Gdip_FillPie
; Description			This function uses a brush to fill a pie in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the pie
; y						y-coordinate of the top left of the pie
; w						width of the pie
; h						height of the pie
; StartAngle			specifies the angle between the x-axis and the starting point of the pie
; SweepAngle			specifies the angle between the starting and ending points of the pie
;
; return				status enumeration. 0 = success

Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle)
{
return DllCall("gdiplus\GdipFillPie", "uint", pGraphics, "uint", pBrush
, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_FillEllipse
; Description			This function uses a brush to fill an ellipse in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the ellipse
; y						y-coordinate of the top left of the ellipse
; w						width of the ellipse
; h						height of the ellipse
;
; return				status enumeration. 0 = success

Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
{
return DllCall("gdiplus\GdipFillEllipse", "uint", pGraphics, "uint", pBrush, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function				Gdip_FillRegion
; Description			This function uses a brush to fill a region in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Region				Pointer to a Region
;
; return				status enumeration. 0 = success
;
; notes					You can create a region Gdip_CreateRegion() and then add to this

Gdip_FillRegion(pGraphics, pBrush, Region)
{
return DllCall("gdiplus\GdipFillRegion", "uint", pGraphics, "uint", pBrush, "uint", Region)
}

;#####################################################################################

; Function				Gdip_FillPath
; Description			This function uses a brush to fill a path in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Region				Pointer to a Path
;
; return				status enumeration. 0 = success

Gdip_FillPath(pGraphics, pBrush, Path)
{
return DllCall("gdiplus\GdipFillPath", "uint", pGraphics, "uint", pBrush, "uint", Path)
}

;#####################################################################################

; Function				Gdip_DrawImagePointsRect
; Description			This function draws a bitmap into the Graphics of another bitmap and skews it
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBitmap				Pointer to a bitmap to be drawn
; Points				Points passed as x1,y1|x2,y2|x3,y3 (3 points: top left, top right, bottom left) describing the drawing of the bitmap
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source rectangle
; sh					height of source rectangle
; Matrix				a matrix used to alter image attributes when drawing
;
; return				status enumeration. 0 = success
;
; notes					if sx,sy,sw,sh are missed then the entire source bitmap will be used
;						Matrix can be omitted to just draw with no alteration to ARGB
;						Matrix may be passed as a digit from 0 - 1 to change just transparency
;						Matrix can be passed as a matrix with any delimiter

Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx="", sy="", sw="", sh="", Matrix=1)
{
    StringSplit, Points, Points, |
    VarSetCapacity(PointF, 8*Points0) 
    Loop, %Points0%
    {
        StringSplit, Coord, Points%A_Index%, `,
        NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
    }

    if (Matrix&1 = "")
        ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
    else if (Matrix != 1)
        ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")

    if (sx = "" && sy = "" && sw = "" && sh = "")
    {
        sx := 0, sy := 0
        sw := Gdip_GetImageWidth(pBitmap)
        sh := Gdip_GetImageHeight(pBitmap)
    }

    E := DllCall("gdiplus\GdipDrawImagePointsRect", "uint", pGraphics, "uint", pBitmap
    , "uint", &PointF, "int", Points0, "float", sx, "float", sy, "float", sw, "float", sh
    , "int", 2, "uint", ImageAttr, "uint", 0, "uint", 0)
    if ImageAttr
        Gdip_DisposeImageAttributes(ImageAttr)
return E
}

;#####################################################################################

; Function				Gdip_DrawImage
; Description			This function draws a bitmap into the Graphics of another bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBitmap				Pointer to a bitmap to be drawn
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of destination image
; dh					height of destination image
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source image
; sh					height of source image
; Matrix				a matrix used to alter image attributes when drawing
;
; return				status enumeration. 0 = success
;
; notes					if sx,sy,sw,sh are missed then the entire source bitmap will be used
;						Gdip_DrawImage performs faster
;						Matrix can be omitted to just draw with no alteration to ARGB
;						Matrix may be passed as a digit from 0 - 1 to change just transparency
;						Matrix can be passed as a matrix with any delimiter. For example:
;						MatrixBright=
;						(
;						1.5		|0		|0		|0		|0
;						0		|1.5	|0		|0		|0
;						0		|0		|1.5	|0		|0
;						0		|0		|0		|1		|0
;						0.05	|0.05	|0.05	|0		|1
;						)
;
; notes					MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
;						MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
;						MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|0|0|0|0|1

Gdip_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1)
{
    if (Matrix&1 = "")
        ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
    else if (Matrix != 1)
        ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")

    if (sx = "" && sy = "" && sw = "" && sh = "")
    {
        if (dx = "" && dy = "" && dw = "" && dh = "")
        {
            sx := dx := 0, sy := dy := 0
            sw := dw := Gdip_GetImageWidth(pBitmap)
            sh := dh := Gdip_GetImageHeight(pBitmap)
        }
        else
        {
            sx := sy := 0
            sw := Gdip_GetImageWidth(pBitmap)
            sh := Gdip_GetImageHeight(pBitmap)
        }
    }

    E := DllCall("gdiplus\GdipDrawImageRectRect", "uint", pGraphics, "uint", pBitmap
    , "float", dx, "float", dy, "float", dw, "float", dh
    , "float", sx, "float", sy, "float", sw, "float", sh
    , "int", 2, "uint", ImageAttr, "uint", 0, "uint", 0)
    if ImageAttr
        Gdip_DisposeImageAttributes(ImageAttr)
return E
}

;#####################################################################################

; Function				Gdip_SetImageAttributesColorMatrix
; Description			This function creates an image matrix ready for drawing
;
; Matrix				a matrix used to alter image attributes when drawing
;						passed with any delimeter
;
; return				returns an image matrix on sucess or 0 if it fails
;
; notes					MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
;						MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
;						MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|0|0|0|0|1

Gdip_SetImageAttributesColorMatrix(Matrix)
{
    VarSetCapacity(ColourMatrix, 100, 0)
    Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", "", 1), "[^\d-\.]+", "|")
    StringSplit, Matrix, Matrix, |
    Loop, 25
    {
        Matrix := (Matrix%A_Index% != "") ? Matrix%A_Index% : Mod(A_Index-1, 6) ? 0 : 1
        NumPut(Matrix, ColourMatrix, (A_Index-1)*4, "float")
    }
    DllCall("gdiplus\GdipCreateImageAttributes", "uint*", ImageAttr)
    DllCall("gdiplus\GdipSetImageAttributesColorMatrix", "uint", ImageAttr, "int", 1, "int", 1, "uint", &ColourMatrix, "int", 0, "int", 0)
return ImageAttr
}

;#####################################################################################

; Function				Gdip_GraphicsFromImage
; Description			This function gets the graphics for a bitmap used for drawing functions
;
; pBitmap				Pointer to a bitmap to get the pointer to its graphics
;
; return				returns a pointer to the graphics of a bitmap
;
; notes					a bitmap can be drawn into the graphics of another bitmap

Gdip_GraphicsFromImage(pBitmap)
{
    DllCall("gdiplus\GdipGetImageGraphicsContext", "uint", pBitmap, "uint*", pGraphics)
return pGraphics
}

;#####################################################################################

; Function				Gdip_GraphicsFromHDC
; Description			This function gets the graphics from the handle to a device context
;
; hdc					This is the handle to the device context
;
; return				returns a pointer to the graphics of a bitmap
;
; notes					You can draw a bitmap into the graphics of another bitmap

Gdip_GraphicsFromHDC(hdc)
{
    DllCall("gdiplus\GdipCreateFromHDC", "uint", hdc, "uint*", pGraphics)
return pGraphics
}

;#####################################################################################

; Function				Gdip_GetDC
; Description			This function gets the device context of the passed Graphics
;
; hdc					This is the handle to the device context
;
; return				returns the device context for the graphics of a bitmap

Gdip_GetDC(pGraphics)
{
    DllCall("gdiplus\GdipGetDC", "uint", pGraphics, "uint*", hdc)
return hdc
}

;#####################################################################################

; Function				Gdip_ReleaseDC
; Description			This function releases a device context from use for further use
;
; pGraphics				Pointer to the graphics of a bitmap
; hdc					This is the handle to the device context
;
; return				status enumeration. 0 = success

Gdip_ReleaseDC(pGraphics, hdc)
{
return DllCall("gdiplus\GdipReleaseDC", "uint", pGraphics, "uint", hdc)
}

;#####################################################################################

; Function				Gdip_GraphicsClear
; Description			Clears the graphics of a bitmap ready for further drawing
;
; pGraphics				Pointer to the graphics of a bitmap
; ARGB					The colour to clear the graphics to
;
; return				status enumeration. 0 = success
;
; notes					By default this will make the background invisible
;						Using clipping regions you can clear a particular area on the graphics rather than clearing the entire graphics

Gdip_GraphicsClear(pGraphics, ARGB=0x00ffffff)
{
return DllCall("gdiplus\GdipGraphicsClear", "uint", pGraphics, "int", ARGB)
}

;#####################################################################################

; Function				Gdip_BlurBitmap
; Description			Gives a pointer to a blurred bitmap from a pointer to a bitmap
;
; pBitmap				Pointer to a bitmap to be blurred
; Blur					The Amount to blur a bitmap by from 1 (least blur) to 100 (most blur)
;
; return				If the function succeeds, the return value is a pointer to the new blurred bitmap
;						-1 = The blur parameter is outside the range 1-100
;
; notes					This function will not dispose of the original bitmap

Gdip_BlurBitmap(pBitmap, Blur)
{
    if (Blur > 100) || (Blur < 1)
        return -1	

    sWidth := Gdip_GetImageWidth(pBitmap), sHeight := Gdip_GetImageHeight(pBitmap)
    dWidth := sWidth//Blur, dHeight := sHeight//Blur

    pBitmap1 := Gdip_CreateBitmap(dWidth, dHeight)
    G1 := Gdip_GraphicsFromImage(pBitmap1)
    Gdip_SetInterpolationMode(G1, 7)
    Gdip_DrawImage(G1, pBitmap, 0, 0, dWidth, dHeight, 0, 0, sWidth, sHeight)

    Gdip_DeleteGraphics(G1)

    pBitmap2 := Gdip_CreateBitmap(sWidth, sHeight)
    G2 := Gdip_GraphicsFromImage(pBitmap2)
    Gdip_SetInterpolationMode(G2, 7)
    Gdip_DrawImage(G2, pBitmap1, 0, 0, sWidth, sHeight, 0, 0, dWidth, dHeight)

    Gdip_DeleteGraphics(G2)
    Gdip_DisposeImage(pBitmap1)
return pBitmap2
}

;#####################################################################################

; Function:     		Gdip_SaveBitmapToFile
; Description:  		Saves a bitmap to a file in any supported format onto disk
;   
; pBitmap				Pointer to a bitmap
; sOutput      			The name of the file that the bitmap will be saved to. Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
; Quality      			If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
;
; return      			If the function succeeds, the return value is zero, otherwise:
;						-1 = Extension supplied is not a supported file format
;						-2 = Could not get a list of encoders on system
;						-3 = Could not find matching encoder for specified file format
;						-4 = Could not get WideChar name of output file
;						-5 = Could not save file to disk
;
; notes					This function will use the extension supplied from the sOutput parameter to determine the output format

Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality=75)
{
    SplitPath, sOutput,,, Extension
    if Extension not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
        return -1
    Extension := "." Extension

    DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
    VarSetCapacity(ci, nSize)
    DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, "uint", &ci)
    if !(nCount && nSize)
        return -2

    Loop, %nCount%
    {
        Location := NumGet(ci, 76*(A_Index-1)+44)
        if !A_IsUnicode
        {
            nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int", 0, "uint", 0, "uint", 0)
            VarSetCapacity(sString, nSize)
            DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)
            if !InStr(sString, "*" Extension)
                continue
        }
        else
        {
            nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int", 0, "uint", 0, "uint", 0)
            sString := ""
            Loop, %nSize%
                sString .= Chr(NumGet(Location+0, 2*(A_Index-1), "char"))
            if !InStr(sString, "*" Extension)
                continue
        }
        pCodec := &ci+76*(A_Index-1)
        break
    }
    if !pCodec
        return -3

    if (Quality != 75)
    {
        Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
        if Extension in .JPG,.JPEG,.JPE,.JFIF
        {
            DllCall("gdiplus\GdipGetEncoderParameterListSize", "uint", pBitmap, "uint", pCodec, "uint*", nSize)
            VarSetCapacity(EncoderParameters, nSize, 0)
            DllCall("gdiplus\GdipGetEncoderParameterList", "uint", pBitmap, "uint", pCodec, "uint", nSize, "uint", &EncoderParameters)
            Loop, % NumGet(EncoderParameters) ;%
            {
                if (NumGet(EncoderParameters, (28*(A_Index-1))+20) = 1) && (NumGet(EncoderParameters, (28*(A_Index-1))+24) = 6)
                {
                    p := (28*(A_Index-1))+&EncoderParameters
                    NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20)))
                    break
                }
            } 
        }
    }

    if !A_IsUnicode
    {
        nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sOutput, "int", -1, "uint", 0, "int", 0)
        VarSetCapacity(wOutput, nSize*2)
        DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sOutput, "int", -1, "uint", &wOutput, "int", nSize)
        VarSetCapacity(wOutput, -1)
        if !VarSetCapacity(wOutput)
            return -4
        E := DllCall("gdiplus\GdipSaveImageToFile", "uint", pBitmap, "uint", &wOutput, "uint", pCodec, "uint", p ? p : 0)
    }
    else
        E := DllCall("gdiplus\GdipSaveImageToFile", "uint", pBitmap, "uint", &sOutput, "uint", pCodec, "uint", p ? p : 0)
return E ? -5 : 0
}

;#####################################################################################

; Function				Gdip_GetPixel
; Description			Gets the ARGB of a pixel in a bitmap
;
; pBitmap				Pointer to a bitmap
; x						x-coordinate of the pixel
; y						y-coordinate of the pixel
;
; return				Returns the ARGB value of the pixel

Gdip_GetPixel(pBitmap, x, y)
{
    DllCall("gdiplus\GdipBitmapGetPixel", "uint", pBitmap, "int", x, "int", y, "uint*", ARGB)
return ARGB
}

;#####################################################################################

; Function				Gdip_SetPixel
; Description			Sets the ARGB of a pixel in a bitmap
;
; pBitmap				Pointer to a bitmap
; x						x-coordinate of the pixel
; y						y-coordinate of the pixel
;
; return				status enumeration. 0 = success

Gdip_SetPixel(pBitmap, x, y, ARGB)
{
return DllCall("gdiplus\GdipBitmapSetPixel", "uint", pBitmap, "int", x, "int", y, "int", ARGB)
}

;#####################################################################################

; Function				Gdip_GetImageWidth
; Description			Gives the width of a bitmap
;
; pBitmap				Pointer to a bitmap
;
; return				Returns the width in pixels of the supplied bitmap

Gdip_GetImageWidth(pBitmap)
{
    DllCall("gdiplus\GdipGetImageWidth", "uint", pBitmap, "uint*", Width)
return Width
}

;#####################################################################################

; Function				Gdip_GetImageHeight
; Description			Gives the height of a bitmap
;
; pBitmap				Pointer to a bitmap
;
; return				Returns the height in pixels of the supplied bitmap

Gdip_GetImageHeight(pBitmap)
{
    DllCall("gdiplus\GdipGetImageHeight", "uint", pBitmap, "uint*", Height)
return Height
}

;#####################################################################################

; Function				Gdip_GetDimensions
; Description			Gives the width and height of a bitmap
;
; pBitmap				Pointer to a bitmap
; Width					ByRef variable. This variable will be set to the width of the bitmap
; Height				ByRef variable. This variable will be set to the height of the bitmap
;
; return				No return value
;						Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height)
{
    DllCall("gdiplus\GdipGetImageWidth", "uint", pBitmap, "uint*", Width)
    DllCall("gdiplus\GdipGetImageHeight", "uint", pBitmap, "uint*", Height)
}

;#####################################################################################

Gdip_GetDimensions(pBitmap, ByRef Width, ByRef Height)
{
    Gdip_GetImageDimensions(pBitmap, Width, Height)
}

;#####################################################################################

Gdip_GetImagePixelFormat(pBitmap)
{
    DllCall("gdiplus\GdipGetImagePixelFormat", "uint", pBitmap, "uint*", Format)
return Format
}

;#####################################################################################

; Function				Gdip_GetDpiX
; Description			Gives the horizontal dots per inch of the graphics of a bitmap
;
; pBitmap				Pointer to a bitmap
; Width					ByRef variable. This variable will be set to the width of the bitmap
; Height				ByRef variable. This variable will be set to the height of the bitmap
;
; return				No return value
;						Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

Gdip_GetDpiX(pGraphics)
{
    DllCall("gdiplus\GdipGetDpiX", "uint", pGraphics, "float*", dpix)
return Round(dpix)
}

;#####################################################################################

Gdip_GetDpiY(pGraphics)
{
    DllCall("gdiplus\GdipGetDpiY", "uint", pGraphics, "float*", dpiy)
return Round(dpiy)
}

;#####################################################################################

Gdip_GetImageHorizontalResolution(pBitmap)
{
    DllCall("gdiplus\GdipGetImageHorizontalResolution", "uint", pBitmap, "float*", dpix)
return Round(dpix)
}

;#####################################################################################

Gdip_GetImageVerticalResolution(pBitmap)
{
    DllCall("gdiplus\GdipGetImageVerticalResolution", "uint", pBitmap, "float*", dpiy)
return Round(dpiy)
}

;#####################################################################################

Gdip_BitmapSetResolution(pBitmap, dpix, dpiy)
{
return DllCall("gdiplus\GdipBitmapSetResolution", "uint", pBitmap, "float", dpix, "float", dpiy)
}

;#####################################################################################

Gdip_CreateBitmapFromFile(sFile, IconNumber=1, IconSize="")
{
    SplitPath, sFile,,, ext
    if ext in exe,dll
    {
        Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
        VarSetCapacity(buf, 40)
        Loop, Parse, Sizes, |
        {
            DllCall("PrivateExtractIcons", "str", sFile, "int", IconNumber-1, "int", A_LoopField, "int", A_LoopField, "uint*", hIcon, "uint*", 0, "uint", 1, "uint", 0)
            if !hIcon
                continue

            if !DllCall("GetIconInfo", "uint", hIcon, "uint", &buf)
            {
                DestroyIcon(hIcon)
                continue
            }
            hbmColor := NumGet(buf, 16)
            hbmMask := NumGet(buf, 12)

            if !(hbmColor && DllCall("GetObject", "uint", hbmColor, "int", 24, "uint", &buf))
            {
                DestroyIcon(hIcon)
                continue
            }
            break
        }
        if !hIcon
            return -1

        Width := NumGet(buf, 4, "int"), Height := NumGet(buf, 8, "int")
        hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)

        if !DllCall("DrawIconEx", "uint", hdc, "int", 0, "int", 0, "uint", hIcon, "uint", Width, "uint", Height, "uint", 0, "uint", 0, "uint", 3)
        {
            DestroyIcon(hIcon)
            return -2
        }

        VarSetCapacity(dib, 84)
        DllCall("GetObject", "uint", hbm, "int", 84, "uint", &dib)
        Stride := NumGet(dib, 12), Bits := NumGet(dib, 20)

        DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", Stride, "int", 0x26200A, "uint", Bits, "uint*", pBitmapOld)
        pBitmap := Gdip_CreateBitmap(Width, Height), G := Gdip_GraphicsFromImage(pBitmap)
        Gdip_DrawImage(G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
        SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
        Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapOld)
        DestroyIcon(hIcon)
    }
    else
    {
        if !A_IsUnicode
        {
            VarSetCapacity(wFile, 1023)
            DllCall("kernel32\MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sFile, "int", -1, "uint", &wFile, "int", 512)
            DllCall("gdiplus\GdipCreateBitmapFromFile", "uint", &wFile, "uint*", pBitmap)
        }
        else
            DllCall("gdiplus\GdipCreateBitmapFromFile", "uint", &sFile, "uint*", pBitmap)
    }
return pBitmap
}

;#####################################################################################

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0)
{
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "uint", hBitmap, "uint", Palette, "uint*", pBitmap)
return pBitmap
}

;#####################################################################################

Gdip_CreateHBITMAPFromBitmap(pBitmap, Background=0xffffffff)
{
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "uint", pBitmap, "uint*", hbm, "int", Background)
return hbm
}

;#####################################################################################

Gdip_CreateBitmapFromHICON(hIcon)
{
    DllCall("gdiplus\GdipCreateBitmapFromHICON", "uint", hIcon, "uint*", pBitmap)
return pBitmap
}

;#####################################################################################

Gdip_CreateHICONFromBitmap(pBitmap)
{
    DllCall("gdiplus\GdipCreateHICONFromBitmap", "uint", pBitmap, "uint*", hIcon)
return hIcon
}

;#####################################################################################

Gdip_CreateBitmap(Width, Height, Format=0x26200A)
{
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", 0, "int", Format, "uint", 0, "uint*", pBitmap)
Return pBitmap
}

;#####################################################################################

Gdip_CreateBitmapFromClipboard()
{
    if !DllCall("OpenClipboard", "uint", 0)
        return -1
    if !DllCall("IsClipboardFormatAvailable", "uint", 8)
        return -2
    if !hBitmap := DllCall("GetClipboardData", "uint", 2)
        return -3
    if !pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
        return -4
    if !DllCall("CloseClipboard")
        return -5
    DeleteObject(hBitmap)
return pBitmap
}

;#####################################################################################

Gdip_SetBitmapToClipboard(pBitmap)
{
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    DllCall("GetObject", "uint", hBitmap, "int", VarSetCapacity(oi, 84, 0), "uint", &oi)
    hdib := DllCall("GlobalAlloc", "uint", 2, "uint", 40+NumGet(oi, 44))
    pdib := DllCall("GlobalLock", "uint", hdib)
    DllCall("RtlMoveMemory", "uint", pdib, "uint", &oi+24, "uint", 40)
    DllCall("RtlMoveMemory", "Uint", pdib+40, "Uint", NumGet(oi, 20), "uint", NumGet(oi, 44))
    DllCall("GlobalUnlock", "uint", hdib)
    DllCall("DeleteObject", "uint", hBitmap)
    DllCall("OpenClipboard", "uint", 0)
    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "uint", 8, "uint", hdib)
    DllCall("CloseClipboard")
}

;#####################################################################################

Gdip_CloneBitmapArea(pBitmap, x, y, w, h, Format=0x26200A)
{
    DllCall("gdiplus\GdipCloneBitmapArea", "float", x, "float", y, "float", w, "float", h
    , "int", Format, "uint", pBitmap, "uint*", pBitmapDest)
return pBitmapDest
}

;#####################################################################################
; Create resources
;#####################################################################################

Gdip_CreatePen(ARGB, w)
{
    DllCall("gdiplus\GdipCreatePen1", "int", ARGB, "float", w, "int", 2, "uint*", pPen)
return pPen
}

;#####################################################################################

Gdip_CreatePenFromBrush(pBrush, w)
{
    DllCall("gdiplus\GdipCreatePen2", "uint", pBrush, "float", w, "int", 2, "uint*", pPen)
return pPen
}

;#####################################################################################

Gdip_BrushCreateSolid(ARGB=0xff000000)
{
    DllCall("gdiplus\GdipCreateSolidFill", "int", ARGB, "uint*", pBrush)
return pBrush
}

;#####################################################################################

; HatchStyleHorizontal = 0
; HatchStyleVertical = 1
; HatchStyleForwardDiagonal = 2
; HatchStyleBackwardDiagonal = 3
; HatchStyleCross = 4
; HatchStyleDiagonalCross = 5
; HatchStyle05Percent = 6
; HatchStyle10Percent = 7
; HatchStyle20Percent = 8
; HatchStyle25Percent = 9
; HatchStyle30Percent = 10
; HatchStyle40Percent = 11
; HatchStyle50Percent = 12
; HatchStyle60Percent = 13
; HatchStyle70Percent = 14
; HatchStyle75Percent = 15
; HatchStyle80Percent = 16
; HatchStyle90Percent = 17
; HatchStyleLightDownwardDiagonal = 18
; HatchStyleLightUpwardDiagonal = 19
; HatchStyleDarkDownwardDiagonal = 20
; HatchStyleDarkUpwardDiagonal = 21
; HatchStyleWideDownwardDiagonal = 22
; HatchStyleWideUpwardDiagonal = 23
; HatchStyleLightVertical = 24
; HatchStyleLightHorizontal = 25
; HatchStyleNarrowVertical = 26
; HatchStyleNarrowHorizontal = 27
; HatchStyleDarkVertical = 28
; HatchStyleDarkHorizontal = 29
; HatchStyleDashedDownwardDiagonal = 30
; HatchStyleDashedUpwardDiagonal = 31
; HatchStyleDashedHorizontal = 32
; HatchStyleDashedVertical = 33
; HatchStyleSmallConfetti = 34
; HatchStyleLargeConfetti = 35
; HatchStyleZigZag = 36
; HatchStyleWave = 37
; HatchStyleDiagonalBrick = 38
; HatchStyleHorizontalBrick = 39
; HatchStyleWeave = 40
; HatchStylePlaid = 41
; HatchStyleDivot = 42
; HatchStyleDottedGrid = 43
; HatchStyleDottedDiamond = 44
; HatchStyleShingle = 45
; HatchStyleTrellis = 46
; HatchStyleSphere = 47
; HatchStyleSmallGrid = 48
; HatchStyleSmallCheckerBoard = 49
; HatchStyleLargeCheckerBoard = 50
; HatchStyleOutlinedDiamond = 51
; HatchStyleSolidDiamond = 52
; HatchStyleTotal = 53
Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle=0)
{
    DllCall("gdiplus\GdipCreateHatchBrush", "int", HatchStyle, "int", ARGBfront, "int", ARGBback, "uint*", pBrush)
return pBrush
}

;#####################################################################################

Gdip_CreateTextureBrush(pBitmap, WrapMode=1, x=0, y=0, w="", h="")
{
    if !(w && h)
        DllCall("gdiplus\GdipCreateTexture", "uint", pBitmap, "int", WrapMode, "uint*", pBrush)
    else
        DllCall("gdiplus\GdipCreateTexture2", "uint", pBitmap, "int", WrapMode, "float", x, "float", y, "float", w, "float", h, "uint*", pBrush)
return pBrush
}

;#####################################################################################

; WrapModeTile = 0
; WrapModeTileFlipX = 1
; WrapModeTileFlipY = 2
; WrapModeTileFlipXY = 3
; WrapModeClamp = 4
Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode=1)
{
    CreatePointF(PointF1, x1, y1), CreatePointF(PointF2, x2, y2)
    DllCall("gdiplus\GdipCreateLineBrush", "uint", &PointF1, "uint", &PointF2, "int", ARGB1, "int", ARGB2, "int", WrapMode, "uint*", LGpBrush)
return LGpBrush
}

;#####################################################################################

; LinearGradientModeHorizontal = 0
; LinearGradientModeVertical = 1
; LinearGradientModeForwardDiagonal = 2
; LinearGradientModeBackwardDiagonal = 3
Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode=1, WrapMode=1)
{
    CreateRectF(RectF, x, y, w, h)
    DllCall("gdiplus\GdipCreateLineBrushFromRect", "uint", &RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, "uint*", LGpBrush)
return LGpBrush
}

;#####################################################################################

Gdip_CloneBrush(pBrush)
{
    DllCall("gdiplus\GdipCloneBrush", "uint", pBrush, "uint*", pBrushClone)
return pBrushClone
}

;#####################################################################################
; Delete resources
;#####################################################################################

Gdip_DeletePen(pPen)
{
return DllCall("gdiplus\GdipDeletePen", "uint", pPen)
}

;#####################################################################################

Gdip_DeleteBrush(pBrush)
{
return DllCall("gdiplus\GdipDeleteBrush", "uint", pBrush)
}

;#####################################################################################

Gdip_DisposeImage(pBitmap)
{
return DllCall("gdiplus\GdipDisposeImage", "uint", pBitmap)
}

;#####################################################################################

Gdip_DeleteGraphics(pGraphics)
{
return DllCall("gdiplus\GdipDeleteGraphics", "uint", pGraphics)
}

;#####################################################################################

Gdip_DisposeImageAttributes(ImageAttr)
{
return DllCall("gdiplus\GdipDisposeImageAttributes", "uint", ImageAttr)
}

;#####################################################################################

Gdip_DeleteFont(hFont)
{
return DllCall("gdiplus\GdipDeleteFont", "uint", hFont)
}

;#####################################################################################

Gdip_DeleteStringFormat(hFormat)
{
return DllCall("gdiplus\GdipDeleteStringFormat", "uint", hFormat)
}

;#####################################################################################

Gdip_DeleteFontFamily(hFamily)
{
return DllCall("gdiplus\GdipDeleteFontFamily", "uint", hFamily)
}

;#####################################################################################

Gdip_DeleteMatrix(Matrix)
{
return DllCall("gdiplus\GdipDeleteMatrix", "uint", Matrix)
}

;#####################################################################################
; Text functions
;#####################################################################################

Gdip_TextToGraphics(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0)
{
    IWidth := Width, IHeight:= Height

    RegExMatch(Options, "i)X([\-\d\.]+)(p*)", xpos)
    RegExMatch(Options, "i)Y([\-\d\.]+)(p*)", ypos)
    RegExMatch(Options, "i)W([\-\d\.]+)(p*)", Width)
    RegExMatch(Options, "i)H([\-\d\.]+)(p*)", Height)
    RegExMatch(Options, "i)C(?!(entre|enter))([a-f\d]+)", Colour)
    RegExMatch(Options, "i)Top|Up|Bottom|Down|vCentre|vCenter", vPos)
    RegExMatch(Options, "i)NoWrap", NoWrap)
    RegExMatch(Options, "i)R(\d)", Rendering)
    RegExMatch(Options, "i)S(\d+)(p*)", Size)

    if !Gdip_DeleteBrush(Gdip_CloneBrush(Colour2))
        PassBrush := 1, pBrush := Colour2

    if !(IWidth && IHeight) && (xpos2 || ypos2 || Width2 || Height2 || Size2)
        return -1

    Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
    Loop, Parse, Styles, |
    {
        if RegExMatch(Options, "\b" A_loopField)
            Style |= (A_LoopField != "StrikeOut") ? (A_Index-1) : 8
    }

    Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
    Loop, Parse, Alignments, |
    {
        if RegExMatch(Options, "\b" A_loopField)
            Align |= A_Index//2.1 ; 0|0|1|1|2|2
    }

    xpos := (xpos1 != "") ? xpos2 ? IWidth*(xpos1/100) : xpos1 : 0
    ypos := (ypos1 != "") ? ypos2 ? IHeight*(ypos1/100) : ypos1 : 0
    Width := Width1 ? Width2 ? IWidth*(Width1/100) : Width1 : IWidth
    Height := Height1 ? Height2 ? IHeight*(Height1/100) : Height1 : IHeight
    if !PassBrush
        Colour := "0x" (Colour2 ? Colour2 : "ff000000")
    Rendering := ((Rendering1 >= 0) && (Rendering1 <= 5)) ? Rendering1 : 4
    Size := (Size1 > 0) ? Size2 ? IHeight*(Size1/100) : Size1 : 12

    hFamily := Gdip_FontFamilyCreate(Font)
    hFont := Gdip_FontCreate(hFamily, Size, Style)
    FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
    hFormat := Gdip_StringFormatCreate(FormatStyle)
    pBrush := PassBrush ? pBrush : Gdip_BrushCreateSolid(Colour)
    if !(hFamily && hFont && hFormat && pBrush && pGraphics)
        return !pGraphics ? -2 : !hFamily ? -3 : !hFont ? -4 : !hFormat ? -5 : !pBrush ? -6 : 0

    CreateRectF(RC, xpos, ypos, Width, Height)
    Gdip_SetStringFormatAlign(hFormat, Align)
    Gdip_SetTextRenderingHint(pGraphics, Rendering)
    ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)

    if vPos
    {
        StringSplit, ReturnRC, ReturnRC, |

        if (vPos = "vCentre") || (vPos = "vCenter")
            ypos += (Height-ReturnRC4)//2
        else if (vPos = "Top") || (vPos = "Up")
            ypos := 0
        else if (vPos = "Bottom") || (vPos = "Down")
            ypos := Height-ReturnRC4

        CreateRectF(RC, xpos, ypos, Width, ReturnRC4)
        ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
    }

    if !Measure
        E := Gdip_DrawString(pGraphics, Text, hFont, hFormat, pBrush, RC)

    if !PassBrush
        Gdip_DeleteBrush(pBrush)
    Gdip_DeleteStringFormat(hFormat) 
    Gdip_DeleteFont(hFont)
    Gdip_DeleteFontFamily(hFamily)
return E ? E : ReturnRC
}

;#####################################################################################

Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
{
    if !A_IsUnicode
    {
        nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", 0, "int", 0)
        VarSetCapacity(wString, nSize*2)
        DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", &wString, "int", nSize)
        return DllCall("gdiplus\GdipDrawString", "uint", pGraphics
        , "uint", &wString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", pBrush)
    }
    else
    {
        return DllCall("gdiplus\GdipDrawString", "uint", pGraphics
        , "uint", &sString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", pBrush)
    }	
}

;#####################################################################################

Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
{
    VarSetCapacity(RC, 16)
    if !A_IsUnicode
    {
        nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", 0, "int", 0)
        VarSetCapacity(wString, nSize*2) 
        DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", &wString, "int", nSize)
        DllCall("gdiplus\GdipMeasureString", "uint", pGraphics
        , "uint", &wString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", &RC, "uint*", Chars, "uint*", Lines)
    }
    else
    {
        DllCall("gdiplus\GdipMeasureString", "uint", pGraphics
        , "uint", &sString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", &RC, "uint*", Chars, "uint*", Lines)
    }
return &RC ? NumGet(RC, 0, "float") "|" NumGet(RC, 4, "float") "|" NumGet(RC, 8, "float") "|" NumGet(RC, 12, "float") "|" Chars "|" Lines : 0
}

; Near = 0
; Center = 1
; Far = 2
Gdip_SetStringFormatAlign(hFormat, Align)
{
return DllCall("gdiplus\GdipSetStringFormatAlign", "uint", hFormat, "int", Align)
}

; StringFormatFlagsDirectionRightToLeft    = 0x00000001
; StringFormatFlagsDirectionVertical       = 0x00000002
; StringFormatFlagsNoFitBlackBox           = 0x00000004
; StringFormatFlagsDisplayFormatControl    = 0x00000020
; StringFormatFlagsNoFontFallback          = 0x00000400
; StringFormatFlagsMeasureTrailingSpaces   = 0x00000800
; StringFormatFlagsNoWrap                  = 0x00001000
; StringFormatFlagsLineLimit               = 0x00002000
; StringFormatFlagsNoClip                  = 0x00004000 
Gdip_StringFormatCreate(Format=0, Lang=0)
{
    DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", Lang, "uint*", hFormat)
return hFormat
}

; Regular = 0
; Bold = 1
; Italic = 2
; BoldItalic = 3
; Underline = 4
; Strikeout = 8
Gdip_FontCreate(hFamily, Size, Style=0)
{
    DllCall("gdiplus\GdipCreateFont", "uint", hFamily, "float", Size, "int", Style, "int", 0, "uint*", hFont)
return hFont
}

Gdip_FontFamilyCreate(Font)
{
    if !A_IsUnicode
    {
        nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &Font, "int", -1, "uint", 0, "int", 0)
        VarSetCapacity(wFont, nSize*2)
        DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &Font, "int", -1, "uint", &wFont, "int", nSize)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "uint", &wFont, "uint", 0, "uint*", hFamily)
    }
    else
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "uint", &Font, "uint", 0, "uint*", hFamily)
return hFamily
}

;#####################################################################################
; Matrix functions
;#####################################################################################

Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y)
{
    DllCall("gdiplus\GdipCreateMatrix2", "float", m11, "float", m12, "float", m21, "float", m22, "float", x, "float", y, "uint*", Matrix)
return Matrix
}

Gdip_CreateMatrix()
{
    DllCall("gdiplus\GdipCreateMatrix", "uint*", Matrix)
return Matrix
}

;#####################################################################################
; GraphicsPath functions
;#####################################################################################

; Alternate = 0
; Winding = 1
Gdip_CreatePath(BrushMode=0)
{
    DllCall("gdiplus\GdipCreatePath", "int", BrushMode, "uint*", Path)
return Path
}

Gdip_AddPathEllipse(Path, x, y, w, h)
{
return DllCall("gdiplus\GdipAddPathEllipse", "uint", Path, "float", x, "float", y, "float", w, "float", h)
}

Gdip_AddPathPolygon(Path, Points)
{
    StringSplit, Points, Points, |
    VarSetCapacity(PointF, 8*Points0) 
    Loop, %Points0%
    {
        StringSplit, Coord, Points%A_Index%, `,
        NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
    } 

return DllCall("gdiplus\GdipAddPathPolygon", "uint", Path, "uint", &PointF, "int", Points0)
}

Gdip_DeletePath(Path)
{
return DllCall("gdiplus\GdipDeletePath", "uint", Path)
}

;#####################################################################################
; Quality functions
;#####################################################################################

; SystemDefault = 0
; SingleBitPerPixelGridFit = 1
; SingleBitPerPixel = 2
; AntiAliasGridFit = 3
; AntiAlias = 4
Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
{
return DllCall("gdiplus\GdipSetTextRenderingHint", "uint", pGraphics, "int", RenderingHint)
}

; Default = 0
; LowQuality = 1
; HighQuality = 2
; Bilinear = 3
; Bicubic = 4
; NearestNeighbor = 5
; HighQualityBilinear = 6
; HighQualityBicubic = 7
Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
{
return DllCall("gdiplus\GdipSetInterpolationMode", "uint", pGraphics, "int", InterpolationMode)
}

; Default = 0
; HighSpeed = 1
; HighQuality = 2
; None = 3
; AntiAlias = 4
Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
{
return DllCall("gdiplus\GdipSetSmoothingMode", "uint", pGraphics, "int", SmoothingMode)
}

; CompositingModeSourceOver = 0 (blended)
; CompositingModeSourceCopy = 1 (overwrite)
Gdip_SetCompositingMode(pGraphics, CompositingMode=0)
{
return DllCall("gdiplus\GdipSetCompositingMode", "uint", pGraphics, "int", CompositingMode)
}

;#####################################################################################
; Extra functions
;#####################################################################################

Gdip_Startup()
{
    if !DllCall("GetModuleHandle", "str", "gdiplus")
        DllCall("LoadLibrary", "str", "gdiplus")
    VarSetCapacity(si, 16, 0), si := Chr(1)
    DllCall("gdiplus\GdiplusStartup", "uint*", pToken, "uint", &si, "uint", 0)
return pToken
}

Gdip_Shutdown(pToken)
{
    DllCall("gdiplus\GdiplusShutdown", "uint", pToken)
    if hModule := DllCall("GetModuleHandle", "str", "gdiplus")
        DllCall("FreeLibrary", "uint", hModule)
return 0
}

; Prepend = 0; The new operation is applied before the old operation.
; Append = 1; The new operation is applied after the old operation.
Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder=0)
{
return DllCall("gdiplus\GdipRotateWorldTransform", "uint", pGraphics, "float", Angle, "int", MatrixOrder)
}

Gdip_ScaleWorldTransform(pGraphics, x, y, MatrixOrder=0)
{
return DllCall("gdiplus\GdipScaleWorldTransform", "uint", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}

Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder=0)
{
return DllCall("gdiplus\GdipTranslateWorldTransform", "uint", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}

Gdip_ResetWorldTransform(pGraphics)
{
return DllCall("gdiplus\GdipResetWorldTransform", "uint", pGraphics)
}

Gdip_GetRotatedTranslation(Width, Height, Angle, ByRef xTranslation, ByRef yTranslation)
{
    pi := 3.14159, TAngle := Angle*(pi/180)	

    Bound := (Angle >= 0) ? Mod(Angle, 360) : 360-Mod(-Angle, -360)
    if ((Bound >= 0) && (Bound <= 90))
        xTranslation := Height*Sin(TAngle), yTranslation := 0
    else if ((Bound > 90) && (Bound <= 180))
        xTranslation := (Height*Sin(TAngle))-(Width*Cos(TAngle)), yTranslation := -Height*Cos(TAngle)
    else if ((Bound > 180) && (Bound <= 270))
        xTranslation := -(Width*Cos(TAngle)), yTranslation := -(Height*Cos(TAngle))-(Width*Sin(TAngle))
    else if ((Bound > 270) && (Bound <= 360))
        xTranslation := 0, yTranslation := -Width*Sin(TAngle)
}

Gdip_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
{
    pi := 3.14159, TAngle := Angle*(pi/180)
    if !(Width && Height)
        return -1
    RWidth := Ceil(Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle)))
    RHeight := Ceil(Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle)))
}

; RotateNoneFlipNone   = 0
; Rotate90FlipNone     = 1
; Rotate180FlipNone    = 2
; Rotate270FlipNone    = 3
; RotateNoneFlipX      = 4
; Rotate90FlipX        = 5
; Rotate180FlipX       = 6
; Rotate270FlipX       = 7
; RotateNoneFlipY      = Rotate180FlipX
; Rotate90FlipY        = Rotate270FlipX
; Rotate180FlipY       = RotateNoneFlipX
; Rotate270FlipY       = Rotate90FlipX
; RotateNoneFlipXY     = Rotate180FlipNone
; Rotate90FlipXY       = Rotate270FlipNone
; Rotate180FlipXY      = RotateNoneFlipNone
; Rotate270FlipXY      = Rotate90FlipNone 

Gdip_ImageRotateFlip(pBitmap, RotateFlipType=1)
{
return DllCall("gdiplus\GdipImageRotateFlip", "uint", pBitmap, "int", RotateFlipType)
}

; Replace = 0
; Intersect = 1
; Union = 2
; Xor = 3
; Exclude = 4
; Complement = 5
Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode=0)
{
return DllCall("gdiplus\GdipSetClipRect", "uint", pGraphics, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)
}

Gdip_SetClipPath(pGraphics, Path, CombineMode=0)
{
return DllCall("gdiplus\GdipSetClipPath", "uint", pGraphics, "uint", Path, "int", CombineMode)
}

Gdip_ResetClip(pGraphics)
{
return DllCall("gdiplus\GdipResetClip", "uint", pGraphics)
}

Gdip_GetClipRegion(pGraphics)
{
    Region := Gdip_CreateRegion()
    DllCall("gdiplus\GdipGetClip", "uint" pGraphics, "uint*", Region)
return Region
}

Gdip_SetClipRegion(pGraphics, Region, CombineMode=0)
{
return DllCall("gdiplus\GdipSetClipRegion", "uint", pGraphics, "uint", Region, "int", CombineMode)
}

Gdip_CreateRegion()
{
    DllCall("gdiplus\GdipCreateRegion", "uint*", Region)
return Region
}

Gdip_DeleteRegion(Region)
{
return DllCall("gdiplus\GdipDeleteRegion", "uint", Region)
}

;#####################################################################################
; BitmapLockBits
;#####################################################################################

Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode = 3, PixelFormat = 0x26200a)
{ 
    CreateRect(Rect, x, y, w, h)
    VarSetCapacity(BitmapData, 21, 0)
    E := DllCall("Gdiplus\GdipBitmapLockBits", "uint", pBitmap, "uint", &Rect, "uint", LockMode, "int", PixelFormat, "uint", &BitmapData)
    Stride := NumGet(BitmapData, 8)
    Scan0 := NumGet(BitmapData, 16)
return E
}

;#####################################################################################

Gdip_UnlockBits(pBitmap, ByRef BitmapData)
{
return DllCall("Gdiplus\GdipBitmapUnlockBits", "uint", pBitmap, "uint", &BitmapData)
}

;#####################################################################################

Gdip_SetLockBitPixel(ARGB, Scan0, x, y, Stride)
{
    Numput(ARGB, Scan0+0, (x*4)+(y*Stride))
}

;#####################################################################################

Gdip_GetLockBitPixel(Scan0, x, y, Stride)
{
return NumGet(Scan0+0, (x*4)+(y*Stride))
}

;#####################################################################################

Gdip_PixelateBitmap(pBitmap, ByRef pBitmapOut, BlockSize)
{
    static PixelateBitmap
    if !PixelateBitmap
    {
        MCode_PixelateBitmap := "83EC388B4424485355568B74245C99F7FE8B5C244C8B6C2448578BF88BCA894C241C897C243485FF0F8E2E0300008B44245"
        . "499F7FE897C24448944242833C089542418894424308944242CEB038D490033FF397C2428897C24380F8E750100008BCE0FAFCE894C24408DA4240000"
        . "000033C03BF08944241089442460894424580F8E8A0000008B5C242C8D4D028BD52BD183C203895424208D3CBB0FAFFE8BD52BD142895424248BD52BD"
        . "103F9897C24148974243C8BCF8BFE8DA424000000008B5C24200FB61C0B03C30FB619015C24588B5C24240FB61C0B015C24600FB61C11015C241083C1"
        . "0483EF0175D38B7C2414037C245C836C243C01897C241475B58B7C24388B6C244C8B5C24508B4C244099F7F9894424148B44245899F7F9894424588B4"
        . "4246099F7F9894424608B44241099F7F98944241085F60F8E820000008D4B028BC32BC18D68038B44242C8D04B80FAFC68BD32BD142895424248BD32B"
        . "D103C18944243C89742420EB038D49008BC88BFE0FB64424148B5C24248804290FB644245888010FB644246088040B0FB644241088040A83C10483EF0"
        . "175D58B44243C0344245C836C2420018944243C75BE8B4C24408B5C24508B6C244C8B7C2438473B7C2428897C24380F8C9FFEFFFF8B4C241C33D23954"
        . "24180F846401000033C03BF2895424108954246089542458895424148944243C0F8E82000000EB0233D2395424187E6F8B4C243003C80FAF4C245C8B4"
        . "424280FAFC68D550203CA8D0C818BC52BC283C003894424208BC52BC2408BFD2BFA8B54241889442424895424408B4424200FB614080FB60101542414"
        . "8B542424014424580FB6040A0FB61439014424600154241083C104836C24400175CF8B44243C403BC68944243C7C808B4C24188B4424140FAFCE99F7F"
        . "9894424148B44245899F7F9894424588B44246099F7F9894424608B44241099F7F98944241033C08944243C85F60F8E7F000000837C2418007E6F8B4C"
        . "243003C80FAF4C245C8B4424280FAFC68D530203CA8D0C818BC32BC283C003894424208BC32BC2408BFB2BFA8B54241889442424895424400FB644241"
        . "48B5424208804110FB64424580FB654246088018B4424248814010FB654241088143983C104836C24400175CF8B44243C403BC68944243C7C818B4C24"
        . "1C8B44245C0144242C01742430836C2444010F85F4FCFFFF8B44245499F7FE895424188944242885C00F8E890100008BF90FAFFE33D2897C243C89542"
        . "45489442438EB0233D233C03BCA89542410895424608954245889542414894424400F8E840000003BF27E738B4C24340FAFCE03C80FAF4C245C034C24"
        . "548D55028BC52BC283C003894424208BC52BC2408BFD03CA894424242BFA89742444908B5424200FB6040A0FB611014424148B442424015424580FB61"
        . "4080FB6040F015424600144241083C104836C24440175CF8B4424408B7C243C8B4C241C33D2403BC1894424400F8C7CFFFFFF8B44241499F7FF894424"
        . "148B44245899F7FF894424588B44246099F7FF894424608B44241099F7FF8944241033C08944244085C90F8E8000000085F67E738B4C24340FAFCE03C"
        . "80FAF4C245C034C24548D53028BC32BC283C003894424208BC32BC2408BFB03CA894424242BFA897424448D49000FB65424148B4424208814010FB654"
        . "24580FB644246088118B5424248804110FB644241088043983C104836C24440175CF8B4424408B7C243C8B4C241C403BC1894424407C808D04B500000"
        . "00001442454836C2438010F858CFEFFFF33D233C03BCA89542410895424608954245889542414894424440F8E9A000000EB048BFF33D2395424180F8E"
        . "7D0000008B4C24340FAFCE03C80FAF4C245C8B4424280FAFC68D550203CA8D0C818BC52BC283C003894424208BC52BC240894424248BC52BC28B54241"
        . "8895424548DA424000000008B5424200FB6140A015424140FB611015424588B5424240FB6140A015424600FB614010154241083C104836C24540175CF"
        . "8B4424448B4C241C403BC1894424440F8C6AFFFFFF0FAF4C24188B44241499F7F9894424148B44245899F7F9894424588B44246099F7F9894424608B4"
        . "4241099F7F98944241033C03944241C894424540F8E7B0000008B7C241885FF7E688B4C24340FAFCE03C80FAF4C245C8B4424280FAFC68D530203CA8D"
        . "0C818BC32BC283C003894424208BC32BC2408BEB894424242BEA0FB65424148B4424208814010FB65424580FB644246088118B5424248804110FB6442"
        . "41088042983C10483EF0175D18B442454403B44241C894424547C855F5E5D33C05B83C438C3"
        VarSetCapacity(PixelateBitmap, StrLen(MCode_PixelateBitmap)//2)
        Loop % StrLen(MCode_PixelateBitmap)//2		;%
        NumPut("0x" SubStr(MCode_PixelateBitmap, (2*A_Index)-1, 2), PixelateBitmap, A_Index-1, "char")
    }

    Gdip_GetImageDimensions(pBitmap, Width, Height)
    if (Width != Gdip_GetImageWidth(pBitmapOut) || Height != Gdip_GetImageHeight(pBitmapOut))
        return -1
    if (BlockSize > Width || BlockSize > Height)
        return -2

    E1 := Gdip_LockBits(pBitmap, 0, 0, Width, Height, Stride1, Scan01, BitmapData1)
    E2 := Gdip_LockBits(pBitmapOut, 0, 0, Width, Height, Stride2, Scan02, BitmapData2)
    if (E1 || E2)
        return -3

    E := DllCall(&PixelateBitmap, "uint", Scan01, "uint", Scan02, "int", Width, "int", Height, "int", Stride1, "int", BlockSize)
    Gdip_UnlockBits(pBitmap, BitmapData1), Gdip_UnlockBits(pBitmapOut, BitmapData2)
return 0
}

;#####################################################################################

Gdip_ToARGB(A, R, G, B)
{
return (A << 24) | (R << 16) | (G << 8) | B
}

;#####################################################################################

Gdip_FromARGB(ARGB, ByRef A, ByRef R, ByRef G, ByRef B)
{
    A := (0xff000000 & ARGB) >> 24
    R := (0x00ff0000 & ARGB) >> 16
    G := (0x0000ff00 & ARGB) >> 8
    B := 0x000000ff & ARGB
}

;#####################################################################################

Gdip_AFromARGB(ARGB)
{
return (0xff000000 & ARGB) >> 24
}

;#####################################################################################

Gdip_RFromARGB(ARGB)
{
return (0x00ff0000 & ARGB) >> 16
}

;#####################################################################################

Gdip_GFromARGB(ARGB)
{
return (0x0000ff00 & ARGB) >> 8
}

;#####################################################################################

Gdip_BFromARGB(ARGB)
{
return 0x000000ff & ARGB
}
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
Class HButton	{
    ;Gen 3 Button Class By Hellbent
    static init , Button := [] , Active , LastControl , HoldCtrl 

    __New( Input := "" , All := "" , Default := "" , Hover := "" , Pressed := "" ){

        local hwnd 

        ;If this is the first time the class is being used.
        if( !HButton.init && HButton.init := 1 )

        ;Set a timer to watch to see if the cursor goes over one of the controls.
        HButton._SetHoverTimer()

        This._CreateNewButtonObject( hwnd := This._CreateControl( Input ) , Input )

        This._BindButton( hwnd , Input )

        This._GetButtonBitmaps( hwnd , Input , All , Default , Hover , Pressed )

        This._DisplayButton( hwnd , HButton.Button[hwnd].Bitmaps.Default.hBitmap )

        return hwnd
    }

    _DisplayButton( hwnd , hBitmap){

        SetImage( hwnd , hBitmap )

    }

    _GetButtonBitmaps( hwnd , Input := "" , All := "" , Default := "" , Hover := "" , Pressed := "" ){

        HButton.Button[hwnd].Bitmaps := GuiButtonType1.CreateButtonBitmapSet( Input , All , Default , Hover , Pressed )

    }

    _CreateNewButtonObject( hwnd , Input ){

        local k , v 

        HButton.Button[ hwnd ] := {}

        for k , v in Input

        HButton.Button[ hwnd ][ k ] := v

        HButton.Button[ hwnd ].Hwnd := hwnd

    }

    _CreateControl( Input ){

        local hwnd

        Gui , % Input.Owner ":Add" , Pic , % "x" Input.X " y" Input.Y " w" Input.W " h" Input.H " hwndhwnd 0xE" 

        return hwnd

    }

    _BindButton( hwnd , Input ){

        local bd

        bd := This._OnClick.Bind( This )

        GuiControl, % Input.Owner ":+G" , % hwnd , % bd

    }

    _SetHoverTimer( timer := "" ){

        local HoverTimer 

        if( !HButton.HoverTimer ) 

        HButton.HoverTimer := ObjBindMethod( HButton , "_OnHover" ) 

        HoverTimer := HButton.HoverTimer

        SetTimer , % HoverTimer , % ( Timer ) ? ( Timer ) : ( 100 )

    }

    _OnHover(){

        local Ctrl

        MouseGetPos,,,,ctrl,2

        if( HButton.Button[ ctrl ] && !HButton.Active ){

            HButton.Active := 1

            HButton.LastControl := ctrl

            HButton._DisplayButton( ctrl , HButton.Button[ ctrl ].Bitmaps.Hover.hBitmap )

        }else if( HButton.Active && ctrl != HButton.LastControl ){

            HButton.Active := 0

            HButton._DisplayButton( HButton.LastControl , HButton.Button[ HButton.LastControl ].Bitmaps.Default.hBitmap )

        }

    }

    _OnClick(){

        local Ctrl, last

        HButton._SetHoverTimer( "Off" )

        MouseGetPos,,,, Ctrl , 2
        last := ctrl
        HButton._SetFocus( ctrl )
        HButton._DisplayButton( last , HButton.Button[ last ].Bitmaps.Pressed.hBitmap )

        While(GetKeyState("LButton"))
            sleep, 60

        HButton._SetHoverTimer()

        loop, 2
            This._OnHover()

        MouseGetPos,,,, Ctrl , 2

        if(ctrl!=last){

            HButton._DisplayButton( last , HButton.Button[ last ].Bitmaps.Default.hBitmap )

        }else{
            HButton._DisplayButton( last , HButton.Button[ last ].Bitmaps.Hover.hBitmap )
            if( HButton.Button[ last ].Label ){

                if(IsFunc( HButton.Button[ last ].Label ) )

                fn := Func( HButton.Button[ last ].Label )
                , fn.Call()

                else 

                gosub, % HButton.Button[ last ].Label
            }

        }

    }

    _SetFocus( ctrl ){

        GuiControl, % HButton.Button[ ctrl ].Owner ":Focus" , % ctrl

    }

    DeleteButton( hwnd ){

        for k , v in HButton.Button[ hwnd ].Bitmaps
            Gdip_DisposeImage( HButton.Button[hwnd].Bitmaps[k].pBitmap )
        , DeleteObject( HButton.Button[ hwnd ].Bitmaps[k].hBitmap )

        GuiControl , % HButton.Button[ hwnd ].Owner ":Move", % hwnd , % "x-1 y-1 w0 h0" 
        HButton.Button[ hwnd ] := ""
    }

}
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
Class GuiButtonType1	{

    static List := [ "Default" , "Hover" , "Pressed" ]

    _CreatePressedBitmap(){

        local arr := [] , Bitmap := {} , fObj := This.CurrentBitmapData.Pressed

        Bitmap.pBitmap := Gdip_CreateBitmap( fObj.W , fObj.H ) , G := Gdip_GraphicsFromImage( Bitmap.pBitmap ) , Gdip_SetSmoothingMode( G , 2 )

        Brush := Gdip_BrushCreateSolid( fObj.BackgroundColor ) , Gdip_FillRectangle( G , Brush , -1 , -1 , fObj.W+2 , fObj.H+2 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_BrushCreateSolid( fObj.ButtonOuterBorderColor ) , Gdip_FillRoundedRectangle( G , Brush , 3 , 4 , fObj.W-7 , fObj.H-7 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , fObj.W , fObj.H , fObj.ButtonInnerBorderColor1 , fObj.ButtonInnerBorderColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 2 , 3 , fObj.W-5 , fObj.H-8 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , fObj.W-7 , fObj.H-10 , fObj.ButtonMainColor1 , fObj.ButtonMainColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 5 , 5 , fObj.W-11 , fObj.H-12 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextBottomColor1 , fObj.TextBottomColor2 , 1 , 1 )

        arr := [ { X: -1 , Y: -1 } , { X: 0 , Y: -1 } , { X: 1 , Y: -1 } , { X: -1 , Y: 0 } , { X: 1 , Y: 0 } , { X: -1 , Y: 1 } , { X: 0 , Y: 1 } , { X: 1 , Y: 1 } ]

        Loop, % 8

        Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 1 + arr[A_Index].X + fObj.TextOffsetX " y" 3 + arr[A_Index].Y + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )

        Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextTopColor1 , fObj.TextTopColor2 , 1 , 1 )

        Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 1 + fObj.TextOffsetX " y" 3 + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )

        if( fObj.ButtonAddGlossy ){

            Brush := Gdip_BrushCreateSolid( fObj.GlossTopColor ) , Gdip_FillRectangle( G , Brush , 5 , 10 , fObj.W-11 , ( fObj.H / 2 ) - 10 ) , Gdip_DeleteBrush( Brush )

            Brush := Gdip_BrushCreateSolid( fObj.GlossTopAccentColor ) , Gdip_FillRectangle( G , Brush , 10 , 12 , fObj.W-21 , fObj.H / 15 ) , Gdip_DeleteBrush( Brush )

            Brush := Gdip_BrushCreateSolid( fObj.GlossBottomColor ) , Gdip_FillRectangle( G , Brush , 5 , 10 + ( fObj.H / 2 ) - 10 , fObj.W-11 , ( fObj.H / 2 ) - 7 ) , Gdip_DeleteBrush( Brush )

        }

        Gdip_DeleteGraphics( G )

        Bitmap.hBitmap := Gdip_CreateHBITMAPFromBitmap( Bitmap.pBitmap )

        return Bitmap
    }

    _CreateHoverBitmap(){

        local arr := [] , Bitmap := {} , fObj := This.CurrentBitmapData.Hover

        Bitmap.pBitmap := Gdip_CreateBitmap( fObj.W , fObj.H ) , G := Gdip_GraphicsFromImage( Bitmap.pBitmap ) , Gdip_SetSmoothingMode( G , 2 )

        Brush := Gdip_BrushCreateSolid( fObj.BackgroundColor ) , Gdip_FillRectangle( G , Brush , -1 , -1 , fObj.W+2 , fObj.H+2 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_BrushCreateSolid( fObj.ButtonOuterBorderColor ) , Gdip_FillRoundedRectangle( G , Brush , 2 , 3 , fObj.W-5 , fObj.H-7 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_BrushCreateSolid( fObj.ButtonCenterBorderColor ) , Gdip_FillRoundedRectangle( G , Brush , 3 , 4 , fObj.W-7 , fObj.H-9 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , fObj.W , fObj.H-10 , fObj.ButtonInnerBorderColor1 , fObj.ButtonInnerBorderColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 4 , 5 , fObj.W-9 , fObj.H-11 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_CreateLineBrushFromRect( 5 , 7 , fObj.W-11 , fObj.H-14 , fObj.ButtonMainColor1 , fObj.ButtonMainColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 5 , 7 , fObj.W-11 , fObj.H-14 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextBottomColor1 , fObj.TextBottomColor2 , 1 , 1 )

        arr := [ { X: -1 , Y: -1 } , { X: 0 , Y: -1 } , { X: 1 , Y: -1 } , { X: -1 , Y: 0 } , { X: 1 , Y: 0 } , { X: -1 , Y: 1 } , { X: 0 , Y: 1 } , { X: 1 , Y: 1 } ]

        Loop, % 8

        Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 0 + arr[A_Index].X + fObj.TextOffsetX " y" 2 + arr[A_Index].Y + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )

        Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextTopColor1 , fObj.TextTopColor2 , 1 , 1 )

        Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 0 + fObj.TextOffsetX " y" 2 + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )

        if( fObj.ButtonAddGlossy = 1 ){

            Brush := Gdip_BrushCreateSolid( fObj.GlossTopColor ) , Gdip_FillRectangle( G , Brush , 6 , 10 , fObj.W-13 , ( fObj.H / 2 ) - 10 ) , Gdip_DeleteBrush( Brush )

            Brush := Gdip_BrushCreateSolid( fObj.GlossTopAccentColor ) , Gdip_FillRectangle( G , Brush , 10 , 12 , fObj.W-21 , fObj.H / 15 ) , Gdip_DeleteBrush( Brush )

            Brush := Gdip_BrushCreateSolid( fObj.GlossBottomColor ) , Gdip_FillRectangle( G , Brush , 6 , 10 + ( fObj.H / 2 ) - 10 , fObj.W-13 , ( fObj.H / 2 ) - 7 ) , Gdip_DeleteBrush( Brush )

        }

        Gdip_DeleteGraphics( G )

        Bitmap.hBitmap := Gdip_CreateHBITMAPFromBitmap( Bitmap.pBitmap )

        return Bitmap

    }

    _CreateDefaultBitmap(){

        local arr := [] , Bitmap := {} , fObj := This.CurrentBitmapData.Default

        Bitmap.pBitmap := Gdip_CreateBitmap( fObj.W , fObj.H ) , G := Gdip_GraphicsFromImage( Bitmap.pBitmap ) , Gdip_SetSmoothingMode( G , 2 )

        Brush := Gdip_BrushCreateSolid( fObj.BackgroundColor ) , Gdip_FillRectangle( G , Brush , -1 , -1 , fObj.W+2 , fObj.H+2 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_BrushCreateSolid( fObj.ButtonOuterBorderColor ) , Gdip_FillRoundedRectangle( G , Brush , 2 , 3 , fObj.W-5 , fObj.H-7 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_BrushCreateSolid( fObj.ButtonCenterBorderColor ) , Gdip_FillRoundedRectangle( G , Brush , 3 , 4 , fObj.W-7 , fObj.H-9 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , fObj.W , fObj.H-10 , fObj.ButtonInnerBorderColor1 , fObj.ButtonInnerBorderColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 4 , 5 , fObj.W-9 , fObj.H-11 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_CreateLineBrushFromRect( 5 , 7 , fObj.W-11 , fObj.H-14 , fObj.ButtonMainColor1 , fObj.ButtonMainColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 5 , 7 , fObj.W-11 , fObj.H-14 , 5 ) , Gdip_DeleteBrush( Brush )

        Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextBottomColor1 , fObj.TextBottomColor2 , 1 , 1 )

        arr := [ { X: -1 , Y: -1 } , { X: 0 , Y: -1 } , { X: 1 , Y: -1 } , { X: -1 , Y: 0 } , { X: 1 , Y: 0 } , { X: -1 , Y: 1 } , { X: 0 , Y: 1 } , { X: 1 , Y: 1 } ]

        Loop, % 8

        Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 0 + arr[A_Index].X + fObj.TextOffsetX " y" 2 + arr[A_Index].Y + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )

        Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextTopColor1 , fObj.TextTopColor2 , 1 , 1 )

        Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 0 + fObj.TextOffsetX " y" 2 + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )

        if( fObj.ButtonAddGlossy ){

            Brush := Gdip_BrushCreateSolid( fObj.GlossTopColor ) , Gdip_FillRectangle( G , Brush , 6 , 10 , fObj.W-13 , ( fObj.H / 2 ) - 10 ) , Gdip_DeleteBrush( Brush )

            Brush := Gdip_BrushCreateSolid( fObj.GlossTopAccentColor ) , Gdip_FillRectangle( G , Brush , 10 , 12 , fObj.W-21 , fObj.H / 15 ) , Gdip_DeleteBrush( Brush )

            Brush := Gdip_BrushCreateSolid( fObj.GlossBottomColor ) , Gdip_FillRectangle( G , Brush , 6 , 10 + ( fObj.H / 2 ) - 10 , fObj.W-13 , ( fObj.H / 2 ) - 7 ) , Gdip_DeleteBrush( Brush )

        }

        Gdip_DeleteGraphics( G )

        Bitmap.hBitmap := Gdip_CreateHBITMAPFromBitmap( Bitmap.pBitmap )

        return Bitmap

    }

    _GetMasterDefaultValues(){ ;Default State

        local Default := {}

        Default.pBitmap := "" 
        , Default.hBitmap := ""
        , Default.Font := "Arial"
        , Default.FontOptions := " Bold Center vCenter "
        , Default.FontSize := "12"
        , Default.Text := "Button"
        , Default.W := 10
        , Default.H := 10
        , Default.TextBottomColor1 := "0x0002112F"
        , Default.TextBottomColor2 := Default.TextBottomColor1
        , Default.TextTopColor1 := "0xFFFFFFFF"
        , Default.TextTopColor2 := "0xFF000000"
        , Default.TextOffsetX := 0
        , Default.TextOffsetY := 0
        , Default.TextOffsetW := 0
        , Default.TextOffsetH := 0
        , Default.BackgroundColor := "0xFF22262A"
        , Default.ButtonOuterBorderColor := "0xFF161B1F"	
        , Default.ButtonCenterBorderColor := "0xFF262B2F"	
        , Default.ButtonInnerBorderColor1 := "0xFF3F444A"
        , Default.ButtonInnerBorderColor2 := "0xFF24292D"
        , Default.ButtonMainColor1 := "0xFF272C32"
        , Default.ButtonMainColor2 := "" Default.ButtonMainColor1
        , Default.ButtonAddGlossy := 0
        , Default.GlossTopColor := "0x11FFFFFF"
        , Default.GlossTopAccentColor := "0x05FFFFFF"	
        , Default.GlossBottomColor := "0x33000000"

        return Default

    }

    _GetMasterHoverValues(){ ;Hover State

        local Default := {}

        Default.pBitmap := ""
        , Default.hBitmap := ""
        , Default.Font := "Arial"
        , Default.FontOptions := " Bold Center vCenter "
        , Default.FontSize := "12"
        , Default.Text := "Button"
        , Default.W := 10
        , Default.H := 10
        , Default.TextBottomColor1 := "0x0002112F"
        , Default.TextBottomColor2 := Default.TextBottomColor1
        , Default.TextTopColor1 := "0xFFFFFFFF"
        , Default.TextTopColor2 := "0xFF000000"
        , Default.TextOffsetX := 0
        , Default.TextOffsetY := 0
        , Default.TextOffsetW := 0
        , Default.TextOffsetH := 0
        , Default.BackgroundColor := "0xFF22262A"
        , Default.ButtonOuterBorderColor := "0xFF161B1F"	
        , Default.ButtonCenterBorderColor := "0xFF262B2F"	
        , Default.ButtonInnerBorderColor1 := "0xFF3F444A"
        , Default.ButtonInnerBorderColor2 := "0xFF24292D"
        , Default.ButtonMainColor1 := "0xFF373C42"
        , Default.ButtonMainColor2 := "" Default.ButtonMainColor1
        , Default.ButtonAddGlossy := 0
        , Default.GlossTopColor := "0x11FFFFFF"
        , Default.GlossTopAccentColor := "0x05FFFFFF"	
        , Default.GlossBottomColor := "0x33000000"

        return Default

    }

    _GetMasterPressedValues(){ ;Pressed State

        local Default := {}

        Default.pBitmap := ""
        , Default.hBitmap := ""
        , Default.Font := "Arial"
        , Default.FontOptions := " Bold Center vCenter "
        , Default.FontSize := "12"
        , Default.Text := "Button"
        , Default.W := 10
        , Default.H := 10
        , Default.TextBottomColor1 := "0x0002112F"
        , Default.TextBottomColor2 := Default.TextBottomColor1
        , Default.TextTopColor1 := "0xFFFFFFFF"
        , Default.TextTopColor2 := "0xFF000000"
        , Default.TextOffsetX := 0
        , Default.TextOffsetY := 0
        , Default.TextOffsetW := 0
        , Default.TextOffsetH := 0
        , Default.BackgroundColor := "0xFF22262A"
        , Default.ButtonOuterBorderColor := "0xFF62666a"
        , Default.ButtonCenterBorderColor := "0xFF262B2F"	
        , Default.ButtonInnerBorderColor1 := "0xFF151A20"
        , Default.ButtonInnerBorderColor2 := "0xFF151A20"
        , Default.ButtonMainColor1 := "0xFF12161a"
        , Default.ButtonMainColor2 := "0xFF33383E"
        , Default.ButtonAddGlossy := 0
        , Default.GlossTopColor := "0x11FFFFFF"
        , Default.GlossTopAccentColor := "0x05FFFFFF"	
        , Default.GlossBottomColor := "0x33000000"

        return Default

    }

    SetSessionDefaults( All := "" , Default := "" , Hover := "" , Pressed := "" ){ ;Set the default values based on user input

        This.SessionBitmapData := {} 
        , This.Preset := 1
        , This.init := 0

        This._LoadDefaults("SessionBitmapData")

        This._SetSessionData( All , Default , Hover , Pressed )

    }

    _SetSessionData( All := "" , Default := "" , Hover := "" , Pressed := "" ){

        local index , k , v , i , j

        if( IsObject( All ) ){

            Loop, % GuiButtonType1.List.Length()	{
                index := A_Index
                For k , v in All
                    This.SessionBitmapData[ GuiButtonType1.List[ index ] ][ k ] := v
            }
        }

        For k , v in GuiButtonType1.List
            if( isObject( %v% ) )
            For i , j in %v%
            This.SessionBitmapData[ GuiButtonType1.List[ k ] ][ i ] := j

    }

    _LoadDefaults( input := "" ){

        This.CurrentBitmapData := "" , This.CurrentBitmapData := {}

        For k , v in This.SessionBitmapData
            This.CurrentBitmapData[k] := {}

        This[ input ].Default := This._GetMasterDefaultValues()
        , This[ input ].Hover := This._GetMasterHoverValues()
        , This[ input ].Pressed := This._GetMasterPressedValues()

    }

    _SetCurrentBitmapDataFromSessionData(){

        local k , v , i , j

        This.CurrentBitmapData := "" , This.CurrentBitmapData := {}

        For k , v in This.SessionBitmapData
        {
            This.CurrentBitmapData[k] := {}

            For i , j in This.SessionBitmapData[k]

            This.CurrentBitmapData[k][i] := j

        }

    }

    _UpdateCurrentBitmapData( All := "" , Default := "" , Hover := "" , Pressed := "" ){

        local k , v , i , j

        if( IsObject( All ) ){

            Loop, % GuiButtonType1.List.Length()	{

                index := A_Index

                For k , v in All

                This.CurrentBitmapData[ GuiButtonType1.List[ index ] ][ k ] := v

            }
        }

        For k , v in GuiButtonType1.List

        if( isObject( %v% ) )

        For i , j in %v%

        This.CurrentBitmapData[ GuiButtonType1.List[ k ] ][ i ] := j

    }

    _UpdateInstanceData( obj := ""){

        For k , v in GuiButtonType1.List	

        This.CurrentBitmapData[v].Text := obj.Text
        , This.CurrentBitmapData[v].W := obj.W
        , This.CurrentBitmapData[v].H := obj.H

    }

    CreateButtonBitmapSet( obj := "" , All := "" , Default := "" , Hover := "" , Pressed := "" ){ ;Create a new button

        local Bitmaps := {}

        if( This.Preset )

        This._SetCurrentBitmapDataFromSessionData()

        else

        This._LoadDefaults( "CurrentBitmapData" )

        This._UpdateCurrentBitmapData( All , Default , Hover , Pressed )

        This._UpdateInstanceData( obj )

        Bitmaps.Default := This._CreateDefaultBitmap()
        , Bitmaps.Hover := This._CreateHoverBitmap()
        , Bitmaps.Pressed := This._CreatePressedBitmap()

        return Bitmaps

    }

}
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************

/*  ;Template for setting button session defaults

MasterTheme(){
	
	local Theme := {}

	Theme.All := {}
	
	Theme.All.pBitmap := ""
	, Theme.All.hBitmap := ""
	, Theme.All.Font := "Arial"
	, Theme.All.FontOptions := " Bold Center vCenter "
	, Theme.All.FontSize := "12"
	, Theme.All.Text := "Button"
	, Theme.All.W := 10
	, Theme.All.H := 10
	, Theme.All.TextBottomColor1 := "0x0002112F"
	, Theme.All.TextBottomColor2 := Theme.All.TextBottomColor1
	, Theme.All.TextTopColor1 := "0xFFFFFFFF"
	, Theme.All.TextTopColor2 := "0xFF000000"
	, Theme.All.TextOffsetX := 0
	, Theme.All.TextOffsetY := 0
	, Theme.All.TextOffsetW := 0
	, Theme.All.TextOffsetH := 0
	, Theme.All.BackgroundColor := "0xFF22262A"
	, Theme.All.ButtonOuterBorderColor := "0xFF62666a"
	, Theme.All.ButtonCenterBorderColor := "0xFF262B2F"	
	, Theme.All.ButtonInnerBorderColor1 := "0xFF151A20"
	, Theme.All.ButtonInnerBorderColor2 := "0xFF151A20"
	, Theme.All.ButtonMainColor1 := "0xFF12161a"
	, Theme.All.ButtonMainColor2 := "0xFF33383E"
	, Theme.All.ButtonAddGlossy := 0
	, Theme.All.GlossTopColor := "0x11FFFFFF"
	, Theme.All.GlossTopAccentColor := "0x05FFFFFF"	
	, Theme.All.GlossBottomColor := "0x33000000"
	
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	;<<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>>
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	
	Theme.Default := {}
	
	Theme.Default.pBitmap := "" 
	, Theme.Default.hBitmap := ""
	, Theme.Default.Font := "Arial"
	, Theme.Default.FontOptions := " Bold Center vCenter "
	, Theme.Default.FontSize := "12"
	, Theme.Default.Text := "Button"
	, Theme.Default.W := 10
	, Theme.Default.H := 10
	, Theme.Default.TextBottomColor1 := "0x0002112F"
	, Theme.Default.TextBottomColor2 := Theme.Default.TextBottomColor1
	, Theme.Default.TextTopColor1 := "0xFFFFFFFF"
	, Theme.Default.TextTopColor2 := "0xFF000000"
	, Theme.Default.TextOffsetX := 0
	, Theme.Default.TextOffsetY := 0
	, Theme.Default.TextOffsetW := 0
	, Theme.Default.TextOffsetH := 0
	, Theme.Default.BackgroundColor := "0xFF22262A"
	, Theme.Default.ButtonOuterBorderColor := "0xFF161B1F"	
	, Theme.Default.ButtonCenterBorderColor := "0xFF262B2F"	
	, Theme.Default.ButtonInnerBorderColor1 := "0xFF3F444A"
	, Theme.Default.ButtonInnerBorderColor2 := "0xFF24292D"
	, Theme.Default.ButtonMainColor1 := "0xFF272C32"
	, Theme.Default.ButtonMainColor2 := "" Theme.Default.ButtonMainColor1
	, Theme.Default.ButtonAddGlossy := 0
	, Theme.Default.GlossTopColor := "0x11FFFFFF"
	, Theme.Default.GlossTopAccentColor := "0x05FFFFFF"	
	, Theme.Default.GlossBottomColor := "0x33000000"
	
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	;<<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>>
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	
	Theme.Hover := {}
	
	Theme.Hover.pBitmap := ""
	, Theme.Hover.hBitmap := ""
	, Theme.Hover.Font := "Arial"
	, Theme.Hover.FontOptions := " Bold Center vCenter "
	, Theme.Hover.FontSize := "12"
	, Theme.Hover.Text := "Button"
	, Theme.Hover.W := 10
	, Theme.Hover.H := 10
	, Theme.Hover.TextBottomColor1 := "0x0002112F"
	, Theme.Hover.TextBottomColor2 := Theme.Hover.TextBottomColor1
	, Theme.Hover.TextTopColor1 := "0xFFFFFFFF"
	, Theme.Hover.TextTopColor2 := "0xFF000000"
	, Theme.Hover.TextOffsetX := 0
	, Theme.Hover.TextOffsetY := 0
	, Theme.Hover.TextOffsetW := 0
	, Theme.Hover.TextOffsetH := 0
	, Theme.Hover.BackgroundColor := "0xFF22262A"
	, Theme.Hover.ButtonOuterBorderColor := "0xFF161B1F"	
	, Theme.Hover.ButtonCenterBorderColor := "0xFF262B2F"	
	, Theme.Hover.ButtonInnerBorderColor1 := "0xFF3F444A"
	, Theme.Hover.ButtonInnerBorderColor2 := "0xFF24292D"
	, Theme.Hover.ButtonMainColor1 := "0xFF373C42"
	, Theme.Hover.ButtonMainColor2 := "" Theme.Hover.ButtonMainColor1
	, Theme.Hover.ButtonAddGlossy := 0
	, Theme.Hover.GlossTopColor := "0x11FFFFFF"
	, Theme.Hover.GlossTopAccentColor := "0x05FFFFFF"	
	, Theme.Hover.GlossBottomColor := "0x33000000"
	
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	;<<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>>
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	
	Theme.Pressed := {}
	
	Theme.Pressed.pBitmap := ""
	, Theme.Pressed.hBitmap := ""
	, Theme.Pressed.Font := "Arial"
	, Theme.Pressed.FontOptions := " Bold Center vCenter "
	, Theme.Pressed.FontSize := "12"
	, Theme.Pressed.Text := "Button"
	, Theme.Pressed.W := 10
	, Theme.Pressed.H := 10
	, Theme.Pressed.TextBottomColor1 := "0x0002112F"
	, Theme.Pressed.TextBottomColor2 := Theme.Pressed.TextBottomColor1
	, Theme.Pressed.TextTopColor1 := "0xFFFFFFFF"
	, Theme.Pressed.TextTopColor2 := "0xFF000000"
	, Theme.Pressed.TextOffsetX := 0
	, Theme.Pressed.TextOffsetY := 0
	, Theme.Pressed.TextOffsetW := 0
	, Theme.Pressed.TextOffsetH := 0
	, Theme.Pressed.BackgroundColor := "0xFF22262A"
	, Theme.Pressed.ButtonOuterBorderColor := "0xFF62666a"
	, Theme.Pressed.ButtonCenterBorderColor := "0xFF262B2F"	
	, Theme.Pressed.ButtonInnerBorderColor1 := "0xFF151A20"
	, Theme.Pressed.ButtonInnerBorderColor2 := "0xFF151A20"
	, Theme.Pressed.ButtonMainColor1 := "0xFF12161a"
	, Theme.Pressed.ButtonMainColor2 := "0xFF33383E"
	, Theme.Pressed.ButtonAddGlossy := 0
	, Theme.Pressed.GlossTopColor := "0x11FFFFFF"
	, Theme.Pressed.GlossTopAccentColor := "0x05FFFFFF"	
	, Theme.Pressed.GlossBottomColor := "0x33000000"
	
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	;<<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>>
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	
	
	return Theme
}
