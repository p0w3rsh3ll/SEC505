#.SYNOPSIS
# Create one firewall rule.



# Delete existing Windows Firewall rules:
Remove-NetFirewallRule -PolicyStore PersistentStore


# Enable the Windows Firewall for all profiles:
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True


# Allow inbound and outbound traffic by default:
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Allow -DefaultInboundAction Allow



# Create one firewall rule that requires IPsec encryption for:
#   TCP/3389 : Remote Desktop Protocol (RDP)
#   TCP/139  : File and Printer Sharing with NetBIOS (SMB)
#   TCP/445  : File and Printer Sharing (SMB)
#   TCP/21   : File Transport Protocol (FTP) Passwords and Commands

$RuleSplat = @{
    Direction = 'Inbound'
    Action = 'Allow'
    Protocol = 'TCP'
    LocalPort = @('3389','139','445','21')
    Name = 'DangerousPorts'
    DisplayName = 'DangerousPorts'
    Authentication = 'Required'
    Encryption = 'Dynamic'
}

New-NetFirewallRule @RuleSplat -ErrorAction Stop | Out-Null

