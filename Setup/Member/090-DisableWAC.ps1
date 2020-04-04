########################################################
#.SYNOPSIS
#   Stop and disable Windows Admin Center, if present.
#.NOTES
#   For clean slate.  
########################################################

Stop-Service -Name ServerManagementGateway -ErrorAction SilentlyContinue

Set-Service -Name ServerManagementGateway -StartupType Disabled -ErrorAction SilentlyContinue 


