#Requires AutoHotkey v2.0
#include "UIA-v2\Lib\UIA.ahk"

exe := "ahk_exe laserOS.exe"
exePath := "C:\Program Files\LaserOS\laserOS.exe"
debug := ""

main := ""
elSettings := ""
btnSettings := ""
elLaserOn := ""
btnLaserOn := ""
listPrograms := ""

StartLaserOS(*){
    ;CoordMode("Mouse", "Screen")
    ;CoordMode("Pixel", "Screen")
    if !WinExist(exe) {
        Run(exePath)
        WinWait(exe, ,10) ; wait up to 10 seconds for window to appear
        Sleep 400
    }
    WinActivate(exe)
    WinWait(exe, ,10) ; wait up to 10 seconds for window to appear
    debug.Value .= "Before init`r`n"
    Sleep 400
    InitControls()
    debug.Value .= "After init`r`n"
}

InitControls(*){
    global main, elSettings, btnSettings, elLaserOn, btnLaserOn, listPrograms, btnImageZoomX, btnImageZoomY, btnImagePosX, btnImagePosY, btnImageRotate
    ; Get the element for the laserOS window
    main := UIA.ElementFromHandle(exe)

    elSettings := main.ElementFromPath("Y0/").Highlight()
    btnSettings := elSettings.InvokePattern
    ;btnSettings.Invoke()

    elLaserOn := main.ElementFromPath("Y0q").Highlight()
    btnLaserOn := elLaserOn.InvokePattern
    ;btnLaserOn.Invoke()

    listPrograms := main.ElementFromPath("YYu").Highlight()
    ;listPrograms.Invoke()
   
}

ToggleLaser(*){
    btnLaserOn.Invoke()
}

GetLaser(*){
    global main, elLaserOn
    color := PixelGetColor(elLaserOn.Location.x - main.Location.x + 30, elLaserOn.Location.y - main.location.y + 16) ;+ 0
    ;MsgBox(elLaserOn.Location.x+30 ", " elLaserOn.Location.y+16 ", " color)
    return color + 0 < 1048575 ;fffff
}

SetLaser(state := ""){
    if (GetLaser() != state){
        ToggleLaser()
    }
}

ToggleSettings(*){
    global btnSettings
    btnSettings.Invoke()
}

SetSettings(state := ""){
    if (GetSettings() != state){
        ToggleSettings()
    }
}

GetSettings(*){
    global main, elSettings
    x := elSettings.Location.x - main.Location.x + 77
    y := elSettings.Location.y - main.location.y + 12
    color := PixelGetColor(x, y) ;+ 0
    ;MsgBox(x ", " y ", " color)
    return color + 0 < 1048575 ;fffff
}

setProjectorSetup(*){
    global main, listPrograms
    x := listPrograms.Location.x - main.location.x + Floor(listPrograms.Location.w / 2)
    y := listPrograms.Location.y - main.location.y + 17 ; listItem is 35.3 tall
    Click('L', x, y, 1)
}

BurnImportImage(FileName, BurnTime){
    global main
    send "b"
    Sleep(200)
    elImportImage := main.ElementFromPath("YY/Y/0").Highlight()
    btnImportImage := elImportImage.InvokePattern
    btnImportImage.Invoke()
    Sleep(200)
    SendText(FileName)
    Sleep(200)
    Send("{Enter}")
    Sleep(1000) ; Wait for svg data to load
    StartBurn()
    Sleep(BurnTime)
    SetLaser(false)
}

StartBurn(*){
    global main
    SetLaser(true)
    elBurnStart := main.ElementFromPath("YY/Y/0s").Highlight()
    btnBurnStart := elBurnStart.InvokePattern
    btnBurnStart.Invoke()
}

; sets slider value on the current page
SetDialogByValue(value){
    global main
    pt := 200
    main.ElementFromPath("XG").SetFocus()
    Send("{Backspace}{Backspace}{Backspace}{Backspace}") ; clear value
    Sleep(pt)
    SendText("" value)
    Sleep(pt)
    Click('R', 116, 195, 1) ; close dialog
    Sleep(pt)
}