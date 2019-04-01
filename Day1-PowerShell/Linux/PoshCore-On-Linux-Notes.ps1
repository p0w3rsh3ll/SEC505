#!/usr/bin/pwsh -noprofile

#################################################################
#
# Just some notes about PoSh Core vs. Windows PoSh...
#
# Note that the shebang (#!) above is not required, but it does
# work on Linux to allow PowerShell script execution directly 
# from within bash.  Don't forget to "chmod 700 thescript.ps1" 
# like usual then.
#
#################################################################  

# Is it "Core" or "Desktop"?  Desktop = Windows PowerShell.
$PSVersionTable.PSEdition

# Is the PoSh version 6.0 or later?
$PSVersionTable.PSVersion.Major
$PSVersionTable.PSVersion.ToString() 

# Does the OS property exist?  What is it?
if ( $PSVersionTable.ContainsKey("OS") ){ $PSVersionTable.OS } 

# Normally, PoSh Core output will be converted to UTF8 stdin strings before piping to native commands:
Get-Process | Select-Object -Unique -ExpandProperty Path | grep -E -e 'bash|systemd|firefox'

# And the output of native commands are converted to System.String back in PoSh Core:
Get-Process | grep -E -e 'systemd' | awk '{print $7}' | Get-Member 

# PoSh Core defaults to UTF8 instead of UTF16 ("Unicode") like with Windows PoSh:
Get-Process | Out-File -Encoding utf8 -FilePath one.txt  #UTF8 Encoding
Get-Process | Out-File -FilePath two.txt                 #UTF8 Encoding

# PoSh Core and Windows PoSh aliases are not identical, so better to avoid aliases entirely:
Get-Alias
Get-Command -Name "ls"
Get-Command -Name "ps"

# Don't forget to update help, and you don't have to be root:
Update-Help 


