# Purpose: use DSC to install the IIS web server role.

# This step is not one of the required steps to "bootstrap"
# a machine into being ready to receive a DSC configuration. 
# 
# This script is an example of how real work can be done with 
# DSC now that all necessary resource modules have (hopefully)
# been installed in the prior steps.  Hence, we are done 
# getting ready to use DSC, we can now actually use DSC.  


Configuration DSC-WebServer
{
    Param ( [String[]] $ComputerName = "LocalHost" )
 
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName
    { 
        WindowsFeature YesIIS
        { Ensure = "Present" ; Name = "Web-Server" }

        WindowsFeature NoWINS
        { Ensure = "Absent" ; Name = "WINS" }

        Service StartWinRM
        {
            Name = "WinRM"
            StartupType = "Automatic"
            State = "Running"
        }
    }
}



# Create the MOF from the above function and save to the MOF share:

DSC-WebServer -ComputerName $env:COMPUTERNAME -OutputPath "\\$env:COMPUTERNAME\MOF\DSC-WebServer"  



# Apply the MOF to the target computer, which happens to be this one:

Start-DscConfiguration -ComputerName $env:COMPUTERNAME -Path "\\$env:COMPUTERNAME\MOF\DSC-WebServer" -Force -Verbose -Wait 




