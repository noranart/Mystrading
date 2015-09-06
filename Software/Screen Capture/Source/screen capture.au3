#include <GDIPlus.au3>
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>
#include <ScreenCapture.au3>
#include <Clipboard.au3>
#include <File.au3>

Opt("WinWaitDelay", 0)
Opt("SendCapslockMode",0)
HotKeySet("^q", "stop")
;HotKeySet("!q", "stop")


$delay = 250
$calibrateX = 0
$calibrateY = 15

$traytipDelay = 1000
Dim $pos[2]				;x,y

$path = "option.ini"
$hFile = ""
$mode = 0
$size = 0
$save = 0
$dirs = 0
$idPrefix = 0
$idNum = 0
$dbDirs = 0
$hGuiPrev = -1
$hBitmap = -1
tip("")
openFile(1)
$link = ""

$oExcel = 0
$oExcelHandle = 0

excelRefresh()
While 1
   If  _IsPressed("14") And _IsPressed("11") Then		;12: alt, 11: ctrl
	  Send("{CapsLock off}{CapsLock off}{CapsLock off}")
	  If $hGuiPrev<>-1 Then
		 GUIDelete($hGuiPrev)
	  EndIf
	  RunWait("Util\option.exe")
	  ;refresh
	  openFile()
	  Sleep($delay)
	  excelRefresh()
   ElseIf _IsPressed("14") And _IsPressed("10") Then
	  Send("{CapsLock off}{CapsLock off}{CapsLock off}")
	  If $hBitmap<>-1 Then
		 If $oExcelHandle<>0 Then
			copyLink()
		 EndIf
		 $hBitmap = _ScreenCapture_Capture("", $posx,$posy,$posx+$size,$posy+$size,false)
		 _ClipBoard_Open(0)
		 _ClipBoard_Empty()
		 _ClipBoard_SetDataEx($hBitmap, $CF_BITMAP)
		 _ClipBoard_Close()
		 save()
		 _WinAPI_DeleteObject($hBitmap)
	  EndIf
   ElseIf _IsPressed("14") Then
	  $active = WinGetHandle("[ACTIVE]")
	  Send("{CapsLock off}{CapsLock off}{CapsLock off}")
	  $pos = MouseGetPos()

	  If $mode = 0 Then
		 $posx = MouseGetPos(0)
		 $posy = MouseGetPos(1)
	  ElseIf $mode = 1 Then
		 $posx = MouseGetPos(0)-$size/2
		 $posy = MouseGetPos(1)-$size/2
	  EndIf

	  If $posx<0 Then
		 $posx = 0
	  ElseIf $posx+$size>@DesktopWidth Then
		 $posx = @DesktopWidth-$size
	  EndIf
	  If $posy<0 Then
		 $posy = 0
	  ElseIf $posy+$size>@DesktopHeight Then
		 $posy = @DesktopHeight-$size
	  EndIf

	  _drawRect($posx,$posy,$size,$size)

	  $hBitmap = _ScreenCapture_Capture("", $posx,$posy,$posx+$size,$posy+$size,false)
	  _ClipBoard_Open(0)
	  _ClipBoard_Empty()
	  _ClipBoard_SetDataEx($hBitmap, $CF_BITMAP)
	  _ClipBoard_Close()
	  _WinAPI_DeleteObject($hBitmap)
	  If $save = 1 Then
		 save()
	  EndIf

	  WinActivate($active)
	  WinWaitActive($active,"",500)
	  ;Sleep($delay)
   ElseIf _IsPressed("1B") Then
	  GUIDelete($hGuiPrev)
   EndIf
   Sleep(50)
WEnd

Func save()
   _GDIPlus_Startup()
   $hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	For $i=$size To $size-66 Step -1
	  For $j=$size To $size-15 Step -1
		 $factor = 0.6
		 $iColor = _GDIPlus_BitmapGetPixel($hImage, $i, $j) ;get current pixel color
		 $iR = $factor*BitShift(BitAND($iColor, 0x00FF0000), 16) ;extract red color channel
		 $iG = $factor*BitShift(BitAND($iColor, 0x0000FF00), 8) ;extract green color channel
		 $iB = $factor*BitAND($iColor, 0x000000FF) ;;extract blue color channel
		 $iColor = "0xFF" & Hex(Int($iR), 2) & Hex(Int($iG), 2) & Hex(Int($iB), 2)
		 _GDIPlus_BitmapSetPixel($hImage,$i,$j,$iColor)
	  Next
   Next

   $fileName = $idPrefix & $idNum
   $idNum = StringFormat("%04s",$idNum + 1)
   _FileWriteToLine($path,5,"id="& $idPrefix & $idNum,1)

   $hBrush = _GDIPlus_BrushCreateSolid(0xFFFFFFFF)
   $hFormat = _GDIPlus_StringFormatCreate()
   $hFamily = _GDIPlus_FontFamilyCreate("Tahoma")
   $hFont = _GDIPlus_FontCreate($hFamily, 11, 1, 2)

   $hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage)
   For $i=1 To 6 Step 1
	  $tLayout = _GDIPlus_RectFCreate($size-74+$i*10, $size-14, 11, 11)
	  _GDIPlus_GraphicsDrawStringEx($hGraphic, StringMid($fileName,$i,1), $hFont, $tLayout, $hFormat, $hBrush)
   Next
   TrayTip("",$fileName,1000)
   ;_GDIPlus_ImageSaveToFile($hImage,$dirs & $fileName&".png")


   $tParams = _GDIPlus_ParamInit (1)
   $tData = DllStructCreate("int Quality")
   DllStructSetData($tData, "Quality", 100) ;quality 0-100
   $pData = DllStructGetPtr($tData)
   _GDIPlus_ParamAdd($tParams, $GDIP_EPGQUALITY, 1, $GDIP_EPTLONG, $pData)
   $pParams = DllStructGetPtr($tParams)

   $sCLSID = _GDIPlus_EncodersGetCLSID("jpg")
   _GDIPlus_ImageSaveToFileEx ( $hImage, $dirs & $fileName&".jpg", $sCLSID,$pParams)

   _GDIPlus_FontDispose($hFont)
   _GDIPlus_FontFamilyDispose($hFamily)
   _GDIPlus_StringFormatDispose($hFormat)
   _GDIPlus_BrushDispose($hBrush)
   _GDIPlus_GraphicsDispose($hGraphic)
   _GDIPlus_ImageDispose($hImage)
   _GDIPlus_Shutdown()

   Sleep(100)
   Send("{CapsLock off}{CapsLock off}{CapsLock off}")
EndFunc

Func openFile($first=0)
   FileClose($hFile)
   $hFile = FileOpen($path)
   If $hFile = -1 Then
	  FileWrite($path,"mode=1"&@CRLF&"size=400"&@CRLF&"save=1"&@CRLF&"dirs=D:\Image\"&@CRLF&"id=HH0001"&@CRLF)
	  $hFile = FileOpen($path)
   EndIf
   $mode = StringTrimLeft(FileReadLine($hFile,1),5)
   $size = StringTrimLeft(FileReadLine($hFile,2),5)
   $save = StringTrimLeft(FileReadLine($hFile,3),5)
   $dirs = StringTrimLeft(FileReadLine($hFile,4),5)
   $id = StringTrimLeft(FileReadLine($hFile,5),3)
   $idPrefix = StringLeft($id,2)
   $dbDirs = StringTrimLeft(FileReadLine($hFile,6),3)
   If DirGetSize($dbDirs)<0 Then
	  $input = InputBox("Database Picture Directory"," ",$dbDirs,"",80,10,MouseGetPos(0),MouseGetPos(1))
	  If $input<>"" Then
		 If StringRight($input,1)<>"\" Then
			$input = $input&"\"
		 EndIf
		 _FileWriteToLine($path,6,"db="&$input,1)
		 $dbDirs = $input
	  Else
		 Exit
	  EndIf
   EndIf

   If $first = 1 Then
	  $id = $idPrefix & searchLatestId()
   EndIf
   _FileWriteToLine($path,5,"id="& $id,1)
   $idNum = StringTrimLeft($id,2)

   If DirGetSize($dirs) = -1 Then
	  DirCreate($dirs)
   EndIf
   FileClose($hFile)
EndFunc

Func searchLatestId()
   Dim $list
   $list = _FileListToArray($dbDirs&$idPrefix)
   $latestId = 0
   If Not(@error) Then
	  For $i=1 To $list[0] Step 1
		 If StringLeft($list[$i],2)=$idPrefix Then
			$fileNumber = Number(StringMid($list[$i],3,4))
			If $fileNumber>$latestId Then
			   $latestId = $fileNumber
			EndIf
		 EndIf
	  Next
   EndIf
   Return StringFormat("%04s",$latestId+1)
EndFunc

Func tip($msg)
   TrayTip("",$msg, $traytipDelay)
EndFunc

Func stop()
   Exit
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

    $hPen = 0
	If $oExcelHandle<>0 Then
	  $hPen = _GDIPlus_PenCreate(0xFFFF0000, 3)
    Else
	  $hPen = _GDIPlus_PenCreate(0xFF0000FF, 3)
    EndIf

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

 Func excelRefresh()
   $oExcelHandle = 0
   $oExcel = ObjGet("", "Excel.Application") ; Get an existing Excel Object
   If Not(@error) Then
	  For $oWB in $oExcel.Workbooks
		 If StringLeft($oWB.Name,2)=$idPrefix Then
			$oExcelHandle = $oWB
			ExitLoop
		 EndIf
	  Next
   EndIf
EndFunc

Func copyLink()
   Send("!d")
   Do
	  Send("^c")
	  Sleep($delay)
   Until ClipGet()<>""
   $link = ClipGet()

   ;;;;; insert hyperlink [cache] ;;;;;
   $value = $oExcelHandle.Sheets(2).Cells($idNum,1).Value
   If $value = "" Then
	  $row = $oExcelHandle.Sheets(2).Cells(1,2).Value
	  $oExcelHandle.Sheets(1).Cells($row+1,1).Value = $idPrefix&$idNum
	  insertHyperlink($row+1)
   Else
	  insertHyperlink($value)
   EndIf
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   #cs
   ;;;;; insert hyperlink [search];;;;;
   $skip = 0
   $tmp = $oExcelHandle.ActiveSheet.Cells($idNum+1,1).Value
   $value = Int(StringRight($tmp,4))
   $i = $value
   If $tmp="" Then					;greater number
	  $i = $idNum
	  Do
		 $i = $i-1
		 $tmp = $oExcelHandle.ActiveSheet.Cells($i,1).Value
	  Until $tmp<>""
	  If $tmp = $idPrefix&$idNum Then
		 insertHyperlink($i)
		 $skip = 1
	  ElseIf Int(StringRight($oExcelHandle.ActiveSheet.Cells($i,1).Value,4))<$idNum Then
		 $oExcelHandle.ActiveSheet.Cells($i+1,1).Value = $idPrefix&$idNum
		 insertHyperlink($i+1)
		 $skip = 1
	  Else
		 $value = Int(StringRight($oExcelHandle.ActiveSheet.Cells($i,1).Value,4))
	  EndIf
   EndIf
   If $skip = 0 Then				;exist number
	  $step = 1
	  If $value>$idNum Then
		 $step = -1
	  EndIf
	  While True
		 $tmp = $oExcelHandle.ActiveSheet.Cells($i,1).Value
		 $value = Int(StringRight($tmp,4))
		 If $value = $idNum Then
			insertHyperlink($i)
			ExitLoop
		 ElseIf ($value>$idNum And $step=1) Or ($value<$idNum And $step=-1) Then
			$oExcelHandle.ActiveSheet.Cells($i+1,1).EntireRow.Insert
			$oExcelHandle.ActiveSheet.Cells($i+1,1).Value = $idPrefix&$idNum
			insertHyperlink($i+1)
			ExitLoop
		 EndIf
		 $i = $i+$step
	  WEnd
   EndIf
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   #ce
EndFunc

Func insertHyperlink($i)
   $oExcelHandle.ActiveSheet.Hyperlinks.Add($oExcelHandle.ActiveSheet.Range("A"&$i),$link,"","")
EndFunc