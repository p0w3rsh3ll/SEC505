###############################################################################
#
#"[+] Always show file name extensions in File Explorer..."
#
###############################################################################

$curpref = $ErrorActionPreference
if (-not $Verbose) { $ErrorActionPreference = "SilentlyContinue" } 
$key = Get-Item 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
$subkey = $key.OpenSubKey("Advanced",$true)
$subkey.SetValue("HideFileExt",0)
$subkey = $key = $null
$ErrorActionPreference = $curpref

