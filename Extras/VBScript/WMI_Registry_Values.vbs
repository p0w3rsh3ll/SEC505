'***********************************************************************************
'        Name: GetRegistryValue()
'     Version: 1.2
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 26.May.2006
'     Purpose: Connects to local/remote system on which you have administrative 
'              rights and reads any registry value.  Function returns True
'              if no problems, false otherwise.
'       Notes: Use the period (".") to denote the local machine.  When reading a 
'              REG_MULTI_SZ or REG_BINARY value, the sValue variable must be an array 
'              of strings or bytes, respectively.  Declare as such before calling function.
'              Target machine must support WMI, e.g., Windows 2000 or later.
'              If you will be setting many values on one machine, modify the code
'              to pass in an array of values and set them all with one WMI connection.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without implied warranty or guarantee.  USE
'              AT YOUR OWN RISK and only on networks with prior written permission.
'***********************************************************************************


Function GetRegistryValue(sIPaddress,sHive,sPath,sValueName,sValueType,sValue)
    On Error Resume Next
    
    Const HKEY_LOCAL_MACHINE  = &H80000002
    Const HKEY_CLASSES_ROOT   = &H80000000
    Const HKEY_CURRENT_USER   = &H80000001 
    Const HKEY_USERS          = &H80000003
    Const HKEY_CURRENT_CONFIG = &H80000005 
    Const HKEY_DYN_DATA       = &H80000006  'Valid on Windows 9x only.
    
    Const REG_SZ              = 1
    Const REG_EXPAND_SZ       = 2
    Const REG_BINARY          = 3
    Const REG_DWORD           = 4
    Const REG_MULTI_SZ        = 7
    
    Dim oRegistry, bReturn, lsHive, lsValueName, lsValueType
    
    If InStr(sPath,"\") = 1 Then sPath = Trim(Right(sPath,Len(sPath) - 1))    'sPath should not start with a backslash.
    lsHive = Trim(UCase(Replace(sHive,"\","")))         'sHive should have no backslashes and be in uppercase.
    lsValueName = Trim(Replace(sValueName,"\",""))      'sValueName should have no backslashes.
    lsValueType = Trim(UCase(sValueType))   
    
    Set oRegistry = GetObject("WinMgmts:{ImpersonationLevel=Impersonate}!\\" & _ 
                                sIPaddress & "\root\default:StdRegProv")
    
    If Err.Number <> 0 Then
        'WScript.Echo Err.Description & ": " & sIPaddress
        GetRegistryValue = False
        Exit Function
    End If
            
    Select Case lsHive
        Case "HKEY_LOCAL_MACHINE","HKLM" 
            lsHive = HKEY_LOCAL_MACHINE
        Case "HKEY_CLASSES_ROOT","HKCR"
            lsHive = HKEY_CLASSES_ROOT
        Case "HKEY_CURRENT_USER","HKCU"
            lsHive = HKEY_CURRENT_USER
        Case "HKEY_USERS","HKU"
            lsHive = HKEY_USERS
        Case "HKEY_CURRENT_CONFIG","HKCC"
            lsHive = HKEY_CURRENT_CONFIG
        Case "HKEY_DYN_DATA","HKDD"
            lsHive = HKEY_DYN_DATA
        Case Else
            GetRegistryValue = False
            Exit Function
    End Select
    
            
    Select Case lsValueType
        Case "REG_DWORD","DWORD"
            bReturn = oRegistry.GetDWORDValue(lsHive,sPath,lsValueName,sValue)
            
        Case "REG_SZ","SZ"
            bReturn = oRegistry.GetStringValue(lsHive,sPath,lsValueName,sValue)
            
        Case "REG_EXPAND_SZ","EXPAND_SZ","EXPAND"
            bReturn = oRegistry.GetExpandedStringValue(lsHive,sPath,lsValueName,sValue)
            
        Case "REG_MULTI_SZ","MULTI_SZ","MULTI"
            If VarType(sValue) >= vbArray Then  'MULTI_SZ requires an array of strings.
                bReturn = oRegistry.GetMultiStringValue(lsHive,sPath,lsValueName,sValue)
            Else
                GetRegistryValue = False
                Exit Function
            End If
            
        Case "REG_BINARY","BINARY"
            If VarType(sValue) >= vbArray Then  'REG_BINARY requires an array of bytes.
                bReturn = oRegistry.GetBinaryValue(lsHive,sPath,lsValueName,sValue)
            Else
                GetRegistryValue = False
                Exit Function
            End If
            
        Case Else
            GetRegistryValue = False
            Exit Function
    End Select
            
     
    If (Err.Number = 0) And (bReturn = 0) Then 
        GetRegistryValue = True 
    Else 
        GetRegistryValue = False
    End If
    
    Set oRegistry = Nothing
End Function



'***********************************************************************************
'        Name: SetRegistryValue()
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 19.Mar.2003
'     Purpose: Connects to local/remote system on which you have administrative 
'              rights and sets/creates any registry value.  Function returns True
'              if no problems, false otherwise.
'       Notes: Script does not create any registry keys, but it will create the
'              specified value if it does not exist.  Use the period (".") to denote
'              the local machine.  When creating REG_MULTI_SZ or REG_BINARY values, 
'              the input value must be an array of strings or bytes, respectively.
'              Target machine must support WMI, e.g., Windows 2000 or later.
'              If you will be setting many values on one machine, modify the code
'              to pass in an array of values and set them all with one WMI connection.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without implied warranty or guarantee.  USE
'              AT YOUR OWN RISK and only on networks with prior written permission.
'***********************************************************************************

Function SetRegistryValue(sIPaddress,sHive,sPath,sValueName,sValueType,sValue)
    On Error Resume Next

    Const HKEY_LOCAL_MACHINE  = &H80000002
    Const HKEY_CLASSES_ROOT   = &H80000000
    Const HKEY_CURRENT_USER   = &H80000001 
    Const HKEY_USERS          = &H80000003
    Const HKEY_CURRENT_CONFIG = &H80000005 
    Const HKEY_DYN_DATA       = &H80000006  'Valid on Windows 9x only.
    
    Const REG_SZ              = 1
    Const REG_EXPAND_SZ       = 2
    Const REG_BINARY          = 3
    Const REG_DWORD           = 4
    Const REG_MULTI_SZ        = 7

    Dim oRegistry, bReturn, lsHive, lsValueName, lsValueType
    
    If InStr(sPath,"\") = 1 Then sPath = Trim(Right(sPath,Len(sPath) - 1))    'sPath should not start with a backslash.
    lsHive = Trim(UCase(Replace(sHive,"\","")))         'sHive should have no backslashes and be in uppercase.
    lsValueName = Trim(Replace(sValueName,"\",""))      'sValueName should have no backslashes.
    lsValueType = Trim(UCase(sValueType))   
    
    Set oRegistry = GetObject("WinMgmts:{ImpersonationLevel=Impersonate}!\\" & _ 
                                sIPaddress & "\root\default:StdRegProv")

    If Err.Number <> 0 Then
        'WScript.Echo Err.Description & ": " & sIPaddress
        SetRegistryValue = False
        Exit Function
    End If

    Select Case lsHive
        Case "HKEY_LOCAL_MACHINE","HKLM" 
            lsHive = HKEY_LOCAL_MACHINE
        Case "HKEY_CLASSES_ROOT","HKCR"
            lsHive = HKEY_CLASSES_ROOT
        Case "HKEY_CURRENT_USER","HKCU"
            lsHive = HKEY_CURRENT_USER
        Case "HKEY_USERS","HKU"
            lsHive = HKEY_USERS
        Case "HKEY_CURRENT_CONFIG","HKCC"
            lsHive = HKEY_CURRENT_CONFIG
        Case "HKEY_DYN_DATA","HKDD"
            lsHive = HKEY_DYN_DATA
        Case Else
            SetRegistryValue = False
            Exit Function
    End Select

    Select Case lsValueType
        Case "REG_DWORD","DWORD"
            bReturn = oRegistry.SetDWORDValue(lsHive,sPath,lsValueName,sValue)
            
        Case "REG_SZ","SZ"
            bReturn = oRegistry.SetStringValue(lsHive,sPath,lsValueName,CStr(sValue))
            
        Case "REG_EXPAND_SZ","EXPAND_SZ","EXPAND"
            bReturn = oRegistry.SetExpandedStringValue(lsHive,sPath,lsValueName,CStr(sValue))
            
        Case "REG_MULTI_SZ","MULTI_SZ","MULTI"
            If VarType(sValue) >= vbArray Then  'MULTI_SZ requires an array of strings.
                bReturn = oRegistry.SetMultiStringValue(lsHive,sPath,lsValueName,sValue)
            Else
                SetRegistryValue = False
                Exit Function
            End If
            
        Case "REG_BINARY","BINARY"
            If VarType(sValue) >= vbArray Then  'REG_BINARY requires an array of bytes.
                bReturn = oRegistry.SetBinaryValue(lsHive,sPath,lsValueName,sValue)
            Else
                SetRegistryValue = False
                Exit Function
            End If
            
        Case Else
            SetRegistryValue = False
            Exit Function
    End Select
    
    If (Err.Number = 0) And (bReturn = 0) Then 
        SetRegistryValue = True 
    Else 
        SetRegistryValue = False
    End If
    
    Set oRegistry = Nothing
End Function





'***********************************************************************************
' The following demonstrates the functions.
'***********************************************************************************


WScript.Quit 'Comment this out to test script.

  aData = Array("The","SANS","Institute")
aBytes1 = Array(0,1,2,3,128,240,255) 'But not 256! &HFF = 255
aBytes2 = Array(&H00,&H01,&H02,&H03,&H80,&HF0,&HFF)
sComputer = "."

SetRegistryValue sComputer,"HKCU","Control Panel\Keyboard","SANS1","REG_DWORD",333
SetRegistryValue sComputer,"HKCU","Control Panel\Keyboard","SANS2","REG_SZ","www.sans.org"
SetRegistryValue sComputer,"HKCU","Control Panel\Keyboard","SANS3","REG_EXPAND_SZ","%SystemRoot%\SANS"
SetRegistryValue sComputer,"HKCU","Control Panel\Keyboard","SANS4","REG_MULTI_SZ",aData
SetRegistryValue sComputer,"HKCU","Control Panel\Keyboard","SANS5","REG_BINARY",aBytes1

If SetRegistryValue(sComputer,"HKCU","Control Panel\Keyboard","SANS6","REG_BINARY",aBytes2) Then
    WScript.Echo "Change written!"
Else
    WScript.Echo "Not written."
End If

