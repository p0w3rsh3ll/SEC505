@ECHO OFF
REM --------------------------------------------------------------------------
REM Pass in logfile name as first arg.
REM This script requires the free Win32 TAIL.EXE from http://unxutils.sourceforge.net (or equivalent).
REM This script requires that MS Excel be installed and .CSV files be associated with it (ftype|find ".CSV").
REM --------------------------------------------------------------------------

REM AutoDumpAndClearEventLogs.bat


SET FILE=%1
IF "%FILE%"=="" SET FILE=%COMPUTERNAME%-EventLogs.csv

findstr.exe /c:",Security,529," /c:",Security,530," /c:",Security,531," /c:",Security,532," /c:",Security,533," /c:",Security,534," /c:",Security,535," /c:",Security,536," /c:",Security,537," /c:",Security,539," /c:",Security,548," /c:",Security,549," %FILE% | tail.exe -n 50 > temp82129.csv 
ECHO Close Excel to continue...
START /wait temp82129.csv
DEL temp82129.csv













REM --------------------------------------------------------------------------
REM 529 Logon failure. A logon attempt was made with an unknown user name or a known user name with a bad password.
REM 530 Logon failure. A logon attempt was made outside the allowed time.
REM 531 Logon failure. A logon attempt was made using a disabled account.
REM 532 Logon failure. A logon attempt was made using an expired account.
REM 533 Logon failure. A logon attempt was made by a user who is not allowed to log on at the specified computer.
REM 534 Logon failure. The user attempted to log on with a password type that is not allowed.
REM 535 Logon failure. The password for the specified account has expired.
REM 536 Logon failure. The Net Logon service is not active.
REM 537 Logon failure. The logon attempt failed for other reasons.
REM 539 Logon failure. The account was locked out at the time the logon attempt was made.
REM 548 Logon failure. The security identifier (SID) from a trusted domain does not match the account domain SID of the client.
REM 549 Logon failure. All SIDs corresponding to untrusted namespaces were filtered out during an authentication across forests.
REM ---------------------------------------------------------------------------

