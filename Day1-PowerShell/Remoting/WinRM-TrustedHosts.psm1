########################################################################
<#
.SYNOPSIS
 Functions to manage the TrustedHosts list for WinRM remoting.

.DESCRIPTION
 The Windows Remote Management (WinRM) service implements the Web Services
 for Management (WSMan) protocol and handles remoting endpoints. In a
 domain environment, Kerberos single sign-on is used automatically by
 default for PowerShell remoting when using global user accounts. When
 authenticating using a local account at the remoting target, especially
 when that target computer is a stand alone, the client computer must
 add either the hostname, NetBIOS name, FQDN, or IP address of the target
 to a special list (the TrustedHosts list) which signifies that it is
 permissible to remote into that target despite not being able to
 authenticate the target computer's identity.  It is possible to simply
 put "*" in the TrustedHosts list in order to trust any target, but
 then care must be taken to avoid remoting into untrustworthy or infected
 targets, perhaps using IPsec authentication and other precautions. When
 the trusted target name is "<local>", this includes any computer name
 which does NOT include a period, such as a simple hostname or NetBIOS 
 name. It's also permissible to use a wildcard with a domain name, such
 as "*.sans.org", or in an IP address, such as "10.4.*".  When entering 
 IPv6 addresses, enclose the IPv6 address in square brackets, such 
 as "[2147:fa70:9000:800::2004]". 

.NOTES
 Legal: Script provided "AS IS" without warranties or guarantees of any kind.
 Redistribution: Public domain, no rights reserved.
 Author: Enclave Consulting LLC  (http://sans.org/sec505) 
#>
########################################################################

function Get-TrustedHosts ( [Switch] $RawString ) 
{
    #.SYNOPSIS
    # Gets the TrustedHosts list as a string or an array of strings.
    #
    #.PARAMETER RawString
    # Return the comma-delimited TrustedHosts list as a single string.

    if ($RawString)
    { 
        [String] $raw = Get-Item -Path WSMan:\localhost\Client\TrustedHosts | Select -ExpandProperty Value 
        if ($raw.Length -ge 1){ $raw } #Output nothing if the string is empty or zero-length.  
    }
    else
    { 
        [String[]] $list = @((Get-Item -Path WSMan:\localhost\Client\TrustedHosts | Select -ExpandProperty Value) -split ',')

        if ($list.Count -eq 1)
          { 
            if ($list[0].Length -ge 1){ $list[0] } #Output nothing if blank.
          }
        elseif ($list.Count -ge 2)
          { 
            $list | ForEach { if($_.Length -ge 1){ $_ } } 
          } 
    }
}



function Remove-TrustedHosts ( [String[]] $TrustedHost = '<local>', [Switch] $RemoveAll ) 
{
    #.SYNOPSIS
    # Removes one, many or all entries from the TrustedHosts list.
    #
    #.PARAMETER TrustedHost
    # One string or an array of strings to remove from the TrustedHosts list.
    # The default value is "<local>".  
    #
    #.PARAMETER RemoveAll
    # Removes all entries from the TrustedHosts list.  

    if ($RemoveAll)
    {
        Clear-Item -Path WSMan:\localhost\Client\TrustedHosts -Force 
    }
    else
    {
        [String[]] $list = @((Get-Item -Path WSMan:\localhost\Client\TrustedHosts | Select -ExpandProperty Value) -split ',') 
       
        $list = @( $list | ForEach { if($TrustedHost -notcontains $_){ $_ } } ) 

        [String] $TrustedHost = $list -join ','

        Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $TrustedHost -Force 
    }
} 




function Add-TrustedHosts ([String[]] $TrustedHost = '<local>', [Switch] $Overwrite)
{
    #.SYNOPSIS
    # Appends or overwrites the TrustedHosts list.
    #
    #.DESCRIPTION
    # Appends or overwrites the TrustedHosts list with one or more
    # of the following acceptable strings: *, IP, hostname, NetBIOS name,
    # or fully-qualified domain name (FQDN). By default, the strings are
    # appended to the existing list, unless the -Overwrite switch is used.
    #
    #.PARAMETER TrustedHost
    # A string or an array of strings containing: *, IP, hostname, NetBIOS
    # name, or FQDN. If a single comma-delimited string is provided, it will
    # be split into an array of strings automatically. The default is "<local>",
    # which results in all target hosts being trusted which do NOT have a 
    # period in their names, i.e., simple hostnames or NetBIOS names. A value 
    # of "*" will result in all possible hosts being trusted without exception. 
    # If "*" is the value, WinRM requires that it be the only string in the
    # TrustedHosts list, hence, this value will require the -Overwrite switch
    # to be used as a reminder (an error will be thrown without it). It's also 
    # permissible to use a wildcard with a domain name, such as "*.sans.org".  
    # When entering IPv6 addresses, enclose the IPv6 address in square brackets, 
    # such as "[2607:f8b0:4000:800::2004]". 
    #
    #.PARAMETER Overwrite
    # Overwrite the existing TrustedHosts list, do not append to it.

    #If a comma-delimited string is given, split it into an array:
    $TrustedHost = @( $TrustedHost -split ',' ) 
    
    #Require -Overwrite whenever "*" is included in -TrustedHost as a precaution:
    if ( $TrustedHost -contains '*' -and -not $Overwrite)
    { throw "When specifying '*' as the TrustedHost, the -Overwrite switch must be used." ; return } 

    #When "*" is the -TrustedHost, no others may be in the list, as per WinRM requirements:
    if ( $TrustedHost -contains '*'){ $TrustedHost = @('*') } 

    #Reconstruct the comma-delimited string again:
    [String] $TrustedHost = $TrustedHost -join ','

    if ($Overwrite)
    { Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $TrustedHost -Force }
    else
    { Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $TrustedHost -Force -Concatenate } 
}



