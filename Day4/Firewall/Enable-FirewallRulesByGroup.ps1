##############################################################
#.SYNOPSIS
# Enable groups of firewall rules with Out-Gridview.
##############################################################


Get-NetFirewallRule |
Select-Object -ExpandProperty DisplayGroup -Unique |
Sort-Object |
Out-GridView -PassThru |
ForEach { Enable-NetFirewallRule -DisplayGroup $_ -Verbose } 



# It is the "-PassThru" switch to Out-GridView which
# displays the OK button in Out-GridView and passes
# through whatever object(s) are highlighted.
