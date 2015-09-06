While Not(WinActive("Choose File to Upload"))
   Sleep(100)
WEnd
BlockInput(1)
Sleep(500)
$msg = FileRead("msg")
While ClipGet()<>$msg
   ClipPut($msg)
   Sleep(100)
WEnd
Send("^v")
Send("{ENTER}")
BlockInput(0)