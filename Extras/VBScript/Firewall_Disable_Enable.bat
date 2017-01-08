@ECHO OFF
REM Securing Windows Track :: SANS Institute :: Jason Fossen

REM This is for the firewall in Windows Vista, Server 2008 and later only (not XP).


REM   Disables the firewall for all profiles.

netsh.exe advfirewall set allprofiles state off

REM   Enables the firewall for all profiles.

netsh.exe advfirewall set allprofiles state on





