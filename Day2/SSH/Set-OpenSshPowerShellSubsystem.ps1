##############################################################################
#.SYNOPSIS
#  Configure the OpenSSH Server "Subsystem" for PowerShell Core.
#
#.DESCRIPTION
#  If PowerShell Core and OpenSSH Server are both installed, then configure
#  OpenSSH with the 'Subsystem' necessary for PowerShell Core.  This is
#  required to support SSH-integrated PowerShell Core commands.  This script
#  will restart the OpenSSH Server service (sshd.exe) if this script
#  modifies the $env:ProgramData\ssh\sshd_config file.  This script will
#  prefer the latest non-preview version of PowerShell Core installed over 
#  any preview versions, even if the preview version(s) is more recent.
#
#  The existing sshd_config file is backed up to the same folder with a name
#  like "sshd_config.YEAR-MONTH-DAY-HOUR-MINUTE-SECOND.BACKUP".
#
#  WARNING!  If the sshd_config file already has a 'Subsystem powershell' line,
#  then this script will overwrite it!  The intent is to make it easier to
#  upgrade to a newer version of PowerShell Core and to fix an config mistakes.
#
#.NOTES
#  Last Updated: 7.Nov.2019 by JF@Enclave
##############################################################################


# Confirm that the OpenSSH Server configuration file exists:
If ( Test-Path -Path $env:ProgramData\ssh\sshd_config )
{
    $ConfigFile = @( Get-Content -Path $env:ProgramData\ssh\sshd_config ) 
}
Else
{ 
    Write-Verbose -Message "OpenSSH sshd_config file does not exist, exiting..." -Verbose
    Exit
}



# Confirm that we could actually read the non-empty sshd_config file:
If ( $ConfigFile.Count -lt 1 )
{
    Write-Verbose -Message "The sshd_config file is empty or could not be read, exiting..." -Verbose
    Exit
}



# Try to find a non-preview version of PowerShell Core installed:
# (Descending sort places higher-numbered folders first: not preview)
$Release = @( dir -Directory -Path $env:ProgramFiles\PowerShell | 
              Where-Object { $_.Name -notlike '*preview' } | 
              Sort-Object -Descending -Property Name | 
              Select-Object -First 1 )


# Try to find a preview version of PowerShell Core installed:
# (Descending sort places higher-numbered folders first: preview version)
$Preview = @( dir -Directory -Path $env:ProgramFiles\PowerShell | 
              Where-Object { $_.Name -like '*preview' } | 
              Sort-Object -Descending -Property Name | 
              Select-Object -First 1 )



#Prefer final release version over preview, but grudgingly accept preview:
If ($Release.Count -eq 1)
{ 
    $PwShPath = Join-Path -Path $Release[0].FullName -ChildPath 'pwsh.exe'
} 
ElseIf ($Release.Count -eq 0 -and $Preview.Count -eq 1)
{ 
    $PwShPath = Join-Path -Path $Preview[0].FullName -ChildPath 'pwsh.exe' 
} 
Else 
{ 
    Write-Verbose -Message "Could not find a PowerShell Core directory, exiting..."
    Exit
}



# The path to pwsh.exe must not have any space characters, so convert to 8.3 format.
# The following is cheating, but will work 98% of the time:
$PwShPath = $PwShPath -replace 'Program Files','PROGRA~1'


# Is pwsh.exe really there?  Did the 8.3 cheat fail?
If ( -not (Test-Path -Path $PwShPath) )
{
    Write-Verbose -Message "Could not find $PwShPath, exiting..."
    Exit
}


# Construct the correct Subsystem line for the sshd_config file:
# (Note: the 'Subsystem powershell' line is case sensitive!)
$SubsystemLine = "Subsystem" + "`t" + "powershell" + "`t" + $PwShPath + " -sshs -nologo -noprofile"


# Make a backup copy of the config file, else exit:
$BackupPath = "$env:ProgramData\ssh\sshd_config" + "." + (Get-Date -Format 'yyyy-MM-dd-hh-mm-ss') + ".BACKUP"

Copy-Item -Path $env:ProgramData\ssh\sshd_config -Destination $BackupPath -Force

If (-not (Test-Path -Path $BackupPath))
{ 
    Write-Verbose -Message "Could not save $BackupPath, exiting..."
    Exit
}



# Update the lines for the sshd_config file:
ForEach ($Line in $ConfigFile)
{
    if ($Line -match 'Subsystem\W+powershell\W+')
    { Continue } #Don't add it back to the $NewConfigFile.

    if ($Line -match 'sftp-server\.exe')
    { $Line = $Line + "`n" + $SubsystemLine } #Add our new line after the sftp subsystem.

    $NewConfigFile += ($Line + "`n")   #File is not very long...
}


# Try to overwrite the existing sshd_config; hard stop if error:
$NewConfigFile | Out-File -FilePath $env:ProgramData\ssh\sshd_config -Encoding utf8 -Force -ErrorAction Stop


# Restart the OpenSSH Server service, if we didn't hard stop: 
Restart-Service -Name sshd

