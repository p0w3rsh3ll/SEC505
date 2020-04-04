###############################################################################
#
#"[+] Checking for the existence of C:\SANS..."
#
###############################################################################

if (-not (test-path C:\SANS)) 
{
    new-item -type directory -path C:\SANS -force | out-null 
    cls
    "`n`n A new folder has been created: C:\SANS `n"
    " Please copy the SEC505 course files into C:\SANS in your VM, then,"
    " in PowerShell, switch to C:\SANS and run this script again with"
    " administrative privileges. Your course files are inside the ISO file"
	" given to you on the SEC505 USB flash drive or DVD disk.`n`n"

    $Top.Request = "Stop"
}
