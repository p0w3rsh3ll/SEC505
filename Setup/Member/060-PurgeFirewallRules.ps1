
# Delete existing Windows Firewall rules:
Remove-NetFirewallRule -PolicyStore PersistentStore

# Enable the Windows Firewall for all profile types:
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Configure all three profiles to Allow/Allow for Inbound/Outbound:
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Allow -DefaultInboundAction Allow 

