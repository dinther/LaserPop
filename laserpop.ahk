#Requires AutoHotkey v2

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

exe := "ahk_exe laserOS.exe"
exePath := "C:\Program Files\LaserOS\laserOS.exe"

; global array to hold captured coordinates
coords := []
step := 1
ww := 1275
wh := 1275

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
} else {
    PI := 3.14159265359
    count := 0 ;32
    idx := 0
    coords := []
    while (idx < count){
        angle := idx * PI * 2 / count        
        coords.Push({x: floor(1036 + cos(angle) * 185), y: floor(218 + sin(angle) * 185)})
        idx++
    }
}

ShowCoords()

SetLaserOS()

; ensure mouse uses screen coordinates for capture
CoordMode("Mouse", "Client")

; Hotkeys
Hotkey "^a", CaptureCoord
Hotkey "^p", PlayCoords
Hotkey "^s", PlayStep
Hotkey "^l", StopLoop

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
    if !WinExist(exe) {
        Run(exePath)
        WinWait(exe, ,10) ; wait up to 10 seconds for window to appear
    }
    WinActivate(exe)
    WinWait(exe, ,10) ; wait up to 10 seconds for window to appear
    send "p"
    WinMove(0, 0, ww, wh)    
}

CaptureCoord(ThisHotkey) {
    global coords, coordMemo, exe
    WinActivate(exe)
    ; get mouse position in screen coordinates
    MouseGetPos &mx, &my
    ; get LaserOS window position
    ;WinGetPos &wx, &wy, &ww, &wh, exe
    ; convert to relative coordinates
    ;relX := mx - wx
    ;relY := my - wy
    coords.Push({x:mx, y:my})
    ; append to memo text
    coordMemo.Value .= mx ", " my "`r`n"
}

PlayCoords(*) {
    global coords, exe, bpmEdit
    if coords.Length = 0 {
        MsgBox("No coordinates stored.")
        return
    }

    ; read BPM and calculate wait time in ms
    bpm := bpmEdit.Value
    if !bpm || bpm <= 0
        bpm := 120 ; fallback
    waitTime := 60000 / bpm  ; time per click in ms

    WinActivate(exe)

    ; get window position in case it moved
    ;WinGetPos &wx, &wy, &ww, &wh, exe

    
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
    if FileExist(dataFile) {
        FileDelete(dataFile)
    }
}

SaveAndExit(*) {
    global coords, bpmEdit, dataFile
    if (coords.Length > 0){
        ; open file for writing
        file := FileOpen(dataFile, "w")
        if !IsObject(file)
            return ExitApp() ; fallback if file can't be written
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
