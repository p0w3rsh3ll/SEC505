#.NOTES
# Rough draft of function to obtain the ed25519 SSH host key
# from a Windows computer from \\Machine\C$ during initial
# provisioning.  Add more functions for updating known_hosts,
# updating the homePostalAddress property of the AD computer
# account, or updating known_hosts from homePostalAddress
# prior to ssh connection to avoid the confirmation prompt. 



function Get-SshHostKeyFromShare 
{
    [CmdletBinding()]
    Param (
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    $ComputerName
    )


    if (Test-Path -Path "\\$ComputerName\C$\ProgramData\ssh\ssh_host_ed25519_key.pub" )
    {
        $Key = Get-Content -Path "\\$ComputerName\C$\ProgramData\ssh\ssh_host_ed25519_key.pub" -ErrorAction Stop
    }
    else
    { 
        Write-Verbose -Verbose "Host key inaccessible at $ComputerName" 
        Return
    }
 

    #Split into an array 
    $Key = @($Key -split ' ') 


    #Sanity checks
    if ($Key.Count -lt 2)
    { 
        Throw "Host key is not formatted correctly."
        Return
    }

    if ($Key[0] -notlike "ssh-ed25519")
    { 
        Throw "Host key is not the correct type."
        Return
    }


    #Return known_hosts compatible string:
    "$ComputerName ssh-ed25519 " + $Key[1]
}


