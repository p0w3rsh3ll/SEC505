###############################################################################
#
#"[+] Showing completion message and restoring original culture..."
#
# This should be the very last script.
###############################################################################


("`n" * 25) 
Write-Host -ForegroundColor Green -Object ("*" * 48)
"`n  Finished!  `n"
"  The name of this VM is $env:ComputerName. `n"
"  Remember, your new password is P@ssword.`n" 
Write-Host -ForegroundColor Green -Object ("*" * 48)
("`n" * 7) 


[System.Threading.Thread]::CurrentThread.CurrentCulture = $Top.CurrentCulture
[System.Threading.Thread]::CurrentThread.CurrentUICulture = $Top.CurrentUICulture

cd C:\SANS 
