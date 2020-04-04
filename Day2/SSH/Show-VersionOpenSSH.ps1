<#
.SYNOPSIS
    Show version of OpenSSH binaries installed.
#>


$OpenSshPath = @( $Env:Path -split ';' | Where { $_ -like "*OpenSSH*" } ) 


if ($OpenSshPath.Count -eq 0)
{ 
    "`nPATH environment variable does not include an OpenSSH folder."
    "Is OpenSSH even installed?`n"
}
else
{
    # Catch misconfigured PATH containing multiple OpenSSH folders.
    "`n`n"
    "+" * 50
    " PATH environment variable includes:"
    "+" * 50
    $OpenSshPath -join "`n" 
}



"`n`n"
"+" * 50
" OpenSSH Binary Executables:"
"+" * 50

$binaries = @() 

#Display those in PATH first
ForEach ($folder in $OpenSshPath)
{
    $binaries += dir (Join-Path -Path $folder -ChildPath '\*.exe') -ErrorAction SilentlyContinue 
}

#Might not be in the normal PATH OpenSSH folder
$binaries += dir (Get-Command -Name 'ssh.exe' | Split-Path -Parent | Join-Path -ChildPath '\*.exe') -ErrorAction SilentlyContinue

#Recommended folders
$binaries += dir $env:ProgramFiles\OpenSSH\*.exe -ErrorAction SilentlyContinue
$binaries += dir ${env:ProgramFiles(x86)}\OpenSSH\*.exe -ErrorAction SilentlyContinue

#Default
$binaries += dir $env:WinDir\System32\OpenSSH\*.exe -ErrorAction SilentlyContinue

# Suppress duplicates in table:
$binaries | Select-Object -Unique |
Select-Object -ExpandProperty VersionInfo | 
Format-Table -AutoSize -Property FileName,FileVersion,ProductVersion 

# See also: ssh.exe -V

"`n`n"
"+" * 50
" OpenSSH SSH Server Service (sshd):"
"+" * 50
if ((Get-Service -Name sshd -ErrorAction SilentlyContinue) -eq $null)
{
    "The OpenSSH SSH Server service (sshd) is not installed."
}
else
{
    Get-Service -Name sshd | Format-Table Status,StartType,Name,DisplayName -AutoSize 

    if ( (Get-Service -Name sshd).Status -eq 'Running') 
    {
        if ($PSVersionTable.PSEdition -eq 'Core')
        {
            sc.exe qc sshd | Select-String -Pattern 'sshd' -NoEmphasis
            sc.exe qprivs sshd | Select-String -Pattern '\: Se' -NoEmphasis
        }
        else
        {
            sc.exe qc sshd | Select-String -Pattern 'sshd'
            sc.exe qprivs sshd | Select-String -Pattern '\: Se'
        }
    }
}



"`n`n"
"+" * 50
" OpenSSH SSH Agent Service (ssh-agent):"
"+" * 50

if ((Get-Service -Name ssh-agent -ErrorAction SilentlyContinue) -eq $null)
{
    "The OpenSSH SSH Agent service (ssh-agent) is not installed."
}
else
{
    Get-Service -Name ssh-agent | Format-Table Status,StartType,Name,DisplayName -AutoSize 

    if ( (Get-Service -Name ssh-agent).Status -eq 'Running') 
    {
        if ($PSVersionTable.PSEdition -eq 'Core')
        {
            sc.exe qc ssh-agent | Select-String -Pattern 'ssh\-agent' -NoEmphasis
            sc.exe qprivs ssh-agent | Select-String -Pattern '\: Se' -NoEmphasis
        }
        else
        {
            sc.exe qc ssh-agent | Select-String -Pattern 'ssh\-agent'
            sc.exe qprivs ssh-agent | Select-String -Pattern '\: Se'
        }
    }
}

