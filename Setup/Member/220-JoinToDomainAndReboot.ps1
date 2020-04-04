# Join member server to the testing.local domain, requires reboot.
# Try to make this script the last one so that Start-Top.ps1 is only run once.

# Assume failure:
$Top.Request = "Stop"


#$Domain = "TESTING"  #Try to do without.
$DnsDomain = $Top.DnsDomain
$NewComputerName = $Top.NewComputerName


# Sanity check required settings:
if ($DnsDomain -eq $null)
{ Throw "ERROR: Do not have a DNS domain name assigned." ; Exit }
elseif ($NewComputerName -eq $null)
{ Throw "ERROR: Do not have a new computer name assigned." ; Exit }


# Is the machine already a member of a domain?
$thisbox = Get-CimInstance -ClassName Win32_ComputerSystem

if ($thisbox.PartOfDomain -eq $False)
{ 
    # Resolve an SRV DNS record for the domain as a test:
    $Response = @( Resolve-DnsName -Type SRV -Name ("_kerberos._tcp." + $DnsDomain) -DnsOnly -QuickTimeout ) 

    if ($Response.Count -eq 0)
    {
        $Top.Request = "Stop"
        Throw ("ERROR: Cannot resolve DNS records for " + $DnsDomain)
        Exit 
    }


    # This will prompt the user for credentials:
    $Creds = $null
    $Creds = Get-Credential -Message "Enter the <DOMAIN>\<USERNAME> and password to join this computer to the $DnsDomain domain.  This computer will be renamed to $NewComputerName and will then reboot."

    # Did the user click Cancel when prompted?
    if ($Creds -eq $null) 
    { 
        $Top.Request = "Stop"
        Throw "ERROR: AD domain join failed, no admin credentials were entered." 
        Exit
    }

    # Joins and renames machine in one command:
    Try { 
        Add-Computer -DomainName $DnsDomain -Credential $Creds -NewName $NewComputerName -Restart -Force 
        # Should be good now to reboot as a member server:
        $Top.Request = "Reboot" 
        Exit
    } 
    Catch [System.InvalidOperationException] {
        if ($_.Exception.Message -like '*directory service is busy*') 
        {
            Write-Verbose -Verbose "Renaming computer from $env:ComputerName to $NewComputerName"
            Rename-Computer -NewName $NewComputerName -DomainCredential $Creds 
            if ($?){ $Top.Request = "Reboot" ; Exit } 
            #If failure again, no reboot, script falls through to second rename attempt.
        }
    }
    Catch { 
            $Top.Request = "Stop" 
            Throw "ERROR: Failed to rename computer and join to domain.  Is your password correct?" 
            Exit 
    } 
} 


# If the join works, but the rename fails, attendees will run this script again.
# Second rename attempt, check the $NewComputerName and rename:
if ($env:ComputerName -ne $NewComputerName)
{
    # This will prompt the user for credentials:
    $Creds = $null
    $Creds = Get-Credential -Message "Enter the <DOMAIN>\<USERNAME> and password to rename this computer from $env:ComputerName to $NewComputerName and then reboot."

    # Did the user click Cancel when prompted?
    if ($Creds -eq $null) 
    { 
        $Top.Request = "Stop"
        Throw "ERROR: Rename failed, no admin credentials were entered." 
        Exit
    }

    Try { Rename-Computer -NewName $NewComputerName -DomainCredential $Creds }
    Catch { 
        Throw "ERROR: Rename failed. Is the password correct?" 
        Exit
    }

    $Top.Request = "Reboot" 
}


