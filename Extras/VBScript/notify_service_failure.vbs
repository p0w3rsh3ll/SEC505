' This is just an example of a script that could be executed automatically when
' a service fails.  A real-world script might send e-mail, write to remote
' event logs, send pager messages, send an alert to an IDS or EMS product, etc.

If WScript.Arguments.Count >= 1 Then sArg = WScript.Arguments.Item(0)
MsgBox "Service Failure!" & vbCrLf & sArg,,"Attention"



