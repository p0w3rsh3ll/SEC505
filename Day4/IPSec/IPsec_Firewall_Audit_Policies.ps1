###############################################################################
# Use auditpol.exe to temporarily enable logging of IPsec and Windows Firewall
# activity to the Security event log in Windows for troubleshooting.
#
# Requires Vista, Server 2008, or later.
# 
# You may need to restart the Windows Firewall service:
#
#       Restart-Service -Name MPSSVC -Force 
#
# If the error is certificate-related, also try enabling CAPI2 Diagnostics
# logging in Event Viewer (Applications and Services Logs > Microsoft >
# Windows > CAPI2 > Operational).  
###############################################################################




##############################################################################
#
# Show current audit subcategories related to IPSec and the Windows Firewall: 
#
##############################################################################

auditpol.exe /get /subcategory:"MPSSVC rule-level Policy Change,Filtering Platform policy change,IPsec Main Mode,IPsec Quick Mode,IPsec Extended Mode,IPsec Driver,Other System Events,Filtering Platform Packet Drop,Filtering Platform Connection"


##############################################################################
#
# Enable audit subcategories related to IPSec and the Windows Firewall: 
#
##############################################################################

auditpol.exe /set /subcategory:"MPSSVC rule-level Policy Change,Filtering Platform policy change,IPsec Main Mode,IPsec Quick Mode,IPsec Extended Mode,IPsec Driver,Other System Events,Filtering Platform Packet Drop,Filtering Platform Connection" /success:enable /failure:enable



##############################################################################
#
# Disable audit subcategories related to IPSec and the Windows Firewall: 
#
##############################################################################

auditpol.exe /set /subcategory:"MPSSVC rule-level Policy Change,Filtering Platform policy change,IPsec Main Mode,IPsec Quick Mode,IPsec Extended Mode,IPsec Driver,Other System Events,Filtering Platform Packet Drop,Filtering Platform Connection" /success:disable /failure:disable



