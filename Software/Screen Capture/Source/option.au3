#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <File.au3>
 #include <Array.au3>
#Include <WinAPI.au3>

#NoTrayIcon

$sizeX = 90
$sizeY = 138

; Create a GUI with various controls.
$hGUI = GUICreate("Option",$sizeX,$sizeY,MouseGetPos(0),MouseGetPos(1), $WS_POPUP)
GUISetFont(10, 400, 0, "Tahoma")

$path = "option.ini"
$hFile = FileOpen($path)

$sizeInput = StringTrimLeft(FileReadLine($hFile,2),5)
$size = GUICtrlCreateInput($sizeInput,40,0,50,20)
$sizeLabel = GUICtrlCreateLabel("size : ",5,1,40,30)

$prefixInput = StringMid(FileReadLine($hFile,5),4,2)
$prefix = GUICtrlCreateInput($prefixInput,0,25,40,20)

$idInput = StringTrimLeft(FileReadLine($hFile,5),5)
$id = GUICtrlCreateInput($idInput,40,25,50,20)

$dbDirInput = StringTrimLeft(FileReadLine($hFile,6),3)
If StringRight($dbDirInput,1)<>"\" Then
   $dbDirInput = $dbDirInput&"\"
EndIf
$dbDirs = GUICtrlCreateButton("db",0,48,40,30)

$saveDirInput = StringTrimLeft(FileReadLine($hFile,4),5)
$saveDirs = GUICtrlCreateButton("save",40,48,50,30)

If StringTrimLeft(FileReadLine($hFile,1),5)=1 Then
   $modeInput = "center"
Else
   $modeInput = "edge"
EndIf
$mode = GUICtrlCreateButton($modeInput,0,78,90,30)

If StringTrimLeft(FileReadLine($hFile,3),5)=1 Then
   $saveInput = "on"
Else
   $saveInput = "off"
EndIf
$save = GUICtrlCreateButton("autosave : "&$saveInput,0,108,90,30)

; Display the GUI.
GUISetState(@SW_SHOW, $hGUI)
GuiCtrlSetState($size, $GUI_FOCUS)

; Loop until the user exits.
While 1
   $input = GUICtrlRead($id)
   If $input<>$idInput Then
	  _FileWriteToLine($path,5,"id="& $prefixInput & StringFormat("%04s",$input),1)
	  $idInput = $input
   EndIf

   $input = GUICtrlRead($prefix)
   If $input<>$prefixInput Then
	  $prefixInput = StringUpper($input)
	  $latestId = searchLatestId()
	  If $latestId > 0 Then
		 _FileWriteToLine($path,5,"id="& $prefixInput & $latestId,1)
		 $idInput = $latestId
		 GUICtrlSetData($id,$idInput)
		 GUICtrlSetData($prefix,$prefixInput)
	  EndIf
   EndIf

   $input = GUICtrlRead($size)
   If $input<>$sizeInput Then
	  _FileWriteToLine($path,2,"size="&$input,1)
	  $sizeInput = $input
   EndIf

   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE
		 ExitLoop
	  Case $mode
		 If $modeInput = "center" Then
			_FileWriteToLine($path,1,"mode=0",1)
			$modeInput = "edge"
			GUICtrlSetData($mode,"edge")
		 ElseIf $modeInput = "edge" Then
			_FileWriteToLine($path,1,"mode=1",1)
			$modeInput = "center"
			GUICtrlSetData($mode,"center")
		 EndIf
	  Case $save
		 If $saveInput = "on" Then
			_FileWriteToLine($path,3,"save=0",1)
			$saveInput = "off"
			GUICtrlSetData($save,"autosave : off")
		 ElseIf $saveInput = "off" Then
			_FileWriteToLine($path,3,"save=1",1)
			$saveInput = "on"
			GUICtrlSetData($save,"autosave : on")
		 EndIf
	  Case $saveDirs
		 $input = InputBox("Save Directory"," ",$saveDirInput,"",80,10,MouseGetPos(0),MouseGetPos(1))
		 If $input<>"" Then
			If StringRight($input,1)<>"\" Then
			   $input = $input&"\"
			EndIf
			_FileWriteToLine($path,4,"dirs="&$input,1)
			$saveDirInput = $input
		 EndIf
	  Case $dbDirs
		 $input = InputBox("Database Picture Directory"," ",$dbDirInput,"",80,10,MouseGetPos(0),MouseGetPos(1))
		 If $input<>"" Then
			If StringRight($input,1)<>"\" Then
			   $input = $input&"\"
			EndIf
			_FileWriteToLine($path,6,"db="&$input,1)
			$dbDirInput = $input
		 EndIf
   EndSwitch
WEnd

; Delete the previous GUI and all controls.
GUIDelete($hGUI)

Func searchLatestId()
   Dim $list
   $list = _FileListToArray($dbDirInput&$prefixInput)
   $latestId = 0
   If Not(@error) Then
	  For $i=1 To $list[0] Step 1
		 If StringLeft($list[$i],2)=$prefixInput Then
			$fileNumber = Number(StringMid($list[$i],3,4))
			If $fileNumber>$latestId Then
			   $latestId = $fileNumber
			EndIf
		 EndIf
	  Next
	  If $latestId>0 Then
		 Return StringFormat("%04s",$latestId+1)
	  EndIf
   EndIf
   Return 0
EndFunc

Func stop()
   FileClose($hFile)
   Exit
EndFunc