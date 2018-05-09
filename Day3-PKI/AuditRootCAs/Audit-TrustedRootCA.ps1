####################################################################################
#.Synopsis 
#    Compare the list of root certification authorities (CAs) trusted by a user 
#    on a computer against a reference list of CAs.  The reference list is just a 
#    simple text file of the hash thumbprints of root CA certificates. 
#
#.Description
#    Compare the list of root certification authorities (CAs) trusted by a user 
#    on a computer against a reference list CAs.  The reference list is just a 
#    simple text file of the hash thumbprints of the CA certificates.  The
#    output is a CSV text file of the currently-trusted certificates which are
#    NOT in the reference list.  Script also writes an event to the Application
#    event log (Event ID = 9017, Source = RootCertificateAudit) on the computer
#    where the script is run.  The script is quite simple, actually, and is
#    mainly intended as a starter script or skeleton script to be modified for
#    the needs of the organization; feel free to add more error handling, etc.
#
#.Parameter PathToReferenceList 
#    The local or UNC path to the text file containing the list of certificate
#    SHA-1 hash thumbprints against which to compare as a reference.  Note that
#    the hashes must be SHA-1, not SHA-256.  
#
#.Parameter OutputPath
#    The local or UNC path to the folder for the output CSV file which will contain 
#    a list of the currently-trusted root CAs which are NOT on the reference
#    list of hashes, hence, possibly bad or in violation of policy.
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)  
# Version: 1.2
# Updated: 9.Nov.2015
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################

Param ($PathToReferenceList = $(throw "`nEnter path to text file with thumbprints of CA certifiate hashes.`n"), $OutputPath = ".\") 


# Extract hashes of "Trusted Root Certification Authorities" for the current user.
$usertrusted  = dir cert:\currentuser\root | foreach { $_ | select-object Thumbprint,Subject} 



# Extract hashes of "Third-Party Trusted Root Certification Authorities" for the current user.
$usertrusted += dir cert:\currentuser\authroot | foreach { $_ | select-object Thumbprint,Subject} 



# Extract hashes of "Trusted Root Certification Authorities" for the computer.
$computertrusted = dir cert:\localmachine\root | foreach { $_ | select-object Thumbprint,Subject} 



# Extract hashes of "Third-Party Trusted Root Certification Authorities" for the computer.
$computertrusted += dir cert:\localmachine\authroot | foreach { $_ | select-object Thumbprint,Subject} 



# Combine all the user and computer CA hashes and exclude the duplicates.
$combined = ($usertrusted + $computertrusted) | sort Thumbprint -unique



# Read in the hashes from the reference list of thumbprints.
$reference = get-content -path $PathToReferenceList



# Get list of locally-trusted hashes which are NOT in the reference file.
$additions = @( $combined | foreach { if ($reference -notcontains $_.Thumbprint) { $_ } } ) 



# Save the list to a CSV file to the output path, where the name of the file is
# ComputerName+UserName+TickCount.csv, which permits the use of the tick count for sorting
# many files by time and extraction of a timestamp for when the file was created.
# To convert a timestamp number into a human-readable date and time:  get-date 634890196060064770
$PathToFile = "$OutputPath" + "\" + $env:computername + "+" + $env:username + "+" + $(get-date).ticks + ".csv"



# Save an empty file if there are no CA additions; otherwise, save the CSV list.
if ($additions.count -ge 1)
{
    $additions | export-csv -notypeinfo -literalpath $($PathToFile)
}
else
{
    $null | set-content -path $PathToFile
}



# Write the list to the local Application event log for archival:
new-eventlog -LogName Application -Source RootCertificateAudit -ErrorAction SilentlyContinue

$GoodMessage = "All of the root CA certificates trusted by $env:userdomain\$env:username are on the reference list of certificate hashes obtained from " + $FilePath

$BadMessage = "WARNING: The following root CA certificates are trusted by $env:userdomain\$env:username, but these certificates are NOT on the reference list of certificate hashes obtained from " + $FilePath + "`n" + $($additions | format-list | out-string)

if ($additions.count -eq 0)
{ write-eventlog -logname Application -source RootCertificateAudit -eventID 9017 -message $GoodMessage -EntryType Information }
else
{ write-eventlog -logname Application -source RootCertificateAudit -eventID 9017 -message $BadMessage -EntryType Warning } 





