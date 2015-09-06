#include <GDIPlus.au3>
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>
#include <ScreenCapture.au3>
#include <Clipboard.au3>
#include <File.au3>

$input = InputBox("Initial Code"," ","HH0001","",80,10,MouseGetPos(0),MouseGetPos(1))
If StringLen($input)<>6 Then
   MsgBox(0,"","ERROR",1000)
   Sleep(1000)
Else
   $count = StringTrimLeft($input,2)
   $prefix = StringLeft($input,2)

   Dim $list
   $list = _FileListToArray(@WorkingDir)

   For $i= 1 To $list[0] Step 1
	  If StringRight($list[$i],4) = ".jpg" Then
		 $fileName = StringFormat("%04s",$count)
		 FileMove(@WorkingDir & "\" & $list[$i], @WorkingDir & "\" & $prefix & $fileName &".jpg")
		 $count = $count +1
	  EndIf
   Next
EndIf