#include <GDIPlus.au3>
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>
#include <ScreenCapture.au3>
#include <Clipboard.au3>
#include <File.au3>

Opt("SendCapslockMode",0)
HotKeySet("^q", "stop")

$calibrateX = 0
$calibrateY = 15

Dim $list
$list = _FileListToArray(@WorkingDir)

For $i= 1 To $list[0] Step 1
   If StringRight($list[$i],4) = ".jpg" Then
	  save($list[$i])
   EndIf
Next

Func save($fileName)
   _GDIPlus_Startup()
   $hImage = _GDIPlus_ImageLoadFromFile ($fileName)
   $height = _GDIPlus_ImageGetHeight($hImage)
   $width = _GDIPlus_ImageGetWidth($hImage)

   For $i=$width To $width-66 Step -1
	  For $j=$height To $height-15 Step -1
		 $factor = 0.6
		 $iColor = _GDIPlus_BitmapGetPixel($hImage, $i, $j) ;get current pixel color
		 $iR = $factor*BitShift(BitAND($iColor, 0x00FF0000), 16) ;extract red color channel
		 $iG = $factor*BitShift(BitAND($iColor, 0x0000FF00), 8) ;extract green color channel
		 $iB = $factor*BitAND($iColor, 0x000000FF) ;;extract blue color channel
		 $iColor = "0xFF" & Hex(Int($iR), 2) & Hex(Int($iG), 2) & Hex(Int($iB), 2)
		 _GDIPlus_BitmapSetPixel($hImage,$i,$j,$iColor)
	  Next
   Next

   $hBrush = _GDIPlus_BrushCreateSolid(0xFFFFFFFF)
   $hFormat = _GDIPlus_StringFormatCreate()
   $hFamily = _GDIPlus_FontFamilyCreate("Tahoma")
   $hFont = _GDIPlus_FontCreate($hFamily, 11, 1, 2)

   $hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage)
   For $i=1 To 6 Step 1
	  $tLayout = _GDIPlus_RectFCreate($width-74+$i*10, $height-14, 11, 11)
	  _GDIPlus_GraphicsDrawStringEx($hGraphic, StringMid($fileName,$i,1), $hFont, $tLayout, $hFormat, $hBrush)
   Next

   $tParams = _GDIPlus_ParamInit (1)
   $tData = DllStructCreate("int Quality")
   DllStructSetData($tData, "Quality", 100) ;quality 0-100
   $pData = DllStructGetPtr($tData)
   _GDIPlus_ParamAdd($tParams, $GDIP_EPGQUALITY, 1, $GDIP_EPTLONG, $pData)
   $pParams = DllStructGetPtr($tParams)

   $sCLSID = _GDIPlus_EncodersGetCLSID("jpg")
   _GDIPlus_ImageSaveToFileEx ( $hImage, @WorkingDir & "\tmp" & $fileName, $sCLSID, $pParams)

   _GDIPlus_FontDispose($hFont)
   _GDIPlus_FontFamilyDispose($hFamily)
   _GDIPlus_StringFormatDispose($hFormat)
   _GDIPlus_BrushDispose($hBrush)
   _GDIPlus_GraphicsDispose($hGraphic)
   _GDIPlus_ImageDispose($hImage)
   _GDIPlus_Shutdown()

   FileMove ( @WorkingDir & "\tmp" & $fileName, @WorkingDir & "\" & $fileName ,1 )
EndFunc

Func _DrawRect($x, $y, $w, $h)
    Local $hBitmap, $hGui, $hGraphic, $GuiSizeX = @DesktopWidth, $GuiSizeY = @DesktopHeight
    Local $GuiSize = 70, $hWnd, $hDC, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend, $hPen
    Local $iOpacity = 255
    If $hGuiPrev<>-1 Then
	   GUIDelete($hGuiPrev)
    EndIf
    Local $hGui = GUICreate("L1", $GuiSizeX, $GuiSizeY, -1, -1, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_TOPMOST))
	$hGuiPrev = $hGui

    GUISetState()

    _GDIPlus_Startup()
    $hWnd = _WinAPI_GetDC(0)
    $hDC = _WinAPI_CreateCompatibleDC($hWnd)
    $hBitmap = _WinAPI_CreateCompatibleBitmap($hWnd, $GuiSizeX, $GuiSizeY)
    _WinAPI_SelectObject($hDC, $hBitmap)
    $hGraphic = _GDIPlus_GraphicsCreateFromHDC($hDC)

    $hPen = _GDIPlus_PenCreate(0xFFFF0000, 3)

    $tSize = DllStructCreate($tagSIZE)
    $pSize = DllStructGetPtr($tSize)
    DllStructSetData($tSize, "X", $GuiSizeX)
    DllStructSetData($tSize, "Y", $GuiSizeY)
    $tSource = DllStructCreate($tagPOINT)
    $pSource = DllStructGetPtr($tSource)
    $tBlend = DllStructCreate($tagBLENDFUNCTION)
    $pBlend = DllStructGetPtr($tBlend)
    DllStructSetData($tBlend, "Alpha", $iOpacity)
    DllStructSetData($tBlend, "Format", 1)

    _GDIPlus_GraphicsDrawRect($hGraphic, $x+$calibrateX-1, $y+$calibrateY-1, $w+4, $h+4, $hPen) ; <-- Graphics to layered wimdow.
    _WinAPI_UpdateLayeredWindow($hGui, $hWnd, 0, $pSize, $hDC, $pSource, 0, $pBlend, $ULW_ALPHA)

    _GDIPlus_PenDispose($hPen)
    _GDIPlus_GraphicsDispose($hGraphic)
    _WinAPI_ReleaseDC(0, $hWnd)
    _WinAPI_DeleteObject($hBitmap)
    _WinAPI_DeleteDC($hDC)
    _GDIPlus_Shutdown()
	return $hGui
EndFunc   ;==>_DrawRect
