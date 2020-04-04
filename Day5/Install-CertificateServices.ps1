################################################################
#.SYNOPSIS
#   Installs Certificate Services on Server 2016 and later.  
#
#.NOTES
#   Must use Windows PowerShell, not PowerShell Core.
#
#   If the ADCS role is uninstalled, then installed again, the
#   name of the CA below (Testing-CA) will have to be changed first
#   or else an "exiting private key" error will be thrown.
#
#   Note that removing the OCSP role requires a reboot.
################################################################

# Confirm that the ServerManager module can be imported:
Import-Module -Name ServerManager -ErrorAction Stop


# Try to get the Certificate Services role to see if it already exists:
$CS = Get-WindowsFeature -Name ADCS-Cert-Authority -ErrorAction Stop 


# Really slow laptops seem to time out when getting the above roles.
# To diagnose, check if Server Manager is suffering this problem too.
# Rebooting the VM seems to help, but it unclear why this helps.
if ($CS -eq $null)
{
  "Failed to get list of installed roles and features."
  "Please close this PowerShell, open PowerShell ISE,"
  "and run this script again.  If this script still"
  "fails afterwards, please reboot your VM."
  
  Exit
}


# Exit if the ADCS role is already installed:
if ( $CS.Installed ) 
{ 
   "Certificate Services role is already installed, exiting."
   Exit 
} 


# Install Certificate Services role and the OCSP responder IIS app:
$CSRoles = Install-WindowsFeature -Name ADCS-Cert-Authority,ADCS-Online-Cert -IncludeManagementTools -ErrorAction Stop


# Confirm that the ADCSDeployment module is ready before moving forward.
# The ADCS role is still being installed in the background right now.
Do 
{ 
  Write-Verbose -Verbose "Waiting for the ADCSDeployment module..."
  Start-Sleep -Seconds 5
  $CSDeployMod = Get-Module -ListAvailable -Name ADCSDeployment 
}
While ($CSDeployMod -eq $null)


# Confirm that the ADCSDeployment module can be imported before proceeding.
# This module is installed as a part of installing the ADCS role.
Import-Module -Name ADCSDeployment -ErrorAction Stop


# Now we can configure the CA service itself as an Enterprise Root CA.
# The Certification Authority type (-CAtype) can be one of the following:
#    EnterpriseRootCA
#    EnterpriseSubordinateCA
#    StandaloneRootCA
#    StandaloneSubordinateCA


# Configure the CA as an Enterprise Root with a 4096-bit RSA public key:
Install-AdcsCertificationAuthority `
  -CACommonName "Testing-CA" `
  -KeyLength 4096 `
  -ValidityPeriod Years -ValidityPeriodUnits 20 `
  -CAtype EnterpriseRootCA -Force | Out-Null


# Install the OCSP responder web app on top of IIS:
Install-AdcsOnlineResponder -Force | Out-Null


Write-Verbose -Verbose "Done!"













# Note that if you also wanted the optional IIS web enrollment 
# pages (http://yourca/certsrv/) then also install:
#
#   Install-WindowsFeature -Name ADCS-Cert-Authority,ADCS-Web-Enrollment,ADCS-Online-Cert -IncludeManagementTools
#   Install-AdcsWebEnrollment -Force
