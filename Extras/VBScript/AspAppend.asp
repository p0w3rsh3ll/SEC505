<%@ LANGUAGE="VBSCRIPT" %>
<%
'*********************************************************
'Version: 1.0
'Date: 8.July.2003
'Note: Used to demonstrate IIS authentication principles.
'      It attempts to append some text to c:\AspAppend.txt
'      under the context of the authenticated user, hence,
'      showing that NTFS permissions are enforced.
'*********************************************************
Set oWshShellNet = Server.CreateObject("WScript.Network")
sUserAccount = UCase(oWshShellNet.UserName) 
If IsObject(oWshShellNet) Then Set oWshShellNet = Nothing

If AppendToTextFile(Now(),"c:\AspAppend.txt") Then
    Response.Write("<h2>Authenticated User = " & sUserAccount & "<P>")
    Response.Write("Success! A timestamp was written to C:\AspAppend.txt</h2>")
Else
    Response.Write("<h2>Authenticated User = " & sUserAccount & "<P>")
    Response.Write("Error: " & Err.Description & "</h2>")
End If



Function AppendToTextFile(sLine, sFile)
    On Error Resume Next
    Const ForAppending =      8
    Const ForOverWriting =    2
    Const ForReading =        1
    Const OpenAsASCII =       0
    Const OpenAsUnicode =    -1
    Const OpenUsingDefault = -2
    
    'Changed "WScript." to "Server." in the next line for ASP compliance...
    If Not IsObject(oFileSystem) Then Set oFileSystem = Server.CreateObject("Scripting.FileSystemObject")
    
    If Not oFileSystem.FileExists(sFile) Then 
        Set oTextStream = oFileSystem.CreateTextFile(sFile)
    Else
        Set oFile = oFileSystem.GetFile(sFile)
        Set oTextStream = oFile.OpenAsTextStream(ForAppending, OpenUsingDefault)     
    End If

    
    If oTextStream.Column = 1 Then
        oTextStream.WriteLine(sLine)  
    Else
        oTextStream.WriteLine(vbCr)
        oTextStream.WriteLine(sLine)
    End If

    oTextStream.Close
    
    Set oTextStream = Nothing   
    Set oFile = Nothing
    
    If Err.Number = 0 Then 
        AppendToTextFile = True  
    Else  
        AppendToTextFile = False
    End If
End Function

%>


