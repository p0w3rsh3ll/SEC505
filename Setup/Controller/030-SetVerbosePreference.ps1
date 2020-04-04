###############################################################################
#
#"[+] Testing for the Verbose switch..."
#
###############################################################################

# When script is run with -Verbose switch, $VerbosePreference is set to Continue:
if ($VerbosePreference -eq "Continue") 
{ $Top.Verbose = $True } 
else 
{ $Top.Verbose = $False } 
