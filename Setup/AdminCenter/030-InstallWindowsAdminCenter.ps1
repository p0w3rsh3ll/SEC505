###############################################################################
#.SYNOPSIS
#   Install Microsoft Windows Admin Center (WAC) web application.
#
#.NOTES
#   Must give msiexec.exe the full path to MSI or else the install will fail.
#
#   Must restart the WinRM service after WAC install.  This will terminate any
#   existing WSMAN remoting sessions.  Add "RESTART_WINRM=0" to the install
#   command to prevent the WinRM service from being automatically restarted.
#   However, despite what Microsoft says, the "RESTART_WINRM=0" option does
#   not seem to work reliably to prevent WinRM restart (???).
#
#   When generating a self-signed cert, the Subject Alternative Name in the cert
#   (not the Subject) will be set to both the hostname and the FQDN of the WAC
#   server. The 2048-bit RSA cert will only have a 60-day TTL.  Rename the 
#   computer before installing WAC.
#
#   Note the log written to $Home\Documents when troubleshooting. 
#
#   WAC is not compatible with Server 2012 or earlier.  It is normal for there
#   to be a delay of 5-15 seconds between restarting the WAC service and
#   its listening TCP port to appear (at least when DevMode reg value is set).
#
#   Do not set the DevMode registry value BEFORE installing WAC, wait until 
#   after installating, if you are going to set this value at all.  
#   Do we still need to set the DevMode reg value and restart?  Seems to cause 
#   problems in v1904 when set this way:
#       reg.exe add HKLM\SOFTWARE\Microsoft\ServerManagementGateway /v DevMode /t REG_SZ /d 1 /f | Out-Null 
#       Restart-Service -Name ServerManagementGateway -ErrorAction SilentlyContinue 
#
#   To uninstall WAC, the commands will be like:
#       $msi = dir .\Resources\AdminCenter\*Admin*.msi | Select -Last 1
#       msiexec.exe /uninstall $msi.FullName /qn 
###############################################################################

# Default TCP port for WAC service:
[String] $Port = "47"


# Override default port if specified in $Top:
if ((Test-Path -Path Variable:\Top) -and ($Top.WindowsAdminCenterPort -ne $null))
{ $Port = $Top.WindowsAdminCenterPort } 

# Is there a TLS certificate hash to use for WAC?



# Test if the WAC service already exists before installing:
$WAC = Get-Service -Name ServerManagementGateway -ErrorAction SilentlyContinue

if ($WAC -eq $null) 
{
    # Must give full path to MSI, not relative:
    $msi = dir .\Resources\AdminCenter\*Admin*.msi | Select -Last 1

    # Must give full path to log file, not relative:
    $logfile = Join-Path -Path "$Home\Documents" -ChildPath ($MyInvocation.MyCommand.Name + ".txt") 

    # Generate a self-signed cert:
    msiexec.exe /i $msi.FullName /qn /log $logfile SME_PORT=$Port SSL_CERTIFICATE_OPTION=generate #RESTART_WINRM=0

    # Give it a few seconds for the quick-fingered attendees:
    Start-Sleep -Seconds 6 
    
    # Or use the hash of an existing TLS cert with the FQDN in the Subject Alternative Name:
    #   $thumbprint = "FFFFFFFFFFFFFF"  #Hard-code or script the hash value, no space characters.
    #   msiexec.exe /i $msi.FullName /qn /log $logfile SME_PORT=$Port SME_THUMBPRINT=$thumbprint SSL_CERTIFICATE_OPTION=installed #RESTART_WINRM=0

    # If you set 'RESTART_WINRM=0', either restart WinRM here or restart it as part of the lab:
    # Restart-Service -Name WinRM
}
else 
{
    # Attendees might run this script again for troubleshooting
    Set-Service -Name ServerManagementGateway -StartupType Automatic 
    Restart-Service -Name ServerManagementGateway
}


