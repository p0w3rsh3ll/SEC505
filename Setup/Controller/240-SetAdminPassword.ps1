###############################################################################
#.SYNOPSIS
#   Changing current user's password to P@ssword
#
# Only check if the VM is not a domain controller.
#
###############################################################################

# Assume failure:
$Top.Request = "Stop"

# Get the password from the data file:
$NewAdminPassword = $Top.NewAdminPassword 

# Sanity check:
if ($NewAdminPassword -eq $null)
{ 
    Throw "ERROR: No password available to be assigned." 
    Exit  
}

# This function is backwards compatible to PoSh 1.0 btw:
Function Reset-LocalUserPassword ($UserName, $NewPassword)
{
    Try 
    {
        $ADSI = [ADSI]("WinNT://" + $env:ComputerName + ",computer")
        $User = $ADSI.PSbase.Children.Find($UserName)
        $User.PSbase.Invoke("SetPassword",$NewPassword)
        $User.PSbase.CommitChanges()
        $User = $null
        $ADSI = $null
        $True
    }
    Catch
    { $False }
}


# Reset password if the machine is not a controller:
if ($Top.IsDomainController)
{
    $Top.Request = "Continue"
}
else
{
    if (Reset-LocalUserPassword -UserName $env:username -NewPassword $NewAdminPassword )
    {
        $Top.Request = "Continue"
    } 
    else
    {
        $Top.Request = "Stop"
        Throw "ERROR: The password reset failed."
    }
}

