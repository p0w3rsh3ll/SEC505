# Create a CSV inventory of firmware versions for each
# machine listed in ComputerList.txt, which could be 
# filled by, for example, an AD query.  It would be more
# efficient to capture the data in memory and then
# write it once to the CSV, but the example code 
# would not be as clean for new scipters...


$Query = "SELECT * FROM Win32_BIOS"

Get-Content -Path ComputerList.txt | ForEach {
	Get-CimInstance -Query $Query -ComputerName $_ |
	Select-Object PSComputerName,Manufacturer,Version |
	Export-Csv -Append -Path FirmwareInventory.csv
}


