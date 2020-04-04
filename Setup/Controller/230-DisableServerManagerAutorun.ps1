###############################################################################
#
#"[+] Turning off Server Manager autorun..."
#
###############################################################################

$curpref = $ErrorActionPreference
if (-not $Verbose) { $ErrorActionPreference = "SilentlyContinue" } 
$key = get-item 'HKCU:\SOFTWARE\Microsoft' 
$subkey = $key.opensubkey("ServerManager",$true)
$subkey.SetValue("DoNotOpenServerManagerAtLogon",1)
$key = get-item 'HKLM:\SOFTWARE\Microsoft'
$subkey = $key.opensubkey("ServerManager",$true)
$subkey.SetValue("DoNotOpenServerManagerAtLogon",1)
$ErrorActionPreference = $curpref

