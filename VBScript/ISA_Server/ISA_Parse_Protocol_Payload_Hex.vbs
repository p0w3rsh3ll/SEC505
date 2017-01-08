'*******************************************************************************
' Script Name: ISA_Parse_Raw_Hex_Payload.vbs
'     Version: 1.0
'      Author: Jason Fossen (www.ISAscripts.org)
'Last Updated: 19.Aug.2005
'     Purpose: Extracts the raw hex protocol fields out of the lines from an ISA
'              Server firewall log and decodes it using tethereal.exe, which is 
'              a part of the free Ethereal sniffer at http://www.etheral.com.
'              Log lines must be passed in as standard-input (StdIn) to the script
'              and you must pipe through cscript.exe.  For example:
'                  find.exe "10.4.4.4" ISALOG_FWS.w3c | cscript.exe ISA_Parse_Raw_Hex_Payload.vbs
'              Notice that you must specify cscript.exe.  Works with both types of
'              text logs produced by the firewall service (.W3C and .IIS), but Not
'              MSDE database logs.  Script is too slow to process entire log files,
'              so use find.exe/findstr.exe/grep.exe to only parse what you want.
'        Note: If you didn't install Ethereal into %ProgramFiles%\Ethereal\, Then
'              edit the sEtherealPath variable below.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'*******************************************************************************
Option Explicit
On Error Resume Next


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  NOTE:  Edit the following path to text2pcap.exe and tethereal.exe.
'         Make sure it ends with a backslash ("\").  Get these free tools
'         with the Ethereal sniffer at http://www.ethereal.com
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim sEtherealPath : sEtherealPath = "%ProgramFiles%\Ethereal\" 


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''






Dim oStdIn, oStdOut, sLine, sActionField, sStatusField, sRuleField, sIPHeaderField, oFileSystem
Dim sProtocolPayloadField, aFields, oWshShell, iLastField, sCommand, oExec, bReturn

Set oStdIn  = WScript.StdIn
Set oStdOut = WScript.StdOut
Set oWshShell = WScript.CreateObject("WScript.Shell")

If (WScript.Arguments.Count <> 0) Or (Err.Number <> 0) Then Call ShowHelpAndQuit()

sEtherealPath = oWshShell.ExpandEnvironmentStrings(sEtherealPath)
sEtherealPath = Replace(LCase(sEtherealPath), "\program files\", "\PROGRA~1\") 

Do While Not oStdIn.AtEndOfStream
    sLine = oStdIn.ReadLine
    
    If (Left(sLine, 1) <> "#") And (Trim(sLine) <> "") Then
        aFields = Split(sLine, vbTab)
        iLastField = UBound(aFields)
        
        If iLastField >= 2 Then
            sIPHeaderField = aFields(iLastField - 1)     'Always the next-to-last field, if enabled.
            sProtocolPayloadField = aFields(iLastField)  'Always the last field, if enabled.
        End If
        
        If (Len(sIPHeaderField) > 10) And (Len(sProtocolPayloadField) > 10) Then
        
            WScript.Echo "*******************************************************************************"
            WScript.Echo MakeNiceParagraph(Join(aFields,","), 79, 0)
            WScript.Echo "*******************************************************************************"
        
            'The following command will be executed to create a valid libpcap file with a single packet.
            sCommand = "cmd.exe /c @echo 000000 " & sIPHeaderField & " " & sProtocolPayloadField & "  | " & sEtherealPath & "text2pcap.exe -e 0x800 - - > %TEMP%\tmp-safetodeleteme-28199.libpcap"
            'WScript.Echo sCommand   'for debugging
            Set oExec = oWshShell.Exec(sCommand)
            
            'Wait for the command to finish before proceeding.
            Do While oExec.Status = 0
                WScript.Sleep 100
            Loop
            Set oExec = Nothing
            
            'The following command will parse that libpcap file into its protocol fields.
            sCommand = sEtherealPath & "tethereal.exe -n -x -V -r %TEMP%\tmp-safetodeleteme-28199.libpcap" 
            'WScript.Echo sCommand  'for debugging
            Set oExec = oWshShell.Exec(sCommand)

            Do While oExec.Status = 0
                WScript.Sleep 100
            Loop
            
            'Now read the output of tethereal, one line at a time, and write that to StdOut.
            Do While Not oExec.StdOut.AtEndOfStream
                oStdOut.WriteLine oExec.StdOut.ReadLine
            Loop
            Set oExec = Nothing
            
            WScript.Echo ""
        End If

    End If
Loop



''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Note: Why not just pipe the output of text2pcap.exe into tethereal.exe?  Because it doesn't work
'       reliably enough on Windows.  Why not write all the lines to a single file and then run
'       text2pcap.exe on that one file?  Because ISA is logging the headers of packets that are very
'       often malformed or deliberately mangled.  When Ethereal or tethereal.exe read in a libpcap
'       file with corrupted packets, they just stop.  We want to parse as many of these headers
'       as possible and show error information, hence, it must be done one packet at a time.  Very
'       inefficient and ugly, I know, but that's the way it goes...
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


bReturn = DeleteFile("%TEMP%\tmp-safetodeleteme-28199.libpcap")



Function DeleteFile(sPath)
    On Error Resume Next
    
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")

    If InStr(sPath, "%") <> 0 Then
        If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell")
        sPath = oWshShell.ExpandEnvironmentStrings(sPath)
    End If 
    
    If InStr(sPath, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sPath = sCurrentFolder & sPath
    End If    
    
    If oFileSystem.FileExists(sPath) Then oFileSystem.DeleteFile sPath, True 'True to delete read-only files too.
    
    If Err.Number = 0 Then
       'WScript.Echo "Successfully deleted file '" & sPath & "'"
       DeleteFile = True
    Else
       'WScript.Echo "Failed to delete file '" & sPath & "' " & Err.Description 
       DeleteFile = False
    End If
    
    On Error Goto 0
End Function



Function MakeNiceParagraph(sText, iMaxLength, iIndent)
    '
    'Note: iMaxLength is the max length of each line of output, including
    '      the prepended space characters.  80 is the usual CMD shell width.
    'Note: iIndent is the number of space characters prepended to each line.
    '
    
    Dim sOutput, iChunkSize, iStart, iTextLength
    
    If (Len(sText) + iIndent) <= iMaxLength Then
        MakeNiceParagraph = Space(iIndent) & sText
        Exit Function
    End If
    
    iChunkSize = iMaxLength - iIndent
    iStart = 1
    iTextLength = Len(sText)
    sOutput = ""
    
    Do Until iStart > iTextLength
        sOutput = sOutput & Space(iIndent) & LTrim(Mid(sText, iStart, iChunkSize)) & vbCrLf
        iStart = iStart + iChunkSize
    Loop
    
    If sOutput <> "" Then
        MakeNiceParagraph = Left(sOutput, Len(sOutput) - 1) 'Trim off last vbCrLf
    Else
        MakeNiceParagaph = ""
    End If
End Function



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_Parse_Raw_Hex_Payload.vbs [/?]" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Purpose: " & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "  A line in an ISA Server firewall log may contain the raw hex dump of the IP" & vbCrLf
    sUsage = sUsage & "  and Payload headers of an offending packet.  This script parses that header" & vbCrLf
    sUsage = sUsage & "  information with tethereal.exe and displays an analysis of the hex data for" & vbCrLf
    sUsage = sUsage & "  use in forensics and troubleshooting.  The log can be in .W3C or .IIS format," & vbCrLf
    sUsage = sUsage & "  but it cannot be an MSDE database (.MDF) unless dumped to a text log first." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Requirements:" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "1) You must download and install the free (and wonderful!) Ethereal protocol" & vbCrLf
    sUsage = sUsage & "   analyzer from http://www.ethereal.com (and make sure to install the" & vbCrLf
    sUsage = sUsage & "   optional tools named text2pcap.exe and tethereal.exe too). " & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "2) If you don't install Ethereal into %ProgramFiles%\Ethereal\, then edit" & vbCrLf
    sUsage = sUsage & "   the sEtherealPath variable at the top of the script." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "How To Use:" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "  This script takes no command-line arguments, only standard input (StdIn)." & vbCrLf
    sUsage = sUsage & "  The line(s) of a firewall log must be piped into the script as StdIn using" & vbCrLf
    sUsage = sUsage & "  tools like find.exe, findstr.exe, tail.exe or grep.exe.  For example:" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "  find ""10.4.4.4"" ISALOG_FWS.w3c | cscript.exe ISA_Parse_Raw_Hex_Payload.vbs" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "  Notice that you must specify cscript.exe. This script ignores all commented" & vbCrLf
    sUsage = sUsage & "  lines and lines without the raw hex data.  Pipe in as few lines as possible" & vbCrLf
    sUsage = sUsage & "  since the output is verbose and the script is very slow by necessity.  " & vbCrLf
    sUsage = sUsage & vbCrLf
    
    WScript.Echo sUsage
    WScript.Quit
End Sub


'END OF SCRIPT ****************************************************************
