####################################################################################
#.Synopsis 
#    Delete chosen trusted root CA certificates. 
#
#.Description
#    Edit the $BadCerts array in this script prior to execution.  The $BadCerts
#    array contains the hash thumbprints of root Certification Authority (CA)
#    certificates which should be deleted.  The script writes its report to the
#    shell and also to the Application event log (Event ID = 9019).
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)  
# Version: 1.1
# Updated: 5.Apr.2015
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################


# The following is the array of the hash thumbprints of 
# the CA certificates to delete. Edit this array before 
# pushing out the script, the following hashes are just
# examples for the sake of demonstrations.

$BadCerts = @("4EF2E6670AC9B5091FE06BE0E5483EAAD6BA32D9","1AF5EA670AC9B5091FE06BE0E5483EAAD6BE3212")  



function Remove-CertificateArray ($StoreName = "My", $StoreLocation = "CurrentUser", [Object[]] $HashArrayToRemove)
{
    $discoveredhashes = @()
    $deletedhashes = @()

    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store($StoreName,$StoreLocation) 
    if (-not $?) { "`nERROR: Failed to access the $StoreLocation\$StoreName certificate store!" ; return } 

    $store.open("MaxAllowed")
    if (-not $?) { "`nERROR: Failed to open the $StoreLocation\$StoreName certificate store with MaxAllowed privileges!" ; return } 

    $store.certificates | 
        foreach `
        { 
            if ($HashArrayToRemove -contains $_.thumbprint)
            {
                $discoveredhashes += $_.thumbprint
                $store.remove($_) 
                if ($?){ $deletedhashes += $_.thumbprint } 
            } 
        } 
    $store.close() 

    "`n*For the $StoreLocation in the $StoreName certificate store, $($discoveredhashes.count) matching certificates were found and $($deletedhashes.count) certificates were removed.`n" 
    "`nDiscovered in $StoreLocation\$StoreName :`n" 
    $discoveredhashes | foreach { $_ }
    "`n`nRemoved from $StoreLocation\$StoreName :`n"
    $deletedhashes | foreach { $_ } 
    "`n"
}


# Capture output for reporting and writing to the Application event log.
$output = ""


# Look for the unwanted certs in a variety of locations, some of which will be redundant, but
# sometimes the script will be run as a user, sometimes as the computer, so better safe than
# sorry.  Btw, the Root store is "Trusted Root Certification Authorities" and AuthRoot 
# is "Third-Party Trusted Root Certification Authorities."

$output += Remove-CertificateArray -StoreName "Root" -StoreLocation "CurrentUser" -HashArrayToRemove $BadCerts
$output += Remove-CertificateArray -StoreName "AuthRoot" -StoreLocation "CurrentUser" -HashArrayToRemove $BadCerts
$output += Remove-CertificateArray -StoreName "Root" -StoreLocation "LocalMachine" -HashArrayToRemove $BadCerts
$output += Remove-CertificateArray -StoreName "AuthRootRoot" -StoreLocation "LocalMachine" -HashArrayToRemove $BadCerts


# Write the output to the local Application event log.
new-eventlog -LogName Application -Source RemoveRootCertificate -ErrorAction SilentlyContinue
write-eventlog -logname Application -source RemoveRootCertificate -eventID 9019 -message $output -EntryType Information 


# Display report if desired.
"`n" + $output


