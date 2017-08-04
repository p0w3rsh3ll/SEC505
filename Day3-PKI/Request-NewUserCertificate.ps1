<####################################################################

One way to deploy certificates is through user logon scripts.
The following code will 1) test whether the person running the script
has a certificate with the 'Secure Email' allowed key usage, and, if 
not, 2) will enroll hands-free for a certificate from the 'User'
template, which has this allowed purpose by default.  A real logon
script would also check other factors, write to the event logs, etc.

#####################################################################>

# Certificate objects include a list of allowed uses:
$UsageList = dir Cert:\CurrentUser\My | foreach { $_.EnhancedKeyUsageList.FriendlyName } 


# One of these allowed uses has both an ID number and a friendly name of 'Secure Email':
if ( $UsageList -NotContains 'Secure Email' )
{ 
    # Request a new cert from the 'User' template:
    $EnrollResults = Get-Certificate -Template User -CertStoreLocation Cert:\CurrentUser\My 
    
    # If successful, output the new cert:
    if ($EnrollResults.Status -eq 'Issued'){ $EnrollResults.Certificate | Select * } 
} 



