@ECHO OFF

SET FILE=%1
IF "%FILE%"=="" SET FILE=%COMPUTERNAME%-EventLogs.csv

findstr.exe /c:",Security,630,Account Management,<Audit-Success>,\"User Account Deleted: Target Account Name:" %FILE%

