##############################################################################
#.SYNOPSIS
# Get the security-related RDP server settings.
#
#.DESCRIPTION
# Get the security-related Remote Desktop Protocol server settings, such as 
# minimum encryption level, encryption type, and whether NLA is required. 
# Requires access to WMI service and membership in the local Administrators 
# group at the target. 
#
#.PARAMETER ComputerName
# One or more hostnames, FQDNs, or IP addresses.  Defaults to localhost.
#
#.NOTES
# To interpret the output properties, search the Internet for the term 
# "Win32_TSGeneralSetting" and the terms "rdp security layer tls" and also
# for "rdp network level authentication nla".
#
# Some of the possible property values are:
#
#    EncryptionLevel: Low, ClientCompatible, High, FIPS
#
#    SecurityLayer: NativeRDP, Negotiate, TLS, NEWTBD
#
#    RequireNLA: True, False
#
# Legal: Public domain, no rights reserved, script provided "AS IS" without 
#        warranties or guarantees of any kind.  
#
# Author: Enclave Consulting LLC (https://www.sans.org/sec505)
#
# Version: 1.1
#
##############################################################################


[CmdletBinding()]
Param ( [String[]] $ComputerName = @("localhost") ) 

ForEach ($Computer in $ComputerName)
{

# Create a hashtable for the return:
$out = [Ordered] @{ ComputerName = $Computer.ToUpper();
                    DnsName = $null; IP = $null; EncryptionLevel = $null; SecurityLayer = $null; 
                    Protocol =$null; RequireNLA = $null; CertificateStatus =$null; CertificateHash = $null
                  }


# Try to resolve name and extract IP:
Try { $fqdn = [System.Net.Dns]::GetHostByName($Computer) } 
Catch { $IP = "CouldNotResolveName" } 

if ($IP -eq "CouldNotResolveName")
{ 
    $out.DnsName = "CouldNotResolveName" 
    $out.IP = "CouldNotResolveName"
} 
else
{ 
    $out.DnsName = $fqdn.HostName.ToLower()
    $out.IP = ($fqdn.AddressList)[0]
}



# To connect to the \root\CIMV2\TerminalServices namespace, the 
# authentication level must be PacketPrivacy:
Try 
{
  $ts = Get-WmiObject -Query "Select * From Win32_TSGeneralSetting" -Namespace root\CIMv2\TerminalServices -ComputerName $Computer -Authentication PacketPrivacy 
}
Catch
{
    Write-Verbose "ERROR: Failed to query $Computer"
    Continue #to next $Computer
}


switch ($ts.MinEncryptionLevel)
{
    1 { $out.EncryptionLevel = "Low" }               #56-bit for client-to-server, plaintext for server-to-client
    2 { $out.EncryptionLevel = "ClientCompatible" }  #Largest key supported by client
    3 { $out.EncryptionLevel = "High" }              #At least a 128-bit key
    4 { $out.EncryptionLevel = "FIPS" }              #Federal Information Processing Standard
}


switch ($ts.SecurityLayer)
{
    0 { $out.SecurityLayer = "NativeRDP" } #Default
    1 { $out.SecurityLayer = "Negotiate" } #TLS preferred, NativeRDP acceptable
    2 { $out.SecurityLayer = "TLS" }       #SSL (TLS 1.0) only, no NativeRDP
    3 { $out.SecurityLayer = "NEWTBD" }    #Research this Jason...

}


switch ($ts.SSLCertificateSHA1HashType)
{
    0 { $out.CertificateStatus = "NotValid" } 
    1 { $out.CertificateStatus = "DefaultSelfSigned" } 
    2 { $out.CertificateStatus = "GroupPolicyDefined" } 
    3 { $out.CertificateStatus = "Custom" } #Configured explicitly or directly, not auto.
}


switch ($ts.UserAuthenticationRequired)
{
    1 { $out.RequireNLA = $True  }
    0 { $out.RequireNLA = $False }
}



$out.Protocol = $ts.TerminalProtocol
$out.CertificateHash = $ts.SSLCertificateSHA1Hash


#Emit and move on to next machine:
$out 

}#END.FOREACH

