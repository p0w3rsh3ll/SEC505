
Configuration TestConfig
{
    Param ([String[]] $ComputerName = "LocalHost")

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName
    {
        File CreateFileExample
        {
            DestinationPath = "C:\Temp\SetByDsc.txt"
            Contents = "This file was created by DSC." 
        }

        File SyncFolderExample
        {
            SourcePath = "C:\SANS\Day1-PowerShell\Examples"
            DestinationPath = "C:\Temp\SyncTarget"
            Type = "Directory"
            Recurse = $True
            Checksum = "ModifiedDate" #or SHA-512
        }
    }
} 



# Create MOF file(s):
TestConfig -ComputerName "LocalHost" 


# Enact MOF for localhost only:
Start-DscConfiguration -Path .\TestConfig -ComputerName "LocalHost" -Verbose -Wait 



