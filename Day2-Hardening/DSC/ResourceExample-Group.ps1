# THIS SCRIPT DOES NOT WORK ON DOMAIN CONTROLLERS, IT IS ONLY
# FOR LOCAL GROUPS, NOT "DOMAIN LOCAL GROUPS" IN AD.


Configuration TestConfig
{
    Param ([String[]] $ComputerName = "LocalHost")

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName
    {
        Group LocalGroupExample
        {
            Ensure = "Present"
            GroupName = "HelpDeskAdmins"
            Description = "Help Desk Administrators"
            MembersToInclude = "Administrator"
            MembersToExclude = "Guest"
        }
    }
} 



# Create MOF file(s):
TestConfig -ComputerName "LocalHost" 


# Enact MOF for localhost only:
Start-DscConfiguration -Path .\TestConfig -ComputerName "LocalHost" -Verbose -Wait -Force



