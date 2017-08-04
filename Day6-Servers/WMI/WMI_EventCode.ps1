
function Get-LogonFailures ($computer = ".")  # A period indicates the local machine.
{ 
    $query = "SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND ( EventCode = '529' OR EventCode = '4625' )"
 
    get-wmiobject -query $query -computername $computer 
} 




# Run the function to query the local computer:

$events = Get-LogonFailures

$events.Count  #Total number of events returned.

$events | Select-Object TimeGenerated,CategoryString,Type,EventCode



# The InsertionStrings property is itself an array of strings:

$example = $events[0]                    #Get one event as an example.
$example.InsertionStrings                #Extract the whole array.
$first  = $example.InsertionStrings[0]   #Extract just the first string from the array.
$second = $example.InsertionStrings[1]   #Extract just the second string from the array.



# WMI encodes date and time information in a special way (DMTF format):

function Convert-DMTFtoDateTime ($DMTF) { [Management.ManagementDateTimeConverter]::ToDateTime($DMTF) }

function Convert-DateTimeToDMTF ($Date) { [Management.ManagementDateTimeConverter]::ToDmtfDateTime($Date) }
 





# Note: Logging logon successes and failures requires the Logon audit policy:
# Query the current audit policy:
auditpol.exe /get /subcategory:'Logon'
# Enable success and failure logging for Logon events: 
auditpol.exe /set /subcategory:'Logon' /success:enable /failure:enable
