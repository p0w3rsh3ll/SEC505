'***********************************************************************************
' Script Name: BeingSynFlooded.vbs
'     Version: 3.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 21.May.2004
'     Purpose: Captures the standard out (StdOut) of a launched process, in this case,
'              the output of "netstat.exe -an -p tcp" for the sake of counting how
'              many SYN_RECEIVED lines there are as a sign of a SYN flood DoS attack.
'              Function returns true if too many SYN_RECEIVED lines, false otherwise.
'       Notes: Requires WSH 5.6 or later!  
'    Keywords: standard out, stdout, capture, syn, flood, flooding
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************


Function BeingSynFlooded(iCount)
    Set oWshShell = WScript.CreateObject("WScript.Shell")
    Set oExec = oWshShell.Exec("netstat.exe -an -p tcp")

    iSynReceived = iCount  'When exceeded, SYN flooding assumed; adjust for your environment.

    Do While Not oExec.StdOut.AtEndOfStream
        sLine = oExec.StdOut.ReadLine    
        If InStr(sLine,"SYN_RECEIVED") <> 0 Then iSynReceived = iSynReceived - 1
    Loop

    If iSynReceived <= 0 Then BeingSynFlooded = True Else BeingSynFlooded = False
End Function




'END OF SCRIPT *********************************************************************





If BeingSynFlooded(200) Then 
    WScript.Echo "You are under attack!" 
Else
    WScript.Echo "Not under attack...yet."
End If

