# Purpose: create a DSC configuration function to change 
# the settings of the LCM itself, then run that function
# to change the LCM.  We will talk about how this script
# works right after the lab.



[DSCLocalConfigurationManager()]
Configuration LocalConfigManager
{
    Param ( [String[]] $ComputerName = "LocalHost" )

    Node $ComputerName
    {
        Settings
        {
            RefreshMode = "Push"           
            ConfigurationMode = "ApplyOnly"
            RebootNodeIfNeeded = $True   
        }
    }
}



# Run the above configuration function, saving the MOF file 
# it creates to the shared folder created a minute ago:

LocalConfigManager -ComputerName $env:COMPUTERNAME -OutputPath "\\$env:COMPUTERNAME\MOF\LocalConfigManager"  



# Use a special built-in cmdlet to apply the MOF file
# from the shared folder to the local computer's LCM,
# which reconfigures the LCM the way we want it: 

Set-DscLocalConfigurationManager -ComputerName $env:COMPUTERNAME -Path "\\$env:COMPUTERNAME\MOF\LocalConfigManager" 





