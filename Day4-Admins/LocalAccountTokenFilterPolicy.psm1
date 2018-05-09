<#
.SYNOPSIS
 Manage the LocalAccountTokenFilterPolicy registry value (KB951016).

.DESCRIPTION
 Manage the LocalAccountTokenFilterPolicy registry value (KB951016). 
 This value controls whether network logons to a computer using a 
 local account defined on that computer will have a normal, full, 
 unmodified Security Access Token ($Setting = 1) or a Security Access 
 Token which has been stripped of it's dangerous privileges and 
 administrative group memberships ($Setting = 0, the default).

.NOTES
 Legal: Script provided "AS IS" without warranties of any kind.
 Redistribution: Public domain, no rights reserved.
 Author: Enclave Consulting LLC. 
#>




function Get-LocalAccountTokenFilterPolicy
{
    <#
    .SYNOPSIS
     Returns the LocalAccountTokenFilterPolicy registry value (KB951016).

    .DESCRIPTION
     The LocalAccountTokenFilterPolicy registry value controls whether 
     network logons to a computer using a local account defined on that 
     computer will have a normal, full, unmodified Security Access Token 
     (returns 1) or a Security Access Token which has been stripped of it's 
     dangerous privileges and administrative group memberships (returns 0, 
     which is the factory default). This impacts whether a local user may be
     used for tasks like PowerShell remoting and system administration (0 = No, 
     1 = Yes). See KB951016 for more information, the issues are complex and 
     potentially compromising. Use the -Verbose switch to show additional 
     information about consequences. 

    .NOTES
     Legal: Script provided "AS IS" without warranties of any kind.
     Redistribution: Public domain, no rights reserved.
     Author: Enclave Consulting LLC. 
    #>

    [CmdletBinding()][OutputType([Int32])] Param()

    $value = $null
    $msg0 = 'Network logons to this computer using local accounts on this computer will have their Security Access Tokens (SATs) stripped of dangerous privileges and administrative group memberships (except when using the built-in local Administrator account, to which this behavior never applies).'
    $msg1 = 'Network logons to this computer using local accounts on this computer will NOT have their Security Access Tokens (SATs) stripped of dangerous privileges or administrative group memberships. The SAT will be a full, unmodified token, just like for the built-in Administrator account.'

    $value = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -ErrorAction SilentlyContinue
    
    if ($value -eq $null)
    { 
        [Int32] 0 
        Write-Verbose -Message "Value does not exist: defaults to 0"
        Write-Verbose -Message $msg0 
    }
    else
    {
        $value.LocalAccountTokenFilterPolicy 
        Write-Verbose -Message ("Value exists: " + $value.LocalAccountTokenFilterPolicy) 

        if ($value.LocalAccountTokenFilterPolicy -eq 0) 
            { Write-Verbose -Message $msg0 } 
        elseif ($value.LocalAccountTokenFilterPolicy -eq 1)
            { Write-Verbose -Message $msg1 }
        else
            { Write-Verbose -Message ("NON-STANDARD VALUE EXISTS: " + $value.LocalAccountTokenFilterPolicy) } 
    }
}




function Set-LocalAccountTokenFilterPolicy
{
    <#
    .SYNOPSIS
     Sets the LocalAccountTokenFilterPolicy registry value (KB951016).

    .DESCRIPTION
     The LocalAccountTokenFilterPolicy registry value controls whether 
     network logons to a computer using a local account defined on that 
     computer will have a normal, full, unmodified Security Access Token 
     (returns 1) or a Security Access Token which has been stripped of it's 
     dangerous privileges and administrative group memberships (returns 0, 
     which is the factory default). This impacts whether a local user may be
     used for tasks like PowerShell remoting and system administration (0 = No, 
     1 = Yes). This does not apply to the built-in local Administrator account, 
     however, for which the effective value is always 1, that is to say, the 
     Administrator's SAT is unmodified.  See KB951016 for more information, the 
     issues are complex and potentially compromising. Use the -Verbose switch to 
     show additional information about consequences. Note that changes to this 
     value take effect immediately, no reboot required. Function outputs true or 
     false to indicate successful setting of the registry value. 

    .PARAMETER Settings
     Mandatory, must be 0 or 1. There is no default for the function (Windows 
     defaults to 0 because, by default, the registry value does not exist).  
     Setting to 0 has the same effect as deleting the value from the registry. 
     Function cannot delete the value. 

    .NOTES
     Legal: Script provided "AS IS" without warranties or guarantees of any kind.
     Redistribution: Public domain, no rights reserved.
     Author: Enclave Consulting LLC. 
    #>

    [CmdletBinding()][OutputType([Boolean])]
    Param( [ValidateSet(0,1)] [Int32] $Setting ) #No default, force choice. 

    $msg0 = 'Network logons to this computer using local accounts on this computer will have their Security Access Tokens (SATs) stripped of dangerous privileges and administrative group memberships (except when using the built-in local Administrator account, to which this behavior never applies).'
    $msg1 = 'Network logons to this computer using local accounts on this computer will NOT have their Security Access Tokens (SATs) stripped of dangerous privileges or administrative group memberships. The SAT will be a full, unmodified token, just like for the built-in Administrator account.'

    $value = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -ErrorAction SilentlyContinue
    
    if ($value -eq $null)
    { 
        New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -PropertyType DWord -Value $Setting | Out-Null
        Write-Verbose -Message "Value did not exist, created it."
    }
    else
    {
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value $Setting | Out-Null
        Write-Verbose -Message "Value already existed, setting it."
    }

    #Now try to read the value to elicit any errors:
    $value = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy 

    #But still return $true if value matches desired $setting:
    if ($value.LocalAccountTokenFilterPolicy -eq $Setting){ $True } Else { $False } 

    #Verbose output only:
    if ($value.LocalAccountTokenFilterPolicy -eq 0) 
        { Write-Verbose -Message $msg0 } 
    elseif ($value.LocalAccountTokenFilterPolicy -eq 1)
        { Write-Verbose -Message $msg1 }
    else
        { Write-Verbose -Message ("NON-STANDARD VALUE EXISTS: " + $value.LocalAccountTokenFilterPolicy) } 

}



