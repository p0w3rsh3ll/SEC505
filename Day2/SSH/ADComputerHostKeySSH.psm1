<#
.DESCRIPTION
    BETA: this isn't ready yet...

    Functions to get/set the OpenSSH host public key
    from an attribute of a computer account in Active
    Directory for the sake of known_hosts files.  An
    existing computer attribute must be repurposed for
    this string, unless the schema is extended.  The
    SSH host public key is obtained with ssh-keyscan.exe.

    TODO:
    Only allow one key in attribute?  How to gracefully transition?
    When scan returns multiple keys, use first?  All?  Ask?
    Always convert $ComputerName to NetBIOS name, even when FQDN?
    Restrict $PublicKeyType values.
    Make proper module and support computer obj piping.
#>


function Set-ADComputerHostKeySSH
{
    Param ( $ComputerName = $env:COMPUTERNAME, $PublicKeyType = 'ed25519' )

    # An existing computer attribute must be repurposed for SSH:
    $ComputerAttributeToUse = 'postalAddress'

    Get-Command -Name 'ssh-keyscan.exe' -ErrorAction Stop | Out-Null

    if (-not (Test-Path -Path 'AD:\'))
    { Import-Module -Name ActiveDirectory -ErrorAction Stop } 

    # Does $? always set $False with ssh-keyscan.exe?
    [String[]] $key = ssh-keyscan.exe -t $PublicKeyType $ComputerName 2>$null

    if ($key.Count -eq 0)
    { 
        Throw "ERROR: Could not obtain $PublicKeyType key from $ComputerName using ssh-keyscan.exe."
        Return $False 
    } 

    #Ignore multiple keys, just use first one for now...
    Set-ADComputer -Identity $ComputerName -Replace @{ $ComputerAttributeToUse = $key[0] } 
}




function Get-ADComputerHostKeySSH
{
    Param ( $ComputerName = $env:COMPUTERNAME )

    # An existing computer attribute must be repurposed for SSH:
    $ComputerAttributeToUse = 'postalAddress'

    if (-not (Test-Path -Path 'AD:\'))
    { Import-Module -Name ActiveDirectory -ErrorAction Stop } 

    #Ignore multiple keys, just use first one for now...
    Get-ADComputer -Identity $ComputerName -Properties $ComputerAttributeToUse |
    Select-Object -ExpandProperty $ComputerAttributeToUse |
    Select-Object -First 1
}



function Clear-ADComputerHostKeySSH
{
    Param ( $ComputerName = $env:COMPUTERNAME )

    # An existing computer attribute must be repurposed for SSH:
    $ComputerAttributeToUse = 'postalAddress'

    if (-not (Test-Path -Path 'AD:\'))
    { Import-Module -Name ActiveDirectory -ErrorAction Stop } 

    Set-ADComputer -Identity $ComputerName -Clear $ComputerAttributeToUse  
}


