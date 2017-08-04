##################################################################
# This script demos how to create a client-side VPN connectoid
# for IKEv2 with custom IPsec settings.
##################################################################


# View existing VPN connectoids for just the current user:
Get-VpnConnection


# View existing VPN connectoids for all users:
Get-VpnConnection -AllUserConnection


# Create a new VPN connectoid:
Add-VpnConnection -ServerAddress '<your.vpngateway.com>' -Name 'Home VPN IKEv2' -TunnelType Ikev2 -AllUserConnection -AuthenticationMethod MachineCertificate -EncryptionLevel Maximum -PassThru


# Customize the IPsec settings for the new connectoid:
Set-VpnConnectionIPsecConfiguration -ConnectionName 'Home VPN IKEv2' -AuthenticationTransformConstants GCMAES256 -CipherTransformConstants GCMAES256 -EncryptionMethod AES256 -IntegrityCheckMethod SHA256 -PfsGroup PFS2048 -DHGroup Group14 -Force -PassThru 


# Viewing the connectoid does NOT show the IPsec customizations:
Get-VpnConnection -AllUserConnection -Name 'Home VPN IKEv2' | Select *


# Delete the connectoid:
# Remove-VpnConnection -AllUserConnection -Force -Name 'Home VPN IKEv2'


