#.SYNOPSIS
#   Runs Install-OpenSSH.ps1 and overwrites sshd_config.
#
#.NOTES
#   Installation source folder and other files can be placed
#   anywhere, but the paths to these item below must be correct.


#Assume failure:
$Top.Request = "Stop"

# Notice the path underneath .\WebServer:
& .\Resources\OpenSSH\Install-OpenSSH.ps1 -SourceFiles .\Resources\OpenSSH\OpenSSH-Win64\

Start-Sleep -Seconds 5

# Notice the path underneath .\WebServer:
Copy-Item -Path .\Resources\OpenSSH\sshd_config -Destination $env:ProgramData\ssh\sshd_config -Force 


# Restarting the sshd service will fail if either the service
# does not exist or if the sshd_config settings are mangled:
Try
{ 
  Restart-Service -Name sshd
}
Catch
{
  Throw "ERROR: Failed to install OpenSSH or it has bad config settings."
  Exit
}


#Assume success:
$Top.Request = "Continue"

