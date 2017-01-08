#################################################################
#  Server 2012, Windows 8 and later support SMB encryption.
#################################################################


# To disable SMBv1 or SMBv2:
Set-SmbServerConfiguration –EnableSMB1Protocol $False
Set-SmbServerConfiguration -EnableSMB2Protocol $False


# To require SMB encryption for the entire server (all shares):
Set-SmbServerConfiguration -EncryptData $True


# To only prefer (not require) SMB encryption:
Set-SmbServerConfiguration -RejectUnencryptedAccess $False


# To require SMB encryption for one shared folder only:
Set-SmbShare –Name <ShareName> -EncryptData $True


# To list which shared folders do or do not require SMB encryption:
Get-SmbShare | Format-Table Name,Path,EncryptData -AutoSize


# To see what version of SMB is being used (run on server, not client):
Get-SmbSession | Format-List *





