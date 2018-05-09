
function Get-LogonFailures ($Computer = ".")  # A period indicates the local machine.
{ 
    $Query = "SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND ( EventCode = '529' OR EventCode = '4625' )"
 
    Get-CimInstance -Query $Query -ComputerName $Computer 
} 




# Run the function to query the local computer:

$Events = Get-LogonFailures

$Events.Count  #Total number of events returned.

$Events | Select-Object TimeGenerated,CategoryString,Type,EventCode



# The InsertionStrings property is itself an array of strings:

$example = $Events[0]                    #Get one event as an example.
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
