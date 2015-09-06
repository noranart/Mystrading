#AutoIt3Wrapper_run_debug_mode=y
#include <Array.au3>
#include <File.au3>
#include <Crypt.au3>
Opt("SendCapslockMode",0)

HotKeySet("!1","stop")
HotKeySet("^{CAPSLOCK}","option")


$num = 5	;upload per 1/2 hour

$s = 100
$m = 500
$l = 2000
$vl = 3000
$xl = 5000
$white = 16777215
$title = "Instwogram"
$path = "option.ini"
$hFile = ""
$hFile = FileOpen($path)
$pwd = BinaryToString(_Crypt_DecryptData(StringTrimLeft(FileReadLine($hFile,1),4),"saintsol", $CALG_RC4))
FileClose($hFile)

;read folder(id) list
$csvPath = @ScriptDir &"\..\description_search\"
RunWait($csvPath&"\Util\csv_update.exe",$csvPath)

Dim $user = _FileListToArray(@ScriptDir&"\List\", "*", 2)									;list file in src folder
$id = ""
$prefix = "『Pre-order』" & "|"
$signature = ""

If Not(WinExists($title)) Then
   restart()
EndIf
WinMoveVertical()

For $j=1 To 999999 Step 1
   $time = TimerInit()
   ;BlockInput(1)
   windowsActivate($title)
   For $i=1 To $user[0] Step 1
	  $id = $user[$i]
	  $list = _FileListToArray(@ScriptDir&"\List\"&$id,"*.jpg",1,True)
	  If Not(@error) Then
		 $signature = ""
		 $signaturePath = @ScriptDir&"\List\"&$id&"\signature.txt"
		 $file = FileOpen($signaturePath)
		 For $k=1 To _FileCountLines($signaturePath) Step 1
			$signature = $signature& "|" &FileReadLine($file,$k)
		 Next
		 FileClose($file)

		 While PixelGetColor(1339,399)=$white And Round(PixelGetColor(1346,656)/1000000)=4
			key("{ESC}",$l)
		 WEnd
		 logout($id)
		 For $pic = 1 To $num
			If $pic<=$list[0] Then
			   upload($list,$pic)
			Else
			   ExitLoop
			EndIf
		 Next
	  EndIf
   Next
   BlockInput(0)
   While TimerDiff($time)<1600000
	  Sleep(60000)
   WEnd
Next

Func upload($list,$pic)
   ConsoleWrite($list[$pic]&@LF)
   click(1206,659,2)
   While PixelGetColor(1206,649)=$white	;user
	  click(1206,659,2)
   WEnd
   click(1215,396,1,$m*2)
   click(1215,396,1,$m*2)
   sendClip($list[$pic])
   key("{Enter}")
   While PixelGetColor(1034,49)<>16777215
	  Sleep($l)
   WEnd
   click(1361,50,1,$l)
   click(1361,50,1,$l)
   click(1152,162)
   click(1152,162)
   $description = $prefix & searchDescription($list[$pic]) & $signature
   sendNewLine($description)
   click(1361,50,1,$xl)
   FileDelete($list[$pic])
EndFunc

Func searchDescription($listPath)
   $descriptionPath = $csvPath &"csv\"& StringLeft(StringRight($listPath,10),2) &"_Description.csv"
   $no = StringLeft(StringRight($listPath,8),4)
   $notFound = True
   If FileExists($descriptionPath) Then
	  $numLine = _FileCountLines($descriptionPath)
	  $hFile = FileOpen($descriptionPath)
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
		 If $csvNo<$no Then
			$low = $mid
		 Else
			$high = $mid
		 EndIf
	  Until $csvNo = $no
	  If Not($notFound) Then
		 $result = FileReadLine($hFile,$mid)
		 $result = StringTrimLeft($result,8)
		 $result = StringTrimRight($result,1)
		 FileClose($hFile)
		 Return $result
	  EndIf
   EndIf
   Return False
EndFunc

Func logout($id)
   If PixelGetColor(1326,654)<>$white Then
	  click(1345,642,2)
	  $count = 0
	  While PixelGetColor(1345,654)<>$white	;user
		 click(1345,642,2)
		 $count = $count+1
		 If Mod($count,20)=0 Then
			key("{ESC}")
		 EndIf
	  WEnd
	  While PixelGetColor(1362,51)=$white		;...
		 click(1362,61)
	  WEnd
	  key("{END}{END}{END}{END}")
	  While PixelGetColor(1034,49)=$white		;logout
		 click(1116,590,1,$l)
	  WEnd
	  While PixelGetColor(1363,585)<>$white		;confirmz
		 click(1292,377,1,$l)
	  WEnd
   EndIf
   login($id)
EndFunc

Func login($id)
   click(1055,284,2)
   sendClip($id&"_shop")
   click(1158,331,3)
   sendClip($pwd)
   click(1358,331)
   While PixelGetColor(1326,667)=$white
	  Sleep($l)
	  If PixelGetColor(1050,332)=$white And PixelGetColor(1041,332)<2000000 Then
		 restart()
		 login($id)
	  EndIf
   WEnd
EndFunc

Func click($x,$y,$click=1,$delay=$m)
   MouseClick("left",$x,$y,$click,0)
   If $delay>0 Then
	  Sleep($delay)
   EndIf
EndFunc

Func sendNewLine($msg)
   While $msg<>""
	  $index = StringInStr($msg,"|")
	  If $index=0 Then
		 sendClip($msg,$s)
		 key("{ENTER}",$s)
		 ExitLoop
	  Else
		 sendClip(StringLeft($msg,$index-1),$s)
		 $msg = StringTrimLeft($msg,$index)
		 key("{ENTER}",$s)
	  EndIf
   WEnd
EndFunc

Func sendClip($msg,$delay=$m)
   While ClipGet()<>$msg
	  ClipPut($msg)
	  Sleep($s)
   WEnd
   key("^v",$delay)
EndFunc

Func key($msg,$delay=$m)
   Send($msg)
   Sleep($delay)
EndFunc

Func restart()
   WinClose($title)
   RunWait(@ComSpec & " /c " &  '"' & '"' & @ScriptDir &"\Instwogram.lnk" &'"')
   Sleep($xl)
   WinMoveVertical()
   windowsActivate($title)
EndFunc

Func windowsActivate($tmpHandle)
   While WinGetTitle("[ACTIVE]")<>$tmpHandle
	  WinActivate($tmpHandle)
	  Sleep($m)
   WEnd
EndFunc

Func WinMoveVertical()
   WinMove($title,"",1023,0,360,672,1)
EndFunc

Func option()
   RunWait("Util\option.exe")
   Send("{CapsLock off}{CapsLock off}{CapsLock off}")
   Sleep($m)
   $hFile = ""
   $hFile = FileOpen($path)
   $pwd = BinaryToString(_Crypt_DecryptData(StringTrimLeft(FileReadLine($hFile,1),4),"saintsol", $CALG_RC4))
   FileClose($hFile)
EndFunc

Func stop()
   Exit
EndFunc