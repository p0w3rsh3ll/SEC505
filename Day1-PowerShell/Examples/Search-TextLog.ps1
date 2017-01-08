######################################################################################
#  Script: Search-TextLog.ps1
#    Date: 2.Jun.2012
# Version: 2.1
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: Will search every line of a textual log file against every regex
#          pattern provided in a second file, producing a summary of matches
#          found, or, if -ShowMatchedLines is specified, only the log lines
#          which matched at least one regex with no summary report.
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
######################################################################################




param ($LogFile, $PatternsFile, [Switch] $ShowMatchedLines)

# Load file with the regex patterns, but ignore blank lines.  
$patterns = ( get-content $patternsfile | where-object {$_.length -ne 0} ) 


# From each line in $patterns, extract the regex pattern and its description, add these 
# back as synthetic properties to each line, plus a counter of matches initialized to zero.

foreach ($line in $patterns) 
{
    if ( $line -match "(?<pattern>^[^\t]+)\t+(?<description>.+$)" )
    { 
        add-member -membertype NoteProperty -name Pattern     -value $matches.pattern     -input $line | out-null
        add-member -membertype NoteProperty -name Description -value $matches.description -input $line | out-null
        add-member -membertype NoteProperty -name Count       -value 0                    -input $line | out-null
    }
}

# Remove lines which could not be parsed correctly (they will not have Count property).
# If you have comments lines, don't include any tabs in those lines so they'll be ignored.
$patterns = ( $patterns | where-object {$_.count -ne $null } ) 


# Must resolve full path to $logfile or else StreamReader constructor will fail.
if ($logfile -is [System.IO.FileInfo])
 { $logfile = $logfile.FullName }
elseif ($logfile -notlike "*\*") #Simple file name.
 { $logfile = "$pwd" + "\" + "$logfile" }
elseif ($logfile -like ".\*")  #pwd of script
 { $logfile = $logfile -replace "^\.",$pwd.Path }
elseif ($logfile -like "..\*") #parent directory of pwd of script
 { $logfile = $logfile -replace "^\.\.",$(get-item $pwd).Parent.FullName }
else
 { throw "Cannot resolve path!" }



# Use StreamReader to process each line of logfile, one line at a time, comparing each line against
# all the patterns, incrementing the counter of matches to each pattern.  Have to use StreamReader
# because get-content and the Switch statement are extremely slow with large files.  

$reader = new-object System.IO.StreamReader -ArgumentList "$logfile"

if (-not $?) { "`nERROR: Could not find file: $logfile`n" ; exit }

while ( ($line = $reader.readline()) -ne $null ) 
{
    #Ignore blank lines and comment lines.
    if ($line.length -eq 0 -or $line.startswith(";") -or $line.startswith("#") ) { continue }

    foreach ($pattern in $patterns) 
    {
        if ($line -match $pattern.pattern) 
        {
            if ($ShowMatchedLines) { $line ; break }  #Break out of foreach, one match good enough.
            $pattern.count++ 
        }     
    }
}



# Emit count of patterns which matched at least one line.

if (-not $ShowMatchedLines) 
{
    $patterns | where-object { $_.count -gt 0 } | 
    select-object Count,Description,Pattern | sort-object count -desc
}



