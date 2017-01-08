##############################################################################
#  Script: Update-AccessDB.ps1
#    Date: 19.Jul.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Perform a INSERT, UPDATE or DELETE command against an Access 
#          database.  For SELECT, see the Query-AccessDB.ps1 script. 
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################



# param ($Path = $(throw "Enter path to Access database file."), 
#        $SqlText = $(throw "Enter SQL insert, update or delete string.") )



function Update-AccessDB ($Path = $(throw "Enter path to Access database file."), 
                          $SqlText = $(throw "Enter SQL insert, update or delete string.") )
{
#Assume database file is in present working directory if no path given.
if ($Path -notmatch "\\") { $Path = "$PWD\$Path" } 

$ConnectionString = "Provider= Microsoft.Jet.OLEDB.4.0; Data Source= $Path;"
$Connection = new-object "System.Data.OleDb.OleDbConnection" -arg $ConnectionString
$Connection.Open()

$OleDbCommand = new-object "System.Data.OleDb.OleDbCommand" -arg $SqlText,$Connection
$RecordsUpdatedCount = $OleDbCommand.ExecuteNonQuery()
$Connection.Close()
[String] $RecordsUpdatedCount + " record(s) successfully updated!"
}



Update-AccessDB -path states.mdb -sqltext "INSERT INTO StatesTable (Code,Name) Values ('SANS','WisconSANS')" 
Update-AccessDB -path states.mdb -sqltext "UPDATE StatesTable SET Name = 'ArkanSANS' WHERE Code = 'SANS'" 
Update-AccessDB -path states.mdb -sqltext "DELETE FROM StatesTable WHERE Code = 'SANS'" 

# Update-AccessDB -path $path -sqltext $sqltext 

