#Include, findtext2.ahk

; Dialogue patterns (always included)
DialogueText1 := "|<diologue>**50$87.000000000000000000003zz000000000000EAA000000000002TQvU0000000000G/pI00000000002TKiU0000000000EOKg00000000003tGl000000000001+rM00000000003dQpU0000000000T9Ya000000000023VCE0000000000TrzS0000000000000000000000000000000004"
DialogueText2 := "|<diologue>**50$22.zzk21VU/xnjYLjyTKisB/KyJgE9KvCZvKynPC3VCzvzjU"
DialogueText3 := "|<diologue>**50$75.00003UQ000001zz00o2Vzs000Q5c04UIA50002SxzbbyVTjzzyqRU7Ulo/QMvMykhLNYqVTeP2Po5jvQjIARrfriUhMOU2VsihQ1q5iuI/o3pYeZyvhrPZiXqixKrPpivQjoHpr+rvUiEQ62X1l3H1DzzzzzwDzzyDw"
DialogueText4 := "|<diologue>**50$75.00003UQ000001zz00I2Uzs000M5c00UIA50002SxzbbuVSjxzwKR07Uko/M8uMSUg2M4mVTWP2NY5jvQjI8RrfriUhMG02VsgZI1q5iuE9o1pYeYunhbOZiVqihKrHpavQbI3Yr+HfUiEQ62V1l3H17zTzzzwDvzyDw"

; Stat patterns
StrText1 := "|<str>**50$69.00000000000000000001k0w07zU0003e0Bc0kI0000JE1jz5yzzzvyvsPJchlP7FkFFWHV5ycHMYmcYKBslrSxSiLSWVg7WfU+pGeoIB0DJIjG+JGWVcDOuquJuuIIB1DLKzGaLGWrcA7+M+K3+IGr0zzlznyTnXT0000005q009U000000VU01Y0000007s007U00000000000U"
StrText2 := "|<str>**50$69.00A500005I0LjlSjzvyziy67G/MIkoQ0IMXMFTW4m10W15xS8RrjLfZrcge1sec2YEeZ5ZE1pJ9oW5Iche1qihiZQiZ5tE3YobId4occO11ma2ZUmZ4zkDvwTwzbwsk0000001RU0200000008M00M0000001y001000000000004"

DexText1 := "|<dex>**50$69.07y00Q01y01c0UM02U0/E0Bz5tzxrzzvlnRchaDy4Rf3OGV5aarJBVOempsgpvKvpvRqIg5aUMq0hOiWZ0gpTimx/KgIc5xhurPdPl2Z0jBymvx/SMKc47k7MUdQP2L0znzjzzDzEP000000000K18000000002UA000000000Q0w"
DexText2 := "|<dex>**50$69.0000000000000000000003U3z00C00z00ksEA01E05c04gWwzivzTxsth4In3I26Z1h9AWWH/caEgJNMYIOxfRuxiv+42X0AP0IhGFEUIEbrNCZfK+42yqxPhohcVEUL6R9AuZbA/A23s3YEIiBV90TlzrzzbT8BjU"

WisText1 := "|<wis>*124$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzzzzDzzCSjznzzzwwzyQRzzbzzzvVoysmssAB4TbnVwpZYUG80TTaDt/OTQCLAyzAzmmqAsSiNxyNzpVi1kxQnvwvzXXT3Vutbrtrz7CiH9ZnDjnjyCR1UMPaTC1zzzzzzzzzzTzzzzzzzzzzyTzzzzzzzzzzyTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
WisText2 := "|<wis>*111$71.zzzzzkzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxzzzzDzzCSjznzzzwwzyQRzzbzzzvlqysmssAB4TbnVwpZYUG80TTbDt/OTQiLAyzCzumqAsSiNxyRzpVi1kxQnvwvzXXT3Vutbrtrz7CiH9ZnDjnjzCRVUMPaTC1zzzzzzzzzzTzzzzzzzzzzyTzzzzzzzzzzyTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

AgiText1 := "|<agi>**50$69.000000000000000000000000000000000000000000000000000000000000003U00D00007U3rw03Pns00a0KqU0PukzwAnzrrXaoJlqVekKq6oYmjq4/QmqpJZWRTLXPiKqvgcHdOkPhGqpR52RNI21+KqhMcHfuUrZuqrW52JyI6aaKqwkhna6Ugq2qsq4gC7w7XyTzyUrzz0005q00g2M00000VU050N000007s00s1s0000000000000000000000004"
AgiText2 := "|<agi>**50$69.00000000000600000Q001k0E00w0SzU0MSO004k2qo02KKzTVWTyywQqWiCY9K2qUqYaJakVPUKq+ggGhuwPBmqrRZ2J9I2R8Kqd8cGd+UE92qpf52JfI6wiKqoEcGhmUYoWqna5aQko4WkKr6kYVnzUsTnzjY6rz0000ik05UG000004A00c3000000z0070C04"

IntText1 := "|<int>*115$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzqzzzzzzzszrzhjzzzzzzbzjzPzzzzzzzSW26qsAB733ww29ZhaH84onvvZrfPQjL/vrrrf0Kos0j7UDjjKThdkzSDDzTSgzPHVywSTyyxAuqm9puORxZv45hkM/q63tzzzzzwzzzzzvzzzzynzzzzznzzzzwDzzzzzrzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
IntText2 := "|<int>*128$71.zzzzzzzzzrzjzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzPzzzzzzz3zTyqzzzzzzzTyzxjzzzzzzyu88PPUkoQADxk8aKqFAUGHDviLShhmxQjjTrSg1PHU2wS0zixNyqb3xswzzRunxhC7vltzyvonfP8bLddrsLcEKr1UjMMDzzzzzznzzzzzzzzzzvDzzzzzzzzzzkzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

VitText1 := "|<vit>**50$58.000000000000000000000000000000000Q001s0wTs1Tk0Bj2HKU5h00rpBBvzLrXaoIqhU7P3OGNFCqfhhJNMb6vPyqrRZ2QPRf3PJoI9kZqvhhOlEb3JPiqrW52IApivPSMKtkHL8BiBV/31tzzzzo6zw000002k9U000000+0m0000000s1s00000000008"
VitText2 := "|<vit>**50$69.000000000000000000000000000000000000000000000000000000000000000Q001k001szk2zU0MSM09BO0Ko02KKrtdDTuywQqWfdBfE1qUqYaJg8bP0aq+ggGij6nPyqrRZ2JJ0KvK6qd8cGec2JPiqpf52Jp0MfNqqoEcGgc1BNiqna5aQB09/Y6r6kYVrs1trzzjY6rz00000005UG000000000c300000000070C0000000000000000000000004"

; dcube patterns (commented in original but included for completeness)
DcubeText1 := "|<dcube>**50$87.0000000000000000000000000000000007k000000000C001W00Dy0000C1E008E031E0001LzzT3TvwLfzyzjvVOC6EloWq5AB701/0aH4q4LsVAUE8TPpu/jLW7RvputO/G0FN+US+e0d4+FOFC/9I0RJGR8VH/KhlROURffPdL/DPYu+iI0tB9p+FA/1kFK6UEQdUdMAzvvyCTw3yz7zDts1E0000000000LM0+00000000002601k0000000000TUU"
DcubeText2 := "|<dcube>**50$87.00000000000000000000000000000000000000000000000DU00000000CQ003Y00zw0000RGU00GU062U0002ezyz6zzsjrzzzTrOoQQlXh5i/MuC2+KNBa9g8jp2P4aJ6rfoLSj6CvrfpmvKZ0WupUwJQ1KeJGoewKGc1ueZuFGeqxPWvp1vLKrGjLKr/wLQc9uuruImuK3UWgB1UtH1GkNLrrwQzs7zyDyTny2U0000000000ik0I00000000004A03U0000000000z000000000000000000000000000000000000000000000000000000000004"
DcubeText3 := "|<dcube>**50$78.00070003U00w0zk050Dw2U01jzUM050Q42U01g6jDvxQHrCyz3TqhYCpkqROXXWLGgpq5Yq5ONBWkqgrqxAo5OxSWUqgq6oMo5OZ0WVjgpqYMq5OZLWXMjhqZgrRuxPWavjBqZqPpmtTWpzUw6ZmQ623UWI2zrzbSDzzyzXTz00000000001A000000000001Y000000000000w0U"
DcubeText4 := "|<dcube>**50$78.00070003U00s0zk050Dw2U01bzUM050M42U01A6jDvxQHrCyy3TqdYCZkKR+XVWEGcYa5Yo521AWkqcrqxAY52xSWUqcq6YMo52Y0WVjcZqYMq52YHWXMjdqZgKRmhPWani9qZaHomtCWozUw6ZmQ623UWI2zbzbS7zzyzXTz000000000018000000000001U000000000000s0U"

; imbu patterns (commented in original but included for completeness)
ImbuText1 := "|<imbu>**50$87.1k0000000000008+0000000s7y0031E00000051UM00LvzDxzxxzi9tzw6XFdMOMsO81NeMMU852N42N0UO52N5NScLfaLfpWEfrcfeJ01Is1GcO5I15JGc4uZ4uJ3FeYseepmrIerGg/BKr5JQaHeZHeItDOHcecC31If1GlA7H14rzTzyxzyTsziDsk0000000000000200000000000000M00000000000001U"
ImbuText2 := "|<imbu>**50$87.000000000000w00000003UTs00BjT000000I61U01je4zzzrzywbjzsPFLhXdXXckhahXWH+Jdgl9gGZco9gK9HhSixSjLB2jSWV+5U5HU5OVcJk4I9TgLeQLdIBaeLWV8DfRHfR+lhpPQI9RtTeRTdLaxfTWrDsA5Hg5/4sRA4GkkzzvzztzXzszXTzs000000000009U0000000000001Y00000000000007U0U"
ImbuText3 := "|<imbu>*113$71.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzvzzzzzzzzwDzrzzzzzzzTxzzjzzzzzzyzvcXFjMO8sO8Dr021QaE0aE8xitZutSiNSiLvRn/pk1Qk1SjqvaLfVytVyxTxrAjL3xn3xuzviNQaHfaHfozVQm30kLAkLcTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

; Global variables
SelectedStat := "str"
Running := false
DialogueX1 := 1143
DialogueY1 := 144
DialogueX2 := 1767
DialogueY2 := 583
NPCClickX := 747
NPCClickY := 327
SelectingDialogue := false
SelectingNPC := false
DragStartX := 0
DragStartY := 0

; Create GUI
Gui, Add, Text, x10 y10, Select Stat to Search For:
Gui, Add, Radio, x10 y30 vRadioStr gStatChanged Checked, STR
Gui, Add, Radio, x10 y50 vRadioDex gStatChanged, DEX  
Gui, Add, Radio, x10 y70 vRadioWis gStatChanged, WIS
Gui, Add, Radio, x10 y90 vRadioAgi gStatChanged, AGI
Gui, Add, Radio, x80 y30 vRadioInt gStatChanged, INT
Gui, Add, Radio, x80 y50 vRadioVit gStatChanged, VIT
gui, add, radio, x80 y70 vRadioDcube gStatChanged, DCUBE
gui, add, radio, x80 y90 vRadioImbu gStatChanged, IMBU

Gui, Add, Text, x10 y160, Dialogue Search Area:
Gui, Add, Button, x10 y180 w150 h25 gSelectDialogueArea, Select Dialogue Area
Gui, Add, Text, x10 y210 vDialogueCoords, Area: %DialogueX1%,%DialogueY1% to %DialogueX2%,%DialogueY2%

Gui, Add, Text, x10 y235, NPC Click Position:
Gui, Add, Button, x10 y255 w150 h25 gSelectNPCPosition, Select NPC Position
Gui, Add, Text, x10 y285 vNPCCoords, Position: %NPCClickX%,%NPCClickY%

Gui, Add, Button, x10 y315 w80 h30 gStartStop, Start
Gui, Add, Button, x100 y315 w80 h30 gExit, Exit

Gui, Add, Text, x10 y355, Status:
Gui, Add, Text, x60 y355 vStatusText w120, Stopped

Gui, Add, Text, x10 y375, Instructions:
Gui, Add, Text, x10 y395 w180 h40, Click and drag to select dialogue area. Single click for NPC position.

Gui, Add, Text, x10 y440, Hotkeys:
Gui, Add, Text, x10 y460, Ctrl+1: Start/Stop
Gui, Add, Text, x10 y480, Ctrl+2: Reload Script

Gui, Show, w200 h510, Stat Search Tool

return

StatChanged:
Gui, Submit, NoHide
if (RadioStr)
    SelectedStat := "str"
else if (RadioDex)
    SelectedStat := "dex"
else if (RadioWis)
    SelectedStat := "wis"
else if (RadioAgi)
    SelectedStat := "agi"
else if (RadioInt)
    SelectedStat := "int"
else if (RadioVit)
    SelectedStat := "vit"
else if (RadioDcube)
    SelectedStat := "dcube"
else if (RadioImbu)
    SelectedStat := "imbu"
return

SelectDialogueArea:
SelectingDialogue := true
SelectingNPC := false
Gui, Hide
MsgBox, 0, Select Dialogue Area, Click and drag to select the dialogue search area. Press ESC to cancel., 3
SetTimer, CheckForDialogueSelection, 10
return

SelectNPCPosition:
SelectingNPC := true
SelectingDialogue := false
Gui, Hide
MsgBox, 0, Select NPC Position, Click on the NPC position. Press ESC to cancel., 3
SetTimer, CheckForNPCSelection, 10
return

CheckForDialogueSelection:
if (!SelectingDialogue) {
    SetTimer, CheckForDialogueSelection, Off
    return
}

; Check for mouse button press to start drag
if GetKeyState("LButton", "P") && (DragStartX = 0 && DragStartY = 0) {
    MouseGetPos, DragStartX, DragStartY
    return
}

; Check for mouse button release to end drag
if !GetKeyState("LButton", "P") && (DragStartX != 0 && DragStartY != 0) {
    MouseGetPos, DragEndX, DragEndY
    
    ; Ensure we have top-left and bottom-right coordinates
    DialogueX1 := (DragStartX < DragEndX) ? DragStartX : DragEndX
    DialogueY1 := (DragStartY < DragEndY) ? DragStartY : DragEndY
    DialogueX2 := (DragStartX > DragEndX) ? DragStartX : DragEndX
    DialogueY2 := (DragStartY > DragEndY) ? DragStartY : DragEndY
    
    ; Reset drag variables
    DragStartX := 0
    DragStartY := 0
    SelectingDialogue := false
    
    ; Update GUI
    GuiControl,, DialogueCoords, Area: %DialogueX1%,%DialogueY1% to %DialogueX2%,%DialogueY2%
    Gui, Show
    SetTimer, CheckForDialogueSelection, Off
    return
}

if GetKeyState("Escape", "P") {
    SelectingDialogue := false
    DragStartX := 0
    DragStartY := 0
    Gui, Show
    SetTimer, CheckForDialogueSelection, Off
}
return

CheckForNPCSelection:
if (!SelectingNPC) {
    SetTimer, CheckForNPCSelection, Off
    return
}

if GetKeyState("LButton", "P") {
    Sleep, 100  ; Small delay to ensure clean click detection
    if GetKeyState("LButton", "P") {  ; Double check the button is still pressed
        MouseGetPos, NPCClickX, NPCClickY
        SelectingNPC := false
        
        ; Update GUI
        GuiControl,, NPCCoords, Position: %NPCClickX%,%NPCClickY%
        
        ; Wait for button release to avoid multiple clicks
        KeyWait, LButton
        Gui, Show
        SetTimer, CheckForNPCSelection, Off
        return
    }
}

if GetKeyState("Escape", "P") {
    SelectingNPC := false
    Gui, Show
    SetTimer, CheckForNPCSelection, Off
}
return

StartStop:
if (Running) {
    Running := false
    GuiControl,, StatusText, Stopped
    GuiControl,, StartStop, Start
    SetTimer, MainLoop, Off
} else {
    Running := true
    GuiControl,, StatusText, Running (%SelectedStat%)
    GuiControl,, StartStop, Stop
    SetTimer, MainLoop, 100
}
return

Exit:
ExitApp

GuiClose:
ExitApp

MainLoop:
if (!Running) {
    SetTimer, MainLoop, Off
    return
}
WinActivate, Rappelz
; First, search for and click any dialogue patterns
FoundAnyDialogue := false
Loop, 4 {
    ; Check for dialogue patterns (always search these first)
    if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, DialogueText1)) {
        Sleep, 5
        FindText().Click(X, Y, "L")
        FoundAnyDialogue := true
        return  ; Exit and wait for next loop cycle
    }
    if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, DialogueText2)) {
        Sleep, 5
        FindText().Click(X, Y, "L")
        FoundAnyDialogue := true
        return  ; Exit and wait for next loop cycle
    }
    if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, DialogueText3)) {
        Sleep, 5
        FindText().Click(X, Y, "L")
        FoundAnyDialogue := true
        return  ; Exit and wait for next loop cycle
    }
    if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, DialogueText4)) {
        Sleep, 5
        FindText().Click(X, Y, "L")
        FoundAnyDialogue := true
        return  ; Exit and wait for next loop cycle
    }
    
    ; Check for selected stat patterns
    if (SelectedStat = "str") {
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, StrText1)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, StrText2)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
    }
    else if (SelectedStat = "dex") {
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, DexText1)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, DexText2)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
    }
    else if (SelectedStat = "wis") {
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, WisText1)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, WisText2)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
    }
    else if (SelectedStat = "agi") {
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, AgiText1)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, AgiText2)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
    }
    else if (SelectedStat = "int") {
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, IntText1)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, IntText2)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
    }
    else if (SelectedStat = "vit") {
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, VitText1)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, VitText2)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
    }
    Else if (selectedstat = "dcube") {
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, DcubeText1)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, DcubeText2)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
    }
    Else if (selectedstat = "imbu") {
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, ImbuText1)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
        if (FindText(X, Y, DialogueX1, DialogueY1, DialogueX2, DialogueY2, 0, 0, ImbuText2)) {
            Sleep, 5
            FindText().Click(X, Y, "L")
            FoundAnyDialogue := true
            return  ; Exit and wait for next loop cycle
        }
    }
}

; Only perform NPC clicks if NO dialogue patterns were found (dialogue sequence is complete)
if (!FoundAnyDialogue) {
    MouseClick, Left, %NPCClickX%, %NPCClickY%
    Sleep, 50
    MouseClick, Left, %NPCClickX%, %NPCClickY%
    Sleep, 50
    MouseClick, Left, %NPCClickX%, %NPCClickY%
    Sleep, 50
    MouseClick, Left, %NPCClickX%, %NPCClickY%
}

return

^2::
Reload