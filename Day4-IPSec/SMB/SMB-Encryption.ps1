# Server 2012, Windows 8 and later support SMB encryption.


# To disable SMB 1.0 on Server 2012, Windows 8 and later:
Set-SmbServerConfiguration –EnableSMB1Protocol $False


# To only prefer (not require) SMB encryption:
Set-SmbServerConfiguration -RejectUnencryptedAccess $False


# To list which shared folders do or do not require SMB encryption:
Get-SmbShare | Format-Table Name,Path,EncryptData -AutoSize


# To require SMB encryption for the entire server (all shares):
Set-SmbServerConfiguration -EncryptData $True


# To require SMB encryption for one shared folder only:
Set-SmbShare –Name <ShareName> -EncryptData $True


