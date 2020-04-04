###############################################################################
#
#"[+] Setting some environment variables..."
#
###############################################################################

[System.Environment]::SetEnvironmentVariable("POWERSHELL_TELEMETRY_OPTOUT", "1", "Machine")
[System.Environment]::SetEnvironmentVariable("POWERSHELL_UPDATECHECK_OPTOUT", "1", "Machine")
