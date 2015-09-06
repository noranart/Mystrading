#AutoIt3Wrapper_run_debug_mode=y
#include <Array.au3>
#include <File.au3>
#include <Crypt.au3>
#include <Misc.au3>
Opt("SendCapslockMode",0)

HotKeySet("{ESC}","stop")
HotKeySet("[","pause")
HotKeySet("^{CAPSLOCK}","option")

Dim $follow[6] = [1,1,1,1,1,1]
Dim $unfollow[6] = [0,1,1,1,0,1]

$followThres = 60
$unfollowThres = 45
$s = 100
$m = 500
$l = 2000
$vl = 3000
$xl = 5000
$white = 16777215
$black = 6000000
$title = "Instwogram"
$path = "option.ini"
$hFile = ""
$hFile = FileOpen($path)
$pwd = BinaryToString(_Crypt_DecryptData(StringTrimLeft(FileReadLine($hFile,1),4),"saintsol", $CALG_RC4))
FileClose($hFile)

$path2 = @ScriptDir&"\List\"
Dim $user = _FileListToArray($path2, "*.txt", 1)
Dim $line[$user[0]+1]
Dim $lineCount[$user[0]+1]
For $i=1 To $user[0] Step 1
   $line[$i] = _FileCountLines($path2&$user[$i])
Next

If Not(WinExists($title)) Then
   restart()
EndIf
WinMoveVertical()
windowsActivate($title)
WinSetOnTop($title,"",1)

While True
   ;For $i=$user[0] To 1 Step -1
   For $i=1 To $user[0] Step 1
	  $id = StringTrimRight($user[$i],4)
	  logout($id)
	  Dim $targetFile
	  _FileReadToArray($path2&$user[$i],$targetFile)
	  $rand = Random(1,$line[$i],1)
	  follow($targetFile[$rand],$i)
   Next
WEnd

Func follow($target,$switch)
   If $follow[$switch-1]=1 Then
	  While PixelGetColor(1057,43)<>$white		;follow
		 click(1131,647,2)
	  WEnd
	  While PixelGetColor(1035,49)<>$white		;search
		 click(1121,52,2)
	  WEnd
	  sendClip($target)
	  Sleep($m)
	  While PixelGetColor(1365,58)<>$white		;target
		 click(1365,176,2)
	  WEnd
	  Sleep($l)
	  click(1259,106)
	  While PixelGetColor(1365,58)=$white Or PixelGetColor(1365,197)=$white Or PixelGetColor(1324,100)=$white
		 Sleep($m)
	  WEnd
	  Sleep($m)
	  ;follow
	  $count = 0
	  $first = 1
	  While True
		 $chk = 0
		 For $j=0 To 1 Step 1
			For $i=0 To 7 Step 1
			   If PixelGetColor(1364,100+$i*65)=$white Then
				  click(1364,100+$i*65,1,$s)
				  $count = $count+1
				  $chk = 1
			   EndIf
			Next
			Sleep($s)
		 Next
		 If $count>$followThres Then
			ExitLoop
		 EndIf
		 ;banned target
		 If Round(PixelGetColor(1153,273)/1000000)=7040626 Or PixelGetColor(1365,47)=467510 Then
			click(1143,438)
		 EndIf
		 ;scroll
		 If $first = 1 Or $chk = 1 Then
			key("{SPACE}",$s)
		 EndIf
		 If $chk=0 And Random(0,1,1)=1 Then
			key("{END}")
			key("+{SPACE}")
		 Else
			key("{SPACE}")
		 EndIf
		 Sleep($m)
		 $first = 0
	  WEnd
   EndIf
   If $unfollow[$switch-1]=1 Then
	  Sleep($m*2)
	  unfollow()
   EndIf
EndFunc

Func unfollow()
   ;my user
   While PixelGetColor(1345,654)<>$white
	  click(1345,642,2)
   WEnd
   Sleep($l)
   click(1334,104)
   ;scroll down
   While Round(PixelGetColor(1365,559)/1000000)<>13
	  key("{END}")
	  WinActivate($title)
   WEnd
   Sleep($m)
   key("+{SPACE}")
   ;unfollow
   $count = 0
   While True
	  $chk = 0
	  For $i=0 To 7 Step 1
		 $pixel = Round(PixelGetColor(1364,100+$i*65)/1000000)
		 If $pixel>=3 And $pixel<=8 Then
			click(1364,100+$i*65,1,$s)
			$chk = False
			For $j=1 To 50 Step 1
			   If PixelGetColor(1354,453)=$white Then
				  $chk = True
				  ExitLoop
			   EndIf
			   ;banned target
			   If Round(PixelGetColor(1153,273)/1000000)=7040626 Then
				  click(1143,438)
				  ExitLoop
			   EndIf
			   Sleep($s)
			Next
			If $chk Then
			   click(1354,453,1,$s)
			EndIf
			While PixelGetColor(1354,453)=$white
			   Sleep($s)
			WEnd
			$count = $count+1
		 EndIf
	  Next
	  If $count>$unfollowThres Then
		 ExitLoop
	  EndIf
	  key("+{SPACE}")
   WEnd
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
	  While PixelGetColor(1034,49)=$white		;logoutprincesslook_shop
		 click(1116,590,1,$m)
	  WEnd
	  While PixelGetColor(1345,654)=$white
		 Sleep($s)
	  WEnd
	  Sleep($m)
	  While PixelGetColor(1298,349 )<>$white	;confirm
		 click(1292,377,1,$l)
	  WEnd
	  While PixelGetColor(1363,642)<>$white
		 Sleep($s)
	  WEnd
   EndIf
   Sleep($m)
   login($id)
EndFunc

Func login($id)
   click(1055,284,2)
   sendClip($id&"_shop")
   click(1158,331,3)
   key($pwd)
   click(1358,331)
   $count = 0
   While PixelGetColor(1364,647)>4000000
	  Sleep($vl)
	  $count = $count+1
	  If $count>7 Or PixelGetColor(1350,356)=$white Or (PixelGetColor(1050,332)=$white And PixelGetColor(1041,332)<2000000) Then
		 restart()
		 Sleep($m)
		 login($id)
		 ExitLoop
	  ElseIf PixelGetColor(1363,642)=$white Then
		 click(1158,331,2)
		 sendClip($pwd)
		 click(1358,331)
		 Sleep($l)
	  EndIf
   WEnd
   Sleep($m*2)
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
   If WinExists($title) Then
	  WinClose($title)
	  Sleep($m*2)
   EndIf
   Run(@ComSpec & " /c " &  '"' & '"' & @ScriptDir &"\Instwogram.lnk" &'"')
   Sleep($xl)
   If Not(WinExists($title)) Then
	  restart()
	  Return
   Else
	  While PixelGetColor(1059,646)<>$white
		 Sleep($m)
	  WEnd
	  Sleep($m*2)
   EndIf
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

Func pause()
   TrayTip("","Pause",1000)
   While True
	  If _IsPressed("DD") Then
		 TrayTip("","Resume",1000)
		 ExitLoop
	  Else
		 Sleep($s)
	  EndIf
   WEnd
EndFunc

Func stop()
   Exit
EndFunc