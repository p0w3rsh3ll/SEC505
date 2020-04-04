####################################################################################
#.SYNOPSIS 
#   Configures the SSL/TLS settings for PowerShell remoting with WinRM.
#
#.DESCRIPTION
#   Attempt to automatically configure WSMAN PowerShell remoting to use an 
#   existing SSL/TLS certificate.  If multiple valid certificates are found, the
#   certificate with the longest time before expiration will be selected.  The
#   aim to make the hands-free HTTPS configuration changes for WSMAN remoting as
#   reliable and reproducible as possible for DevOps, scheduled scripts, and
#   remote execution with Invoke-Command.  This script does not install or  
#   delete any SSL/TLS certificates.  This script does not modify any firewall
#   rules to allow or block access to TCP port 5986, and it does not run the
#   Enable-PSRemoting cmdlet to enable PowerShell remoting in general.  The
#   WinRM service does not need to be restarted after using this script.  
#
#.PARAMETER RunInteractively
#   Prompt the user to select which certificate to use, if there are multiple
#   valid certificates.  If there is only one acceptable certificate, that 
#   certificate will be applied and the user will not be prompted, even if this
#   switch is enabled.  
#
#.PARAMETER ClearCurrentSettings
#   Deletes any existing HTTPS settings used for PowerShell remoting, then
#   exits.  No other changes are made, and no certificates are modified.  Note
#   that the current HTTPS settings are always cleared whenever this script is
#   run; this switch simply leaves HTTPS disabled/unconfigured afterwards.  Use
#   this when you simply want to turn off SSL/TLS support for WSMAN remoting
#   and stop listening on TCP port 5986.  
#   
#.NOTES 
#   The script outputs a hashtable with a Success key set to $true/$false, plus
#   information about the certificate used for HTTPS.  This will be returned by
#   Invoke-Command.  Avoid required arguments to simplify Invoke-Command use, you
#   can only pass in arguments by position with -ArgumentList and switches are a pain.
#
#   The SSL/TLS certificate must have the 'Server Authentication' enhanced key usage,
#   which has an OID number of 1.3.6.1.5.5.7.3.1.  Some of the certificate templates
#   that include this are Web Server, Kerberos Authentication, Domain Controller
#   Authentication, Domain Controller, and Computer.    
#
#   Author: Jason Fossen, Enclave Consulting LLC (https://www.sans.org/SEC505)  
#   Version: 2.1
#   Created: 28.Nov.2012
#   Updated: 7.Jan.2020
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
#
#   TODO: Add -ComputerName parameter for remote use?  Avoid chicken-egg.
#   TODO: Add options to manage firewall rules, disable HTTP transport on TCP/5985?
#   TODO: Add option to manage client auth, allow only cert auth?
####################################################################################

[CmdletBinding()]
Param ([Switch] $RunInteractively, [Switch] $ClearCurrentSettings)


# The script's only output, unless -RunInteractively is set:
$ReturnObject = [Ordered] @{ 'Success' = $False; 'Message' = $null; 'FQDN' = $null; 
                             'DnsNameList' = $null; 'CertificateExpiration' = $null; 
                             'CertificateThumbprint' = $null } 


# Sanity check:
if ($RunInteractively -and $ClearCurrentSettings)
{ 
    Write-Verbose "ERROR: Cannot use both -RunInteractively and -ClearCurrentSettings."
    $ReturnObject.Success = $False
    $ReturnObject.Message = "ERROR: Cannot use both -RunInteractively and -ClearCurrentSettings."
    $ReturnObject
    Exit -1
}



# Get current WSMAN listener or fail:
Try
{
    $listener = dir -Path WSMan:\localhost\Listener -ErrorAction Stop 
    Write-Verbose "SUCCESS: WSMAN listener obtained."
}
Catch
{
    $ReturnObject.Success = $false
    $ReturnObject.Message = 'ERROR: Failed to get current WSMAN listener.'
    $ReturnObject
    Exit -1
}


#.SYNOPSIS
# Clear any HTTPS configuration settings for WSMAN remoting.
#.PARAMETER Address
# The local IP selector for the HTTPS binding. Defaults to '*'.
#.OUTPUTS
# System.Boolean
function Clear-CurrentSettings 
{ 
    [OutputType([Boolean])] Param ([String] $Address = '*')
    try 
    {
        # Get WSMAN listener (again)
        $listener = dir -Path WSMan:\localhost\Listener -ErrorAction Stop 
        #Is there something to clear?
        if ($listener.Keys.Contains("Transport=HTTPS"))
        { 
            Remove-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet @{Transport = 'HTTPS'; Address = $Address}  
            Write-Verbose "STATUS: Clear-CurrentSettings called and found HTTPS settings to clear."
        }
        else
        {
            Write-Verbose "STATUS: Clear-CurrentSettings called, but no HTTPS settings currently exist to be cleared."
        }
    }
    catch 
    { 
        Write-Verbose "ERROR: Clear-CurrentSettings called and suffered an exception."
        $False
        Return
    } 

    Write-Verbose "SUCCESS: Clear-CurrentSettings called and is returning $True."
    $True
} 



# Exit afterwards if -ClearCurrentSettings:
if ($ClearCurrentSettings)
{
    if (Clear-CurrentSettings)
    { 
        Write-Verbose "SUCCESS: Current HTTPS settings cleared."
        $ReturnObject.Success = $True
        $ReturnObject.Message = 'SUCCESS: Current HTTPS settings cleared for WSMAN.'
        $ReturnObject
        Exit 0
    }
    else
    {
        Write-Verbose "ERROR: Current HTTPS settings not cleared."
        $ReturnObject.Success = $False
        $ReturnObject.Message = 'ERROR: Failed to clear current HTTPS settings for WSMAN.'
        $ReturnObject
        Exit -1
    }
}



# Always clear the current settings first:
if (Clear-CurrentSettings)
{
    Write-Verbose "SUCCESS: Current HTTPS settings cleared, not running interactively."
}
else
{
    Write-Verbose "ERROR: Failed to automatically clear current HTTPS settings."
    $ReturnObject.Success = $False
    $ReturnObject.Message = 'ERROR: Failed to automatically clear current HTTPS settings.'
    $ReturnObject
    Exit -1
}


# Get machine certificates with the Server Authentication enhanced key usage that have not expired:
$certs = dir Cert:\LocalMachine\My | 
    where { $_.NotAfter -gt $(get-date) } |
    where { $_.HasPrivateKey } |
    where { $_.EnhancedKeyUsageList.FriendlyName -Contains 'Server Authentication' } |
    Sort-Object -Property NotAfter -Descending


Write-Verbose ("STATUS: " + $certs.Count + " non-expired certificates found with Server Authentication EKU.")


# Select one cert from the machine certificates available.
if ($certs.count -eq 0)
{ 
    Write-Verbose 'ERROR: No valid certificates installed, so nothing can be configured.'
    $ReturnObject.Success = $False
    $ReturnObject.Message = 'ERROR: No valid certificates installed, so nothing can be configured.'
    $ReturnObject
    Exit -1
}
elseif ($certs.count -eq 1)
{ 
    $certchoice = 0 
}
else  #More than one compatible cert
{
    # Ask the user or simply use the one with the longest TTL remaining
    if ($RunInteractively)
    { 
        #Show list of options from which to choose:
        for ($i = 0; $i -lt $certs.count; $i++)
        {
            #Try to carve out the name of the template:
            #OID 1.3.6.1.4.1.311.21.7 is for "Certificate Template Information".
            $Template = $certs[$i].Extensions | Where-Object { $_.Oid.FriendlyName -eq 'Certificate Template Information' } 
            # String will be like "Template=MachineAuth(1.3.6.1.4...."
            $Template = $Template.Format($False) -Replace 'Template=',''
            $Template = $Template.SubString(0, $Template.IndexOf('(') ) 

            #Make it pretty...
            "`n"
            "-" * 23
            "Certificate Number: $i"
            "-" * 23

            $output = [Ordered] @{ 
                         'DnsNameList' = ($certs[$i].DnsNameList -join ', ') ; 
                         'Subject'     = $certs[$i].Subject ; 
                         'Template'    = $Template.Trim() ;
                         'Expires'     = $certs[$i].NotAfter ; 
                         'Issuer'      = $certs[$i].Issuer ;
                         'Thumbprint'  = $certs[$i].Thumbprint
                       }

            if ($output.Subject.Length -eq 0)
            { $output.Subject = "<None>" } 

            if ($output.Template.Length -eq 0)
            { $output.Template = "<Unknown>" } 

            $output | Format-Table -HideTableHeaders -AutoSize 
        }

        $certchoice = Read-Host "`n`nPlease enter the Certificate Number above that you wish to use (or Ctrl-C) "

        "`n`n"
    } 
    else #Not running interactively
    { 
        Write-Verbose 'STATUS: First valid certificate has been automatically selected.'
        #Default to first compatible cert, which, because of the sorting above, it will the longest TTL:
        $certchoice = 0
    }
}


# Get the thumbprint of the chosen cert.
$cert = $certs[$certchoice]
$hash = $cert.thumbprint
Write-Verbose ('STATUS: Hash of selected certificate: ' + $hash)


# Extract FQDN from either the Subject (preferred) or the DnsNameList (second preferred).
if ($cert.subject.length -ne 0)
{
    $fqdn = @($cert.subject -split ',')[0]
    $fqdn = $($fqdn -replace "CN=","").trim().tolower()
    $fqdnToUse = $fqdn  #These can be different
}
else
{
    $fqdn = ''
    if ( @($cert.DnsNameList).Count -ne 0) 
    {
        #Defaults to the first one, but maybe better to choose longest or with most periods? Think more...
        $fqdnToUse = $($cert.DnsNameList[0].Unicode).trim().tolower()   
    } 
}


# Create the two hashtables of settings to be used when creating the HTTPS settings:
$valueset = @{}
$valueset.add('Hostname',$fqdn)
$valueset.add('CertificateThumbprint',$hash)

$selectorset = @{}
$selectorset.add('Transport','HTTPS')
$selectorset.add('Address','*')  #Always '*'?  Make it a parameter?



# Create the WSMan listener for HTTPS:
try 
{ 
    Write-Verbose ('STATUS: $ValueSet is Hostname=' + $valueset.Hostname + ',CertificateThumbprint=' + $valueset.CertificateThumbprint )
    Write-Verbose ('STATUS: $SelectorSet is Transport=' + $selectorset.Transport + ',Address=' + $selectorset.Address )

    New-WSManInstance -ResourceURI 'winrm/config/Listener' -SelectorSet $selectorset -ValueSet $valueset -ErrorAction Stop | out-null 

    Write-Verbose 'SUCCESS: New HTTPS listening settings successfully assigned.'
    $ReturnObject.Success = $True
    $ReturnObject.Message = 'SUCCESS: New HTTPS settings were successfully assigned.'
    $ReturnObject.CertificateThumbprint = $cert.Thumbprint
    $ReturnObject.DnsNameList = $cert.DnsNameList
    $ReturnObject.CertificateExpiration = $cert.NotAfter
    $ReturnObject.FQDN = $fqdnToUse
    $ReturnObject
    Exit 0
} 
catch 
{ 
    Write-Verbose ('ERROR: Failed to assign new HTTPS listening settings: ' + $_.Exception)
    $ReturnObject.Success = $False
    $ReturnObject.Message = ('ERROR: Failed to configure HTTPS settings with this certificate. Exception: ' + $_.Exception )
    $ReturnObject.CertificateThumbprint = $cert.Thumbprint
    $ReturnObject.DnsNameList = $cert.DnsNameList
    $ReturnObject.CertificateExpiration = $cert.NotAfter
    $ReturnObject.FQDN = $fqdnToUse
    $ReturnObject
    Exit -1
}


#FIN
