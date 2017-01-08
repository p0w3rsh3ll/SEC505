###################################################################
# This script will install the File Server Resource Manager role
# on Server 2012 and later, then prompt the user to reboot.
# Please do not run this script unless asked by the instructor.
###################################################################


if ( $(Get-WindowsFeature -Name FS-Resource-Manager).installed) { "File Server Resource Manager already installed!" ; exit } 

Install-WindowsFeature -Name FS-Resource-Manager -IncludeManagementTools

"`n`n`nYou must reboot for all changes to take effect."

$answer = Read-Host -Prompt "Are you ready to reboot now? (yes/no)"

if ($answer -like "y*") { Restart-Computer } 


