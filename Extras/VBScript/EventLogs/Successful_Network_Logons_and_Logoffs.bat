@ECHO OFF

SET FILE=%1
IF "%FILE%"=="" SET FILE=%COMPUTERNAME%-EventLogs.csv

findstr.exe /c:",Security,540," /c:",Security,538," %FILE% > temp892.csv
findstr.exe /v /c:"ANONYMOUS LOGON" /c:"Security,NT AUTHORITY\SYSTEM," temp892.csv > temp114.csv
findstr.exe /c:"Logon Type: 3" temp114.csv

del temp892.csv
del temp114.csv



