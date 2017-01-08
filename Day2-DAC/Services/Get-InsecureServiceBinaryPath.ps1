# Service binaries should be installed under C:\Windows or C:\Program*
# in order to inherit the better NTFS permissions of those folders.
# This command lists the service binaries which are installed elsewhere.  
# Hopefully this command will display nothing on the audited computer.

Get-WmiObject Win32_Service | 
Where { $_.PathName -NotMatch '^\"*C\:\\Windows\\.+' } | 
Where { $_.PathName -NotMatch '^\"*C\:\\Program Files\\.+' } | 
Where { $_.PathName -NotMatch '^\"*C\:\\Program Files \(x86\)\\.+' } | 
Format-List DisplayName,PathName








# If you're not using the C: drive or standard folder names, you can use this instead:
#
# Get-WmiObject Win32_Service | 
# Where { $_.PathName -NotMatch '^\"*' + ($env:windir).replace('\','\\').replace(':','\:') + '\\.+' } | 
# Where { $_.PathName -NotMatch '^\"*' + ($env:programfiles).replace('\','\\').replace(':','\:') + '\\.+' } |
# Where { $_.PathName -NotMatch '^\"*' + (($env:programfiles).replace('\','\\').replace(':','\:') + '\\.+').replace('Files','Files \(x86\)') } | 
# Format-List DisplayName,PathName


