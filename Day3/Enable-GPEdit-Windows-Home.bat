REM Enable the Group Policy Object Editor MMC snap-in for the local GPO on Windows 10 Home.
REM Windows 10 Home disables this feature by default.  Run gpedit.msc afterwards.
REM Credit for this script goes to iTechtics:
REM https://www.itechtics.com/easily-enable-group-policy-editor-gpedit-msc-in-windows-10-home-edition/

@echo off 
pushd "%~dp0" 

dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~3*.mum >List.txt 
dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~3*.mum >>List.txt 

for /f %%i in ('findstr /i . List.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i" 

pause


