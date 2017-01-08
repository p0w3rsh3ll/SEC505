'***********************************************************************************
' Script Name: WMI_List_MSI_Packages.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 21.Mar.2004
'     Purpose: Connects to target and enumerates installed MSI packages.
'       Usage: Enter IP address of target as an optional argument to script.
'       Notes: Script connects under the credentials of the current user, so you
'              must be logged on as a domain-wide administrator.
'    Keywords: WMI, WBEM, patches, hotfixes,  
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
Set cProducts = oWMI.ExecQuery("SELECT * FROM Win32_Product")

For Each oItem In cProducts
    WScript.Echo "Description: " & oItem.Description
    WScript.Echo "       Name: " & oItem.Name
    WScript.Echo "     Vendor: " & oItem.Vendor
    WScript.Echo "    Version: " & oItem.Version
    WScript.Echo "       GUID: " & oItem.IdentifyingNumber
    WScript.Echo "  Installed: " & oItem.InstallDate
    WScript.Echo "Cached Copy: " & oItem.PackageCache
    WScript.Echo "--------------------------------------------------------"
Next



'END OF SCRIPT**********************************************************************
