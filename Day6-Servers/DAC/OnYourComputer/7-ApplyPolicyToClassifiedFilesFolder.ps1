# Apply the Central Access Policy named "File Servers Policy" to C:\Classified-Files.



# Get current NTFS access control list so that it may be restored.

$ACL = Get-ACL -Path "C:\Classified-Files" -Audit



# Add the 'File Servers Policy' CAP to the folder.

Set-ACL -Path "C:\Classified-Files" -AclObject $ACL -CentralAccessPolicy "File Servers Policy" 


