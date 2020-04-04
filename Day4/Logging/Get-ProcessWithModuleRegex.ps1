<#
.SYNOPSIS
Get process with a particular module loaded.

.PARAMETER ModuleNameRegEx
The regular expression pattern for the module whose existence is checked 
in every running process by comparing against the full path of every module
loaded into each process.  Must be a regex pattern.  For compatibility with
PowerShell Core on Linux and the ".ni." portion of the string on Windows, it 
defaults to '[/\\]System\.Management\.Automation\..*dll$'.

.PARAMETER ExcludeCommonHosts
Suppresses the output of common hosting processes for the named module.
Defaults to PowerShell.exe, PowerShell_ISE.exe and ServerManager.exe.
Edit the list of regexes in the script to exclude more.

.NOTES
Malware can load the PowerShell engine DLL into other .NET processes
to execute PowerShell commands.  Hackers and ransomware do not have to run
powershell.exe in order to execute PowerShell code.  
#> 

[CmdletBinding()]
Param ([String] $ModuleNameRegEx = '[/\\]System\.Management\.Automation\..*dll$', 
       [Switch] $ExcludeCommonHosts)


# Regex patterns to common PowerShell host processes to exclude:
$CommonHostPathRegExs = @(
'\\Windows\\system32\\WindowsPowerShell\\v1\.0\\PowerShell_ISE\.exe$',
'\\Windows\\system32\\WindowsPowerShell\\v1\.0\\powershell\.exe$',
'\\Windows\\system32\\ServerManager\.exe$',
'\\Program Files\\PowerShell\\.+\\pwsh.exe$',
'/snap/powershell-preview/\d+/opt/powershell/pwsh$',
'/snap/powershell/\d+/opt/powershell/pwsh$',
'/opt/powershell/pwsh$')


# Examine loaded modules of every running process (slow):
:outer ForEach ($Process in Get-Process)
{
    # Assume process should not be emitted
    $Emit = $False

    # Array of the full file system path to each module of the $Process:
    Write-Verbose ("DOING: " + $Process.Path + " [" + $Process.Id + "]")

    # Desired module found? Break ASAP.  
    :inner ForEach ($Path in $Process.Modules.FileName)
    {
        if ($Path -match $ModuleNameRegEx)
        {
            Write-Verbose "INCLUDED: $Path matched $ModuleNameRegEx" 
            $Emit = $True
            Break inner
        } 
    }

    # Didn't find it?
    if (-not $Emit){ Continue outer } 

    # If we're not excluding common hosts, then emit and goto next:
    if (-not $ExcludeCommonHosts)
    {
        $Process
        Continue outer
    }

    # We're excluding common hosts then, break ASAP.
    :inner2 ForEach ($regex in $CommonHostPathRegExs)
    { 
        if ($Process.Path -match $regex)
        { 
            Write-Verbose ("EXCLUDED: $Process.Path matched $regex")
            $Emit = $False
            Break inner2
        }
        else
        { Write-Verbose "CHECKING: $Process.Path did not match $regex" } 
    }

    # Finally...ugh, what ugly code:
    if ($Emit){ $Process } 

}

