#.SYNOPSIS
#  Installs the Web-WebServer and Web-Ftp-Server roles.
#
#.NOTES
#  Sometimes you'll want more detailed control over the
#  installation process, perhaps to handle errors more
#  gracefully or to write to a log.


# Assume failure:
$Top.Request = "Stop"


# Confirm that the ServerManager module can be imported:
Import-Module -Name ServerManager -ErrorAction Stop


# Get the Web-WebServer role:
$WebRole = Get-WindowsFeature -Name "Web-WebServer" -ErrorAction Stop 


# Install Web-WebServer role if necessary:
if (-not $WebRole.Installed)
{
    Install-WindowsFeature -Name "Web-WebServer" -IncludeManagementTools -ErrorAction Stop
}


# Get the Web-Ftp-Server role:
$FtpRole = Get-WindowsFeature -Name "Web-Ftp-Server" -ErrorAction Stop 


# Install Web-Ftp-Server role if necessary:
if (-not $FtpRole.Installed)
{
    Install-WindowsFeature -Name "Web-Ftp-Server" -IncludeManagementTools -ErrorAction Stop
}


# If we get here, assume it worked:
$Top.Request = "Continue" 

