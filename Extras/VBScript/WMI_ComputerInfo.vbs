'***********************************************************************************
' Script Name: WMI_ComputerInfo.vbs
'     Version: 2.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 21.Mar.2004
'     Purpose: Connects to target and dumps a mishmash of information.  This script
'              is mainly just to give a sampling of what can be queried via WMI.
'       Usage: Enter IP address of target as an argument to script.
'       Notes: Script connects under the credentials of the current user, so you
'              must be logged on as an administrator.
'    Keywords: WMI, WBEM, username, sysinfo, dump, enumerate 
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************

On Error Resume Next

If WScript.Arguments.Count = 1 Then
    sIPaddress = WScript.Arguments.Item(0)
Else
    sIPaddress = "127.0.0.1"
End If

Set oWMI = GetObject("WinMgmts://" & sIPaddress & "/root/cimv2")

If Err.Number <> 0 Then
    WScript.Echo sIPaddress & " : ERROR : " & Err.Description
    WScript.Quit(Err.Number)
End If


'
' *************************************************************************
'

WScript.Echo vbCr
Set cComputerData = oWMI.ExecQuery("SELECT * FROM Win32_ComputerSystem")
For Each oItem In cComputerData
    WScript.Echo "        Computer Name: " & oItem.Name 
    WScript.Echo "    Target IP Address: " & sIPaddress    
    WScript.Echo "          Domain Name: " & oItem.Domain
    WScript.Echo " Computer Description: " & oItem.Description
    WScript.Echo "Computer Manufacturer: " & oItem.Manufacturer
    WScript.Echo "       Computer Model: " & oItem.Model
    WScript.Echo " Number Of Processors: " & oItem.NumberOfProcessors
    WScript.Echo "Total Physical Memory: " & Round(oItem.TotalPhysicalMemory / 1048576,1) & " MB"
    WScript.Echo "          System Type: " & oItem.SystemType
    WScript.Echo " Primary Owner's Name: " & oItem.PrimaryOwnerName
    WScript.Echo " Who Is Logged On Now: " & oItem.UserName
Next
Set cComputerData = Nothing

'
' *************************************************************************
'

Set cComputerData = oWMI.ExecQuery("SELECT * FROM Win32_BIOS")
For Each oItem In cComputerData
    WScript.Echo "         BIOS Version: " & oItem.Version
    WScript.Echo "  BIOS Version Number: " & oItem.SMBIOSBIOSVersion
Next
Set cComputerData = Nothing

'
' *************************************************************************
'

Set cComputerData = oWMI.ExecQuery("SELECT * FROM Win32_Processor")
For Each oItem In cComputerData
    WScript.Echo "     CPU Manufacturer: " & oItem.Manufacturer
    WScript.Echo "             CPU Name: " & Trim(oItem.Name)  
    WScript.Echo "      CPU Clock Speed: " & oItem.CurrentClockSpeed & " MHz"
    WScript.Echo "        L2 Cache Size: " & oItem.L2CacheSize & " KB"
Next
Set cComputerData = Nothing

'
' *************************************************************************
'

Set cComputerData = oWMI.ExecQuery("SELECT * FROM Win32_OperatingSystem")
For Each oItem In cComputerData
    WScript.Echo "     Operating System: " & oItem.Caption 'or oItem.Name
    WScript.Echo "      OS Build Number: " & oItem.BuildNumber
    WScript.Echo "    OS Version Number: " & oItem.Version
    WScript.Echo " OS Installation Date: " & GetVBDate(oItem.InstallDate)
    WScript.Echo "     OS Serial Number: " & oItem.SerialNumber
    WScript.Echo "  Service Pack Number: " & oItem.ServicePackMajorVersion
Next
Set cComputerData = Nothing

'
' *************************************************************************
'

Set cComputerData = oWMI.ExecQuery("SELECT Name,SID,Disabled FROM Win32_UserAccount WHERE Disabled = 'False'")
sName = "UNKNOWN"
For Each oItem In cComputerData
    If Right(oItem.SID,4) = "-500" Then 
        sName = oItem.Name & " (even if renamed)"
        Exit For
    End If
Next
WScript.Echo " Built-In Admin Accnt: " & sName 
Set cComputerData = Nothing

'
' *************************************************************************
'

Set cComputerData = oWMI.ExecQuery("SELECT * FROM Win32_QuickFixEngineering")
For Each oItem In cComputerData
    If InStr(oItem.HotFixID,"File") = 0 Then
        WScript.Echo "               HotFix: " & oItem.HotFixID 
    End If
Next
Set cComputerData = Nothing

'
' *************************************************************************
'

WScript.Echo vbCr
WScript.Echo "----------------------------------------------------------------"
WScript.Echo "                MSI Software Packages Installed"
WScript.Echo "----------------------------------------------------------------"
Set cComputerData = oWMI.ExecQuery("SELECT * FROM Win32_Product")
For Each oItem In cComputerData
    WScript.Echo "          Description: " & oItem.Description
    WScript.Echo "                 Name: " & oItem.Name
    WScript.Echo "               Vendor: " & oItem.Vendor
    WScript.Echo "              Version: " & oItem.Version
    WScript.Echo "                 GUID: " & oItem.IdentifyingNumber
    WScript.Echo "            Installed: " & oItem.InstallDate
    WScript.Echo "          Cached Copy: " & oItem.PackageCache
    WScript.Echo "----------------------------------------------------------------"
Next
Set cComputerData = Nothing



'
' *************************************************************************
'


Set oWMI = Nothing


Function GetVBDate(sWmiDate)
    GetVBDate = DateSerial(Left(sWmiDate,4),Mid(sWmiDate,5,2),Mid(sWmiDate,7,2)) _
    	      + TimeSerial(Mid(sWmiDate,9,2),Mid(sWmiDate,11,2),Mid(sWmiDate,13,2))
End Function



'END OF SCRIPT**************************************************************
