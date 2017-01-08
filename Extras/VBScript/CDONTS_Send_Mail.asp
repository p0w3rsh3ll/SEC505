<%@ LANGUAGE="VBSCRIPT" %>

<HTML>
<BODY>

<%
' Enter a description of this page to remind yourself.
sDescription = "This page is part of the RDS exploit!"


' Assemble information to be placed into event log entry and e-mail message.
sResult = "Suspicious attempt to access dangerous web page:" & vbCrLf
sResult = sResult & sDescription & vbCrLf & vbCrLf

sResult = sResult &  "Date: " & Now & vbCrLf
sResult = sResult &  "IIS Server IP: " & Request.ServerVariables("LOCAL_ADDR") & vbCrLf 
sResult = sResult &  "IIS Server Name: " & Request.ServerVariables("SERVER_NAME") & vbCrLf
sResult = sResult &  "URL Path: " & Request.ServerVariables("URL") & vbCrLf
sResult = sResult &  "Local Path: " & Request.ServerVariables("PATH_TRANSLATED") & vbCrLf & vbCrLf

sResult = sResult &  "Client IP: " & Request.ServerVariables("REMOTE_ADDR") & vbCrLf
sResult = sResult &  "Client Host: " & Request.ServerVariables("REMOTE_HOST") & vbCrLf
sResult = sResult &  "Client User: " & Request.ServerVariables("REMOTE_USER") & vbCrLf
sResult = sResult &  "Client Browser: " & Request.ServerVariables("HTTP_USER_AGENT") & vbCrLf
sResult = sResult &  "Client Referer: " & Request.ServerVariables("HTTP_REFERER") & vbCrLf
sResult = sResult &  "Cookie: " & Request.ServerVariables("HTTP_COOKIE") & vbCrLf


' Write an event to the local Application log with assembled information. 
Set oServerShell = Server.CreateObject("WScript.Shell")
oServerShell.LogEvent 2, sResult
 


' Send e-mail to administrator with assembled information...the drawbacks of this should be
' obvious, but this script is intended to demonstrate functionality.  Be careful!
Const CdoBodyFormatHTML = 0
Const CdoBodyFormatText = 1
Const CdoMailFormatMime = 0
Const CdoMailFormatText = 1

Set oMsg = Server.CreateObject("CDONTS.NewMail")

oMsg.From = "webmaster@mothra.research.sans.org"
oMsg.To = "admin@mothra.research.sans.org"
oMsg.Subject = "Security Alert from the IIS Server!"
oMsg.Body = sResult
oMsg.BodyFormat = CdoBodyFormatText
oMsg.MailFormat = CdoMailFormatText

oMsg.Send

Set oMsg = Nothing
Set oServerShell = Nothing
%>




<p>
<center><h1>
Your access attempt has been logged.<p>

Your IP address is <% Response.Write(Request.ServerVariables("REMOTE_ADDR")) %><p>

<i>Have a nice day!</i>
</h1></center>

</BODY>
</HTML>
