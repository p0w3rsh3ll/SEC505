################################################################################
#    Name: Inventory-Applications.ps1
# Purpose: Queries a local or remote computer for information about software
#          applications installed, then exports the data to a CSV file which
#          can be opened in a spreadsheet.  The output from scanning multiple
#          computers can all be appended to one file (each line in the CSV file
#          will have the name of the computer).  By default, the script creates
#          a file in the present directory named ApplicationsInventory.csv.
#          However, beware, there are issues when using the Win32_Product class!
# Version: 1.0
#    Date: 10.Oct.2012
#  Author: Jason Fossen (http://www.sans.org/securing-windows)
#   Legal: Public domain, no guarantees or warranties provided.
################################################################################

param ($ComputerName = ".", $FilePath = ".\ApplicationsInventory.csv")

get-wmiobject -query "SELECT * FROM Win32_Product" -computername $ComputerName | 
sort-object Vendor | 
select-object PSComputerName,Vendor,Name,Version,Caption,Description,InstallDate,InstallLocation,InstallSource,PackageName |
export-csv -path $FilePath -append 


