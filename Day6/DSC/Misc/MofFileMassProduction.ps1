Param ( [String[]] $ArgsToScript = "LocalHost" )


Configuration TestConfig
{
    Param ( [String[]] $ComputerName = "LocalHost" )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName
    {
        Registry RegExample
        {
            Ensure = "Present"  
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\AAANewKey"
            ValueName = "EnableGoodness"
            ValueData = "0x3"
            Hex = $True
            ValueType = "Dword"
            Force = $True 
        }
    }
} 


# Create more MOF files using computer names passed into the script as arguments:
TestConfig -ComputerName $ArgsToScript


# Create MOF files using hard-coded computer names:
TestConfig -ComputerName @("LocalHost","Server47","Server48") 


# Create more MOF files after querying an OU in Active Directory:
$ComputerNames = Get-ADComputer -Filter * -SearchBase "OU=HVT,DC=testing,DC=local" | Select -ExpandProperty Name

TestConfig -ComputerName $ComputerNames


# Apply the MOF file to the local machine only:
Start-DscConfiguration -Path .\TestConfig -ComputerName LocalHost


# Note: 
# A localhost.mof file will be used instead of a <computername>.mof
# on the local machine by default when both MOF files are in the
# target directory and the -ComputerName param is not used. Also,
# the -ComputerName argument(s) is (or are) not case-sensitive.
# Use the -Verbose switch when applying MOFs to remote machines to
# see more details of what is happening behind the scenes.  


