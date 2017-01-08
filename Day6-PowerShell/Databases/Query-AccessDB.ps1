##############################################################################
#  Script: Query-AccessDB.ps1
#    Date: 3.Jun.2007
# Version: 1.0
#  Author: Jason Fossen (www.WindowsPowerShellTraining.com)
# Purpose: Perform a SELECT query against an Access database and return data
#          as an array of comma-delimited strings.  
#   Notes: Column headers are first in the array unless suppressed with the
#          -NoColumnHeaders switch.  Fields that contains commas will be
#          double-quoted.   
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################



# param ($Path = $(throw "Enter path to Access database file."), 
#       $SqlQuery = $(throw "Enter SQL select query string."),
#       [Switch] $NoColumnHeaders )



function Query-AccessDB ($Path = $(throw "Enter path to Access database file."), 
                         $SqlQuery = $(throw "Enter SQL select query string."),
                         [Switch] $NoColumnHeaders )
{
#Assume database file is in present working directory if no path given.
if ($Path -notmatch "\\") { $Path = "$PWD\$Path" } 

$ConnectionString = "Provider= Microsoft.Jet.OLEDB.4.0; Data Source= $Path;"
$Connection = new-object "System.Data.OleDb.OleDbConnection" -arg $ConnectionString
$Connection.Open()

$DataAdapter = new-object "System.Data.OleDb.OleDbDataAdapter" -arg $SqlQuery,$Connection
$DataSet = new-object "System.Data.DataSet" 
$DataAdapter.Fill($DataSet, "TempTableInDataSet") | out-null

$Connection.Close()

$Table = $DataSet.Tables["TempTableInDataSet"]

$Output = @()  #Array will hold entire output of function.
$Line = @()    #Temp array to hold each row before put into $Output.

#Make first item in $Output the column/property names, unless suppressed.
ForEach ($Col In $Table.Columns) { $Line += $Col.ColumnName }
if (-not $NoColumnHeaders) { $Output += [String]::Join(",",$Line) }

#Enumerate each row in table, appending to the $Output array.
For ($i = 0 ; $i -le ($Table.Rows.Count - 1) ; $i++) 
{
    $Row = $Table.Rows[$i]
    $Line = @()

    For ($j = 0 ; $j -le ($Table.Columns.Count - 1) ; $j++)
    {
        #If a field includes a comma, the field must be double-quoted for sake of parsing and CSVs.
        $Line += $( If ($Row.Item($j) -match "\,") { '"' + $($Row.Item($j)) + '"'} Else { $Row.Item($j) } )
    }

    $Output += [String]::Join(",",$Line)
}

$Output
}


Query-AccessDB -path states.mdb -sqlquery "SELECT * FROM StatesTable"
# Query-AccessDB -path $Path -sqlquery $SqlQuery 














# By the way, here's a function to write a table to the console.
# It's the same code as above, but separated into a function.

function Write-TableADO( [System.Data.DataTable] $Table )
{
    For ($i = 0 ; $i -le ($Table.Rows.Count - 1) ; $i++) 
    {
        $Row = $Table.Rows[$i]
        $Line = @()

        For ($j = 0 ; $j -le ($Table.Columns.Count - 1) ; $j++)
        {
            $Line += $Row.Item($j)
        }
        [String]::Join(",",$Line)
    }
}




