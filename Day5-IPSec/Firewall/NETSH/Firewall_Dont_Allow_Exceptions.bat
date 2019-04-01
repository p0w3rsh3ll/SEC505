@ECHO OFF
REM Securing Windows Track :: SANS Institute :: Jason Fossen

REM Enable "panic mode" such that no in-coming connections are permitted.
REM Checks the "Don't Allow Exceptions" box on the General tab of the Windows Firewall applet.
REM Set "exceptions = enable" to uncheck that box.



netsh.exe firewall set opmode mode = enable exceptions = disable

