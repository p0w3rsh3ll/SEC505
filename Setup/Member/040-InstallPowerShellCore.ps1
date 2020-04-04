###############################################################################
#
#"[+] Installing PowerShell Core..."
#
# Install other things first before updating PSCore help to give msiexec time.
###############################################################################

$setup = dir ".\Resources\PSCore\*PowerShell*.msi" | select -Last 1
msiexec.exe /i $setup.FullName /qn

# Not needed when not updating pwsh help manually:
#Start-Sleep -Seconds 12

