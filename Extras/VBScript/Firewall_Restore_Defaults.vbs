'*******************************************************************************
' Script Name: Firewall_Restore_Defaults.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 29.May.2004
'     Purpose: Restores default factory settings on Windows Firewall.
'       Notes: Requires at least Windows XP SP2.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees.
'*******************************************************************************


Set oFirewall = CreateObject("HNetCfg.FwMgr")
oFirewall.RestoreDefaults()




'END OF SCRIPT ****************************************************************
