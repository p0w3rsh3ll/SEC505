# To list the classes available in a particular namespace, such as "root\CIMv2":


Get-CimInstance -Query "select * from meta_class" -Namespace "root\cimv2" | Select-Object CimClass 



