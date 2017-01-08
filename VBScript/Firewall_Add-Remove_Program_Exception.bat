@ECHO OFF
REM Securing Windows Track :: SANS Institute :: Jason Fossen

REM Add a program to the Exceptions tab and configure its scope.
REM You can also set the scope to ALL or SUBNET.




netsh.exe firewall add allowedprogram program = "%WinDir%\system32\notepad.exe" name = Notepad mode = enable profile = current scope = custom 10.0.0.0/255.0.0.0,192.168.0.0/255.255.0.0 



REM Now delete that excepted program.
pause


netsh.exe firewall delete allowedprogram program = "%WinDir%\system32\notepad.exe" profile = current



