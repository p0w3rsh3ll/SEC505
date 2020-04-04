####################################################################################
#.SYNOPSIS 
#   Display digital signature information in PowerShell scripts.
#
#.DESCRIPTION 
#   The script is just a wrapper for Get-AuthenticodeSignature.  Note that if
#   test-path to a file fails for any reason, that file is not checked; hence, 
#   when searching the output, the output will never include these files, hence,
#   the absence of a file does not imply that it has a valid signature.  
#
#.PARAMETER Path
#   Path to a single PowerShell script (.ps1), PowerShell data file (.psd1),
#   Windows catalog file (.cat), or the path to a folder with such files.  May 
#   include wildcard(s).  Only *.ps1, *.psd1 and *.cat files will be checked.  
#
#.PARAMETER Recurse
#    Include subdirectories of the given path.  Only *.ps1, *.psd1 and *.cat files
#    will be checked in these subdirectories.  
#
#.EXAMPLE
#    .\Check-Signature.ps1 c:\folder -Recurse  
#
#.NOTES
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
    if ($recurse) { $files = dir $path -force -recurse -file -include *.ps1,*.psd1,*.cat }
    else  { $files = dir $path -force -file -include *.ps1,*.psd1,*.cat }

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


