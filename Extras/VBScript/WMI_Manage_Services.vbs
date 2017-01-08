'***********************************************************************************
' Script Name: WMI_Manage_Services.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 3/19/03
'     Purpose: Functions for starting/stopping services on local/remote systems.
'    Keywords: WMI, WBEM, service, start, stop, daemon
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************

Function StopServiceAndAntecedents(sIPaddress,sServiceName)
    On Error Resume Next
    Dim oWMI, cTargetService, cServicesThatDependOnIt, bFlag
    bFlag = True  'Assume function will work until error is detected.
    
    Set oWMI = GetObject("WinMgmts:{ImpersonationLevel=Impersonate}!\\" & sIPaddress & "\root\cimv2")
    Set cServicesThatDependOnIt = oWMI.ExecQuery("Associators of {Win32_Service.Name='" & sServiceName & "'} WHERE AssocClass=Win32_DependentService Role=Antecedent")
    
    For Each oItem In cServicesThatDependOnIt
        If oItem.State = "Running" Then 
    		If (oItem.StopService() <> 0) Then bFlag = False ': WScript.Echo "Problem stopping " & oItem.Name
        End If        
    Next
    
    WScript.Sleep 35000  
    
    Set cTargetService = oWMI.ExecQuery("SELECT * from Win32_Service WHERE Name='" & sServiceName & "'")
    For Each oItem In cTargetService
        If oItem.State = "Running" Then 
            If (oItem.StopService() <> 0) Then bFlag = False ': WScript.Echo "Problem stopping " & oItem.Name
        End If
    Next
    
    If (bFlag = True) And (Err.Number = 0) Then
        StopServiceAndAntecedents = True
    Else
        StopServiceAndAntecedents = False
    End If
    
    Set cServicesThatDependOnIt = Nothing
    Set cTargetService = Nothing
    Set oWMI = Nothing
End Function




Function StartServiceAndAutostartDependents(sIPaddress, sServiceName)
    On Error Resume Next
    Dim oWMI, cTargetService, cServicesThatDependOnIt, bFlag
    bFlag = True  'Assume function will work until error is detected.
    
    Set oWMI = GetObject("WinMgmts:{ImpersonationLevel=Impersonate}!\\" & sIPaddress & "\root\cimv2")
    
    Set cTargetService = oWMI.ExecQuery("SELECT * from Win32_Service WHERE Name='" & sServiceName & "'")
    For Each oItem In cTargetService
        If oItem.State = "Stopped" Then 
            If (oItem.StartService() <> 0) Then bFlag = False ': WScript.Echo "Problem starting " & oItem.Name
        End If
    Next
    
    WScript.Sleep 35000  
    
    Set cServicesThatDependOnIt = oWMI.ExecQuery("Associators of {Win32_Service.Name='" & sServiceName & "'} Where AssocClass=Win32_DependentService Role=Antecedent")
    For Each oItem In cServicesThatDependOnIt
        If oItem.State = "Stopped" And oItem.StartMode = "Auto" Then 
            If (oItem.StartService() <> 0) Then bFlag = False ': WScript.Echo "Problem starting " & oItem.Name
        End If
    Next
    
    If (bFlag = True) And (Err.Number = 0) Then
        StartServiceAndAutostartDependents = True
    Else
        StartServiceAndAutostartDependents = False
    End If

    Set cServicesThatDependOnIt = Nothing
    Set cTargetService = Nothing
    Set oWMI = Nothing
End Function


'***********************************************************************************
' It can be difficult to know the name of the service as WMI understands it.
' This procedure dumps a listing of services and their names (on the left) in the
' format which the two functions above expect.  Works locally or remotely.
'***********************************************************************************
Sub WmiListServiceNames(sIPaddress)
    Set oWMI = GetObject("WinMgmts:{ImpersonationLevel=Impersonate}!\\" & sIPaddress & "\root\cimv2")
    Set cCollection = oWMI.ExecQuery("SELECT * FROM Win32_Service")
    For Each oItem In cCollection
        WScript.Echo oItem.Name & " = """ & oItem.Description & """ (" & oItem.State & ")" 
    Next
End Sub



'END OF SCRIPT**********************************************************************


'The following demonstrates the code above.

Call WmiListServiceNames(".")
If StopServiceAndAntecedents(".", "W3SVC") Then WScript.Echo "Done: Good" Else WScript.Echo "Done: Bad"
WScript.Sleep 3000
If StartServiceAndAutostartDependents(".", "W3SVC") Then WScript.Echo "Done: Good" Else WScript.Echo "Done: Bad"
