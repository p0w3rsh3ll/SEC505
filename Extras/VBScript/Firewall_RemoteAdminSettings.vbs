'*******************************************************************************
' Script Name: Firewall_RemoteAdminSettings.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 29.May.2004
'     Purpose: Manage whether remote administration is permitted.
'       Notes: Requires at least Windows XP SP2.  When RemoteAdminSettings is set to
'              enabled, the machine is accessible on TCP/135 and TCP/445 on all interfaces.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees.
'*******************************************************************************

Function SetRemoteAdminSettings(bState) 
	On Error Resume Next
	bState = UCase(CStr(bState))
	
	Select Case bState
		Case "TRUE", "ON", "ENABLE", "ENABLED"      : bState = True
		Case "FALSE", "OFF", "DISABLE", "DISABLED"  : bState = False
		Case Else : bState = False   'Fail to disabled!
	End Select
	
	Set oFirewall = CreateObject("HNetCfg.FwMgr")
	Set oCurrentProfile = oFirewall.LocalPolicy.CurrentProfile
	Set oRemoteAdminSettings = oCurrentProfile.RemoteAdminSettings
	oRemoteAdminSettings.Enabled = bState

	If Err.Number = 0 And oRemoteAdminSettings.Enabled = bState Then
		SetRemoteAdminSettings = True
	Else
		SetRemoteAdminSettings = False
	End If
End Function



If SetRemoteAdminSettings("Enabled") Then 
	WScript.Echo "Remote admin successfully enabled!"
Else
	WScript.Echo Err.Description
End If



'END OF SCRIPT ****************************************************************
