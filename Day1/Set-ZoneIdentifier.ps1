#.DESCRIPTION
# Modifies the Zone.Identifier NTFS alternate data stream so
# that Windows will consider the file to have been downloaded
# from the Internet Zone.  This results in the "Unblock" check
# box being displayed in the properties of the file.

Param ( $Path ) 

Set-Content -Path $Path -Stream 'Zone.Identifier' -Value "[ZoneTransfer]`nZoneId=3"

