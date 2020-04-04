<#############################################################################
.SYNOPSIS
Return hashtable for each type of ZFS item specified.

.DESCRIPTION
The ZFS filesystem includes different types of items which are output by the
"zfs list -t <type>" command, where <type> is one of 'filesystem','snapshot',
'volume' or 'bookmark'.  The "zpool list" command outputs only one type of
item, a pool.  This script outputs a hashtable for each instance of the
specified type.  Each hashtable contains all the properties and all the data
for that instance.

.PARAMETER Type
The type of the ZFS dataset or zpool.  Must be one of 'filesystem', 'snapshot',
'volume', 'bookmark' or 'pool'.  Defaults to 'filesystem.'

.EXAMPLE

    $fs = @( Get-ZfsItem.ps1 -Type filesystem )
    $fs.count
    $fs[0].name
    $fs[0].mountpoint
    $fs[0].avail / 1GB

.NOTES
Version: 1.0
Created: 14.Jan.2020
Author: JF@Enclave
Legal: Public domain, no warranties or guarantees whatsoever.

Kudos to the authors of the zfs and zpool tools!  These tools really
are what make scripts like this possible, the tools are so well-written
that it's easy to write wrappers for them like this.  Thank You OpenZFS!
#############################################################################>

[CmdletBinding()] Param
( 
  [ValidateSet('filesystem','snapshot','volume','bookmark','pool')]
  [String] $Type = 'filesystem'
)

# The zfs and zpool tools seem to prefer lowercase
$Type = $Type.ToLower()


function Get-ZfsDatasetName
{
<#
.SYNOPSIS
Returns zero or more names of the specified type.
#>    
    [CmdletBinding()] Param
    ( [Parameter(Mandatory=$True)]
      [ValidateSet('filesystem','snapshot','volume','bookmark','pool')]
      $Type
    )

    if ($Type -eq 'pool')
    { $names = @(zpool list -H -o name) }
    else
    { $names = @(zfs list -H -t $Type -o name) } 
    Write-Verbose ("Names: " + ($names -join ','))

    $names 
}




function Get-ZfsListHeader
{
<#
.SYNOPSIS
Returns the header names of the specified type.
#>    
    [CmdletBinding()] Param
    ( [Parameter(Mandatory=$True)]
      [ValidateSet('filesystem','snapshot','volume','bookmark','pool')]
      $Type
    )

    # Try to get first instance of $Type
    if ($Type -eq 'pool')
    { $first = @(zpool list -H -o name)[0] }
    else
    { $first = @(zfs list -H -t $Type -o name)[0] } 

    # Return $null if no instances of $Type 
    if ($first.Length -eq 0)
    { 
        Write-Verbose -Message ("There are no $Type" + "s on this computer.")
        return $null 
    }
    else #Return header names of $Type, must be lowercase
    {
        $fsheaders = $null
        Try { 
            if ($Type -eq 'pool')
            { $fsheaders = @(zpool list -o all $first)[0].ToLower() }
            else
            { $fsheaders = @(zfs list -t $Type -o all $first)[0].ToLower() } 

            $fsheaders = ($fsheaders -Replace('\s+',';')) -Split ';' 
        }
        Catch { Write-Error -Message ("Failed to parse $Type headers.") }
        Finally { $fsheaders } 

    }
}


function Confirm-Sanity 
{
<#
.SYNOPSIS
Perform sanity checks for the $Type.
.DESCRIPTION
For each $Type, confirm the data in common keys are the correct type
and size to try to catch errors when aligning headers to values.  If 
the output of this script is fed into another for making changes, 
better to fail here than later.  Look for properties which always have 
values.  Look for a numeric value surrounded by strings and vice versa.
#>
    [CmdletBinding()] Param
    ( 
    [Parameter(Mandatory=$True)]
    [System.Collections.Hashtable] $Hashtable,
    [Parameter(Mandatory=$True)]
    [ValidateSet('filesystem','snapshot','volume','bookmark','pool')]
    $Type
    )

    #Empty is fine
    if ($Hashtable.Count -eq 0){ return $True } 

    Switch ($Type)
    {
        'filesystem'
        {
            if ($Hashtable.copies -notmatch '^[0-3]{1}$'){return $False} 
            if ($Hashtable.devices -notmatch '^off|on$'){return $False} 
            if ($Hashtable.atime -notmatch '^off|on$'){return $False} 
            if ($Hashtable.setuid -notmatch '^off|on$'){return $False} 
            if ($Hashtable.volsize -match '\D'){return $False} 
        }

        'snapshot'
        {
            if ($Hashtable.type -ne 'snapshot'){return $False} 
            if ($Hashtable.guid -match '\D'){return $False} 
            if ($Hashtable.case -notmatch 'sensitive|mixed'){return $False} 
        }

        'volume'
        {
            #TODO
        }

        'bookmark'
        {
            #TODO
        }

        'pool'
        {
            if ($Hashtable.delegation -notmatch '^off|on$'){return $False} 
            if ($Hashtable.expand -notmatch '^off|on$'){return $False} 
            if ($Hashtable.guid -match '\D'){return $False} 
            if ($Hashtable.free -match '\D'){return $False} 
        }

        default
        { $False } 
    }

    #Default return
    $True
}



# For the desired $Type, return a hashtable of all properties for each instance.
# Nothing is returned if there are no instances of the $Type.
ForEach ($ds in (Get-ZfsDatasetName -Type $Type))
{
    $Hash = [Ordered] @{}

    # Get array of property names for the desired $Type
    [String[]] $headers = @(Get-ZfsListHeader -Type $Type)
    Write-Verbose ("Headers count = " + $headers.Count)

    # zfs list: -H no headers and tab delimit, -p byte count, $ds is name of one dataset
    $oarg = $headers -Join ','  # Arg to -o must be comma-delimited lowercase property names

    if ($Type -eq 'pool')
    { [String[]] $data = (zpool list -Hp -o $oarg $ds) -Split "`t" }
    else
    { [String[]] $data = (zfs list -Hp -t $Type -o $oarg $ds) -Split "`t" } 

    Write-Verbose ("Data count = " + $data.Count)

    # Property with no data is "-" in zfs/zpool list output
    $data = $data.Replace('-',$null)

    # Sanity check, but should we Continue or fail?
    if ($headers.Count -ne $data.Count)
    { 
        Throw "Failed to match headers to data." 
    } 

    # Build the hashtable
    For ($i = 0; $i -lt $headers.Count; $i++)
    { 
        $Hash.Add($headers[$i],$data[$i]) 
    }

    # Sanity checks
    if ( Confirm-Sanity -Hashtable $Hash -Type $Type )
    { ,@($Hash) } #Don't delete the comma 
    else 
    {
        Throw "Final sanity checks failed."    
    }

}



<# 
#Return everything in one giant hashtable?
#Do custom object or class instead?
$zfs = [Ordered] @{ 
    filesystem = $null
    snapshot   = $null
    volume     = $null
    bookmark   = $null
    zpool      = $null
    version = @(zfs version) -Join ';' 
} 
#>
