$in = @WorkingDir&"\in\"
$out = @WorkingDir&"\out\"

$hFileOpen = FileOpen("list.txt")
$count = 1
Do
   $sFileRead = FileReadLine($hFileOpen, $count)
   ConsoleWrite($sFileRead &@LF)
   If $sFileRead<>"" Then
	  FileCopy($in&$sFileRead&".jpg",$out&$sFileRead&".jpg")
   EndIf
   $count = $count+1
Until $sFileRead=""

; Close the handle returned by FileOpen.
FileClose($hFileOpen)
