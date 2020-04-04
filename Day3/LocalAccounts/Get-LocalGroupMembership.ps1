#.SYNOPSIS
#   Gets the membership of a local group.
#.NOTES
# Windows PowerShell 5.1 and later includes cmdlets for 
# managing local users and groups.  
# For SSH, use -HostName instead of -ComputerName.


Param ($ComputerName = "localhost", $GroupName = "Administrators") 


function Get-LocalGroupMembership 
{
    Param ($ComputerName = "localhost", $GroupName = "Administrators") 

    if ($ComputerName -eq "localhost")
    { 
        $Members = Get-LocalGroupMember -Group $GroupName 
    }
    else
    {
        $Members = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-LocalGroupMember -Group $Using:GroupName } -ErrorAction Stop 
    }

    $Members | Select-Object -ExpandProperty Name 
}


Get-LocalGroupMembership -ComputerName $ComputerName -GroupName $GroupName

