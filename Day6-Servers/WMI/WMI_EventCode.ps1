
function Get-LogonFailures ($computer = ".")  # A period indicates the local machine.
{ 
    $query = "SELECT * FROM Win32_NTLogEvent WHERE logfile = 'Security' AND ( EventCode = '529' OR EventCode = '4625' )"
 
    get-wmiobject -query $query -computername $computer 
} 


# Run the function to query the local computer:

Get-LogonFailures




# WMI encodes date and time information in a special way (DMTF format):

function Convert-DMTFtoDateTime ($dmtf) { [Management.ManagementDateTimeConverter]::ToDateTime($dmtf) }

function Convert-DateTimeToDMTF ($date) { [Management.ManagementDateTimeConverter]::ToDmtfDateTime($date) }
 
