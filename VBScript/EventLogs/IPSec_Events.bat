@ECHO OFF

SET FILE=%1
IF "%FILE%"=="" SET FILE=%COMPUTERNAME%-EventLogs.csv

findstr.exe /i /c:"ipsec" /c:" IKE " /c:" Oakley " /c:"ISAKMP" %FILE%

