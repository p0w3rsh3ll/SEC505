###############################################################################
#
#"[+] Installing Process Hacker..."
#
# Do not install Process Hacker 3.x until after labs are updated.
#
###############################################################################

$setup = dir .\Resources\ProcessHacker\*setup*.exe | select -Last 1
Invoke-expression -command ($setup.FullName + ' /VERYSILENT')

Start-Sleep -Seconds 1

