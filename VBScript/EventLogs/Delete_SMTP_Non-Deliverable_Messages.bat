@ECHO OFF

SET FILE=%1
IF "%FILE%"=="" SET FILE=%COMPUTERNAME%-EventLogs.csv

findstr.exe /V /C:",,4000,smtpsvc," %FILE% > temp23.csv
findstr.exe /V /C:",,4001,smtpsvc," temp23.csv > temp24.csv
del %FILE%
del temp23.csv
rename temp24.csv %FILE%

