###############################################################################
#
#"[+] Checking for a Windows Server operating system..."
#
# Some attendees will run the script on their host computers.
#
###############################################################################

$check = Get-WmiObject -query "select caption from win32_operatingsystem" | select -expand caption | select-string -Pattern 'Server' -Quiet
if (-not $check)
{
    "`nYou should only run this script in the Windows Server virtual machine"
    "used for this course.  Are you sure this is Windows Server?`n"

    $answer = read-host "`nEnter 'yes' if this is your VM, enter 'no' to exit"
    if ($answer -like "*y*" -and -not $Verbose) { cls }  
    else { "`nScript terminated.`nPlease use your testing VM instead.`n" ; exit } 

    #No more scripts
    $Top.Request = "Stop"
} 

