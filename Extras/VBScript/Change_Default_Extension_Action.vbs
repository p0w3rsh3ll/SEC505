'****************************************************************************
' Script Name: Change_Default_Extension_Action.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/29/01
'     Purpose: Change the default action from Open/Run to Edit on
'              .reg, .vbs, .vbe, .js, .jse and .wsf files.  Note that
'              you will not be able to run scripts from the CMD shell or
'              the Run line by simply typing in the name of the script,
'              you will have to first type "cscript.exe" or "wscript.exe"
'              and then the script name.  You can still run scripts from 
'              within Windows Explorer by right-clicking > Open.
'       Notes: This can help to defend against script viruses and accidental
'              registry modifications by users with "happy fingers".
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'****************************************************************************


Set oWshShell = WScript.CreateObject("WScript.Shell")

'By specifying the key itself (by putting a backslash at the end of the
'registry path) the data is assigned to the "(Default)" value of the key.
'The default value of the \Shell key must be set identical to the name of
'one of the subkeys of \Shell;  these subkeys contain the command to be
'executed;  this is how the default action is set.

oWshShell.RegWrite "HKEY_CLASSES_ROOT\VBSFile\Shell\","Edit","REG_SZ"
oWshShell.RegWrite "HKEY_CLASSES_ROOT\VBEFile\Shell\","Edit","REG_SZ"
oWshShell.RegWrite "HKEY_CLASSES_ROOT\JSFile\Shell\","Edit","REG_SZ"
oWshShell.RegWrite "HKEY_CLASSES_ROOT\JSEFile\Shell\","Edit","REG_SZ"
oWshShell.RegWrite "HKEY_CLASSES_ROOT\WSFFile\Shell\","Edit","REG_SZ"
oWshShell.RegWrite "HKEY_CLASSES_ROOT\regfile\Shell\","edit","REG_SZ"



'END OF SCRIPT **************************************************************
