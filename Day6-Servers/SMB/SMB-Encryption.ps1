#################################################################
# Example PowerShell commands for managing SMB encryption.
# Server 2012, Windows 8 and later support SMB encryption.
#################################################################


# To require SMB encryption for the entire server (all shares):
Set-SmbServerConfiguration -EncryptData $True -Force
Set-SmbServerConfiguration -RejectUnencryptedAccess $True -Force


# To only enable SMB encryption, but not require it:
Set-SmbServerConfiguration -EncryptData $True -Force
Set-SmbServerConfiguration -RejectUnencryptedAccess $False -Force


# To see the current SMB settings for the entire server:
Get-SmbServerConfiguration | Select EncryptData,RejectUnencryptedAccess


# To require SMB encryption for one shared folder only:
Set-SmbShare -Name <ShareName> -EncryptData $True -Force 


# To require SMB encryption for all shared folders individually:
Get-SmbShare | Set-SmbShare -EncryptData $True -Force


# To list which shared folders do or do not require SMB encryption:
Get-SmbShare | Select EncryptData,Name,Path -AutoSize


# To see what version of SMB is being used (run on server, not client):
Get-SmbSession | Select ClientComputerName,ClientUserName,Dialect


# To disable inbound SMBv1 support:
Set-SmbServerConfiguration -EnableSMB1Protocol $False -Force





# Notes: 
# You cannot mark the ADMIN$, IPC$ or C$ shares as encrypted,
# but, if the server as a whole has EncryptData = $True, then
# SMB traffic to these shares will be encrypted anyway. Other
# hidden shares (with a $ at the end of the share name) may
# be encrypted.
#
# You can mark the SYSVOL and NETLOGON shares as encrypted
# on domain controllers, just make sure all domain-joined
# clients are Windows 8, Server 2012, or later.
#
# If a particular shared folder has EncryptData set to $False,
# access to that share will still be encrypted if encryption is
# enabled for the server as a whole. When in doubt, enable 
# encryption for the server as a whole and also mark every 
# individual shared folder as encrypted.  
#
# If RejectUnencryptedAccess is set to $True on the server,
# which is the default, then SMBv1 clients will be rejected
# even if EnableSMB1Protocol is set to $True.  So, this means
# that if RejectUnencryptedAccess is set to $False on the server,
# and EnableSMB1Protocol is set to $True, then SMBv1 clients
# will be allowed access.  The most secure configuration is to
# disable SMBv1 and also reject all unencrypted access.






