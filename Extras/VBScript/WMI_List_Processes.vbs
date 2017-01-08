'***********************************************************************************
' Script Name: WMI_List_Processes.vbs
'     Version: 3.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 07/22/03
'     Purpose: Connects to target and enumerates all running processes, including
'              their PID numbers and domain\useraccount owners.
'       Usage: Enter IP address of target as an argument to script.
'       Notes: Script connects under the credentials of the current user, so you
'              must be logged on as a domain-wide administrator.
'    Keywords: WMI, WBEM, process, processes, ps, enumerate, PID
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************
On Error Resume Next
sIPaddress = "127.0.0.1"
sIPaddress = WScript.Arguments.Item(0)

Dim sOwner, sDomain      'These are variables which will hold the returns from GetOwner(). 

Set oWMI = GetObject("WinMgmts://" & sIPaddress & "/root/cimv2")
Set cProcesses = oWMI.ExecQuery("SELECT * FROM Win32_Process")

For Each oProcess In cProcesses
    oProcess.GetOwner sOwner, sDomain
	WScript.Echo "  NAME: " & oProcess.Name
    WScript.Echo " OWNER: " & sDomain & "\" & sOwner 
	WScript.Echo "  PATH: " & oProcess.ExecutablePath 
	WScript.Echo "   PID: " & oProcess.ProcessID
	WScript.Echo "MEMORY: " & oProcess.WorkingSetSize / 1024 & " KB"
	WScript.Echo "----------------------------------------------------------------"
Next









'***********************************************************************************
'Procedure Name: ConnectToWMIservicesFirst()
'       Purpose: Demonstrates another method of using WMI to enumerate services.
'***********************************************************************************
Sub ConnectToWMIservicesFirst(ByVal sIPaddress)
    On Error Resume Next
    Dim sOwner, sDomain 'These are variables which will hold the returns from GetOwner.

    Set oWMIservices = GetObject("WinMgmts://" & sIPaddress & "/root/cimv2")
    Call CatchAnyErrorsAndQuit("Problem connecting to WMI service on target.")

    Set cProcesses = oWMIservices.InstancesOf("Win32_Process")
    
    For Each oProcess In cProcesses
        oProcess.GetOwner sOwner, sDomain 
    	WScript.Echo oProcess.Name & " PATH:(" & oProcess.ExecutablePath & ") PID:(" & oProcess.ProcessID & ") OWNER:(" & sDomain & "\" & sOwner & ")"
    Next
    
    Set cProcesses = Nothing
    Set oWMIservices = Nothing
End Sub



'***********************************************************************************
'Procedure Name: ConnectToObjectDirectly()
'       Purpose: Demonstrates and yet another method of using WMI to enumerate services.
'***********************************************************************************
Sub ConnectToObjectDirectly(ByVal sIPaddress)
    On Error Resume Next
    Dim sOwner, sDomain 'These are variables which will hold the returns from GetOwner.  Strictly speaking, they are not needed here.
    
    Set oWMIobject = GetObject("WinMgmts://" & sIPaddress & "/root/cimv2:Win32_Process")
    Call CatchAnyErrorsAndQuit("Problem connecting to WMI object on target.")
    
    Set cProcesses = oWMIobject.Instances_  'Instances_ is a method of the WMI object which returns a collection.
    
    For Each oProcess In cProcesses
        oProcess.GetOwner sOwner, sDomain
    	WScript.Echo oProcess.Name & " PATH:(" & oProcess.ExecutablePath & ") PID:(" & oProcess.ProcessID & ") OWNER:(" & sDomain & "\" & sOwner & ")"
    Next
    
    Set cProcesses = Nothing    
    Set oWMIobject = Nothing
End Sub



'***********************************************************************************
'  Helper Functions and Procedures
'***********************************************************************************
Sub CatchAnyErrorsAndQuit(msg)
	If Err.Number <> 0 Then
		sOutput = vbCrLf
		sOutput = sOutput &  "ERROR:             " & msg & vbCrLf 
		sOutput = sOutput &  "Error Number:      " & Err.Number & vbCrlf
		sOutput = sOutput &  "Error Description: " & Err.Description & vbCrLf
		sOutput = sOutput &  "Error Source:      " & Err.Source & vbCrLf 
		sOutput = sOutput &  "Script Name:       " & WScript.ScriptName & vbCrLf 
		sOutput = sOutput &  vbCrLf
		
        WScript.Echo sOutput
		WScript.Quit Err.Number
	End If 
End Sub 


'END OF SCRIPT**********************************************************************
