<#
.SYNOPSIS
    Discovers or deletes files with 260+ character paths.  

.DESCRIPTION
    The MAX_PATH limit prevents most Windows tools from manipulating or 
    deleting files whose full path name is 260 characters or longer.
    This script can discover and list files of any chosen path length
    and optionally delete just those files.  When deleting, the script
    does not have to delete all the files in a given folder hierarchy,
    only the matching long-named files will be deleted, leaving the
    other files intact.  Other tools can use the "\\?\" trick to delete
    these files, but this does not always work.  This script is a
    wrapper for the built-in Windows ROBOCOPY.EXE tool, which should
    make it faster and more reliable.

.EXAMPLE
    Get-MaxPathFiles.ps1 -FolderPath c:\data 

    Returns strings of the full paths to the files under the c:\data
    folder and all subfolders with 260 or more characters.

.EXAMPLE
    Get-MaxPathFiles.ps1 -FolderPath c:\data -DeleteMatchingFiles

    Deletes all the files under the c:\data folder and its subfolders 
    recursively which have 260 or more characters in their full paths.
    User will be prompted to proceed unless the -Force switch is used.

.EXAMPLE
    Get-MaxPathFiles.ps1 -FolderPath c:\data -Length 190 -CountOnly

    Returns just the count of the number of files under the c:\data
    folder and all its subfolders with 190 or more characters.

.PARAMETER FolderPath
    Path to the folder where to begin the recursive search.  Can be
    a relative or explicit path string, or can be a directory object.

.PARAMETER Length
    Minimum length of file paths to return.  Default = 160.

.PARAMETER CountOnly
    Return only the count of matching files, not their paths.

.PARAMETER DeleteMatchingFiles
    Deletes all files of the given length under the specified path
    recursively through all subdirectories.  Deletions are permanent.

.PARAMETER Force
    Avoid confirmation prompt when deleting matching files.

.OUTPUTS
    Zero or more strings, the full paths to the matching files.

.NOTES
     Author: Enclave Consulting LLC, Jason Fossen (http://www.sans.org/sec505)
    Version: 1.0
      Legal: Public domain, no rights reserved, provied "AS IS" without
             warranties or guarantees of any kind.  Use at your own risk.

#Requires -Version 2.0
#>



[CmdletBinding(SupportsShouldProcess=$True)]
Param
(
    [parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Path to folder.")] $FolderPath,
    [Int32]  $Length = 260, 
    [Switch] $CountOnly, 
    [Switch] $DeleteMatchingFiles, 
    [Switch] $Force
)



# If a System.IO.DirectoryInfo object was passed in, get the path string:
[String] $FolderPath = $FolderPath.ToString()



# Confirm that $FolderPath is actually a path to a folder:
if ((test-path -Path $FolderPath -PathType Container) -ne $true)
{ Write-Error -Message "FolderPath must be a folder path or a folder object." ; exit } 



# Confirm that robocopy.exe is where it should be:
if ((test-path -path "$env:windir\system32\robocopy.exe") -ne $true)
{ write-error -message "Cannot find robocopy.exe." ; exit } 



# When script is run with -Verbose switch, $VerbosePreference is set to Continue:
if ($VerbosePreference -eq "Continue") { $Verbose = $True } else { $Verbose = $False } 
filter WriteIfVerbose { if ($Verbose) { $_ } } 


# WARNING! Files deleted by this script do NOT go into the Recycle Bin! 
# Prompt user to confirm deletion if -Force is not specified:
if ($DeleteMatchingFiles -and -not ($Force -or $WhatIfPreference))
{ 
    $answer = read-host -prompt "`n Are you sure you want to delete the matching files? (yes/no)"
    if ($answer -notlike "y*") { exit } 
}



# We need some empty temp directories for robocopy to play with:
$workingtemp1 = "$env:temp\RobocopyTemp1"
$workingtemp2 = "$env:temp\RobocopyTemp2"
mkdir -path $workingtemp1 -ErrorAction Stop | WriteIfVerbose
mkdir -path $workingtemp2 -ErrorAction Stop | WriteIfVerbose



# Run robocopy to get an array of file path strings:
$files = @( robocopy.exe $FolderPath $workingtemp1 /E /L /FP /NS /NDL /NC /NJH /NJS | 
         out-string -stream | foreach { if ($_.trim().length -ge $length){ $_.trim() } } )



# Return count or the file path strings, or just delete silently.  
if ($CountOnly) 
{ 
    $files.count
    remove-item -path $workingtemp1 -recurse -ErrorAction SilentlyContinue | WriteIfVerbose
    remove-item -path $workingtemp2 -recurse -ErrorAction SilentlyContinue | WriteIfVerbose
    exit 
} 
elseif ($DeleteMatchingFiles) 
{ 
    foreach ($file in $files)
    {
        if ($WhatIfPreference)
        {
            "What if: Remove $file"
        }
        else
        {
            $selectedfolder = (split-path -path $file -parent) 
            $filename = (split-path -path $file -leaf) 
            #MOV deletes the file from the source folder, but it must also move the file somewhere.
            #The crazy quoting is required because single-quotes are permitted in file names, and even this still might not be enough to avoid robo-confusion...
            invoke-expression -Command ('robocopy.exe "' + $selectedfolder + '" ' + $workingtemp2 + ' "' + $filename + '" ' + '/MOV /R:1 /W:2') | WriteIfVerbose
            
            #MIR deletes all the moved files by mirroring with an empty folder.
            #This must be done for each file separately or else robocopy will skip over files.
            robocopy.exe $workingtemp1 $workingtemp2 /MIR | WriteIfVerbose
        }
    }

} 
else 
{ 
    $files 
} 


# Clean up temp folders.
remove-item -path $workingtemp1 -recurse -ErrorAction SilentlyContinue | WriteIfVerbose
remove-item -path $workingtemp2 -recurse -ErrorAction SilentlyContinue | WriteIfVerbose

# Notes:
# The maximum path length of a file (folder plus file) is 260 Unicode 
# characters (the infamous MAX_PATH limit).  The maximum path length of 
# a folder is 248 Unicode characters (MAX_PATH minus the length of an 
# 8.3 short name). See http://msdn.microsoft.com/en-us/library/aa365247.aspx

# FIN