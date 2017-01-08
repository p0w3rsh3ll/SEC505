@ECHO OFF

SET FILE=%1
IF "%FILE%"=="" SET FILE=%COMPUTERNAME%-EventLogs.csv

findstr.exe /c:",System,,20048,RemoteAccess,20048,,<Information>," %FILE%

