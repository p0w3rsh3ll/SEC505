@{ 
    #WindowsAdminCenterPort should be a string:
    WindowsAdminCenterPort = "47"

    # Hash of TLS certificate to use for WAC:
    CertificateHash = $null 
    
    # Networking settings of this computer:
    StaticIP = "10.1.1.2"
    PrefixLength = 8  #8 = 255.0.0.0 subnet mask
    PreferredDnsServer = "10.1.1.1"    
    
} 
