REM This is an example batch file for installing multiple patches.

setlocal
set reboot=0
net use m: \\server\share /persistent:no 
m:
cd %1\%2\hotfixes
For %%x In (Q*.exe KB*.exe) Do %%x -z -q & If %errorlevel%==3010 set reboot=1
cd \
If %reboot%==1 shutdown.exe -r -t 1 -c "Hotfixes Applied"  
endlocal

