#!/usr/bin/env pwsh

#################################################################
#
# Just some notes about PoSh Core vs. Windows PoSh.
#
# Note that the shebang (#!) above is not required, but it does
# work on Linux to allow PowerShell script execution directly 
# from within bash without running pwsh explicitly.  If you use
# it, don't forget to "chmod 700 thescript.ps1" like usual.  To
# use the shebang, the script must use LF line endings, not CRLF.
#
#################################################################  

# Is it "Core" or "Desktop"?  Desktop = Windows PowerShell.
$PSVersionTable.PSEdition
$IsCoreCLR

# Is the PoSh version 6.0 or later?
$PSVersionTable.PSVersion.Major
$PSVersionTable.PSVersion.ToString() 

# Does the OS property exist?  What is it?
if ( $PSVersionTable.ContainsKey("OS") ){ $PSVersionTable.OS } 

# Normally, PoSh Core output will be converted to UTF8 stdin strings before piping to native commands:
Get-Process | Select-Object -Unique -ExpandProperty Path | grep -E -e 'bash|systemd|firefox'

# And the output of native commands are converted to System.String back in PoSh Core:
Get-Process | grep -E -e 'systemd' | awk '{print $7}' | Get-Member 

# Unlike Windows PoSh, PoSh Core defaults to UTF8 instead of UTF16 ("Unicode"):
Get-Process | Out-File -Encoding utf8 -FilePath one.txt  #UTF8 Encoding
Get-Process | Out-File -FilePath two.txt                 #UTF8 Encoding

# PoSh Core and Windows PoSh aliases are not identical, so better to avoid aliases entirely:
Get-Alias
Get-Command -Name "ls"
Get-Command -Name "ps"

# Don't forget to update help (and you don't have to be root to do so):
Update-Help 


