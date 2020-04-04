###############################################################################
#.SYNOPSIS
#   Update PowerShell Core help files.
#
#.NOTES
#   If you are trying to use Update-Help -SourcePath, then do not
#   update PSCore help files too quickly after the installation 
#   of PSCore or else the help update will fail.  
#
#   For the time being, simply copy the contents of 
#       .\Resources\UpdateHelp\PSCoreHelp\PSCoreHelpContents.zip
#   into
#       $Home\Documents\PowerShell\Help
#
#   Create PSCoreHelpContents.zip with "Compress-Archive -Path .\Help\*" to get
#   the contents of the $Home\Documents\PowerShell\Help folder, not the Help
#   folder itself.  
###############################################################################

# Create PSCore user help folder if necessary:
if (-not (Test-Path -Path $Home\Documents\PowerShell\Help))
{ mkdir -Path $Home\Documents\PowerShell\Help -Force *>$null } 


# Look for a PSCore help file that should always be present:
$TestFile = @( dir -Path "$Home\Documents\PowerShell\Help\Microsoft.PowerShell.Utility*" ) 


# Copy help files if the $TestFile is absent:
if ($TestFile.Count -eq 0)
{
    # Suppress the GUI progress bar
    # $ProgressPreference = SilentlyContinue
    Expand-Archive -Path .\Resources\UpdateHelp\PSCoreHelp\PSCoreHelpContents.zip -DestinationPath $Home\Documents\PowerShell\Help -Force 
}







<#
# Update-Help from a -SourcePath does not work reliably in pwsh so far, needs testing...

$pwshpath = "Beware of multiple versions of pwsh installed"
$pwshpath = dir -Path $env:ProgramFiles\PowerShell -Recurse -Filter 'pwsh.exe' | Select -ExpandProperty Fullname | Sort -Descending | Select -First 1
$pwshpath = $pwshpath -replace 'Program Files','PROGRA~1'

if (Test-Path $pwshpath) 
{ 
    $cmd3 = "$pwshpath -WindowStyle Hidden -NoLogo -Command { Update-Help -SourcePath .\Resources\UpdateHelp\PSCoreHelp -ErrorAction SilentlyContinue *>$null } "
    Invoke-Expression -Command $cmd3
}
#>
