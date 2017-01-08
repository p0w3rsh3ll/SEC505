'***********************************************************************************
' Script Name: ISA_DNS_Binding_Order.vbs
'     Version: 1.0
'        Date: 1.Feb.2006
'      Author: Jason Fossen ( www.ISAscripts.org ) 
'     Purpose: Changes the order in which DNS servers are queried when different DNS
'              servers are associated with different interfaces and one of those
'              interfaces is a VPN or dial-up connection.  The script causes the DNS 
'              servers associated with the VPN or dial-up connection to either be queried 
'              first or last (presumably first when the VPN or modem is connected, and 
'              last when it is not).  See the "/?" switch for more information.
'       Notes: See the following excellent discussion of this issue by Stefaan Pouseele:
'              http://www.isaserver.org/tutorials/work-around-VPN-clients-split-DNS.html
'              See also http://support.microsoft.com/default.aspx?scid=kb;en-us;311218
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY
'              KIND. USE AT YOUR OWN RISK.
'***********************************************************************************
Option Explicit
On Error Resume Next

Const sHive      = "HKLM"
Const sPath      = "SYSTEM\CurrentControlSet\Services\Tcpip\Linkage\"
Const sValueName = "Bind"
Const sValueType = "REG_MULTI_SZ"

Dim sArg       : sArg = "/?"
Dim sIPaddress : sIPaddress = "."   'Assume action against local machine.
Dim arrData(0)                      'Will hold the return of GetRegistryValue()

    
Call ProcessCommandLineArguments()



'*************************************************************************************
' Procedures and Functions
'*************************************************************************************

Sub ProcessCommandLineArguments()
    On Error Resume Next

    If WScript.Arguments.Count = 2 Then
        sIPaddress = Replace(LCase(WScript.Arguments.Item(0)),"\\","")  'Strip '\\' from name or IP address of computer.
        sArg = LCase(WScript.Arguments.Item(1))
    End If

    If WScript.Arguments.Count = 1 Then sArg = LCase(WScript.Arguments.Item(0))      
    
    If (WScript.Arguments.Count = 0) Or (WScript.Arguments.Count > 2) Or (sArg = "/?")_ 
        Or (sArg = "-?") Or (sArg = "/h") Or (sArg = "/help") Or (sArg = "--help") Then
        Call ShowHelpAndQuit()
    End If
    
    Select Case sArg
        Case "/show","-show","show"
            Call Show()
        Case "/first","-first","first"
            Call WanFirst()
        Case "/last","-last","last"
            Call WanLast()
        Case "/toggle","-toggle","toggle"
            Call Toggle()
        Case Else
            Call ShowHelpAndQuit()
    End Select
    
    On Error Goto 0     
End Sub



Sub Show()
    Dim sResult : sResult = vbCrLf & "Current DNS Binding Order:" & vbCrLf & vbCrLf
    Dim i : i = 1
    Dim sItem
    
    If GetRegistryValue(sIPaddress,sHive,sPath,sValueName,sValueType,arrData) Then
        For Each sItem In arrData
            sResult = sResult & i & ") " & sItem & vbCrLf
            i = i + 1
        Next
        
        sResult = sResult & vbCrLf & "VPN or modem corresponds to the ""\Device\NdisWanIp"" entry."
    Else
        sResult = vbCrLf & "Error Reading Registry Value!" & vbCrLf & Err.Description & vbCrLf
    End If
    
    WScript.Echo sResult
    WScript.Quit
End Sub



Sub WanFirst()
    Dim strData
    
    If GetRegistryValue(sIPaddress,sHive,sPath,sValueName,sValueType,arrData) Then
        strData = Join(arrData,"::")
        strData = Replace(strData, "::\Device\NdisWanIp", "")   'Delete from bottom, if it's there.
        strData = Replace(strData, "\Device\NdisWanIp::", "")   'Delete from anywhere else, if there.
        strData = "\Device\NdisWanIp::" & strData               'Put just one at the top.
        arrData = Split(strData, "::")

        If Not SetRegistryValue(sIPaddress,sHive,sPath,sValueName,sValueType,arrData) Then
            WScript.Echo vbCrLf & "Error Setting Registry Value! (SetRegistryValue)" & vbCrLf & Err.Description & vbCrLf
        End If
    Else
        WScript.Echo vbCrLf & "Error Reading Registry Value!" & vbCrLf & Err.Description & vbCrLf
    End If
    
    If Err.Number <> 0 Then WScript.Echo vbCrLf & "Error Setting Registry Value! (Err)" & vbCrLf & Err.Description & vbCrLf
    WScript.Quit
End Sub



Sub WanLast()
    Dim strData
    
    If GetRegistryValue(sIPaddress,sHive,sPath,sValueName,sValueType,arrData) Then
        strData = Join(arrData,"::")
        strData = Replace(strData, "::\Device\NdisWanIp", "")   'Delete from bottom, if it's there.
        strData = Replace(strData, "\Device\NdisWanIp::", "")   'Delete from anywhere else, if there.
        strData = strData & "::\Device\NdisWanIp"               'Put just one at the bottom.
        arrData = Split(strData, "::")

        If Not SetRegistryValue(sIPaddress,sHive,sPath,sValueName,sValueType,arrData) Then
            WScript.Echo vbCrLf & "Error Setting Registry Value! (SetRegistryValue)" & vbCrLf & Err.Description & vbCrLf
        End If
    Else
        WScript.Echo vbCrLf & "Error Reading Registry Value!" & vbCrLf & Err.Description & vbCrLf
    End If
    
    If Err.Number <> 0 Then WScript.Echo vbCrLf & "Error Setting Registry Value! (Err)" & vbCrLf & Err.Description & vbCrLf
    WScript.Quit
End Sub



Sub Toggle()
    Dim strData
    
    If GetRegistryValue(sIPaddress,sHive,sPath,sValueName,sValueType,arrData) Then
        If InStr(LCase(arrData(0)) , "\device\ndiswanip") <> 0 Then 
            Call WanLast()
        Else 
            Call WanFirst()
        End If
    Else
        WScript.Echo vbCrLf & "Error Reading Registry Value!" & vbCrLf & Err.Description & vbCrLf
    End If
    
    WScript.Quit
End Sub



'***********************************************************************************
'        Name: GetRegistryValue()
'     Version: 1.0
'      Author: Jason Fossen
'Last Updated: 19.Mar.2003
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
    
    Dim oRegistry, bReturn
    
    If InStr(sPath,"\") = 1 Then sPath = Trim(Right(sPath,Len(sPath) - 1))    'sPath should not start with a backslash.
    sHive = Trim(UCase(Replace(sHive,"\","")))         'sHive should have no backslashes and be in uppercase.
    sValueName = Trim(Replace(sValueName,"\",""))      'sValueName should have no backslashes.
    sValueType = Trim(UCase(sValueType))   
    
    Set oRegistry = GetObject("WinMgmts:{ImpersonationLevel=Impersonate}!\\" & _ 
                                sIPaddress & "\root\default:StdRegProv")
    
    If Err.Number <> 0 Then
        'WScript.Echo Err.Description & ": " & sIPaddress
        GetRegistryValue = False
        Exit Function
    End If
            
    Select Case sHive
        Case "HKEY_LOCAL_MACHINE","HKLM" 
            sHive = HKEY_LOCAL_MACHINE
        Case "HKEY_CLASSES_ROOT","HKCR"
            sHive = HKEY_CLASSES_ROOT
        Case "HKEY_CURRENT_USER","HKCU"
            sHive = HKEY_CURRENT_USER
        Case "HKEY_USERS","HKU"
            sHive = HKEY_USERS
        Case "HKEY_CURRENT_CONFIG","HKCC"
            sHive = HKEY_CURRENT_CONFIG
        Case "HKEY_DYN_DATA","HKDD"
            sHive = HKEY_DYN_DATA
        Case Else
            GetRegistryValue = False
            Exit Function
    End Select
    
            
    Select Case sValueType
        Case "REG_DWORD","DWORD"
            bReturn = oRegistry.GetDWORDValue(sHive,sPath,sValueName,sValue)
            
        Case "REG_SZ","SZ"
            bReturn = oRegistry.GetStringValue(sHive,sPath,sValueName,sValue)
            
        Case "REG_EXPAND_SZ","EXPAND_SZ","EXPAND"
            bReturn = oRegistry.GetExpandedStringValue(sHive,sPath,sValueName,sValue)
            
        Case "REG_MULTI_SZ","MULTI_SZ","MULTI"
            If VarType(sValue) >= vbArray Then  'MULTI_SZ requires an array of strings.
                bReturn = oRegistry.GetMultiStringValue(sHive,sPath,sValueName,sValue)
            Else
                GetRegistryValue = False
                Exit Function
            End If
            
        Case "REG_BINARY","BINARY"
            If VarType(sValue) >= vbArray Then  'REG_BINARY requires an array of bytes.
                bReturn = oRegistry.GetBinaryValue(sHive,sPath,sValueName,sValue)
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
'      Author: Jason Fossen
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

    Dim oRegistry, bReturn
    
    If InStr(sPath,"\") = 1 Then sPath = Trim(Right(sPath,Len(sPath) - 1))    'sPath should not start with a backslash.
    sHive = Trim(UCase(Replace(sHive,"\","")))         'sHive should have no backslashes and be in uppercase.
    sValueName = Trim(Replace(sValueName,"\",""))      'sValueName should have no backslashes.
    sValueType = Trim(UCase(sValueType))   
    
    Set oRegistry = GetObject("WinMgmts:{ImpersonationLevel=Impersonate}!\\" & _ 
                                sIPaddress & "\root\default:StdRegProv")

    If Err.Number <> 0 Then
        'WScript.Echo Err.Description & ": " & sIPaddress
        SetRegistryValue = False
        Exit Function
    End If

    Select Case sHive
        Case "HKEY_LOCAL_MACHINE","HKLM" 
            sHive = HKEY_LOCAL_MACHINE
        Case "HKEY_CLASSES_ROOT","HKCR"
            sHive = HKEY_CLASSES_ROOT
        Case "HKEY_CURRENT_USER","HKCU"
            sHive = HKEY_CURRENT_USER
        Case "HKEY_USERS","HKU"
            sHive = HKEY_USERS
        Case "HKEY_CURRENT_CONFIG","HKCC"
            sHive = HKEY_CURRENT_CONFIG
        Case "HKEY_DYN_DATA","HKDD"
            sHive = HKEY_DYN_DATA
        Case Else
            SetRegistryValue = False
            Exit Function
    End Select

    Select Case sValueType
        Case "REG_DWORD","DWORD"
            bReturn = oRegistry.SetDWORDValue(sHive,sPath,sValueName,sValue)
            
        Case "REG_SZ","SZ"
            bReturn = oRegistry.SetStringValue(sHive,sPath,sValueName,CStr(sValue))
            
        Case "REG_EXPAND_SZ","EXPAND_SZ","EXPAND"
            bReturn = oRegistry.SetExpandedStringValue(sHive,sPath,sValueName,CStr(sValue))
            
        Case "REG_MULTI_SZ","MULTI_SZ","MULTI"
            If VarType(sValue) >= vbArray Then  'MULTI_SZ requires an array of strings.
                bReturn = oRegistry.SetMultiStringValue(sHive,sPath,sValueName,sValue)
            Else
                SetRegistryValue = False
                Exit Function
            End If
            
        Case "REG_BINARY","BINARY"
            If VarType(sValue) >= vbArray Then  'REG_BINARY requires an array of bytes.
                bReturn = oRegistry.SetBinaryValue(sHive,sPath,sValueName,sValue)
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



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & "ISA_DNS_BINDING_ORDER.VBS [\\machine] Action" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Changes the order in which DNS servers are queried when there" & vbCrLf
    sUsage = sUsage & "are different DNS servers associated with different interfaces" & vbCrLf
    sUsage = sUsage & "and one of those interfaces is a VPN or dial-up interface.  " & vbCrLf
    sUsage = sUsage & "Typically, you want the DNS servers associated with the VPN or" & vbCrLf
    sUsage = sUsage & "dial-up interface to be queried first while the VPN or modem is " & vbCrLf
    sUsage = sUsage & "connected, and last when the VPN or modem is not connected." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   \\machine     Optional. Name or IP address of remote computer." & vbCrLf
    sUsage = sUsage & "                 Script defaults to local machine when omitted." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   Action        One of the following:" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "                 /show   -- Shows current DNS binding order." & vbCrLf
    sUsage = sUsage & "                 /first  -- Query VPN/Dial-Up DNS servers first." & vbCrLf
    sUsage = sUsage & "                 /last   -- Query VPN/Dial-Up DNS servers last." & vbCrLf
    sUsage = sUsage & "                 /toggle -- Switches back and forth: VPN/Dial-Up" & vbCrLf
    sUsage = sUsage & "                            DNS servers will be made first if " & vbCrLf
    sUsage = sUsage & "                            they are currently last, or made last" & vbCrLf
    sUsage = sUsage & "                            if they are currently first." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "See the following excellent discussion of this issue by Stefaan Pouseele:" & vbCrLf
    sUsage = sUsage & "http://www.isaserver.org/tutorials/work-around-VPN-clients-split-DNS.html" & vbCrLf
    sUsage = sUsage & "See also http://support.microsoft.com/default.aspx?scid=kb;en-us;311218" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "SCRIPT PROVIDED ""AS IS"" AND WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND." & vbCrLf
    sUsage = sUsage & "USE AT YOUR OWN RISK.  ( www.ISAscripts.org )" & vbCrLf

    WScript.Echo sUsage
    WScript.Quit
End Sub


'END OF SCRIPT ************************************************************************
