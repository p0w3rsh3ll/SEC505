# To see a list of all the WMI namespaces:

get-wmiobject -query "select * from __namespace" -namespace "root" | format-table Name



