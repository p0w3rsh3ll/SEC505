
# Need to check if it already exists, don't want to overwrite it:

if (-not $(test-path $profile.CurrentUserAllHosts)) 
{
    new-item -path $profile.CurrentUserAllHosts -itemtype file -force 
}

PowerShell_ISE.exe $profile.CurrentUserAllHosts


