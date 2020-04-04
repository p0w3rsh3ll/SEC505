###############################################################################
#
#"[+] Changing the user interface culture to 'en-US'..."
#
# Not all attendees speak English as their primary language. Parts of this 
# script requires the culture to be en-US.  Don't worry, the current culture 
# is restored at the very end and is temporary to this process anyway. (Note  
# that $Host.CurrentCulture is read-only, hence, the use of CurrentThread.)
#
###############################################################################

$Top.CurrentCulture =   [System.Threading.Thread]::CurrentThread.CurrentCulture
$Top.CurrentUICulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
[System.Threading.Thread]::CurrentThread.CurrentCulture =   "en-US"
[System.Threading.Thread]::CurrentThread.CurrentUICulture = "en-US"

# Jason, is this only used by the posh help installer?