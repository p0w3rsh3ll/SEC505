
Configuration TestConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node @("LocalHost","Server47","Laptop48")
    {
        Registry RegExample
        {
            Ensure = "Present"  
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\AAANewKey"
            ValueName = "EnableGoodness"
            ValueData = "0x2"
            Hex = $True
            ValueType = "Dword"
            Force = $True 
        }
    }
} 



# Create MOF files using the hard-coded computer names above:
TestConfig


# Apply all the MOFs to *all* of the target nodes over the network!
Start-DscConfiguration -Path .\TestConfig -Verbose 


# Use the -Wait switch to run in the foreground, not as a job:
Start-DscConfiguration -Path .\TestConfig -Wait 


# Apply the LocalHost.mof file to the local machine only:
Start-DscConfiguration -Path .\TestConfig -ComputerName LocalHost


# Note: 
# A localhost.mof file will be used instead of a <computername>.mof
# on the local machine by default when both MOF files are in the
# target directory and the -ComputerName param is not used. Also,
# the -ComputerName argument(s) is (or are) not case-sensitive.
# Use the -Verbose switch when applying MOFs to remote machines to
# see more details of what is happening behind the scenes.  


