#############################################################################
# NTFS alternate data streams are used with the RemoteSigned PowerShell 
# execution policy, Dynamic Access Control file classification, MS Office
# security policies, and other applications.  The following commands
# demonstrate how to interact with NTFS streams from within PowerShell.
#############################################################################
#
# Zone.Identifier ZoneId=*
#  0 = My Computer 
#  1 = Local Intranet Zone 
#  2 = Trusted sites Zone 
#  3 = Internet Zone 
#  4 = Restricted Sites Zone
#
#############################################################################


# List streams on a file or all files:
get-item file.ps1 -stream *
get-item * -stream *


# Get the content of a stream named Zone.Identifier:
get-content file.ps1 -stream Zone.Identifier


# Set the content of a stream named Zone.Identifier:
"[ZoneTransfer]`nZoneId=3" | Set-Content file.ps1 -Stream Zone.Identifier


# Remove a stream named Zone.Identifier from all *.ps1 files and
# suppress any error messages when that stream name is not found:
remove-item *.ps1 -stream Zone.Identifier -ErrorAction SilentlyContinue



