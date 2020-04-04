# This script only runs on Windows Server, not any client OS.
# Role names can be seen with Get-WindowsFeature.
# Service names can be seen with Get-Service.  


Configuration TestConfig
{
    Param ([String[]] $ComputerName = "LocalHost")

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName
    {
        WindowsFeature NoWINS
        {
            Ensure = "Absent"
            Name = "WINS" 
        }

        WindowsFeature YesDNS
        {
            Ensure = "Present"
            Name = "DNS" 
        }

        Service StartWMI
        {
            Name = "WinMgmt"
            StartupType = "Automatic"
            State = "Running"
        }
    }
} 



# Create MOF file(s):
TestConfig -ComputerName "LocalHost" 


# Enact MOF for localhost only:
Start-DscConfiguration -Path .\TestConfig -ComputerName "LocalHost" -Verbose -Wait -Force



