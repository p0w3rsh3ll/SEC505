################################################################
# This script demonstrates how to install Certificate Services
# on Server 2012 and later.  Please don't run this in seminar
# unless asked to do so by the instructor.  We normally install
# ADCS manually for the hands-on experience.
################################################################

# Exit if ADCS is already installed:
if ( $(Get-WindowsFeature -Name ADCS-Cert-Authority).installed ) { "PKI already installed!" ; exit } 

# Install Certificate Services, the IIS web enrollment pages, and OCSP responder IIS app:
Install-WindowsFeature -Name ADCS-Cert-Authority,ADCS-Web-Enrollment,ADCS-Online-Cert -IncludeManagementTools

# Configure as an Enterprise Root CA with a 4096-bit RSA public key:
Install-AdcsCertificationAuthority -CAType EnterpriseRootCA -KeyLength 4096 -ValidityPeriod Years -ValidityPeriodUnits 10 -CACommonName Testing-CA -Force

# Install the IIS web enrollment app (http://yourca/certsrv/):
Install-AdcsWebEnrollment -Force

# Install the OCSP responder app in IIS:
Install-AdcsOnlineResponder -Force

# Enable the audit policy for Certification Services:
auditpol.exe /set /subcategory:"Certification Services" /success:enable /failure:enable



