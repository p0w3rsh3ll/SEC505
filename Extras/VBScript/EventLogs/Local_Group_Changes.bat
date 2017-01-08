@ECHO OFF

SET FILE=%1
IF "%FILE%"=="" SET FILE=%COMPUTERNAME%-EventLogs.csv

findstr.exe /c:"Security,635" /c:"Security,636" /c:"Security,637" /c:"Security,638" /c:"Security,639" %FILE% 



