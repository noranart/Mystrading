#include <Excel.au3>
#include <File.au3>

$dropboxPath = StringLeft(@DesktopDir,StringInStr(@DesktopDir,"\",0,-1)) & "Dropbox\"		; "C:\Users\saintsol\" & "Dropbox\"
$databasePath = $dropboxPath & "shop\database\picture\"
$list = _FileListToArray($databasePath,"*",2)
$excelOpen = True
$excelApp = ""
For $i=1 To $list[0]
   ;;;;;;;;;;;; init ;;;;;;;;;;;;;
   $prefix = $list[$i]
   $xlsmPath = $databasePath  & $prefix &"\"& $prefix &"_Description.xlsm"
   $csvFolderPath = @WorkingDir & "\csv\"
   $csvPath = $csvFolderPath & $prefix &"_Description.csv"
   If Not(FileExists($csvFolderPath)) Then
	  DirCreate($csvFolderPath)
   EndIf
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   ;;;;;;;;;;;;; log ;;;;;;;;;;;;;
   $update = True
   $logPath = @WorkingDir & "\log.txt"
   If Not(FileExists($logPath)) Then
	  FileWrite($logPath,"")
   ElseIf Not(FileExists($xlsmPath)) Then
	  $update = False
   Else
	  $hFile = FileOpen($logPath)
	  $array = FileReadToArray($hFile)
	  If Not(@error) Then
		 For $text In $array
			If StringLeft($text,2)=$prefix Then
			   If StringTrimLeft($text,3)=FileGetSize($xlsmPath) Then
				  $update = False		;same file size
				  ExitLoop
			   EndIf
			EndIf
		 Next
	  EndIf
	  FileClose($hFile)
   EndIf
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   If $update Then
	  refreshCSV()
   EndIf
Next
If Not($excelOpen) Then
   _Excel_Close($excelApp,True,True)
EndIf

Func refreshCSV()
   If $excelOpen Then
	  $excelApp = _Excel_Open()
	  $excelOpen = False
   EndIf
   $workbook = _Excel_BookOpen($excelApp, $xlsmPath)
   If Not(@error) Then
	  _Excel_RangeDelete($workbook.ActiveSheet,"1:1")
	  _Excel_BookSaveAs($workbook,$csvPath, $xlcsv, True)
	  _Excel_BookClose($workbook,False)
	  $workbook = _Excel_BookOpen($excelApp, $csvPath)
	  If Not(@error) Then
		 _Excel_RangeDelete($workbook.ActiveSheet,"C:Z")
		 _Excel_RangeSort($workbook,Default,"A:B","A1")
		 _Excel_BookClose($workbook,True)
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
   $log = $prefix&","&FileGetSize($xlsmPath)
   $array = FileReadToArray($hFile)
   $notFound = True
   If Not(@error) Then
	  $count = 1
	  For $text In $array
		 If StringLeft($text,2)=$prefix Then
			_FileWriteToLine($logPath,$count,$log,1)
			$notFound = False
			ExitLoop
		 EndIf
		 $count = $count+1
	  Next
   EndIf
   If $notFound Then
	  FileWriteLine($logPath,$log)
   EndIf
   FileClose($hFile)
EndFunc

Func notFound()
   TrayTip("","not found",2000)
   Sleep(2000)
EndFunc