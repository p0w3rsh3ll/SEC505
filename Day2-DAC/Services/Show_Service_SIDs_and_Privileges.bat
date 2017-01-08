@ECHO OFF
REM ***********************************************************************
REM      This script displays service hardening information on Windows Vista and later.  
REM      Must be run in a CMD.EXE shell or with CMD.EXE /K.    Makes no changes.
REM      Author:JF, Ver:1.0, Date:2.Aug.06
REM ***********************************************************************

sc.exe query | find.exe "SERVICE_NAME" > %TEMP%\777.txt 
for /F "tokens=2 delims= " %%i in (%temp%\777.txt) do @echo %%i >> %temp%\888.txt
del %temp%\777.txt
echo. && echo ------------------------------------------------------ && echo.
for /F %%i in (%temp%\888.txt) do sc.exe query %%i | find.exe "NAME" && sc.exe getdisplayname %%i | find.exe "Name = " && echo. && sc.exe qdescription %%i | find.exe "DESCRIPTION" && echo. && sc.exe qsidtype %%i | find.exe "SID" && echo. && sc.exe qprivs %%i | find.exe "PRIV" && echo. && echo ------------------------------------------------------ && echo.
del %temp%\888.txt


