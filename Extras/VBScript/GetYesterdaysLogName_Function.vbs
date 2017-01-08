'***********************************************************************************
' Script Name: GetYesterdaysLogName_Function.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 22.Nov.04
'     Purpose: Returns the name of the prior day's IIS log file name.  This is 
'              often needed when automating scripts that work with IIS logs.  A 
'              couple other functions also return log names based on today's
'              date and time as examples.
'    Keywords: IIS, logs, log, logfile, CSV
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************


Function GetYesterdaysLogName()
    Dim sDate1,sYear,sMonth,sDay,sYesterday
    sDate1 = Date()
    sYear = DatePart("yyyy",sDate1)
    sMonth = DatePart("m",sDate1)
    sDay = DatePart("d",sDate1)
    sYesterday = DateSerial(sYear,sMonth,sDay - 1)      
    sYear = Right(DatePart("yyyy",sYesterday),2)
    sMonth = Right("0" & DatePart("m",sYesterday),2)
    sDay = Right("0" & DatePart("d",sYesterday),2)
    GetYesterdaysLogName = "ex" & sYear & sMonth & sDay & ".log"
End Function



Function Today()
    Dim sDate1,sYear,sMonth,sDay
    sDate1 = Date()
    sYear = DatePart("yyyy",sDate1)
    sMonth = DatePart("m",sDate1)
    sMonth = Right("0" & sMonth, 2)
    sDay = DatePart("d",sDate1)    
    sDay = Right("0" & sDay, 2)
    Today = sYear & sMonth & sDay & ".csv"
End Function



Function RightNow()
    Dim sDate1,sYear,sMonth,sDay,sHour,sMin,sSec
    sDate1 = Now()
    sYear  = DatePart("yyyy",sDate1)
    sMonth = DatePart("m",sDate1)
    sMonth = Right("0" & sMonth, 2)
    sDay  = DatePart("d",sDate1)    
    sDay  = Right("0" & sDay, 2)
    sHour = DatePart("h",sDate1)
    sHour = Right("0" & sHour, 2)    
    sMin  = DatePart("n",sDate1)
    sMin  = Right("0" & sMin, 2)
    sSec  = DatePart("s",sDate1)
    sSec  = Right("0" & sSec, 2)
    RightNow = sYear & sMonth & sDay & sHour & sMin & sSec & ".csv"
End Function


'END OF SCRIPT *********************************************************************


WScript.Echo GetYesterdaysLogName()
WScript.Echo Today()
WScript.Echo RightNow()

