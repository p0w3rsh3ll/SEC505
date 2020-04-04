##############################################################
#.SYNOPSIS
#   Enable groups of firewall rules with Out-Gridview.
#.DESCRIPTION
#   The enabled rules are also configured to require IPsec.
##############################################################


Get-NetFirewallRule |
Select-Object -ExpandProperty DisplayGroup -Unique |
Sort-Object |
Out-GridView -PassThru |
ForEach `
{ 
    Enable-NetFirewallRule -DisplayGroup $_ -Verbose 

    Get-NetFirewallRule -DisplayGroup $_ -Direction Inbound |
    Get-NetFirewallSecurityFilter | 
    Set-NetFirewallSecurityFilter -Authentication Required -Encryption Dynamic
} 

