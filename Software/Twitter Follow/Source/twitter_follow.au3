#include <File.au3>
#include <FileConstants.au3>
#include <Misc.au3>
#include <IE.au3>
HotKeySet("^q","stop")

;;;;;;;;; configuration ;;;;;;;;;
$followThreshold = 1000	;# of follow for each account
$end = 20				;hit {END} times
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

$xs = 10
$s = 100
$m = 500
$l = 1000
$vl = 2000
$countFollow = 0
$buttonReach = 0

$url = "about:blank"
$oIE = _IECreate($url,0,1,0,0)
Sleep($l)

follow("shoeshoppx",$followThreshold)

Func follow($user,$followThres)
   $url = "https://twitter.com/" & $user & "/followers"
   _IENavigate($oIE,$url,1)
   _IELoadWait($oIE,0,20000)
   While $countFollow<$followThres
	  For $i=1 To $end Step 1
		 $oIE.document.parentwindow.scroll(0, $oIE.document.body.scrollHeight)	; {END}
		 Sleep($m)
	  Next
	  $oIE.document.parentwindow.scroll(0, $oIE.document.body.scrollTop)		; {HOME}
	  Sleep($m)
	  $oTags = _IETagNameGetCollection($oIE,"button")
	  If Not(@error) Then
		 $count = 0
		 For $oTag in $oTags
			If $oTag.classname = "user-actions-follow-button js-follow-btn follow-button btn small small-follow-btn" Then
			   $count = $count+1
			   If $count>$buttonReach Then
				  $outerHtml = $oTag.parentNode.outerhtml
				  If StringInStr($outerHtml,"not-following") Then
					 tip($countFollow)
					 _IEAction($oTag,"click")
					 $countFollow = $countFollow+1
					 If $countFollow>$followThres Then
						ExitLoop(2)
					 EndIf
					 Sleep(10)
				  EndIf
			   EndIf
			EndIf
		 Next
		 $buttonReach = $count
	  EndIf
   WEnd
EndFunc

Func w($msg)
   ConsoleWrite($msg &@LF)
EndFunc

Func tip($msg)
   TrayTip("",$msg,1000)
EndFunc

Func stop()
   Exit
EndFunc