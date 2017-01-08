####################################################################
# Purpose: Tries hard to delete stubborn folders and files.
#
# By design, you may need to use the function two or three times to 
# finally succeed in deletion, but it can still fail, so the script
# is relatively verbose so that you can see when/where it is failing.
#
# Must be run with administrative privileges on Windows 7 or later. 
#
# Warning: There can be unexpected results with junction points,
# especially with recursive or infinite-loop junction paths, but
# the script can sometimes successfully cope anyway (other times, 
# you may need to copy off the desired data and then reformat).
#
# Legal: Public domain.  Script provided "AS IS" with no warranties 
# or guarantees whatsoever.  Use at your own risk.
####################################################################


Param ($FolderPath)

Function Remove-UndeletableFolder ( $FolderPath )
{
    # Get full explicit path to folder.
    Try { $FolderPath = (Resolve-Path -Path "$FolderPath").Path }
    Catch { "`nInvalid path: $FolderPath" ; exit } 

    # Path may includes spaces.
    $LiteralFolderPath = "'" + $FolderPath + "'"

    # The Windows Search service can hold open file locks.
    Try { Stop-Service -Name WSearch } 
    Catch { "`nCould not stop Windows Search service, some files may remain locked.`n" } 

    # Create an empty folder for robocopy.exe to use.
    $tempfolder = "$env:temp\SafeToDeleteThisEmptyFolderDude8675309"
    mkdir $tempfolder | out-null 

    # Remove any hidden, system or readonly attributes.
    ">>> First attempt at removing attributes with attrib.exe..."
    Invoke-Expression -Command "attrib.exe -h -s -r $LiteralFolderPath /S /D /L" 

    # Take ownership recursively for the Administrators group.
    "`n>>> Taking ownership for Administrators..."
    Invoke-Expression -Command "takeown.exe /F $LiteralFolderPath /R /A /D Y"

    # Grant full control to Administrators group.
    # The convoluted things done here are to deal with quoting and escaping issues.
    "`n>>> Granting full control to Administrators with icacls.exe..."
    $cmd = "icacls.exe " + $LiteralFolderPath + " /grant:r Administrators:(OI)(CI)F /T /C /L /Q && exit"
    $cmd = $cmd -replace "'",'"'
    $cmd | Out-File -FilePath "$tempfolder\cmdfile.cmd" -Force -Encoding ascii 
    invoke-expression -command "cmd.exe /c $tempfolder\cmdfile.cmd"
    remove-item -Path "$tempfolder\cmdfile.cmd" 
    
    # Remove any hidden, system or readonly attributes.
    "`n>>> Second attempt at removing attributes with attrib.exe..."
    Invoke-Expression -Command "attrib.exe -h -s -r $LiteralFolderPath /S /D /L" 

    # Use robocopy to mirror with an empty folder, which deletes files with very long path names.
    # This part may need to run for a very long time with recursive junction points.
    "`n>>> Removing files with robocopy.exe..."
    Invoke-Expression -Command "robocopy.exe $tempfolder $LiteralFolderPath /MIR /NP"

    # Delete the empty temp folder created for robocopy.
    remove-item -Path $tempfolder

    # Try a normal deletion now.
    "`n>>> Deleting target folder..."
    remove-item -Path $FolderPath -Recurse -Force -Confirm:$False 

    # Start Windows Search service
    Start-Service -Name WSearch 
} 



Remove-UndeletableFolder -FolderPath $FolderPath


