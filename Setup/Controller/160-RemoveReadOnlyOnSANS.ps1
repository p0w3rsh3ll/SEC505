###############################################################################
#.SYNOPSIS
#   Remove any read-only file attributes from C:\SANS\*
#.NOTES
#   Do this before you update PoSh help files or install any programs.
#   Do this before you might need to edit DefaultDataFile.psd1.
###############################################################################

dir C:\SANS -Recurse -File | foreach { $_.IsReadOnly = $false } 

