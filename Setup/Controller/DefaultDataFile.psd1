@{ 
    # Networking settings of this computer:
    StaticIP = "10.1.1.1"
    PrefixLength = 8  #8 = 255.0.0.0 subnet mask
    PreferredDnsServer = "127.0.0.1"    

    # Name of the new AD domain:
    DnsDomain = "testing.local"
    DomainNetBiosName = "TESTING"
    DomainDistinguishedName = "DC=testing,DC=local"
    
    # New name of this computer:
    NewComputerName = "Controller"

    # New admin password in plaintext!
    NewAdminPassword = "P@ssword"
    
    # Set to $true if you know your VM's adapter is correct:
    SkipNetworkInterfaceCheck = $False 

    # Set to $true if you know your VM is a controller:
    SkipActiveDirectoryCheck = $False 

    # Set to $true when troubleshooting:
    Verbose = $False 
    
    # Very unlikely these will need to be manually
    # configured when troubleshooting:
    IsDomainController = $False 
    CurrentCulture = $null 
    CurrentUICulture = $null 
} 
