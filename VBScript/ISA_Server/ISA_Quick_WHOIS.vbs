'**********************************************************************
' Script Name: ISA_Quick_WhoIs.vbs
'     Version: 1.0
'      Author: Jason Fossen ( www.ISAscripts.org )
'Last Updated: 27.May.2006
'     Purpose: Quick way to pop up an IE whois query of an IP address.
'              Kind of cheeseball script, but...what the heck, I had
'              free time today...  ;-)
'         Use: In the ISA Server Management MMC console, logging tab,
'              highlight a single line of log data, go to the Tasks
'              pane, click 'Copy Selected Results to Clipboard', And
'              then run the script.  IE will pop up and a whois query
'              will be done against the 'Client IP' field from the log.
'              If you do this a lot, put the script at the top of your
'              Start menu by dragging-and-dropping the script there.
'       Notes: If you copy multiple lines to the clipboard, only the
'              first line will actually be used, but no error occurs.
'       Legal: Public Domain.  Modify and redistribute freely.  
'              No rights reserved.  SCRIPT PROVIDED "AS IS" WITHOUT 
'              WARRANTIES OR GUARANTEES OF ANY KIND.  USE AT YOUR OWN 
'              RISK AND ONLY ON NETWORKS WITH PRIOR WRITTEN PERMISSION.
'**********************************************************************
Option Explicit
On Error Resume Next

If WScript.Arguments.Count <> 0 Then Call ShowHelpAndQuit()

Dim aLines, aFields, sIP, i
Dim sClip : sClip = GetClipboardText()

If Err.Number <> 0 Then
    MsgBox Err.Description
    WScript.Quit
End If


'Discover the column number of the 'Client IP' field; set i to that column number.
aLines = Split(sClip, vbCrLf, 2)
aFields = Split(aLines(0), vbTab)
For i = 0 To UBound(aFields)
    If aFields(i) = "Client IP" Then Exit For
Next


'Now extract the column i data from the first non-header row in the clipboard.
aFields = Split(aLines(1), vbTab)
sIP = Trim(aFields(i)) 
'MsgBox i & ": " & sIP


'Check for errors...
If (sClip = "<Clipboard-Data-Not-Text>") Or (Err.Number <> 0) Or (Not IsIpAddress(sIP)) Then
    MsgBox "Copy one line of log data from the ISA Server logging tab, then run this script again" & vbCr &_ 
           "to get a WHOIS query for the client's IP address in that data.",,"Try Again Please!"
    WScript.Quit
End If 


'Open IE and do the WHOIS query; update the URL below as necessary if/when it is changed.
Dim oIE : Set oIE = WScript.CreateObject("InternetExplorer.Application")
oIE.Navigate("http://ws.arin.net/cgi-bin/whois.pl?queryinput=" & sIP)
oIE.Visible = 1
Set oIE = Nothing   'This does not close the browser.



'*************************************************************
' Functions and Procedures
'*************************************************************

Function GetClipboardText()
    Dim oHtmlFile : Set oHtmlFile = CreateObject("htmlfile")
    GetClipboardText = oHtmlFile.ParentWindow.ClipboardData.GetData("Text")
    Set oHtmlFile = Nothing
    If VarType(GetClipboardText) <> 8 Then GetClipboardText = "<Clipboard-Data-Not-Text>"  
End Function



Function IsIpAddress(sInput)
    'Regular expression would be more accurate, but slower...quick-n-dirty will do...    
    IsIpAddress = False
    
    Dim sEnd
    sInput = LCase(sInput)
    sEnd = Right(sInput,1) 
    If (sEnd = "m") Or (sEnd = "u") Or (sEnd = "l") Or (sEnd = "v") Or (sEnd = "g")_
        Or (sEnd = "t") Or (sEnd = "z") Or (sEnd = "o") Or (sEnd = "e") Or (sEnd = "s")_
        Or (sEnd = "r") Or (sEnd = "n") Or (sEnd = "c") Or (sEnd = "k") Or (sEnd = "e") Then Exit Function

    Dim aArray, x
    aArray = Split(sInput,".") 
    If UBound(aArray) <> 3 Then Exit Function
    
    If Not (IsNumeric(aArray(0)) And IsNumeric(aArray(1)) And IsNumeric(aArray(2)) And IsNumeric(aArray(3))) Then Exit Function
    
    IsIpAddress = True
End Function


Sub ShowHelpAndQuit()
    WScript.Echo "Please read the header in the script file."
    WScript.Quit
End Sub


'END-O-SCRIPT **********************************************************
