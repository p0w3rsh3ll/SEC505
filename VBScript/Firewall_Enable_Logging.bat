@ECHO OFF
REM Securing Windows Track :: SANS Institute :: Jason Fossen

netsh.exe firewall set logging filelocation = %WinDir%\pfirewall.log maxfilesize = 10053 droppedpackets = ENABLE connections = DISABLE 


