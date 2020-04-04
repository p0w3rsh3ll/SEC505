########################################################
#.SYNOPSIS
#   Stop and disable the OpenSSH services, if present.
#.NOTES
#   For clean slate, but don't delete the binaries
#   without also updating the PATH.  
########################################################

Stop-Service -Name sshd -ErrorAction SilentlyContinue
Stop-Service -Name ssh-agent -ErrorAction SilentlyContinue

Set-Service -Name sshd -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name ssh-agent -StartupType Disabled -ErrorAction SilentlyContinue 


