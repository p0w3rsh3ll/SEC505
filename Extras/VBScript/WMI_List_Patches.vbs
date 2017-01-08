'***********************************************************************************
' Script Name: WMI_List_Patches.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 21.Mar.2004
'     Purpose: Connects to target and enumerates all hotfixes and patches.
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
Set cPatches = oWMI.ExecQuery("SELECT * FROM Win32_QuickFixEngineering")

For Each oPatch In cPatches
    WScript.Echo oPatch.HotFixID & vbTab & oPatch.CSName & vbTab & sIPaddress
Next



'END OF SCRIPT**********************************************************************
