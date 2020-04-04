###############################################################################
#
#"[+] Enabling audit policy to log successful and failed logons..."
#
# Also captures IPsec logons, claims, NPS logons, account lockouts, etc.
# Set this before the first reboot for AD to ensure some log data.
# 
###############################################################################

auditpol.exe /set /category:"Logon/Logoff" /success:enable /failure:enable | out-null

