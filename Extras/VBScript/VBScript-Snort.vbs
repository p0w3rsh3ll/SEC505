'*******************************************************************************
' Script Name: VBScript-Snort.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 23.Aug.2007
'     Purpose: The output of WinDump is piped into the script, then the script
'              executes command(s) when a regular expression is matched.
'       Usage: windump.exe -n | cscript.exe pipe_from_windump.vbs
'              Use -n, but not -X with WinDump.  Hit Ctrl-C to exit loop. 
'       Notes: Get WinPCap and WindDump from http://www.winpcap.org/windump/install/
'              Needless to say, real Snort (www.snort.org) is 10000% more powerful.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'*******************************************************************************


Set oStdIn  = WScript.StdIn
Set oRegExp = New RegExp

ReDim aPatterns(20)                              'Increase number as needed.
aPatterns(0) = "ICMP echo request"               'Ping request.
aPatterns(1) = " > 64\.112\.229\.\d+\.80: S "    'New HTTP connection to www.sans.org.


Do While Not oStdIn.AtEndOfStream
    sWinDumpLine = oStdIn.ReadLine

    For Each sPattern In aPatterns
        If sPattern <> "" Then

            oRegExp.Pattern = sPattern

            If oRegExp.Test(sWinDumpLine) Then
                MsgBox "SNIFF ALERT!" & vbCrLf & vbCrLf & sPattern
                'Or execute a more useful command...
            End If

        End If
    Next
Loop



'END OF SCRIPT ****************************************************************
