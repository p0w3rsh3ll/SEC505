###############################################################################
#
#"[+] Setting TrustedHosts to a wildcard..."
#
# Do this after installing Windows Admin Center (WAC) because WAC also 
# messes with the TrustedHosts list.  You will get WAC errors in the browser
# when connecting to localhost if TrustedHosts does not include localhost.
#
###############################################################################

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

Add-TrustedHosts -Overwrite -TrustedHost "*"

