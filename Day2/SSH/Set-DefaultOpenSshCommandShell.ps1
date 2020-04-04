########################################################
#.SYNOPSIS
#  Sets the default OpenSSH command shell on Windows.
#
#.DESCRIPTION
#  When the OpenSSH Service service runs on Windows, and
#  a remote user connects inbound to create a new interactive
#  session, the default command shell is CMD.EXE.  This
#  script can set the default command shell to CMD.EXE,
#  POWERSHELL.EXE or PWSH.EXE.  If multiple versions of
#  PowerShell Core (PwSh) are installed, the script will
#  set the latest non-preview version.  If only a preview
#  version of PowerShell Core is installed, the latest
#  preview version will be set.  
#
#.PARAMETER Shell
#  The command shell must be 'CMD', 'PwSh' or
#  'PowerShell' for CMD.EXE, PWSH.EXE or POWERSHELL.EXE.
#
#.NOTES
#  The default command shell cannot be PowerShell ISE.
#  This script may only be used on Windows. 
#  You do not have to restart the OpenSSH service.
#
#  Beware, if you change the default shell to PWSH or
#  POWERSHELL on a system, and you configure the OpenSSH
#  server on that system with the "Subsystem powershell",
#  and you have a $profile script on that system, then
#  that $profile script will be run during the launch of
#  "pwsh.exe -sshs".  If your $profile script produces any
#  output, it will cause an error when you attempt to 
#  Enter-PSSession with SSH.  Hence, either set CMD as
#  the default OpenSSH shell or ensure that all four of
#  your $profile scripts at the target server do not
#  print any output when run, otherwise you will get a
#  error which reads "There is an error processing data
#  from the background process" when connecting. 
#
#  Last Updated: 7.Nov.2019 
########################################################

[CmdletBinding()]
Param ([ValidateSet('CMD','PwSh','PowerShell')] $Shell = 'CMD')

If ($Shell -eq 'PowerShell')
{
    # Set powershell.exe as the default shell:
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShellCommandOption -Value "-nologo -command" -PropertyType String -Force | Out-Null
}
ElseIf ($Shell -eq 'CMD')
{
    # Set CMD.EXE as the default Shell:
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\system32\cmd.exe" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShellCommandOption -Value "/c" -PropertyType String -Force | Out-Null 
}
ElseIf ($Shell -eq 'PwSh')
{
    #Descending sort places higher-numbered folders first: not preview
    $Release = @( dir -Directory -Path $env:ProgramFiles\PowerShell | 
                   Where-Object { $_.Name -notlike '*preview' } | 
                   Sort-Object -Descending -Property Name | 
                   Select-Object -First 1 )

    #Descending sort places higher-numbered folders first: preview version
    $Preview = @( dir -Directory -Path $env:ProgramFiles\PowerShell | 
                   Where-Object { $_.Name -like '*preview' } | 
                   Sort-Object -Descending -Property Name | 
                   Select-Object -First 1 )

    #Prefer final release version over preview, but accept preview
    If ($Release.Count -eq 1)
    { $PwShPath = Join-Path -Path $Release[0].FullName -ChildPath 'pwsh.exe' } 
    ElseIf ($Release.Count -eq 0 -and $Preview.Count -eq 1)
    { $PwShPath = Join-Path -Path $Preview[0].FullName -ChildPath 'pwsh.exe' } 
    Else 
    { 
        throw "Could not find a PowerShell Core directory!"
        Exit
    }

    #Is pwsh.exe really there?
    If ( Test-Path -Path $PwShPath )
    {
        # Set PwSh as the default Shell:
        New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $PwShPath -PropertyType String -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShellCommandOption -Value "-nologo -command" -PropertyType String -Force | Out-Null 
    }
    Else
    { 
        throw "No changes made, could not find $PwShPath"
    }    
}


