get-service | export-csv -path services.csv
$objects = import-csv -path services.csv
$objects | where-object {$_.status -eq 'Running'} | 
ft DisplayName

