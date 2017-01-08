# Install the File Server Resource Manager (FSRM), or just exit if already installed.

if ( $(Get-WindowsFeature -Name FS-Resource-Manager).Installed ) { "FSRM aleady installed!" ; exit }  

Install-WindowsFeature -Name FS-Resource-Manager -IncludeManagementTools -Restart 


