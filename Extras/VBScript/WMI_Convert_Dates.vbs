'***********************************************************************************
' Script Name: WMI_Convert_Dates.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC (with hints from MSDN)
'Last Updated: 3/16/03
'     Purpose: Convert WMI dates and times to/from VBScript date objects.
'       Notes: If you are unfamiliar with VBScript date objects (i.e., variables of
'              of subtype Date) then see the following built-in functions: 
'              DateAdd(), DateDiff(), DatePart(), DateSerial(), DateValue(), 
'              TimeSerial(), and TimeValue().  Also see Date(), Time(), Now(), 
'              Month(), Day(), Hour(), Minute() and Second().
'    Keywords: WMI, date, time
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************

On Error Resume Next


'***********************************************************************************
' Function: GetVBDate()
'  Purpose: Takes a WMI date-time string and converts it into a VBScript Date object.
'***********************************************************************************
Function GetVBDate(sWmiDate)
    GetVBDate = DateSerial(Left(sWmiDate,4),Mid(sWmiDate,5,2),Mid(sWmiDate,7,2)) _
    	      + TimeSerial(Mid(sWmiDate,9,2),Mid(sWmiDate,11,2),Mid(sWmiDate,13,2))
End Function


WScript.Echo GetVBDate("20030301163927.000000-360")



'***********************************************************************************
' Function: GetWMIDate()
'  Purpose: Takes a VBScript Date object and the desired offset in minutes from UTC 
'           time, and converts this data into a string in WMI date-time format.  
'***********************************************************************************
Function GetWMIDate(dDate, sOffset)
    Const VBDate = 7
    If VarType(dDate) <> VBDate Then dDate = DateValue(dDate)
	GetWMIDate = Year(dDate) & Right("0" &  Month(dDate),2) & _
	                           Right("0" &    Day(dDate),2) & _
	                           Right("0" &   Hour(dDate),2) & _
	                           Right("0" & Minute(dDate),2) & _
	                           Right("0" & Second(dDate),2) & _
	                           ".000000" & sOffset
End Function


WScript.Echo GetWMIDate(DateValue("3/1/2003") + TimeValue("4:39:27 PM"),GetUtcOffset("."))



'***********************************************************************************
' Function: GetUtcOffset()
'  Purpose: Returns the offset in minutes between the computer's time and UTC time.
'           This can be used in converting between VBScript Date objects and WMI
'           date-time strings.  
'    Notes: To specify the local computer, the argument should be:  GetUtcOffset(".")
'***********************************************************************************
Function GetUtcOffset(sComputer)
    Set oTempWMI = GetObject("WinMgmts://" & sComputer & "/root/cimv2")
    Set cCollection = oTempWMI.ExecQuery("SELECT * FROM Win32_TimeZone")
    For Each oItem in cCollection
        GetUtcOffset = oItem.Bias
    Next
    Set oTempWMI = Nothing
    Set cCollection = Nothing
End Function


WScript.Echo "Your UTC offset is " & GetUtcOffset(".")


'END OF SCRIPT *********************************************************************
