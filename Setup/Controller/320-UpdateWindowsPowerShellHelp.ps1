###############################################################################
#
#"[+] Updating help files for Windows PowerShell..."
#
# Note that en-US is the hard-coded culture.
# What about help files for PoSh Core?  They have a different path.
# 
# Only update and save help files on Windows Server *after* installing
# all the modules for which you intend to have labs.
#
###############################################################################


if (-not $(Test-Path -Path ".\Resources\UpdateHelp\XDROP.txt") )
{
    if ($PSVersionTable.PSVersion.Major -eq 5)
    {
        #This is for the default unpatched Server 2016/2019, but PSVersion.Minor is not checked:
        Update-Help -SourcePath .\Resources\UpdateHelp\5.1 -ErrorAction SilentlyContinue > $null 
        
        #Drop the above Test-Path file to avoid updating multiple times:
        "Why are you looking at this 5.1 file?" | Out-File -FilePath ".\Resources\UpdateHelp\XDROP.txt"
    }
}

