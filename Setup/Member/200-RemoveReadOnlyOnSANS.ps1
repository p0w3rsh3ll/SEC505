###############################################################################
#
#"[+] Removing any read-only file attributes from C:\SANS\*..."
#
# Do this before you update PoSh help files or install any programs.
# 
###############################################################################

dir C:\SANS -Recurse -File | foreach { $_.IsReadOnly = $false } 

