#include <File.au3>
#include <FileConstants.au3>
#include <Misc.au3>
#include <IE.au3>
HotKeySet("^q","stop")

$url = "https://www.twitter.com"
$type = "preorder"
$path = @WorkingDir & "\"&"List\"

$s = 100
$m = 500
$l = 1000
$xl = 5000

;create ie instance - twitter.com
$oIE = _IECreate($url,0,1,0,0)
_IELoadWait($oIE,0,20000)
$handle = _IEPropertyGet($oIE,"hwnd")
WinMove($handle,"",0,0,900,720,-1)

;;;;;;;;;;;;;;;;;  begin  ;;;;;;;;;;;;;;;;;
$hFile = FileOpen($path & "description.csv")
$line = 1
$msg = FileReadLine($hFile, $line)
Do
   ;decrypt filename and description
   $posComma1 = StringInStr($msg,",")-1
   $posComma2 = StringInStr($msg,",",0,2)-1
   $fileName = $path & StringLeft($msg, $posComma1)
   $description = StringMid($msg,$posComma1+2, $posComma2-$posComma1 - 1)
   If StringLeft($description,1)='"' Then
	  $description = StringTrimLeft($description,1)
   EndIf
   If StringRight($description,1)='"' Then
	  $description = StringTrimRight($description,1)
   EndIf
   $description = StringReplace($description,"|",@LF)

   ;new tweet
   Do
	  $oTags = _IETagNameGetCollection($oIE,"button")
	  If Not(@error) Then
		 For $oTag in $oTags
			If $oTag.id="global-new-tweet-button" Then
			   _IEAction($oTag,"click")
			   ExitLoop(2)
			EndIf
		 Next
	  EndIf
   Until Not(@error)
ConsoleWrite(1111)
   ;add description
   While ClipGet()<>$description
	  ClipPut($description)
	  Sleep($s)
   WEnd
   Send("^a")
   Send("{DEL}")
   Send("^v")
   Sleep($m)

   ;add pictures
   Do
	  Do
		 $oTags = _IETagNameGetCollection($oIE,"input")
		 $first = 1
		 If Not(@error) Then
			For $oTag in $oTags
			   If $oTag.classname="file-input js-tooltip" And $oTag.name="media_empty" Then
				  FileWrite("msg",$fileName&".jpg")
				  Run("Util\Send.exe")
				  _IEAction($oTag,"click")
				  FileDelete("msg")
				  ExitLoop(2)
			   EndIf
			Next
		 EndIf
	  Until Not(@error)
	  $line = $line+1
	  $msg = FileReadLine($hFile, $line)
	  $posComma1 = StringInStr($msg,",")-1
	  $fileName = $path & StringLeft($msg, $posComma1)
	  w($msg)
   Until StringRight($msg,1) <> "N"

   ;tweet
   Sleep($l)
   Do
	  $oTags = _IETagNameGetCollection($oIE,"button")
	  If Not(@error) Then
		 For $oTag in $oTags
			If $oTag.classname="btn primary-btn tweet-action tweet-btn js-tweet-btn" Then
			   _IEAction($oTag,"click")
			   ExitLoop(2)
			EndIf
		 Next
	  EndIf
   Until Not(@error)

   ;wait
   Sleep($l)
   Do
	  $done = 0
	  Do
		 $oTags = _IETagNameGetCollection($oIE,"div")
		 If Not(@error) Then
			For $oTag in $oTags
			   If $oTag.id="global-tweet-dialog" Then
				  If $oTag.style.display ="none" Then
					 $done = 1
				  EndIf
				  ExitLoop(2)
			   EndIf
			Next
		 EndIf
	  Until Not(@error)
	  Sleep($l)
   Until $done = 1
   ;_IENavigate($oIE,$url)
Until $msg = ""
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func w($msg)
   ConsoleWrite($msg &@LF)
EndFunc

Func stop()
   FileClose($hFile)
   Exit
EndFunc