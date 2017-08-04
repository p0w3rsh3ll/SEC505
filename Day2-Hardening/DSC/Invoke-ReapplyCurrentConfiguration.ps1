<#
.SYNOPSIS
   Immediately reapply the last-applied DSC configuration.
.DESCRIPTION
   Immediately reapply the last-applied Desired State Configuration,
   for either push mode or pull mode; pulling the MOF, if necessary, 
   when in DSC pull mode.  
.NOTES
   The last-applied MOF is also called the "current configuration". 
   It is found at C:\Windows\System32\Configuration\Current.mof.     
#>

$HashTable = `
@{
    Namespace = "root/Microsoft/Windows/DesiredStateConfiguration"
    ClassName = "MSFT_DSCLocalConfigurationManager"
    MethodName = "PerformRequiredConfigurationChecks"
    Arguments = @{ Flags = [Uint32] 1 }
}

Invoke-CimMethod @HashTable

