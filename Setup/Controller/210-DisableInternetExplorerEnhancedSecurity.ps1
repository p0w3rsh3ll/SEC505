###############################################################################
#
#"[+] Turning off Internet Explorer Enhanced Security..."
#
# Do this before the first reboot or else the change doesn't "stick."
# 
###############################################################################

$curpref = $ErrorActionPreference
if (-not $Verbose) { $ErrorActionPreference = "SilentlyContinue" } 
$iekey = get-item 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components' 
$subkey = $iekey.opensubkey("{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}",$true)  #For Admins
$subkey.SetValue("IsInstalled",0)
$subkey = $iekey.opensubkey("{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}",$true)  #For Non-Admins
$subkey.SetValue("IsInstalled",0)
$ErrorActionPreference = $curpref

