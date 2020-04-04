##########################################################################
#.SYNOPSIS
# Get services with non-standard paths to their binaries.
#
#.DESCRIPTION
# Service binaries should be installed under C:\Windows or C:\Program*
# in order to inherit the better NTFS permissions of those folders.
# This command lists the service binaries which are installed elsewhere.  
# Hopefully this command will display nothing on the audited computer.
#
#.PARAMETER ComputerName
# Name of the remote computer. Defaults to localhost.
#
##########################################################################

Param ($ComputerName = '.') 

$Query = 'SELECT Name,DisplayName,PathName FROM Win32_Service'

Get-CimInstance -Query $Query -ComputerName $ComputerName | 
Where { ($_.PathName -NotMatch '^\"*[A-Z]\:\\Windows\\.+') -and
        ($_.PathName -NotMatch '^\"*[A-Z]\:\\Program Files\\.+') -and
        ($_.PathName -NotMatch '^\"*[A-Z]\:\\Program Files \(x86\)\\.+') } |
Select-Object Name,DisplayName,PathName





