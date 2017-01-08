####################################################################################
#.Synopsis 
#    Display digital signature information for files.
#
#.Description 
#    The script is just a wrapper for Get-AuthenticodeSignature.  Note that if
#    test-path to a file fails for any reason, that file is not checked; hence, 
#    when sifting the output, the output will never include these files.
#
#.Parameter Path
#    Full or relative path to file(s).  May include wildcard(s).
#
#.Parameter Recurse
#    Recurse down through subdirectories of the given path.
#
#.Example 
#    .\check-signature c:\windows\system32\*.exe -recurse  
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)  
# Version: 1.0
# Updated: 23.Apr.2012
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################
    
param ($Path = "*", [Switch] $Recurse) 
 
function Check-Signature ($Path = "*", [Switch] $Recurse)
{
    if ($recurse) { $files = dir $path -force -recurse | where { $_.gettype().name -eq "FileInfo" } }
    else  { $files = dir $path -force | where { $_.gettype().name -eq "FileInfo" } }

    foreach ($item in $files) 
    { 
        if (test-path $item.fullname) 
        { 
            $file = get-authenticodesignature -filepath $item.fullname 
        
            if ($file.status -eq "Valid") 
            { 
                add-member -input $file -membertype noteproperty -name Subject -value $file.signercertificate.subject
                add-member -input $file -membertype noteproperty -name Issuer -value $file.signercertificate.issuer
                add-member -input $file -membertype noteproperty -name Thumbprint -value $file.signercertificate.thumbprint
            } 
             
            $file | select-object Path,Status,Subject,Issuer,Thumbprint
        } 
    }
}

if ($recurse) { Check-Signature -path $path -recurse }
else { Check-Signature -path $path }


