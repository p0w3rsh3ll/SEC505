# Manage LCM's own settings, e.g., push/pull mode, refresh frequency, etc.
# Requires WMF 5.0 or later.  


[DSCLocalConfigurationManager()]
Configuration ExampleLcmConfig
{
    Param ([String[]] $ComputerName = "LocalHost")

    Node $ComputerName
    {
        Settings
        {
            ConfigurationModeFrequencyMins = "15"   # 15-44640 minutes (default = 15)
            RefreshMode = "Push"                    # Push, Pull, or Disabled (default = Push)
            ConfigurationMode = "ApplyAndMonitor"   # ApplyOnly, ApplyAndMonitor, ApplyAndAutoCorrect (default = ApplyAndMonitor)
            RebootNodeIfNeeded = $False             # Default = $False 
        }
    }
}


# Create the *.META.MOF file(s):
ExampleLcmConfig -ComputerName "LocalHost" 


# Enact the MOF on the localhost only:
Set-DscLocalConfigurationManager -Path .\ExampleLcmConfig -Verbose


# View the current LCM settings:
Get-DscLocalConfigurationManager
