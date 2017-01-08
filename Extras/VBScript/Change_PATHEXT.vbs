'*****************************************************
' Script Name: Change_PATHEXT.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/29/01
'     Purpose: Change the default PATHEXT environmental variable so that
'              scripts cannot be executed without specifying their extensions.
'       Notes: This can help a little bit to defend against script viruses.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Set oWshShell = WScript.CreateObject("WScript.Shell")
oWshShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Control\"&_
        "Session Manager\Environment\PATHEXT",".COM;.EXE","REG_SZ"



'END OF SCRIPT ***************************************
