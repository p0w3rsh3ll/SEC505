###############################################################################
#
#"[+] Checking for Administrator identity..."
#
# Remember, culture is temporarily set to en-US.
#
###############################################################################

if ($env:USERNAME -notlike "*Administrator*")
{ 
    "`n`nErrors will occur during the Active Directory installation"
    "if you are not logged on with the built-in Administrator account."
    "Please log on with the built-in Administrator account and run"
    "this script again.  Using a new account which has been added"
    "to the local Administrators group will NOT prevent the errors.`n"

    $Top.Request = "Stop" 
}

