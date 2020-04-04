##############################################################################
#  Script: Convert-DMTFtoDateTime.ps1
#    Date: 30.May.2007
# Version: 1.0
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505)
# Purpose: WMI encodes date and time information in a special way that is
#          somewhat difficult to read and manipulate.  These functions will
#          convert to/from WMI's DMTF format and System.DateTime objects.
#   Legal: Script provided "AS IS" without warranties or guarantees of any
#          kind.  USE AT YOUR OWN RISK.  Public domain, no rights reserved.
##############################################################################


function Convert-DMTFtoDateTime ( [String] $dmtf ) { 
    [System.Management.ManagementDateTimeConverter]::ToDateTime($dmtf) 
}


function Convert-DateTimeToDMTF ( [System.DateTime] $datetime = $(get-date) ) { 
    [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($datetime) 
}


# Examples:

Convert-DMTFtoDateTime '20070427164745.000000-300'
Convert-DMTFtoDateTime '20011102102233.000000-360'

Convert-DateTimeToDMTF 'February 19, 2007 3:02 PM'
Convert-DateTimeToDMTF $(get-date)   # Now.


