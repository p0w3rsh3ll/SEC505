# This script will cause the Local Configuration Manager (LCM) to immediately
# reapply the current configuration of the local computer, pulling the 
# configuration if necessary.


$HashTable = `
@{
    Namespace = "root/Microsoft/Windows/DesiredStateConfiguration"
    ClassName = "MSFT_DSCLocalConfigurationManager"
    MethodName = "PerformRequiredConfigurationChecks"
    Arguments = @{ Flags = [Uint32] 1 }
}

Invoke-CimMethod @HashTable

