'*******************************************************************************
' Script Name: Firewall_Enable-Disable.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 29.May.2004
'     Purpose: Enable or disable the firewall.
'       Notes: Requires at least Windows XP SP2.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees.
'*******************************************************************************

Function EnableFirewall(bState) 
	On Error Resume Next
	bState = UCase(CStr(bState))
	
	Select Case bState
		Case "TRUE", "ON", "ENABLE", "ENABLED"      : bState = True
		Case "FALSE", "OFF", "DISABLE", "DISABLED"  : bState = False
		Case Else : bState = True   'Fail to enabled.
	End Select
	
	Set oFirewall = CreateObject("HNetCfg.FwMgr")
	Set oCurrentProfile = oFirewall.LocalPolicy.CurrentProfile
	oCurrentProfile.FirewallEnabled = bState
	
	If Err.Number = 0 And oCurrentProfile.FirewallEnabled = bState Then
		EnableFirewall = True
	Else
		EnableFirewall = False
	End If
End Function




If EnableFirewall("Disable") Then 
	WScript.Echo "Firewall successfully enabled!"
Else
	WScript.Echo Err.Description
End If


'END OF SCRIPT ****************************************************************
