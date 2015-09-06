HotKeySet("{ESC}","stop")

$no = 9999
$direction = 1				;1:DOWN, -1:UP

$chrome = ""
$excel = ""
$fbSignature = ""
$chk = 0
While $chk<2
   $active = WinGetTitle("[ACTIVE]")
   If StringInStr($active,"chrome")>0 And $chrome = "" Then
	  $chrome = WinGetHandle($active)
	  $chk = $chk+1
   ElseIf StringInStr($active,".xlsm")>0 And $excel = "" Then
	  $excel = WinGetHandle($active)
	  $pos = StringInStr($active,"_Description")-2
	  $fbPrefix = StringMid($active,$pos,2)
	  Switch $fbPrefix
		 Case "BP"
			$fbSignature = "bambidishop"
		 Case "CP"
			$fbSignature = "princesslookshop"
		 Case "DP"
			$fbSignature = "sanxshop"
		 Case "HP"
			$fbSignature = "hisztoryshop"
		 Case "SP"
			$fbSignature = "queenimshop"
		 Case "ZP"
			$fbSignature = "midecoshop"
	  EndSwitch
	  $chk = $chk+1
   EndIf
WEnd

$first = 1
$m = 300
;$signature = @LF&"------------------------------------------------------"&@LF&"สนใจสั่งซื้อ/สอบถามสินค้า ติดต่อได้ที่"&@LF&"INBOX : www.facebook.com/messages/"&$fbSignature&@LF&"LINE : mamiez"
$signature = ""
For $i=1 To $no Step 1
   WinActivate($excel)
   Sleep($m)
   If $first <> 1 Then
	  If $direction = 1 Then
		 Send("{DOWN}")
	  Else
		 Send("{UP}")
	  EndIf
	  Sleep($m)
   EndIf
   Send("^+c")
   Sleep($m)
   WinActivate($chrome)
   Sleep($m)
   If $first <> 1 Then
	  Send("{TAB}")
	  Sleep($m)
	  #cs
	  Send("{TAB}")
	  Sleep($m)
	  Send("{TAB}")
	  Sleep($m)
	  #ce
   Else
	  $first = 0
   EndIf
   $first = 0
   Send("^a")
   Sleep($m)
   ClipPut(ClipGet()&$signature)
   Sleep($m)
   Send("^v")
   Sleep($m)
Next

Func stop()
   Exit
EndFunc