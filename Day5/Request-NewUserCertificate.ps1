<####################################################################
.SYNOPSIS
    Enroll for an e-mail certificate from an enterprise CA.

.DESCRIPTION
    The following code will 1) test whether the person running the script
    has a certificate with the 'Secure Email' allowed key usage, and, if 
    not, 2) will enroll hands-free for a certificate from the chosen
    template.  The 'User' template has this allowed purpose by default.  
    Script must be run by the user who will get the cerfificate.  

.PARAMETER CertificateTemplateName
    Name of the certificate template in AD which will be used for the
    request.  That template must include 'Secure Email' as an allowed
    key usage.  The 'User' template has this by default.

.NOTES
    One way to deploy certificates is through user logon scripts.  This
    code can be modified for use in a logon script.  A real logon
    script would also need to do other things too, like write to the 
    event logs, etc.
#####################################################################>

Param ($CertificateTemplateName = 'User') 

# Certificate objects include a list of allowed uses:
$UsageList += dir Cert:\CurrentUser\My | foreach { $_.EnhancedKeyUsageList.FriendlyName } 


# One of these allowed uses has a friendly name of 'Secure Email':
if ( $UsageList -NotContains 'Secure Email' )
{ 
    # Request a new cert from the 'User' template:
    $EnrollResults = Get-Certificate -Template $CertificateTemplateName -CertStoreLocation Cert:\CurrentUser\My 
    
    # If successful, output the new cert:
    if ($EnrollResults.Status -eq 'Issued')
    { $EnrollResults.Certificate } 
    else
    { throw "ERROR: Failed to enroll for a new certificate." } 
} 



