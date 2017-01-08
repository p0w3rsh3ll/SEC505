@ECHO OFF

SET FILE=%1
IF "%FILE%"=="" SET FILE=%COMPUTERNAME%-EventLogs.csv

findstr.exe /c:",Security,624,Account Management,<Audit-Success>,\"User Account Created: New Account Name:" %FILE%

