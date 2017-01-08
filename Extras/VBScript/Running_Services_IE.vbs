Set oIE = CreateObject("InternetExplorer.Application")
oIE.Navigate "about:blank"
oIE.ToolBar = 0
oIE.StatusBar = 0
oIE.Width = 670
oIE.Height = 500
oIE.Left = 0
oIE.Top = 0
oIE.Visible = 1

Do While (oIE.Busy)
    WScript.Sleep(100)
Loop

Set oDocument = oIE.Document
oDocument.Open

oDocument.Writeln "<html><head><title>Running Services List</title></head>"
oDocument.Writeln "<body bgcolor='white'>"
oDocument.Writeln "<b>Service : State</b><HR>"

Set oWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Set cServices = oWMI.ExecQuery("SELECT * FROM Win32_Service")
 
For Each oService in cServices
 If oService.State = "Running" Then
    oDocument.Writeln oService.DisplayName & " : <Font color=Green>" & oService.State & "</font><BR>"
 Else 
    oDocument.Writeln oService.DisplayName & " : <Font color=Red>" & oService.State & "</font><BR>"
 End If
Next


oDocument.Writeln "</body></html>"
oDocument.Write()
oDocument.Close 

