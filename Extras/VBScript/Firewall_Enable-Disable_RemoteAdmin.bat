@ECHO OFF
REM Securing Windows Track :: SANS Institute :: Jason Fossen

REM The firewall "services" are factory-configured sets of settings.
REM Type = [FILEANDPRINT, REMOTEADMIN, REMOTEDESKTOP, UPNP, ALL]
REM Changes to these "service types" are not reflected in the WF Control Panel applet.




REM Enable the remote admin feature and limit its scope:

netsh.exe firewall set service type = remoteadmin mode = enable profile = all scope = custom addresses = 10.0.0.0/8




REM Disable the remote administration feature:
pause


netsh.exe firewall set service type = remoteadmin mode = disable profile = all



