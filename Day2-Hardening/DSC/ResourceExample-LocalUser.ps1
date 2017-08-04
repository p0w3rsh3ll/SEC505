# THIS SCRIPT DOES NOT WORK ON DOMAIN CONTROLLERS, IT IS ONLY
# FOR LOCAL USER ACCOUNTS, NOT GLOBAL ACCOUNTS IN AD.


# Microsoft *really* does not want us to put plaintext passwords into scripts,
# but this script will show how to do it anyway (it's a bit of a pain).
# Be aware that the plaintext password goes into the MOF file also!


# Create a PSCredential object without prompting the user for a password.
# The username is "Foo" because the username is not used, it doesn't matter.
$SecString = ConvertTo-SecureString -String "SekritPazzwurd" -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("Foo", $SecString)



Configuration TestConfig
{
    Param ([String[]] $ComputerName = "LocalHost")

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName
    {
        User SetUserExample
        {
            UserName = "TechUser19"
            FullName = "Justin McCarthy"
            Description = "Help desk support account"
            Disabled = $False
            Password = $Cred
        }

        User DelUserExample
        {
            Ensure = "Absent"
            UserName = "HackerDood"
        }
    }
} 


# To get DSC to allow us to use a plaintext password, we must define a special hashtable
# of configuration data, then give this hashtable when the configuration function is run.
# To encrypt passwords properly with a public key certificate, this hashtable would also
# be used, but that is not demonstrated here because of the PKI and other requirements.
$ConfigData = @{ AllNodes = @( @{ NodeName = 'LocalHost'; PSDscAllowPlainTextPassword = $true } ) } 


# Create MOF file and present the $ConfigData hashtable as an argument:
TestConfig -ComputerName "LocalHost" -ConfigurationData $ConfigData 


# Best practice: store configuration data in a separate .psd1 file:
TestConfig -ComputerName "LocalHost" -ConfigurationData .\ResourceExample-LocalUserData.psd1


# Enact MOF for localhost only:
Start-DscConfiguration -Path .\TestConfig -ComputerName "LocalHost" -Verbose -Wait -Force



