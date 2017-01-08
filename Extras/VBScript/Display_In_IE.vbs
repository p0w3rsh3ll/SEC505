'*****************************************************
' Script Name: Display_In_IE.vbs
'     Version: 1.2
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 15.Jul.2006
'     Purpose: Demonstrates how to use Internet Explorer to display
'              HTML-tagged data to the script user (instead of
'              using plain text in message boxes).
'       Legal: Public Domain.  No rights reserved.
'*****************************************************



Sub DisplayInInternetExplorer(ByRef sHtmlData)
    Set oIE = WScript.CreateObject("InternetExplorer.Application")
    oIE.Navigate "about:blank"
    oIE.ToolBar = 0
    oIE.StatusBar = 0
    oIE.Width = 600
    oIE.Height = 500
    oIE.Left = 150
    oIE.Top = 150
    oIE.Visible = 1
    
    Do While oIE.Busy
       WScript.Sleep(100)
    Loop
    
    Set oDocument = oIE.Document
    oDocument.Open    
    oDocument.Write(sHtmlData)
    oDocument.Close
    
    Set oDocument = Nothing
    Set oIE = Nothing 
End Sub




'
' The following shows the procedure in action...
'

Call DisplayInInternetExplorer("<html><body><h1>Great!</h1><br>Just mark up your output with some HTML tags and pop up an IE window!</body></html>")


