'***********************************************************************************
' Script Name: WMI_List_Drivers.vbs
'     Version: 3.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 07/22/03
'     Purpose: Connects to target and enumerates all drivers, including their state,
'              path, startup mode and description.
'       Usage: Enter IP address of target as an argument to script.
'       Notes: Script connects under the credentials of the current user, so you
'              must be logged on as a domain-wide administrator.
'    Keywords: WMI, WBEM, driver, drivers, ps, enumerate, 
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************
On Error Resume Next
sIPaddress = "127.0.0.1"
sIPaddress = WScript.Arguments.Item(0)


Set oWMI = GetObject("WinMgmts://" & sIPaddress & "/root/cimv2")
Set cDrivers = oWMI.ExecQuery("SELECT * FROM Win32_SystemDriver")

For Each oDriver In cDrivers
    WScript.Echo "       NAME: " & oDriver.Name 
    WScript.Echo "DESCRIPTION: " & oDriver.Description 
    WScript.Echo "       PATH: " & oDriver.PathName 
    WScript.Echo "       TYPE: " & oDriver.ServiceType
    WScript.Echo "      STATE: " & oDriver.State 
    WScript.Echo " START-MODE: " & oDriver.StartMode
	WScript.Echo "-------------------------------------------------------------"
Next








'***********************************************************************************
'Procedure Name: ConnectToObjectDirectly()
'       Purpose: Demonstrates one method of using WMI to enumerate drivers.
'***********************************************************************************
Sub ConnectToObjectDirectly(ByVal sIPaddress)
    On Error Resume Next
    
    Set oWMIobject = GetObject("WinMgmts://" & sIPaddress & "/root/cimv2:Win32_SystemDriver")
    Call CatchAnyErrorsAndQuit("Problem connecting to WMI object on target.")
    
    Set cDrivers = oWMIobject.Instances_  'Instances_ is a method of the WMI object which returns a collection.
    
    For Each oDriver In cDrivers
    	WScript.Echo oDriver.Name & " DESCRIPTION:(" & oDriver.Description & ") PATH:(" & oDriver.PathName & ") TYPE:(" & oDriver.ServiceType & ") STATE:(" & oDriver.State & ") START-MODE:(" & oDriver.StartMode & ")"
    Next
    
    Set cDrivers = Nothing    
    Set oWMIobject = Nothing
End Sub



'***********************************************************************************
'Procedure Name: ConnectToWMIservicesFirst()
'       Purpose: Demonstrates another method of using WMI to enumerate services.
'***********************************************************************************
Sub ConnectToWMIservicesFirst(ByVal sIPaddress)
    On Error Resume Next

    Set oWMIservices = GetObject("WinMgmts://" & sIPaddress & "/root/cimv2")
    Call CatchAnyErrorsAndQuit("Problem connecting to WMI service on target.")

    Set cDrivers = oWMIservices.InstancesOf("Win32_SystemDriver")
    
    For Each oDriver In cDrivers
    	WScript.Echo oDriver.Name & " DESCRIPTION:(" & oDriver.Description & ") PATH:(" & oDriver.PathName & ") TYPE:(" & oDriver.ServiceType & ") STATE:(" & oDriver.State & ") START-MODE:(" & oDriver.StartMode & ")"
    Next
    
    Set cDrivers = Nothing
    Set oWMIservices = Nothing
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
