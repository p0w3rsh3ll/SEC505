'**********************************************************************************
' Script Name: IP_Address_Range.vbs
'     Version: 1.0.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 26.May.2006
'     Purpose: Functions for enumerating valid IP address ranges by converting
'              IP addresses into and out of 32-bit decimal numbers.  Useful 
'              for connecting to all machines on a subnet or in an IP range.
'       Notes: If you wish to exclude network ID numbers, i.e., IP addresses
'              whose host IDs equal zero, or to exclude broadcast addresses,
'              i.e., IP addresses whose host IDs equal 255, then you'll have 
'              to provide this code yourself.  Also, these functions are written 
'              primarily for illustrating the mathematics, they are not optimized
'              and they do no error checking; hence, modify them as desired.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'**********************************************************************************

On Error Resume Next


'**********************************************************************************
' Function: IP2Number()
' Purpose: Convert a valid doted decimal IP address to
'          a 32-bit number.
'**********************************************************************************
Function IP2Number(ByVal sIP)
    Dim aOctets
	aOctets = Split(sIP,".")
	IP2Number = (Int(aOctets(0)) * 16777216) + _
	            (Int(aOctets(1)) * 65536   ) + _ 
	            (Int(aOctets(2)) * 256     ) + _
	            (Int(aOctets(3))           )      
End Function



'**********************************************************************************
' Function: Number2IP()
' Purpose: Convert a 32-bit number to an IP address.
'**********************************************************************************
Function Number2IP(ByVal iNumber)
	Dim aOctets(4)
	aOctets(0) = Int(iNumber / 16777216)
    	iNumber = iNumber - (aOctets(0) * 16777216)
	aOctets(1) = Int(iNumber / 65536)
    	iNumber = iNumber - (aOctets(1) * 65536)   
	aOctets(2) = Int(iNumber / 256)
	aOctets(3) = iNumber - (aOctets(2) * 256)
	Number2IP = CStr(aOctets(0) & "." & aOctets(1) & "." & aOctets(2) & "." & aOctets(3))
End Function




'**********************************************************************************
'The following demonstrates the functions.
'**********************************************************************************
iStart = IP2Number(WScript.Arguments.Item(0))
iEnd   = IP2Number(WScript.Arguments.Item(1))

For sAddress = iStart To iEnd
    sIP = Number2IP(sAddress)
    sLastOctet = Trim(Right(sIP, Len(sIP) - InStrRev(sIP,".")))
    If (sLastOctet <> "0") And (sLastOctet <> "255") Then 
        WScript.Echo sIP
	End If
Next








'**********************************************************************************
' The following "slow" functions are only to show the underlying mathematics 
' more clearly.  Use the functions above in real life, not the ones below.
'**********************************************************************************
Function SlowIP2Number(ByVal sIP)
	aOctets = Split(sIP,".")
	SlowIP2Number = (Int(aOctets(0)) * (2^24)) + _
	                (Int(aOctets(1)) * (2^16)) + _ 
	                (Int(aOctets(2)) * (2^8) ) + _
	                (Int(aOctets(3)) * (2^0) )        ' (2^0) = 1  
End Function


Function SlowNumber2IP(ByVal iNumber)
	Dim aOctets(4)
	aOctets(0) = Int(iNumber / (2^24))
	iNumber = iNumber - (aOctets(0) * (2^24))
	
	aOctets(1) = Int(iNumber / (2^16))
	iNumber = iNumber - (aOctets(1) * (2^16))   
	
	aOctets(2) = Int(iNumber / (2^8))
	iNumber = iNumber - (aOctets(2) * (2^8))	  'iNumber will equal aOctets(3).  

	aOctets(3) = Int(iNumber / (2^0))
	iNumber = iNumber - (aOctets(3) * (2^0))      'iNumber will equal zero here.  

	SlowNumber2IP = CStr(aOctets(0) & "." & aOctets(1) & "." & aOctets(2) & "." & aOctets(3))
End Function

'END OF SCRIPT ********************************************************************
