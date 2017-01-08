'***********************************************************************************
' Script Name: Listening_Ports.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 20.Feb.2004
'     Purpose: Show listening TCP/UDP ports and the processes behind them.
'       Notes: Requires WSH 5.6 or later.  Only works on Windows XP/2003 or later.
'    Keywords: ports, listening, TCP
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************
On Error Resume Next

' 
' Do some requirements checking and exit if they're not met.  Relaunch with CSCRIPT.EXE if necessary.
'
If CSng(WScript.Version) < CSng(5.6) Then
    WScript.Echo("Windows Script Host (WSH) must be version 5.6 or better!")
    WScript.Quit(-1)
End If

Set oWMI = GetObject("WinMgmts://./root/cimv2")
Set cComputerData = oWMI.ExecQuery("SELECT * FROM Win32_OperatingSystem")
For Each oItem In cComputerData
    If InStr(oItem.Caption, "Windows 2000") <> 0 Then
        WScript.Echo("Operating system must be Windows XP or later!")
        WScript.Quit(-1)
    End If
Next

If Err.Number <> 0 Then 
    WScript.Echo("Windows Script Host (WSH) must be version 5.6 or better, " &_
                 "and the operating system must be Windows XP or later!")
    WScript.Quit(-1)
End If

If Not IsUsingCScript() Then
    Set oWshShell = CreateObject("WScript.Shell")
    oWshShell.Run "cmd.exe /k cscript.exe //nologo " & """" & WScript.ScriptFullName & """"
    WScript.Quit(0)
End If


    
'
' Create an array of PROCESS objects from the custom PROCESS class below.
'
'Set oWMI = GetObject("WinMgmts://./root/cimv2")  'Already created above.
Set cProcesses = oWMI.ExecQuery("SELECT * FROM Win32_Process")
ReDim aProcesses(cProcesses.Count - 1) 
Dim sOwner, sDomain      'These are variables which will hold the returns from GetOwner() later.  
i = 0 
For Each oProcess In cProcesses
    oProcess.GetOwner sOwner, sDomain
    Set aProcesses(i) = New PROCESS
    aProcesses(i).Owner = sDomain & "\" & sOwner
    aProcesses(i).Name = oProcess.Name
    aProcesses(i).Path = oProcess.ExecutablePath
    aProcesses(i).PID =  oProcess.ProcessID
    i = i + 1
Next

Set cProcesses = Nothing
Set oWMI = Nothing



'
' Now run "netstat.exe -ano" and capture its output (-o switch shows PIDs).
'
Set oWshShell = CreateObject("WScript.Shell")
Set oExec = oWshShell.Exec("netstat.exe -ano")
sOutput = oExec.StdOut.ReadAll
Set oExec = Nothing



'
' Get the RegExp submatches of "netstat -ano" to update the ports and PIDs of the PROCESS objects.
'
Set oRegExp = New RegExp
oRegExp.Global = True 

oRegExp.Pattern = "TCP +(?!127\.0\.0\.1)[0-9\.]+:([0-9]{1,5}) [ 0-9\.:]+ LISTENING +([0-9]{1,5})"    'This pattern excludes ports listening on 127.0.0.1
'oRegExp.Pattern = "TCP +[0-9\.]+:([0-9]{1,5}) [ 0-9\.:]+ LISTENING +([0-9]{1,5})"    'This pattern includes ports listening on 127.0.0.1.  Choose one.
Set cMatches = oRegExp.Execute(sOutput) 
For Each sMatch in cMatches
    sPort = sMatch.SubMatches.Item(0)
    sPID  = sMatch.SubMatches.Item(1)                              
    For Each oProc In aProcesses
        If oProc.PID = sPID Then oProc.TcpPorts = oProc.TcpPorts & sPort & " "
    Next
Next

oRegExp.Pattern = "UDP +(?!127\.0\.0\.1)[0-9\.]+:([0-9]{1,5}).+ ([0-9]{1,5})"   'This pattern excludes ports listening on 127.0.0.1
'oRegExp.Pattern = "UDP +[0-9\.]+:([0-9]{1,5}).+ ([0-9]{1,5})"   'This pattern includes ports listening on 127.0.0.1.  Choose one.
Set cMatches = oRegExp.Execute(sOutput) 
For Each sMatch in cMatches
    sPort = sMatch.SubMatches.Item(0)
    sPID  = sMatch.SubMatches.Item(1)                              
    For Each oProc In aProcesses
        If oProc.PID = sPID Then oProc.UdpPorts = oProc.UdpPorts & sPort & " "
    Next
Next

Set cMatches = Nothing
Set oRegExp = Nothing



'
' Cycle through all the PROCESS objects and print their port information (if any).
'
For Each oProc In aProcesses
    If (oProc.TcpPorts <> "") Or (oProc.UdpPorts <> "") Then 
        oProc.PrintList
        'oProc.PrintTabDelimited     'Choice of output formats...
    End If
Next        



'
'FIN -------------------------------------------------------------------
'



Class PROCESS
    Public Name
    Public Path
    Public Owner
    Public UdpPorts
    Public TcpPorts
    
    Private pvtPID
    Private pvtReport
    
    Public Property Let PID(ByVal sPID)  'Better to cast to string to avoid comparison/evaluation problems.
        pvtPID = CStr(sPID)
    End Property
    
    Public Property Get PID
        PID = CStr(pvtPID)
    End Property    

    Public Sub PrintTabDelimited
        'Name    PID    Path    Owner    TCP-Ports    UDP-Ports
        WScript.Echo Name & vbTab & PID & vbTab & Path & vbTab & Owner & vbTab & Trim(TcpPorts) & vbTab & Trim(UdpPorts)
    End Sub

    Public Sub PrintList
                    pvtReport = "----------------------------------------------" & vbCrLf
        pvtReport = pvtReport & "  Process: " & Name & vbCrLf
        pvtReport = pvtReport & "      PID: " & CStr(pvtPID) & vbCrLf
        pvtReport = pvtReport & "     Path: " & Path & vbCrLf
        pvtReport = pvtReport & "    Owner: " & Owner & vbCrLf
        pvtReport = pvtReport & "TCP Ports: " & Replace(Trim(TcpPorts)," ",", ") & vbCrLf
        pvtReport = pvtReport & "UDP Ports: " & Replace(Trim(UdpPorts)," ",", ")  
        WScript.Echo(pvtReport)
    End Sub
End Class


Function IsUsingCscript()
    Dim iPosition
    iPosition = InStr( LCase(WScript.FullName) , "cscript.exe" )
    If iPosition = 0 Then IsUsingCscript = False Else IsUsingCscript = True 
End Function


'END OF SCRIPT *********************************************************************
