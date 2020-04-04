###########################################################################
#.SYNOPSIS
# Demo how to create a self-signed certificate.
#
#.DESCRIPTION
# Create a self-signed certifiate with its private key, then 1) export the
# certificate to a DER-encoded .CER file and 2) export the certificate and
# private key to a PKCS#12 .PFX file with a hard-coded password.  
#
#.NOTES
# The KeyEncipherment key usage and the Enhanced CSP are needed for the 
# password archive script lab using the Update-PasswordArchive.ps1 script,
# but these may be changed, of course, for other purposes. See the help
# for the New-SelfSignedCertificate cmdlet for the other options.  
###########################################################################


# Create a hashtable of parameters and arguments für Das Splat:
$Splat = @{ CertStoreLocation = "Cert:\CurrentUser\My" ; 
            DnsName = "PasswordArchive" ;
            NotAfter = (Get-Date).AddYears(20) ;
            KeyUsage = "KeyEncipherment" ;
            KeyAlgorithm = "RSA" ;
            KeyLength = 4096 ;
            HashAlgorithm = "SHA256" ;
            Provider = "Microsoft Enhanced Cryptographic Provider v1.0" }


# Create self-signed certificate with priv key, which will also import the 
# cert and key into the local profile of the user running this script:
$Cert = New-SelfSignedCertificate @Splat

# Now this new cert can be seen in the Certificates MMC snap-in and also
# in the PowerShell Cert:\CurrentUser\My\ drive.

# Export the certificate only (not priv key) to a CER file:
Export-Certificate -Cert ("Cert:\CurrentUser\My\" + $Cert.Thumbprint) -FilePath .\PublicKeyCert.cer 


# Password to encrypt the exported private key:
$pw = ConvertTo-SecureString -String "P@ssword" -Force -AsPlainText

# Export the certificate and priv key to the PFX file:
Export-PfxCertificate -Cert ("Cert:\CurrentUser\My\" + $Cert.Thumbprint) -FilePath .\PrivateKey.pfx -Password $pw


