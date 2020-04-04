@{ 
    # Networking settings of this computer:
    StaticIP = "10.1.1.2"
    PrefixLength = 8  #8 = 255.0.0.0 subnet mask
    PreferredDnsServer = "10.1.1.1"    

    # Name of AD domain to join:
    DnsDomain = "testing.local"

    # New name of this computer after joining AD domain:
    NewComputerName = "Member"

    # What about credentials to join to the domain?
    # User will be prompted by that script when needed.
}
