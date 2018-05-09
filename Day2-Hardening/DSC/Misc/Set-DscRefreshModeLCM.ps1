<#############################################################################
.SYNOPSIS
    Enable or disable the Local Configuration Manager (LCM) for DSC.

.DESCRIPTION
    Enable or disable the Local Configuration Manager (LCM) for Desired State 
    Configuration (DSC) on localhost, but, if DSC is enabled, it can only be
    enabled for Push mode; Pull mode cannot be enabled with this script.  

.PARAMETER RefreshMode
    Must be either "Push" or "Disabled"; it cannot be Pull mode.
    Defaults to Push mode for DSC, which is the factory default too.

.PARAMETER ConfigurationMode
    Must be "ApplyOnly","ApplyAndMonitor" or "ApplyAndAutoCorrect."
    Defaults to ApplyAndMonitor, which is the factory default too.

.PARAMETER ConfigurationModeFrequencyMins
    Must be an integer between 15 and 44640.  Defaults to 15 minutes.
    Has no effect if the configuration mode is Disabled or ApplyOnly.

.PARAMETER RebootNodeIfNeeded
    Switch defaults to $False, reboots are not automatic, even if needed.

.NOTES
    Requires WMF 5.0 or later, plus administrative privileges.
    Created: 9.Jun.2017
    Updated: 9.Jun.2017
     Author: Enclave Consulting LLC (https://sans.org/sec505)
      Legal: Public domain, provided "AS IS" without warranties.
#############################################################################>

[CmdletBinding()][OutputType([String])]
Param (
    [ValidateSet("Push","Disabled")]
       $RefeshMode = "Push",
    [ValidateSet("ApplyOnly","ApplyAndMonitor","ApplyAndAutoCorrect")]
       $ConfigurationMode = "ApplyAndMonitor",
    [ValidateRange(15,44640)]
    [UInt32]
       $ConfigurationModeFrequencyMins = 15,
    [Switch]
       $RebootNodeIfNeeded
)

# Get the current working directory:
$CurrentFolder = $PWD 


# Create a randomly-named temp folder and switch into it:
$GUID = [System.Guid]::NewGuid().Guid
mkdir -Path $env:TEMP -Name $GUID | foreach { cd $_ } 
if (-not $?){ Write-Error -Message "ERROR: Failed to create temp folder!" ; Exit }


# Create DSC configuration function to disable LCM:
[DSCLocalConfigurationManager()]
Configuration LcmConfig82389373802
{
    Node LocalHost
    {
        Settings
        {
            RefreshMode = $RefeshMode
            ConfigurationMode = $ConfigurationMode
            ConfigurationModeFrequencyMins = $ConfigurationModeFrequencyMins
            RebootNodeIfNeeded = $RebootNodeIfNeeded   
        }
    }
}


# Create the META.MOF file 
LcmConfig82389373802 | Out-Null


# Enact the MOF on the localhost only:
Set-DscLocalConfigurationManager -Path .\LcmConfig82389373802 -ComputerName "LocalHost"


# Delete the temp folder:
cd $CurrentFolder
Remove-Item -Path (Join-Path -Path $env:TEMP -ChildPath $GUID) -Recurse -Force


# Delete the DSC function:
Remove-Item -Path function:\LcmConfig82389373802 -Force


# Check new LCM RefreshMode:
Get-DscLocalConfigurationManager | Select -ExpandProperty RefreshMode

