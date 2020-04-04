######################################################################
#
# Installs Network Policy Services (NPS) on Server 2012 and later.
#
######################################################################


# Check if NPS is already installed:
if ( $(Get-WindowsFeature -Name NPAS-Policy-Server).installed ) { "NPS already installed!" ; exit } 


# Install NPS is easy:
Install-WindowsFeature -Name NPAS-Policy-Server -IncludeManagementTools 



