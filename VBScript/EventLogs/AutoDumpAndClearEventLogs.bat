@ECHO OFF

REM ***WARNING!**********************************************************
REM This batch file runs the WMI_ADO_DumpEventLog.vbs script to dump all
REM local Event Logs to a file named after the computer's name.
REM Note that the other batch scripts assume, but do not require, that
REM your logfile is named %COMPUTERNAME%-EventLogs.csv
REM *********************************************************************

cscript.exe WMI_ADO_DumpEventLog.vbs %COMPUTERNAME% %COMPUTERNAME%-EventLogs.csv /all /clear



