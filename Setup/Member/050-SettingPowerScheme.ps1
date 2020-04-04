###############################################################################
#
#"[+] Setting Power Scheme to High Performance..."
#
# This must come before the first reboot/logoff.
###############################################################################

powercfg.exe /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
# Set display timeout to zero:
powercfg.exe /SETACVALUEINDEX 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0 

