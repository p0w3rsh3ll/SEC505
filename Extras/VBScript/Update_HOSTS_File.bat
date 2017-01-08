@ECHO OFF
REM *************************************************************
REM Purpose:
REM    To update the HOSTS file from http://www.mvps.org/winhelp2002/
REM    to thwart access to unwanted sites, such as sites hosting 
REM    spyware, trojans, adware, etc.
REM 
REM Requirements:
REM    You'll need to first install the Win32 version of wget.exe
REM    (http://www.gnu.org/software/wget/index.html#downloading)
REM    and then put wget.exe into your PATH.  You must also run
REM    the script with elevated privileges.
REM
REM Notes:
REM    This will overwrite your current HOSTS file.  For more info:
REM    http://www.honeynet.org/papers/mws/  (see "Defense Evaluation").
REM *************************************************************


cd %SystemRoot%\System32\Drivers\Etc

attrib.exe -h -r -s hosts.txt
del hosts.txt
wget.exe --tries=3 --wait=10 http://www.mvps.org/winhelp2002/hosts.txt

if not "%errorlevel%"=="0" goto END

attrib.exe -h -r -s HOSTS
del HOSTS
rename hosts.txt HOSTS

:END


