@ECHO OFF

SET FILE=%1
IF "%FILE%"=="" SET FILE=%COMPUTERNAME%-EventLogs.csv

findstr.exe /c:",6006,EventLog," %FILE% 

