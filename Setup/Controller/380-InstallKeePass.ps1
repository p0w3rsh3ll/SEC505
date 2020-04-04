###############################################################################
#
#"[+] Installing KeePass..."
#
###############################################################################

$setup = dir .\Resources\KeePass\*setup*.exe | select -Last 1
invoke-expression -command ($setup.FullName + ' /VERYSILENT')

Start-Sleep -Seconds 2

