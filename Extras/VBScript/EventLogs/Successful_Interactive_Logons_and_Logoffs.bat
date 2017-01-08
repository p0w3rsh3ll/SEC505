@ECHO OFF
REM See KB828857 for typical MS boneheadedness about Event ID 551 ...


SET FILE=%1
IF "%FILE%"=="" SET FILE=%COMPUTERNAME%-EventLogs.csv

findstr.exe /c:",Security,528," /c:",Security,538," /c:",Security,551," %FILE% > temp444.csv
findstr.exe /v /c:"User Name: NETWORK SERVICE" /c:"User Name: LOCAL SERVICE" /c:"IUSR_" /c:"IWAM_" /c:"ANONYMOUS LOGON" temp444.csv > temp212.csv
findstr.exe /c:"Logon Type: 2" /c:",Security,551," temp212.csv

del temp444.csv
del temp212.csv


