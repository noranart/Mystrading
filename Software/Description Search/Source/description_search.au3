#include <Excel.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <WinAPI.au3>
#include <Misc.au3>
HotKeySet("{ESC}","stop")

$input = ""
RunWait("Util\csv_update.exe")
$dropboxPath = StringLeft(@DesktopDir,StringInStr(@DesktopDir,"\",0,-1)) & "Dropbox\"		; "C:\Users\saintsol\" & "Dropbox\"
$databasePath = $dropboxPath & "shop\database\picture\"
$prefix = ""
$no = ""
$prevCode = ""

$handle = GUICreate("Search Result", 800, 500, -1, -1, $ws_popup) ; will create a dialog box that when displayed is centered
$pic = GUICtrlCreatePic("" , 0, 0, 500, 500)
GUISetFont(14,400,0,"Tahoma")
$edit = GUICtrlCreateEdit("",500,30,300,470,$WS_HSCROLL)
$inputPrefix = GUICtrlCreateInput("",500,0,30,30)
$inputNo = GUICtrlCreateInput("",530,0,190,30)
$search = GUICtrlCreateButton("Search",720,0,80,30)
GuiCtrlSetState($inputPrefix, $GUI_FOCUS)
GUISetState(@SW_SHOW)

$csvFolderPath = @WorkingDir & "\csv\"
$csvPath = ""


While True
   While 1
	  If _IsPressed("0D") Then
		 searchDescription()
		 Sleep(1)
	  ElseIf _IsPressed("26") Then
		 GUICtrlSetData($inputNo,GUICtrlRead($inputNo)-1)
		 searchDescription()
		 Sleep(300)
	  ElseIf _IsPressed("28") Then
		 GUICtrlSetData($inputNo,GUICtrlRead($inputNo)+1)
		 searchDescription()
		 Sleep(300)
	  EndIf
	  Switch GUIGetMsg()
		 Case $GUI_EVENT_CLOSE
			ExitLoop
		 Case $search
			searchDescription()
	  EndSwitch
   WEnd
WEnd

Func searchDescription()
   $msg = GUICtrlRead($input)
   $prefix = StringUpper(GUICtrlRead($inputPrefix))
   $no = StringFormat("%04s",GUICtrlRead($inputNo))
   $csvPath = $csvFolderPath & $prefix &"_Description.csv"
   $notFound = True
   If FileExists($csvPath) Then
	  $numLine = _FileCountLines($csvPath)
	  $hFile = FileOpen($csvPath)
	  $low = 0
	  $high = $numLine
	  $mid = 0
	  $notFound = False
	  Do
		 $mid = Round(($low+$high)/2,0)
		 If $high=$mid Or $low=$mid Then
			$notFound = True
			ExitLoop
		 EndIf
		 $csvNo = StringMid(FileReadLine($hFile,$mid),3,4)
		 If $csvNo<$no And StringLeft($csvNo,1)<>"|" Then
			$low = $mid
		 Else
			$high = $mid
		 EndIf
	  Until $csvNo = $no
	  If Not($notFound) Then
		 $result = FileReadLine($hFile,$mid)
		 $result = StringTrimLeft($result,8)
		 $result = StringTrimRight($result,1)
		 $result = StringReplace($result,"|",@CRLF)
		 If $prevCode<>$prefix&$no Then
			GUICtrlSetData($edit,$result)
			GUICtrlSetImage($pic,$databasePath & $prefix &"\"& $prefix &$no& ".jpg")
			$prevCode = $prefix&$no
			GUICtrlSetData($inputPrefix,$prefix)
			GUICtrlSetData($inputNo,$no)
		 EndIf
		 FileClose($hFile)
	  EndIf
   EndIf
   If $notFound Then
	  GUICtrlSetData($edit,"Not Found")
   EndIf
   GuiCtrlSetState($inputNo, $GUI_FOCUS)
EndFunc

Func refreshCSV()
   $excelApp = _Excel_Open()
   $workbook = _Excel_BookOpen($excelApp, $xlsmPath)
   If Not(@error) Then
	  _Excel_RangeDelete($workbook.ActiveSheet,"1:1")
	  _Excel_BookSaveAs($workbook,$csvPath, $xlcsv, True)
	  _Excel_BookClose($workbook,False)
	  $workbook = _Excel_BookOpen($excelApp, $csvPath)
	  If Not(@error) Then
		 _Excel_RangeDelete($workbook.ActiveSheet,"C:Z")
		 _Excel_RangeSort($workbook,Default,"A:B","A1")
		 _Excel_Close($excelApp,True,True)
		 _ReplaceStringInFile($csvPath,Chr(10),"|")
		 _ReplaceStringInFile($csvPath,Chr(13)&"|",Chr(10))
		 updateLog()
		 Return True
	  EndIf
   EndIf
   Return False
EndFunc

Func updateLog()
   $hFile = FileOpen($logPath)
   $array = FileReadToArray($hFile)
   FileClose($hFile)
   $log = $prefix&","&FileGetSize($xlsmPath)
   If Not(@error) Then
	  $count = 1
	  $notFound = True
	  For $text In $array
		 If StringLeft($text,2)=$prefix Then
			_FileWriteToLine($logPath,$count,$log,1)
			$notFound = False
			ExitLoop
		 EndIf
		 $count = $count+1
	  Next
	  If $notFound Then
		 FileWriteLine($logPath,$log)
	  EndIf
   EndIf
EndFunc

Func stop()
   Exit
EndFunc