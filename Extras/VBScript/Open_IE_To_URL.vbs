'*****************************************************
' Script Name: Open_IE_To_URL.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'     Purpose: Opens an instance of Internet Explorer to
'              the URL specified.
'       Legal: Public Domain.  
'*****************************************************


Set oIE = WScript.CreateObject("InternetExplorer.Application")
oIE.Navigate("http://www.isascripts.org")
oIE.Visible = 1
Set oIE = Nothing   'This does not close the browser.




'*****************************************************


