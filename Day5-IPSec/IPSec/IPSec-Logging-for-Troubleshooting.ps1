###############################################################################
# Run this script to temporarily enable IPSec-related logging to the Security
# event log in Windows for troubleshooting (see event IDs 4600-5500).
#
# Requires Vista, Server 2008, or later.
# 
# If the error is certificate-related, also try enabling CAPI2 Diagnostics
# logging in Event Viewer (Applications and Services Logs > Microsoft >
# Windows > CAPI2 > Operational).  
###############################################################################


# Enable IPSec-related audit policies:
auditpol.exe /set /SubCategory:"IPsec Main Mode" /success:enable /failure:enable
auditpol.exe /set /SubCategory:"IPsec Quick Mode" /success:enable /failure:enable
auditpol.exe /set /SubCategory:"IPsec Extended Mode" /success:enable /failure:enable
auditpol.exe /set /SubCategory:"IPsec Driver" /success:enable /failure:enable


# Restart the Windows Firewall service:
Restart-Service -Name MPSSVC


# Wait for user to finish troubleshooting:
$x = read-host -prompt "Hit any key to disable IPSec logging"


# Disable IPSec-related audit policies:
auditpol.exe /set /SubCategory:"IPsec Main Mode" /success:disable /failure:disable
auditpol.exe /set /SubCategory:"IPsec Quick Mode" /success:disable /failure:disable
auditpol.exe /set /SubCategory:"IPsec Extended Mode" /success:disable /failure:disable
auditpol.exe /set /SubCategory:"IPsec Driver" /success:disable /failure:disable


# Restart the Windows Firewall service:
Restart-Service -Name MPSSVC




