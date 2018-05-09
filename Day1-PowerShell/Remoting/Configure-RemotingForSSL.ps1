####################################################################################
#.Synopsis 
#    Configures the SSL/TLS settings for PowerShell remoting.
#
#.Description
#    The script will walk the user through the steps necessary to choose a
#    machine certificate and configure WSMan settings necessary to support 
#    PowerShell remoting over an SSL/TLS encrypted channel.  The script does
#    not 1) enable PowerShell remoting or 2) create a Windows Firewall rule to
#    allow access to TCP/5986, which is the default for remoting over SSL/TLS.
#    Enable PowerShell remoting by executing "enable-psremoting -force".
#
#.Parameter AttemptAutoConfigure
#    Will attempt to select and use a compatible SSL/TLS certificate hands-free
#    without any prompting.  When there are multiple suitable certificates,
#    the one with the longest TTL will be preferred.
#
#.Parameter ClearCurrentSettings
#    Will delete any existing HTTPS settings used for PowerShell remoting.
#    Will not delete any certificates or private keys, just WSMAN settings.
#    May be used by itself or with the -AttemptAutoConfigure switch.
#
#Requires -Version 2.0 
#
#.Notes 
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)  
# Version: 1.1
# Created: 28.Nov.2012
# Updated: 7.Jun.2017
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################

Param ([Switch] $AttemptAutoConfigure, [Switch] $ClearCurrentSettings)


# Possibly clear current HTTPS settings:
if ($ClearCurrentSettings)
{ 
    # Notice that the following assumes 'Address=*', which might not match yours.
    try { Remove-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet @{Transport='HTTPS'; Address='*'} }
    catch { "`ERROR: There was a problem clearing the PowerShell SSL settings, quitting.`n" ; exit } 
} 


# Test for the existence of an HTTPS listener already.
$capture = dir WSMan:\localhost\Listener | foreach { $_.Keys } | out-string 

if ($capture -like '*Transport=HTTPS*') 
{
    if (-not $AttemptAutoConfigure)
    {
        cls
        $answer = read-host "`nYou already have settings for PowerShell remoting over SSL. `nDo you want to clear these settings and then configure them again? (y/n)"

        if ($answer -like "y*") 
        { 
            # Notice that the following assumes 'Address=*', which might not match yours.
            try { Remove-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet @{Transport='HTTPS'; Address='*'} }
            catch { "`ERROR: There was a problem clearing the PowerShell SSL settings, quitting.`n" ; exit } 
        }
        else { "`nNo changes made, exiting.`n" ; exit } 
    }
    else { "`nNo changes made, you already have HTTPS settings for remoting, exiting.`n" ; exit } 
}


# Get machine certificates with the Server Authentication enhanced key usage that have not expired:
$certs = dir Cert:\LocalMachine\My | 
    where { $_.NotAfter -gt $(get-date) } |
    where { $_.HasPrivateKey } |
    where { $_.EnhancedKeyUsageList.FriendlyName -Contains 'Server Authentication' } |
    Sort-Object -Property NotAfter -Descending


# Select one cert from the machine certificates available.
if ($certs.count -eq 0)
{ 
    Write-Error "ERROR: Apparently you have no appropriate server authentication certificates, so nothing can be configured yet, exiting.`n"
    exit 
}
elseif ($certs.count -eq 1)
{ 
    $certchoice = 0 
}
else  #More than one compatible cert
{
    if ($AttemptAutoConfigure)
    { 
        #Default to first compatible cert, which, because of the sorting above, has the longest TTL:
        $certchoice = 0
    }
    else
    { 
        cls
        for ($i = 0; $i -lt $certs.count; $i++)
        {
            "-" * 23
            "Certificate Number: $i"
            write-host $("-" * 23) -nonewline
            $certs[$i] | format-list Subject,DnsNameList,NotAfter,Issuer,Thumbprint
        }

        $certchoice = Read-Host "`nPlease enter the Certificate Number above that you wish to use"
    } 
}


# Get the thumbprint of the chosen cert.
$cert = $certs[$certchoice]
$hash = $cert.thumbprint


# Extract FQDN from either the Subject (preferred) or the DnsNameList (second preferred).
if ($cert.subject.length -ne 0)
{
    $fqdn = @($cert.subject -split ',')[0]
    $fqdn = $($fqdn -replace "CN=","").trim().tolower()
    $fqdnToUse = $fqdn  #These can be different, see Else.
    # "`nThe FQDN from the Subject field: " + $fqdn 
}
else
{
    $fqdn = ''
    if ( @($cert.DnsNameList).Count -ne 0) 
    {
        #Defaults to first one, without prompting; possibly update script to ask when multiple.
        $fqdnToUse = $($cert.DnsNameList[0].Unicode).trim().tolower()   
    } 
}

# Create the two hashtables of settings to be used:
$valueset = @{}
$valueset.add('Hostname',$fqdn)
$valueset.add('CertificateThumbprint',$hash)

$selectorset = @{}
$selectorset.add('Transport','HTTPS')
$selectorset.add('Address','*')


# Create the WSMan listener for HTTPS:
try 
{ 
    New-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset -ValueSet $valueset | out-null 
} 
catch 
{ 
    Write-Error "ERROR: There was a problem configuring the HTTPS settings for PowerShell remoting." 
    "`nHere is the list of your WSMan listeners as they currently stand:`n"
    dir WSMan:\localhost\Listener
    exit
}


# Display Report
write-host "`nThis is the certificate now used for PowerShell remoting with SSL/TLS:"
$cert | Select-Object Subject,DnsNameList,NotAfter,Issuer,Thumbprint
if ($fqdnToUse)
{ "Hence, you must connect to this computer as: " + $fqdnToUse + "`n" }
else
{ "Use the 'Certificates (Local Computer)' MMC snap-in to see the attributes of the above certificate to confirm which fully-qualified domain name(s) must be used to connect to the computer using PowerShell remoting with SSL.`n" } 


