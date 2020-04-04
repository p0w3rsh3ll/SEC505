############################################################################
<#
.SYNOPSIS
    Renumber the child scripts for the Start-Top.ps1 script.

.DESCRIPTION
    The Start-Top.ps1 script takes the path to a folder containing
    PowerShell scripts and executes those scripts in numerical order. If 
    you need to insert a new script in between two existing scripts, but
    there is not a free number in between them, this script can renumber all 
    the scripts in the folder while 1) maintaining the current ordering, 
    2) only changing the leading three-digit number in the name of each 
    script, and 3) including scripts with a *.ps1.txt file name extension
    in the renumbering procedure.  A child script can be disabled in a 
    folder given to Start-Top.ps1 by appending ".txt" to the script's name
    while keeping that script (and its order) for potential future use.
    Only *.ps1 and *.ps1.txt files will be renamed.  If any file does not
    end with *.ps1, *.ps1.txt or *.psd1, then this script errors out.
    If any two files begin with a duplicate number, this script errors out.
    If the count of scripts is greater than 999, this script errors out.
    And if any scripts violate the required naming scheme, this script
    errors out.  Hence, use -WhatIf to also perform sanity checks.

.PARAMETER ScriptsFolderPath
    Full or relative path to the child scripts folder for Start-Top.ps1.

.PARAMETER MaximizeNumberSpacing
    By default, the existing scripts will be renumbered by 10, e.g., 010-*,
    020-*, 030-*, and so on.  With this switch, the maximum numerical 
    distance between the numbers will be used instead, even though these
    numbers will not be evenly divisible by 10 or 5.  If there are more 
    than 90 scripts in the target folder, this switch is automatically
    applied.  

.PARAMETER WhatIf
    Will not actually rename any scripts.  Outputs only the current names
    and the proposed new names with the different leading numbers.  Also
    performs sanity checks for the sake of troubleshooting.  

.NOTES
    Legal: Public domain, no rights reserved, no guarantees or warranties.
    Last Updated: 10-Dec-2019 by JF@Enclave
#>
############################################################################

Param ($ScriptsFolderPath = $null, [Switch] $MaximizeNumberSpacing, [Switch] $WhatIf) 

# Get the sorted list of scripts to renumber, make sure not to recurse, and
# get both *.ps1 and *.ps1.txt to capture disabled scripts too:
$Scripts = @( dir -Path $ScriptsFolderPath -File -ErrorAction Stop |
           where { $_.Name -match '^[0-9]{3,3}\-.+\.ps1$|^[0-9]{3,3}\-.+\.ps1\.txt$' } |
           Sort-Object -Property Name ) 


# Get all non-compliant file names for a sanity check:
$NonCompliantFiles = @( dir -Path $ScriptsFolderPath -File -ErrorAction Stop |
                     where { $_.Name -notmatch '^[0-9]{3,3}\-.+\.ps1$|^[0-9]{3,3}\-.+\.ps1\.txt$|.+\.psd1$' } )


# Get group count of all numbers from script names for a sanity check:
$NameNums = @( $Scripts | ForEach { $_.Name.SubString(0,3) } | Group-Object | Where { $_.Count -ge 2} ) 


# Sanity checks:
function Write-NonScaryError ($ErrorText) { Write-Error -Message $ErrorText } 

if ($Scripts.Count -ge 1000)
{ 
    Write-NonScaryError "ERROR: Too many scripts, 999 is the maximum for Start-Top.ps1."
    Exit -1
} 

if ($Scripts.Count -le 1)
{ 
    Write-NonScaryError ("ERROR: Nothing to rename, the count of matching scripts is " + $Scripts.Count)
    Exit -1
} 

if ($NonCompliantFiles.Count -ge 1)
{
    Write-NonScaryError "ERROR: These files violate the required naming scheme:"
    Write-NonScaryError ( ($NonCompliantFiles | Select -ExpandProperty Name) -Join "`n" ) 
    Exit -1
} 

if ($NameNums.Count -gt 0)
{
    Write-NonScaryError "ERROR: Cannot have multiple scripts that begin with the same number."
    Write-NonScaryError "Look for files which begin with:"
    Write-NonScaryError ( ($NameNums | Where { $_.Count -ge 2 } | Select -ExpandProperty Name) -Join "`n")
    Exit -1
}

# Note: allow zero or multiple *.psd1 files too in the sanity checks. 


$i = 0
0..$($Scripts.Count - 1) | 
ForEach { 
    #Calculate numerical spacing between file names for the new numbering:
    if ($MaximizeNumberSpacing -or ($Scripts.Count -gt 90))
    { $i += [Math]::Round( ( 999 / ($Scripts.Count + 2) ) ) } 
    else 
    { $i += 10 }
    
    #The required naming scheme is ###-Name.ps1 or ###-Name.ps1.txt:
    $NewName = ([String] $i).PadLeft(3,"0") + $Scripts[$_].Name.Substring(3) 

    #Display new names or write new names:
    if ($WhatIf) 
    { 
        ($Scripts[$_]).Name + " ---> " + "$NewName"
    } 
    else 
    { 
        # One last check before renaming, just in case...
        if ($NewName -match '^[0-9]{3,3}\-.+\.ps1$|^[0-9]{3,3}\-.+\.ps1\.txt$')
        { 
            if ($Scripts[$_].Name -ne $NewName)
            { Rename-Item -Path $Scripts[$_].FullName -NewName $NewName -Force } 
        }
        else 
        { 
            Write-NonScaryError ("ERROR: Something went wrong, violation of naming scheme: " + $NewName) 
            Exit -1
        }
    } 
} 

#FIN