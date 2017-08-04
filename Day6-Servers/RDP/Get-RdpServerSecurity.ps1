<# ###################################################
.SYNOPSIS
 Get the security-related RDP server settings.

.DESCRIPTION
 Get the security-related Remote Desktop Protocol
 server settings, such as minimum encryption level, 
 encryption type, and whether NLA is required. 
 Requires access to WMI service and membership in
 the local Administrators group at the target. 

.PARAMETER ComputerName
 One or more hostnames, FQDNs, or IP addresses.
 Defaults to localhost.

.NOTES
 To interpret the output properties, search the 
 Internet for the term "Win32_TSGeneralSetting" and 
 the terms "rdp security layer tls" and also
 for "rdp network level authentication nla."

 Some of the possible property values are:

    EncryptionLevel: Low, Medium, High, FIPS

    SecurityLayer: NativeRDP, Negotiate, TLS, NEWTBD

    RequireNLA: True, False

 Legal: Public domain, no rights reserved, script
        provided "AS IS" without warranties or
        guarantees of any kind.

 Author: Enclave Consulting LLC (www.sans.org/sec505)

 Version: 1.0

#################################################### #> 

[CmdletBinding()]
Param ( [String[]] $ComputerName = @("localhost") ) 

ForEach ($Computer in $ComputerName)
{

#Resolve name and extract IP:
Try { $fqdn = [System.Net.Dns]::GetHostByName($Computer) }
Catch { $IP = "CouldNotResolveName" } 


#To connect to the \root\CIMV2\TerminalServices namespace, the authentication level must be PacketPrivacy:
$ts = $null
$ts = Get-WmiObject -Query "Select * From Win32_TSGeneralSetting" -Namespace root\CIMv2\TerminalServices -ComputerName $Computer -ErrorAction SilentlyContinue -Authentication PacketPrivacy 


#Check if WMI connection failed, return if it did:
if (-not $ts)
{
    #Create custom object ($out) to organize audit data:
    $out = '' | Select-Object -Property ComputerName,DnsName,IP,EncryptionLevel,SecurityLayer,Protocol,RequireNLA,CertificateHash
    $out.ComputerName = ($Computer).ToUpper()

    if ($IP -eq "CouldNotResolveName")
    { 
        $out.DnsName = "CouldNotResolveName" 
        $out.IP = "CouldNotResolveName"
    } 
    else
    { 
        $out.DnsName = $fqdn.HostName
        $out.IP = ($fqdn.AddressList)[0]
    }

    $out
    $IP = $null 
    $out = $null
    continue
}


switch ($ts.MinEncryptionLevel)
{
    1 { $EncryptionLevel = "Low" }     #56-bit for client to server, plaintext for server to client
    2 { $EncryptionLevel = "Medium" }  #Largest key supported by client
    3 { $EncryptionLevel = "High" }    #At least 128-bit key
    4 { $EncryptionLevel = "FIPS" }    #Federal Information Processing Standard
}


switch ($ts.SecurityLayer)
{
    1 { $SecurityLayer = "NativeRDP" }
    2 { $SecurityLayer = "Negotiate" } #TLS preferred, NativeRDP acceptable
    3 { $SecurityLayer = "TLS" }       #SSL (TLS 1.0)
    4 { $SecurityLayer = "NEWTBD" }    #Research this Jason

}


switch ($ts.UserAuthenticationRequired)
{
    1 { $NLA = $True  }
    0 { $NLA = $False }
}


#Create custom object ($out) to organize audit data:
$out = '' | Select-Object -Property ComputerName,DnsName,IP,EncryptionLevel,SecurityLayer,Protocol,RequireNLA,CertificateHash
$out.ComputerName = $ts.PSComputerName
$out.DnsName = $fqdn.HostName
$out.IP = ($fqdn.AddressList)[0]
$out.EncryptionLevel = $EncryptionLevel
$out.SecurityLayer = $SecurityLayer
$out.Protocol = $ts.TerminalProtocol
$out.RequireNLA = $NLA
$out.CertificateHash = $ts.SSLCertificateSHA1Hash


#Emit custom object and move on to next machine:
$out 

}#END.FOREACH

