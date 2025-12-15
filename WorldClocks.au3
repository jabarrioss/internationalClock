#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=clock.ico
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <GDIPlus.au3>
#include <Array.au3>
#include <Date.au3>

; ===============================================================================
; World Clocks - Multi-timezone Desktop Clock Application
; Similar to Windows 7 Gadget
; ===============================================================================

Global $aClocks[1][12] ; Array to store clock instances
; [n][0] = GUI Handle
; [n][1] = Type (0=Digital, 1=Analog)
; [n][2] = Timezone offset
; [n][3] = City name
; [n][4] = X position
; [n][5] = Y position
; [n][6] = Graphics context (or Label control for digital)
; [n][7] = Bitmap handle (or Label control for time)
; [n][8] = BackBuffer handle (or Label control for seconds)
; [n][9] = Skin style
; [n][10] = Pic control for analog
; [n][11] = City label control

Global $nClockCount = 0
Global $sConfigFile = @ScriptDir & "\clocks.ini"
Global $hMainMenu
Global $idTrayDigital, $idTrayAnalog, $idTrayExit

; Initialize GDI+
_GDIPlus_Startup()

; Load saved clocks or create default
LoadClocks()

; Create system tray menu
CreateTrayMenu()

; Main loop
AdlibRegister("UpdateAllClocks", 1000) ; Update every second

While 1
    $nMsg = GUIGetMsg()
    $trayMsg = TrayGetMsg()
    
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            ExitApplication()
    EndSwitch
    
    Switch $trayMsg
        Case $idTrayDigital
            AddDigitalClock()
        Case $idTrayAnalog
            AddAnalogClock()
        Case $idTrayExit
            ExitApplication()
    EndSwitch
    
    Sleep(10)
WEnd

; ===============================================================================
; Functions
; ===============================================================================

Func CreateTrayMenu()
    Opt("TrayMenuMode", 1) ; Show tray menu items only
    TraySetIcon("shell32.dll", 22) ; Clock icon
    TraySetToolTip("World Clocks")
    
    $idTrayDigital = TrayCreateItem("Add Digital Clock")
    $idTrayAnalog = TrayCreateItem("Add Analog Clock")
    TrayCreateItem("")
    $idTrayExit = TrayCreateItem("Exit")
    
    TraySetState(1) ; Show tray icon
EndFunc

Func AddDigitalClock()
    Local $sCity = InputBox("New Digital Clock", "Enter city name:", "New York")
    If @error Then Return
    
    Local $fOffset = Number(InputBox("Timezone Offset", "Enter timezone offset from UTC (e.g., -5 for EST, +1 for CET):", "-5"))
    If @error Then Return
    
    Local $iSkin = Number(InputBox("Skin Style", "Choose skin (0=Modern Dark, 1=Classic, 2=Colorful):", "0"))
    If @error Or $iSkin < 0 Or $iSkin > 2 Then $iSkin = 0
    
    CreateDigitalClock($sCity, $fOffset, -1, -1, $iSkin)
    SaveClocks()
EndFunc

Func AddAnalogClock()
    Local $sCity = InputBox("New Analog Clock", "Enter city name:", "London")
    If @error Then Return
    
    Local $fOffset = Number(InputBox("Timezone Offset", "Enter timezone offset from UTC (e.g., 0 for GMT, +2 for CEST):", "0"))
    If @error Then Return
    
    Local $iSkin = Number(InputBox("Skin Style", "Choose skin (0=Modern, 1=Classic, 2=Elegant):", "0"))
    If @error Or $iSkin < 0 Or $iSkin > 2 Then $iSkin = 0
    
    CreateAnalogClock($sCity, $fOffset, -1, -1, $iSkin)
    SaveClocks()
EndFunc

Func CreateDigitalClock($sCity, $fOffset, $iX = -1, $iY = -1, $iSkin = 0)
    Local $iWidth = 280
    Local $iHeight = 120
    
    ; Set default position if not specified
    If $iX = -1 Then $iX = 100 + ($nClockCount * 50)
    If $iY = -1 Then $iY = 100 + ($nClockCount * 50)
    
    ; Choose colors based on skin
    Local $iBackColor, $iTextColor, $iAccentColor
    Switch $iSkin
        Case 0 ; Modern Dark
            $iBackColor = 0x1E1E1E
            $iTextColor = 0xFFFFFF
            $iAccentColor = 0x0078D4
        Case 1 ; Classic
            $iBackColor = 0xF0F0F0
            $iTextColor = 0x000000
            $iAccentColor = 0x003366
        Case 2 ; Colorful
            $iBackColor = 0x2C3E50
            $iTextColor = 0xECF0F1
            $iAccentColor = 0xE74C3C
    EndSwitch
    
    ; Create GUI
    Local $hGUI = GUICreate($sCity, $iWidth, $iHeight, $iX, $iY, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
    GUISetBkColor($iBackColor, $hGUI)
    
    ; Create city label
    Local $hLabelCity = GUICtrlCreateLabel($sCity, 10, 10, $iWidth - 20, 20, $SS_CENTER)
    GUICtrlSetBkColor($hLabelCity, $iBackColor)
    GUICtrlSetColor($hLabelCity, $iAccentColor)
    GUICtrlSetFont($hLabelCity, 11, 600, 0, "Segoe UI")
    
    ; Create time label
    Local $hLabelTime = GUICtrlCreateLabel("00:00", 10, 40, $iWidth - 20, 50, $SS_CENTER)
    GUICtrlSetBkColor($hLabelTime, $iBackColor)
    GUICtrlSetColor($hLabelTime, $iTextColor)
    GUICtrlSetFont($hLabelTime, 36, 700, 0, "Consolas")
    
    ; Create seconds label
    Local $hLabelSeconds = GUICtrlCreateLabel(":00", 10, 85, $iWidth - 20, 25, $SS_CENTER)
    GUICtrlSetBkColor($hLabelSeconds, $iBackColor)
    GUICtrlSetColor($hLabelSeconds, $iTextColor)
    GUICtrlSetFont($hLabelSeconds, 14, 400, 0, "Consolas")
    
    ; Store clock data
    ReDim $aClocks[$nClockCount + 1][12]
    $aClocks[$nClockCount][0] = $hGUI
    $aClocks[$nClockCount][1] = 0 ; Digital
    $aClocks[$nClockCount][2] = $fOffset
    $aClocks[$nClockCount][3] = $sCity
    $aClocks[$nClockCount][4] = $iX
    $aClocks[$nClockCount][5] = $iY
    $aClocks[$nClockCount][6] = $hLabelCity
    $aClocks[$nClockCount][7] = $hLabelTime
    $aClocks[$nClockCount][8] = $hLabelSeconds
    $aClocks[$nClockCount][9] = $iSkin
    $aClocks[$nClockCount][10] = 0
    $aClocks[$nClockCount][11] = 0
    
    $nClockCount += 1
    
    ; Show GUI
    GUISetState(@SW_SHOW, $hGUI)
    
    ; Enable dragging and right-click menu
    GUIRegisterMsg($WM_LBUTTONDOWN, "WM_LBUTTONDOWN")
    GUIRegisterMsg($WM_RBUTTONDOWN, "WM_RBUTTONDOWN")
    
    Return $hGUI
EndFunc

Func CreateAnalogClock($sCity, $fOffset, $iX = -1, $iY = -1, $iSkin = 0)
    Local $iSize = 200
    
    ; Set default position if not specified
    If $iX = -1 Then $iX = 100 + ($nClockCount * 50)
    If $iY = -1 Then $iY = 100 + ($nClockCount * 50)
    
    ; Choose colors based on skin
    Local $iBackColor
    Switch $iSkin
        Case 0 ; Modern
            $iBackColor = 0x1E1E1E
        Case 1 ; Classic
            $iBackColor = 0xF5F5F5
        Case 2 ; Elegant
            $iBackColor = 0x000000
    EndSwitch
    
    ; Create GUI
    Local $hGUI = GUICreate($sCity, $iSize, $iSize + 30, $iX, $iY, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
    GUISetBkColor($iBackColor, $hGUI)
    
    ; Create pic control for analog clock
    Local $hPic = GUICtrlCreatePic("", 0, 0, $iSize, $iSize)
    
    ; Create city label
    Local $hLabelCity = GUICtrlCreateLabel($sCity, 0, $iSize, $iSize, 30, $SS_CENTER)
    GUICtrlSetBkColor($hLabelCity, $iBackColor)
    GUICtrlSetColor($hLabelCity, 0xFFFFFF)
    GUICtrlSetFont($hLabelCity, 10, 600, 0, "Segoe UI")
    
    ; Create graphics context
    Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGUI)
    Local $hBitmap = _GDIPlus_BitmapCreateFromGraphics($iSize, $iSize + 30, $hGraphics)
    Local $hBackBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)
    
    _GDIPlus_GraphicsSetSmoothingMode($hBackBuffer, 2)
    _GDIPlus_GraphicsSetTextRenderingHint($hBackBuffer, 4)
    
    ; Store clock data
    ReDim $aClocks[$nClockCount + 1][12]
    $aClocks[$nClockCount][0] = $hGUI
    $aClocks[$nClockCount][1] = 1 ; Analog
    $aClocks[$nClockCount][2] = $fOffset
    $aClocks[$nClockCount][3] = $sCity
    $aClocks[$nClockCount][4] = $iX
    $aClocks[$nClockCount][5] = $iY
    $aClocks[$nClockCount][6] = $hGraphics
    $aClocks[$nClockCount][7] = $hBitmap
    $aClocks[$nClockCount][8] = $hBackBuffer
    $aClocks[$nClockCount][9] = $iSkin
    $aClocks[$nClockCount][10] = $hPic
    $aClocks[$nClockCount][11] = $hLabelCity
    
    $nClockCount += 1
    
    ; Show GUI
    GUISetState(@SW_SHOW, $hGUI)
    
    ; Enable dragging and right-click menu
    GUIRegisterMsg($WM_LBUTTONDOWN, "WM_LBUTTONDOWN")
    GUIRegisterMsg($WM_RBUTTONDOWN, "WM_RBUTTONDOWN")
    
    Return $hGUI
EndFunc

Func UpdateAllClocks()
    For $i = 0 To $nClockCount - 1
        If $aClocks[$i][1] = 0 Then
            UpdateDigitalClock($i)
        Else
            UpdateAnalogClock($i)
        EndIf
    Next
EndFunc

Func UpdateDigitalClock($iIndex)
    Local $hLabelTime = $aClocks[$iIndex][7]
    Local $hLabelSeconds = $aClocks[$iIndex][8]
    Local $fOffset = $aClocks[$iIndex][2]
    Local $hGUI = $aClocks[$iIndex][0]
    
    ; Get current UTC time
    Local $aTime = _Date_Time_GetSystemTime()
    Local $iHour = DllStructGetData($aTime, "Hour")
    Local $iMinute = DllStructGetData($aTime, "Minute")
    Local $iSecond = DllStructGetData($aTime, "Second")
    
    ; Apply timezone offset
    $iHour = $iHour + $fOffset
    
    ; Handle hour overflow
    While $iHour < 0
        $iHour += 24
    WEnd
    While $iHour >= 24
        $iHour -= 24
    WEnd
    
    ; Format time strings
    Local $sTimeShort = StringFormat("%02d:%02d", $iHour, $iMinute)
    Local $sSeconds = StringFormat(":%02d", $iSecond)
    
    ; Update labels
    GUICtrlSetData($hLabelTime, $sTimeShort)
    GUICtrlSetData($hLabelSeconds, $sSeconds)
EndFunc

Func UpdateAnalogClock($iIndex)
    Local $hBackBuffer = $aClocks[$iIndex][8]
    Local $hGraphics = $aClocks[$iIndex][6]
    Local $hBitmap = $aClocks[$iIndex][7]
    Local $fOffset = $aClocks[$iIndex][2]
    Local $sCity = $aClocks[$iIndex][3]
    Local $iSkin = $aClocks[$iIndex][9]
    Local $hGUI = $aClocks[$iIndex][0]
    
    ; Get window size
    Local $aWinPos = WinGetPos($hGUI)
    Local $iWidth = $aWinPos[2]
    Local $iHeight = $aWinPos[3]
    Local $iClockSize = $iWidth
    Local $iCenterX = $iClockSize / 2
    Local $iCenterY = $iClockSize / 2
    Local $iRadius = ($iClockSize / 2) - 10
    
    ; Get current UTC time
    Local $aTime = _Date_Time_GetSystemTime()
    Local $iHour = DllStructGetData($aTime, "Hour")
    Local $iMinute = DllStructGetData($aTime, "Minute")
    Local $iSecond = DllStructGetData($aTime, "Second")
    
    ; Apply timezone offset
    $iHour = $iHour + $fOffset
    
    ; Handle hour overflow
    While $iHour < 0
        $iHour += 24
    WEnd
    While $iHour >= 24
        $iHour -= 24
    WEnd
    
    ; Choose colors based on skin
    Local $iBackColor, $iFaceColor, $iHandColor, $iAccentColor
    Switch $iSkin
        Case 0 ; Modern
            $iBackColor = 0xFF1E1E1E
            $iFaceColor = 0xFF2D2D2D
            $iHandColor = 0xFFFFFFFF
            $iAccentColor = 0xFF0078D4
        Case 1 ; Classic
            $iBackColor = 0xFFF5F5F5
            $iFaceColor = 0xFFFFFFFF
            $iHandColor = 0xFF000000
            $iAccentColor = 0xFF8B4513
        Case 2 ; Elegant
            $iBackColor = 0xFF000000
            $iFaceColor = 0xFF1A1A1A
            $iHandColor = 0xFFFFD700
            $iAccentColor = 0xFFFFD700
    EndSwitch
    
    ; Clear background
    _GDIPlus_GraphicsClear($hBackBuffer, $iBackColor)
    
    ; Draw clock face
    Local $hBrushFace = _GDIPlus_BrushCreateSolid($iFaceColor)
    _GDIPlus_GraphicsFillEllipse($hBackBuffer, 5, 5, $iClockSize - 10, $iClockSize - 10, $hBrushFace)
    _GDIPlus_BrushDispose($hBrushFace)
    
    ; Draw clock border
    Local $hPenBorder = _GDIPlus_PenCreate($iAccentColor, 3)
    _GDIPlus_GraphicsDrawEllipse($hBackBuffer, 5, 5, $iClockSize - 10, $iClockSize - 10, $hPenBorder)
    _GDIPlus_PenDispose($hPenBorder)
    
    ; Draw hour markers
    Local $hPenMarker = _GDIPlus_PenCreate($iHandColor, 2)
    For $i = 0 To 11
        Local $fAngle = ($i * 30) * 3.14159265358979 / 180
        Local $x1 = $iCenterX + ($iRadius - 15) * Sin($fAngle)
        Local $y1 = $iCenterY - ($iRadius - 15) * Cos($fAngle)
        Local $x2 = $iCenterX + $iRadius * Sin($fAngle)
        Local $y2 = $iCenterY - $iRadius * Cos($fAngle)
        _GDIPlus_GraphicsDrawLine($hBackBuffer, $x1, $y1, $x2, $y2, $hPenMarker)
    Next
    _GDIPlus_PenDispose($hPenMarker)
    
    ; Calculate angles
    Local $fSecondAngle = ($iSecond * 6) * 3.14159265358979 / 180
    Local $fMinuteAngle = (($iMinute + $iSecond / 60) * 6) * 3.14159265358979 / 180
    Local $fHourAngle = ((Mod($iHour, 12) + $iMinute / 60) * 30) * 3.14159265358979 / 180
    
    ; Draw hour hand
    Local $hPenHour = _GDIPlus_PenCreate($iHandColor, 6)
    Local $xHour = $iCenterX + ($iRadius * 0.5) * Sin($fHourAngle)
    Local $yHour = $iCenterY - ($iRadius * 0.5) * Cos($fHourAngle)
    _GDIPlus_GraphicsDrawLine($hBackBuffer, $iCenterX, $iCenterY, $xHour, $yHour, $hPenHour)
    _GDIPlus_PenDispose($hPenHour)
    
    ; Draw minute hand
    Local $hPenMinute = _GDIPlus_PenCreate($iHandColor, 4)
    Local $xMinute = $iCenterX + ($iRadius * 0.7) * Sin($fMinuteAngle)
    Local $yMinute = $iCenterY - ($iRadius * 0.7) * Cos($fMinuteAngle)
    _GDIPlus_GraphicsDrawLine($hBackBuffer, $iCenterX, $iCenterY, $xMinute, $yMinute, $hPenMinute)
    _GDIPlus_PenDispose($hPenMinute)
    
    ; Draw second hand
    Local $hPenSecond = _GDIPlus_PenCreate($iAccentColor, 2)
    Local $xSecond = $iCenterX + ($iRadius * 0.8) * Sin($fSecondAngle)
    Local $ySecond = $iCenterY - ($iRadius * 0.8) * Cos($fSecondAngle)
    _GDIPlus_GraphicsDrawLine($hBackBuffer, $iCenterX, $iCenterY, $xSecond, $ySecond, $hPenSecond)
    _GDIPlus_PenDispose($hPenSecond)
    
    ; Draw center circle
    Local $hBrushCenter = _GDIPlus_BrushCreateSolid($iAccentColor)
    _GDIPlus_GraphicsFillEllipse($hBackBuffer, $iCenterX - 5, $iCenterY - 5, 10, 10, $hBrushCenter)
    _GDIPlus_BrushDispose($hBrushCenter)
    
    ; Draw city name
    Local $hBrushCity = _GDIPlus_BrushCreateSolid($iHandColor)
    Local $hFormatCity = _GDIPlus_StringFormatCreate()
    Local $hFamilyCity = _GDIPlus_FontFamilyCreate("Segoe UI")
    Local $hFontCity = _GDIPlus_FontCreate($hFamilyCity, 10, 1)
    Local $tLayoutCity = _GDIPlus_RectFCreate(0, $iClockSize, $iWidth, 30)
    _GDIPlus_StringFormatSetAlign($hFormatCity, 1) ; Center
    
    _GDIPlus_GraphicsDrawStringEx($hBackBuffer, $sCity, $hFontCity, $tLayoutCity, $hFormatCity, $hBrushCity)
    
    ; Render to screen
    _GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, 0, 0)
    
    ; Cleanup
    _GDIPlus_FontDispose($hFontCity)
    _GDIPlus_FontFamilyDispose($hFamilyCity)
    _GDIPlus_StringFormatDispose($hFormatCity)
    _GDIPlus_BrushDispose($hBrushCity)
EndFunc

Func WM_LBUTTONDOWN($hWnd, $iMsg, $wParam, $lParam)
    ; Enable window dragging
    DllCall("user32.dll", "long", "SendMessage", "hwnd", $hWnd, "int", 0xA1, "int", 2, "int", 0)
    
    ; Update position in config
    For $i = 0 To $nClockCount - 1
        If $aClocks[$i][0] = $hWnd Then
            Local $aPos = WinGetPos($hWnd)
            $aClocks[$i][4] = $aPos[0]
            $aClocks[$i][5] = $aPos[1]
            SaveClocks()
            ExitLoop
        EndIf
    Next
EndFunc

Func WM_RBUTTONDOWN($hWnd, $iMsg, $wParam, $lParam)
    ; Show context menu for clock
    For $i = 0 To $nClockCount - 1
        If $aClocks[$i][0] = $hWnd Then
            ShowClockMenu($i)
            ExitLoop
        EndIf
    Next
EndFunc

Func ShowClockMenu($iIndex)
    Local $hMenu = _GUICtrlMenu_CreatePopup()
    _GUICtrlMenu_InsertMenuItem($hMenu, 0, "Change Timezone", 1001)
    _GUICtrlMenu_InsertMenuItem($hMenu, 1, "Change Skin", 1002)
    _GUICtrlMenu_InsertMenuItem($hMenu, 2, "Remove Clock", 1003)
    
    Local $aPos = MouseGetPos()
    Local $iRet = _GUICtrlMenu_TrackPopupMenu($hMenu, $aClocks[$iIndex][0], $aPos[0], $aPos[1], 1, 1, 2)
    
    Switch $iRet
        Case 1001 ; Change Timezone
            Local $fNewOffset = Number(InputBox("Change Timezone", "Enter new timezone offset from UTC:", $aClocks[$iIndex][2]))
            If Not @error Then
                $aClocks[$iIndex][2] = $fNewOffset
                SaveClocks()
            EndIf
        Case 1002 ; Change Skin
            Local $iNewSkin = Number(InputBox("Change Skin", "Choose skin (0, 1, or 2):", $aClocks[$iIndex][9]))
            If Not @error And $iNewSkin >= 0 And $iNewSkin <= 2 Then
                $aClocks[$iIndex][9] = $iNewSkin
                SaveClocks()
            EndIf
        Case 1003 ; Remove Clock
            If MsgBox(4, "Confirm", "Remove this clock?") = 6 Then
                RemoveClock($iIndex)
            EndIf
    EndSwitch
    
    _GUICtrlMenu_DestroyMenu($hMenu)
EndFunc

Func RemoveClock($iIndex)
    ; Cleanup GDI+ resources only for analog clocks
    If $aClocks[$iIndex][1] = 1 Then
        _GDIPlus_GraphicsDispose($aClocks[$iIndex][8])
        _GDIPlus_BitmapDispose($aClocks[$iIndex][7])
        _GDIPlus_GraphicsDispose($aClocks[$iIndex][6])
    EndIf
    
    ; Destroy window
    GUIDelete($aClocks[$iIndex][0])
    
    ; Remove from array
    For $i = $iIndex To $nClockCount - 2
        For $j = 0 To 11
            $aClocks[$i][$j] = $aClocks[$i + 1][$j]
        Next
    Next
    
    $nClockCount -= 1
    ReDim $aClocks[$nClockCount][12]
    
    SaveClocks()
EndFunc

Func SaveClocks()
    ; Delete old config
    FileDelete($sConfigFile)
    
    ; Save each clock
    IniWrite($sConfigFile, "General", "Count", $nClockCount)
    
    For $i = 0 To $nClockCount - 1
        IniWrite($sConfigFile, "Clock" & $i, "Type", $aClocks[$i][1])
        IniWrite($sConfigFile, "Clock" & $i, "Offset", $aClocks[$i][2])
        IniWrite($sConfigFile, "Clock" & $i, "City", $aClocks[$i][3])
        IniWrite($sConfigFile, "Clock" & $i, "X", $aClocks[$i][4])
        IniWrite($sConfigFile, "Clock" & $i, "Y", $aClocks[$i][5])
        IniWrite($sConfigFile, "Clock" & $i, "Skin", $aClocks[$i][9])
    Next
EndFunc

Func LoadClocks()
    If Not FileExists($sConfigFile) Then
        ; Create default clocks
        CreateDigitalClock("New York", -5, 100, 100, 0)
        CreateAnalogClock("London", 0, 400, 100, 0)
        SaveClocks()
        Return
    EndIf
    
    Local $iCount = Int(IniRead($sConfigFile, "General", "Count", 0))
    
    For $i = 0 To $iCount - 1
        Local $iType = Int(IniRead($sConfigFile, "Clock" & $i, "Type", 0))
        Local $fOffset = Number(IniRead($sConfigFile, "Clock" & $i, "Offset", 0))
        Local $sCity = IniRead($sConfigFile, "Clock" & $i, "City", "City")
        Local $iX = Int(IniRead($sConfigFile, "Clock" & $i, "X", 100))
        Local $iY = Int(IniRead($sConfigFile, "Clock" & $i, "Y", 100))
        Local $iSkin = Int(IniRead($sConfigFile, "Clock" & $i, "Skin", 0))
        
        If $iType = 0 Then
            CreateDigitalClock($sCity, $fOffset, $iX, $iY, $iSkin)
        Else
            CreateAnalogClock($sCity, $fOffset, $iX, $iY, $iSkin)
        EndIf
    Next
EndFunc

Func ExitApplication()
    SaveClocks()
    
    ; Cleanup all clocks
    For $i = 0 To $nClockCount - 1
        ; Only dispose GDI+ resources for analog clocks
        If $aClocks[$i][1] = 1 Then
            _GDIPlus_GraphicsDispose($aClocks[$i][8])
            _GDIPlus_BitmapDispose($aClocks[$i][7])
            _GDIPlus_GraphicsDispose($aClocks[$i][6])
        EndIf
        GUIDelete($aClocks[$i][0])
    Next
    
    _GDIPlus_Shutdown()
    Exit
EndFunc

#include <GuiMenu.au3>
