#Requires AutoHotkey v2
;#include "laseros.ahk"
#include "laserOS_UIA_v2.ahk"

; ---------------------------
; File to store data
; ---------------------------
dataFile := A_ScriptDir "\laserPop_Settings.txt"

; ---------------------------
; Create a custom UI window
; ---------------------------
myGui := Gui("+AlwaysOnTop", "LaserOS Control Panel")
myGui.OnEvent("Close", SaveAndExit) ; Exit script when GUI is closed


myGui.Add("Text",, "Hotkeys:`r`n`tCtrl+A = Add coordinate`r`n`tCtrl+S = Next coordinate`r`n`tCtrl+P = Play all coordinates`r`n`tCtrl+L = Stop loop")

; Multiline Edit control (acts like memo)
coordMemo := myGui.AddEdit("w220 h160 +ReadOnly +Multi")
debug := coordMemo

; BPM input
myGui.Add("Text",, "BPM:")
bpmEdit := myGui.AddEdit("w220", "120") ; default BPM = 120

; Buttons
btnSetup := myGui.AddButton("w220", "Set LaserOS window")
btnSetup.OnEvent("Click", SetLaserOS)

btnPlay := myGui.AddButton("w175", "Play coords")
btnPlay.OnEvent("Click", PlayCoords)

chkLoop := MyGui.AddCheckBox("x+m yp+5 w40", "loop")

btnClear := myGui.AddButton("xm w220", "Clear Stored Coords")
btnClear.OnEvent("Click", ClearCoords)


; Show the window
myGui.Show("x50 y50 w250 h370")

; ---------------------------
; Main script
; ---------------------------

;exe := "ahk_exe laserOS.exe"
;exePath := "C:\Program Files\LaserOS\laserOS.exe"

; global array to hold captured coordinates
coords := []
step := 1
ww := -1
wh := -1

; ---------------------------
; Load data if file exists
; ---------------------------
if FileExist(dataFile) {
    Loop Read, dataFile
    {
        line := trim(A_LoopReadLine)
        if line = ""
            continue
        if SubStr(line,1,4) = "BPM=" {
            bpmEdit.Value := SubStr(line,5)
        } if SubStr(line,1,6) = "WIDTH=" {
            ww := SubStr(line,7)
        } if SubStr(line,1,7) = "HEIGHT=" {
            wh := SubStr(line,8)
        } else if RegExMatch(line, "^\d+,\d+$") {
            parts := StrSplit(line,",")
            coords.Push({x:parts[1]+0, y:parts[2]+0})
        }
    }
}

ShowCoords()
StartLaserOS()

; ensure mouse uses screen coordinates for capture
CoordMode("Mouse", "Client")

; Hotkeys
Hotkey "^a", CaptureCoord
Hotkey "^p", PlayCoords
Hotkey "^s", PlayStep
Hotkey "^l", StopLoop
Hotkey "^t", SlideShow
HotKey "^c", GetLaser

; ---------------------------
; Functions
; ---------------------------

ShowCoords(*){
    coordMemo.Value := ""
    for c in coords {
        coordMemo.Value .= c.x ", " c.y "`r`n"
    }
}

SetLaserOS(*){
    StartLaserOS()
    WinGetPos &wx, &wy, &wwo, &who, exe
    if (ww > -1 || wh > -1)
        WinMove(wx, wy, ww, wh)    
}

SlideShow(*){
    SetLaserOutputSize(50, 50, -100, 0,)
    loop {
        pg := 2000 ; Fade duration
        BurnImportImage("c:\Users\Paul\Pictures\Urge\svg\gay_erotic_lineart_1_edit.svg", 6000)
        SetLaserPosX(100)
        sleep(pg)
        BurnImportImage("c:\Users\Paul\Pictures\Urge\svg\nz_falcons.svg", 7000)
        SetLaserPosX(-100)
        sleep(pg)
        BurnImportImage("c:\Users\Paul\Pictures\Urge\svg\gay_erotic_lineart_2_edit.svg", 8000)
        SetLaserPosX(100)
        sleep(pg)
        BurnImportImage("c:\Users\Paul\Pictures\Urge\svg\Urge_events.svg", 8000)
        SetLaserPosX(-100)
        sleep(pg)
        BurnImportImage("c:\Users\Paul\Pictures\Urge\svg\gay_erotic_lineart_5_edit.svg", 6000)
        SetLaserPosX(100)
        sleep(pg)

        BurnImportImage("c:\Users\Paul\Pictures\Urge\svg\beatline.xyz_logo_single stroke.svg", 14000)
        SetLaserPosX(-100)
        sleep(pg)
    } Until chkLoop.value != 1
}

SetBurn(fileName, drawTime, glowDuration := 0){
    global exe
    pt := 3000
    WinActivate(exe)        ; activate laserOS
    ;Click('L', 442, 842, 1) ; select burn
    send "b"
    Sleep(pt)
    Click('L', 948, 205, 1) ; select import image
    Sleep(pt)
    SendText(fileName)      ; define svg file
    Sleep(pt)
    Send("{Enter}")         ; load the file
    Sleep(1000)
    SetLaser(true)
    Click('L', 872, 382, 1) ; burn image on glow panel
    Sleep(drawTime)
    SetLaser(false)
    sleep(glowDuration)
}

SetProjectorImageSettings(*){
    global main
    pt := 200
    WinActivate(exe)
    setSettings(true)
    setProjectorSetup()
    Sleep(pt)
    ; Open drop down
    elProjectorSettingType := main.ElementFromPath("Y3q").Highlight() ;image dropdown
    btnProjectorSettingType := elProjectorSettingType.InvokePattern
    btnProjectorSettingType.Invoke()
    Click('L', elProjectorSettingType.Location.x - main.Location.x + 15, 147, 1)
    Sleep(pt)
}

SetLaserOutputSize(zoomx:="", zoomy:="", posx:="", posy:="", angle:=""){
    global main
    SetProjectorImageSettings()
    pt := 200
    WinActivate(exe)
    setSettings(true)
    setProjectorSetup()

    if (zoomx != ""){
        btnImageZoomX := main.ElementFromPath("YY/0").Highlight().InvokePattern
        btnImageZoomX.Invoke()
        Sleep(40)
        SetDialogByValue(zoomx)
    }
    if (zoomy != ""){
        btnImageZoomY := main.ElementFromPath("YY/0q").Highlight().InvokePattern
        btnImageZoomY.Invoke()
        Sleep(40)
        SetDialogByValue(zoomy)
    }
    if (posx != ""){
        btnImagePosX := main.ElementFromPath("YY/0r").Highlight().InvokePattern
        btnImagePosX.Invoke()
        Sleep(40)
        SetDialogByValue(posx)
    }
    if (posy != ""){
        btnImagePosY := main.ElementFromPath("YY/0t").Highlight().InvokePattern
        btnImagePosY.Invoke()
        Sleep(40)
        SetDialogByValue(posy)
    }
    if (angle != ""){
        btnImageRotate := main.ElementFromPath("YY/0v").Highlight().InvokePattern
        btnImageRotate.Invoke()
        Sleep(40)
        SetDialogByValue(angle)
    }    
    setSettings(false)
    Sleep(pt)
}

SetLaserPosX(value){
    SetLaserOutputSize(, , value, )
}

SetLaserPosY(value){
    SetLaserOutputSize(, , , value)
}



CaptureCoord(*) {
    global coords, coordMemo, exe, ww, wh
    WinActivate(exe)
    if (ww > -1 || wh > -1)
        WinGetPos &wx, &wy, &ww, &wh, exe
    ; get mouse position in screen coordinates
    MouseGetPos &mx, &my
    coords.Push({x:mx, y:my})
    color := PixelGetColor(mx, my)
    ; append to memo text
    coordMemo.Value .= mx ", " my ", " color "`r`n"
}

PlayCoords(*) {
    global coords, exe, bpmEdit
    if coords.Length = 0 {
        MsgBox("No coordinates defined.")
        return
    }

    ; activate Pop mode in laserOS (if "P" hotkey was defined by the user)
    send "p"

    ; read BPM and calculate wait time in ms
    bpm := bpmEdit.Value
    if !bpm || bpm <= 0
        bpm := 120 ; fallback
    waitTime := 60000 / bpm  ; time per click in ms

    WinActivate(exe)   
    loop {
        ; start system time
        startTime := A_TickCount
        for idx, c in coords {
            targetTime := startTime + (idx-1) * waitTime
            ; busy-wait until system time reaches targetTime
            while (A_TickCount < targetTime)
                Sleep(1)
            Click('L', c.x, c.y, 1)
        }
    } Until chkLoop.value != 1

    ToolTip("Finished clicking " coords.Length " coords at " bpm " BPM")
    SetTimer () => ToolTip(), -1500
}

PlayStep(*){
    global coords, step
    if (step <= coords.Length){
        Click('L', coords[step].x, coords[step].y, 1)
        step++
    }
    if step > coords.Length
        step := 1
}

StopLoop(*){
    chkLoop.Value := 0
}

ClearCoords(*) {
    global coords, coordMemo
    coords := [] ; reset array
    coordMemo.Value := "" ; clear the memo
    ww := -1
    wh := -1
    if FileExist(dataFile) {
        FileDelete(dataFile)
    }
}

SaveAndExit(*) {
    global coords, bpmEdit, dataFile, ww, wh
    if (coords.Length > 0){
        ; open file for writing
        file := FileOpen(dataFile, "w")
        if !IsObject(file)
            return ExitApp() ; fallback if file can't be written
        if (ww = -1 || wh = -1)
            WinGetPos &wx, &wy, &ww, &wh, exe
        ; write BPM
        file.WriteLine("BPM=" bpmEdit.Value)
        ; write Width
        file.WriteLine("WIDTH=" ww)
        ; write height
        file.WriteLine("HEIGHT=" wh)

        ; write all coordinates
        for c in coords {
            file.WriteLine(c.x "," c.y)
        }

        file.Close()
    }
    ExitApp()
}
