#.SYNOPSIS
#  Configures the computer as an NTP time server.
#
#.DESCRIPTION
#  Configures the computer as an NTP time server. Requires
#  Windows 7, Server 2008 R2, or later.  There are other
#  issues to consider, especially on the PDC Emulator and
#  the choice of upstream time data, if any.  See the
#  following:  https://support.microsoft.com/help/816042


# Set reg value to enable NTP server capability:
reg.exe add HKLM\System\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer /v Enabled /t REG_DWORD /d 1 /f


# Set the W32Time service to start automatically:
Set-Service -Name W32Time -StartupType Automatic 


# Update the W32Time service configuration:
w32tm.exe /config /update


# Restart the W32Time service:
Restart-Service -Name W32Time 


# Confirm the configuration change; output should look like:
#    NtpClient  (Local)
#    Enabled: 1 (Local)
#    NtpServer  (Local)
#    Enabled: 1 (Local)  <--The Important Line 
w32tm.exe /query /configuration | Select-String -Pattern 'Client|Server|Enabled'



# Don't forget to enable or add an inbound firewall rule for UDP/123 to the W32Time service,
# and consider using IPsec to prevent spoofing or MITM attacks:
#  New-NetFirewallRule -DisplayName 'NTP-Time-Server-UDP123' -Name 'NTP-Time-Server-UDP123' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 123 -Service W32Time



#.NOTES
# How to configure a stand-alone to use your new time server?
#  w32tm.exe /config /syncfromflags:manual /manualpeerlist:<FQDN-Of-Your-Time-Server>
#  w32tm.exe /resync
#
#
#
# W32Time service config settings as either an NTP client
# or NTP server are stored in the registry under:
# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time

