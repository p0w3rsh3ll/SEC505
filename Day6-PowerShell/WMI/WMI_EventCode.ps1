
$computer = "."     # A period indicates the local machine.

$query = "SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND EventCode = '529' OR EventCode = '4625'"

get-wmiobject -query $query -computername $computer |
sort-object TimeGenerated,RecordNumber |
select-object -last 20 | 
format-table ComputerName,TimeGenerated,User,Message -autosize



# WMI encodes date and time information in a special way (DMTF format):

function Convert-DMTFtoDateTime ($dmtf) { [Management.ManagementDateTimeConverter]::ToDateTime($dmtf) }

function Convert-DateTimeToDMTF ($date) { [Management.ManagementDateTimeConverter]::ToDmtfDateTime($date) }
 
