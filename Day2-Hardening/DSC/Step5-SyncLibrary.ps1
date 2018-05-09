# Purpose: create a DSC configuration function to copy all 
# the modules from the DscModuleLibrary shared folder into
# the local PowerShell modules folder.  


Configuration DSC-SyncModuleLibrary
{
    Param ( [String[]] $ComputerName = "LocalHost" )
 
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName
    { 
        File SyncLibrary 
        {
            SourcePath = "\\$env:COMPUTERNAME\DscModuleLibrary" 
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\Modules\"
            Type = "Directory"
            Recurse = $True
            Force = $True 
            MatchSource = $True 
            Checksum = "ModifiedDate"  #or SHA-512 
        }
    }
}



# Now run this configuration function to create a MOF
# file in the MOF shared folder that was created earlier:

DSC-SyncModuleLibrary -ComputerName $env:COMPUTERNAME -OutputPath "\\$env:COMPUTERNAME\MOF\DSC-SyncModuleLibrary"  



# Apply the MOF from the shared folder to start the sync:

Start-DscConfiguration -ComputerName $env:COMPUTERNAME -Path "\\$env:COMPUTERNAME\MOF\DSC-SyncModuleLibrary" -Force -Verbose -Wait 




