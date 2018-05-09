# To see a list of all the WMI namespaces:

Get-CimInstance -Query "select * from __namespace" -Namespace "root" | Select-Object Name



