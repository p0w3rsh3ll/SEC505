# This command will enable the Active Directory Recycle Bin 
# feature of Windows Server 2008-R2 and later.  Once the AD 
# Recycle Bin is enabled, it cannot be disabled ever again.
# The feature requires a forest functionality level of 
# Server 2008-R2 or better.

Enable-ADOptionalFeature "Recycle Bin Feature" -server $((Get-ADForest -Current LocalComputer).DomainNamingMaster) -scope ForestOrConfigurationSet -target $(Get-ADForest -Current LocalComputer) 

