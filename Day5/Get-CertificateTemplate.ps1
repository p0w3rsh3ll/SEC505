#########################################################################
#.SYNOPSIS
#    Demo how to get ADCS certificate template objects.
#.NOTES
#    TODO: Rewrite as full module with OID mappers.
#########################################################################


Import-Module -Name ActiveDirectory -ErrorAction Stop 

$DN = Get-ADDomain -Current LocalComputer -ErrorAction Stop | Select-Object -ExpandProperty DistinguishedName

$Templates = Get-ADObject -Filter { objectClass -eq 'pKICertificateTemplate' } -Properties * `
               -SearchBase ("CN=Public Key Services,CN=Services,CN=Configuration," + $DN) 


# Example:
$Templates | Format-List DisplayName,pKIExtendedKeyUsage



# Reference: OID numbers for PKI-related objects:
$OID = @{
    "Any Purpose" = "2.5.29.37.0"
    "Client Authentication" = "1.3.6.1.5.5.7.3.2"
    "Server Authentication" = "1.3.6.1.5.5.7.3.1" 
    "IP security end system" = "1.3.6.1.5.5.7.3.5"
    "IP security user" = "1.3.6.1.5.5.7.3.7" 
    "IP security tunnel termination" = "1.3.6.1.5.5.7.3.6"
    "IP security IKE intermediate" = "1.3.6.1.5.5.8.2.2"
    "Remote Desktop Authentication" = "1.3.6.1.4.1.311.54.1.2"
    "Lifetime Signing" = "1.3.6.1.4.1.311.10.3.13" 
    "Document Encryption" = "1.3.6.1.4.1.311.80.1"
    "Protected Process Light Verification" = "1.3.6.1.4.1.311.10.3.22" 
    "Directory Service Email Replication" = "1.3.6.1.4.1.311.21.19"
    "Private Key Archival" = "1.3.6.1.4.1.311.21.5" 
    "Windows Hardware Driver Verification" = "1.3.6.1.4.1.311.10.3.5" 
    "Digital Rights" = "1.3.6.1.4.1.311.10.5.1"
    "Preview Build Signing" = "1.3.6.1.4.1.311.10.3.27" 
    "Certificate Request Agent" = "1.3.6.1.4.1.311.20.2.1"
    "Platform Certificate" = "2.23.133.8.2" 
    "CTL Usage" = "1.3.6.1.4.1.311.20.1"
    "Windows Update" = "1.3.6.1.4.1.311.76.6.1" 
    "Kernel Mode Code Signing" = "1.3.6.1.4.1.311.61.1.1"
    "Windows Software Extension Verification" = "1.3.6.1.4.1.311.10.3.26" 
    "Attestation Identity Key Certificate" = "2.23.133.8.3"
    "Windows Store" = "1.3.6.1.4.1.311.76.3.1" 
    "Key Pack Licenses" = "1.3.6.1.4.1.311.10.6.1"
    "Smart Card Logon" = "1.3.6.1.4.1.311.20.2.2" 
    "KDC Authentication" = "1.3.6.1.5.2.3.5"
    "Embedded Windows System Component Verification" = "1.3.6.1.4.1.311.10.3.8"
    "Windows Kits Component" = "1.3.6.1.4.1.311.10.3.20" 
    "Windows Hardware Driver Extended Verification" = "1.3.6.1.4.1.311.10.3.39" 
    "License Server Verification" = "1.3.6.1.4.1.311.10.6.2"
    "Windows Hardware Driver Attested Verification" = "1.3.6.1.4.1.311.10.3.5.1" 
    "Dynamic Code Generator" = "1.3.6.1.4.1.311.76.5.1"
    "Time Stamping" = "1.3.6.1.5.5.7.3.8" 
    "File Recovery" = "1.3.6.1.4.1.311.10.3.4.1"
    "SpcRelaxedPEMarkerCheck" = "1.3.6.1.4.1.311.2.6.1" 
    "Endorsement Key Certificate" = "2.23.133.8.1"
    "SpcEncryptedDigestRetryCount" = "1.3.6.1.4.1.311.2.6.2" 
    "Encrypting File System" = "1.3.6.1.4.1.311.10.3.4"
    "Key Recovery" = "1.3.6.1.4.1.311.10.3.11"
    "Windows Third Party Application Component" = "1.3.6.1.4.1.311.10.3.25"
    "Key Recovery Agent" = "1.3.6.1.4.1.311.21.6"
    "Windows System Component Verification" = "1.3.6.1.4.1.311.10.3.6" 
    "Early Launch Antimalware Driver" = "1.3.6.1.4.1.311.61.4.1"
    "Windows TCB Component" = "1.3.6.1.4.1.311.10.3.23" 
    "HAL Extension" = "1.3.6.1.4.1.311.61.5.1"
    "Secure Email" = "1.3.6.1.5.5.7.3.4" 
    "Root List Signer" = "1.3.6.1.4.1.311.10.3.9" 
    "Disallowed List" = "1.3.6.1.4.1.311.10.3.30"
    "Revoked List Signer" = "1.3.6.1.4.1.311.10.3.19" 
    "Windows RT Verification" = "1.3.6.1.4.1.311.10.3.21"
    "Qualified Subordination" = "1.3.6.1.4.1.311.10.3.10" 
    "Document Signing" = "1.3.6.1.4.1.311.10.3.12"
    "Protected Process Verification" = "1.3.6.1.4.1.311.10.3.24" 
    "OCSP Signing" = "1.3.6.1.5.5.7.3.9" 
    "Code Signing" = "1.3.6.1.5.5.7.3.3"
    "Microsoft Trust List Signing" = "1.3.6.1.4.1.311.10.3.1" 
    "Microsoft Time Stamping" = "1.3.6.1.4.1.311.10.3.2"
    "Microsoft Publisher" = "1.3.6.1.4.1.311.76.8.1" 
    "OEM Windows System Component Verification" = "1.3.6.1.4.1.311.10.3.7" 
}
