@ECHO OFF
REM Securing Windows Track :: SANS Institute :: Jason Fossen

REM mode = [ENABLE|DISABLE]
REM profile = [CURRENT|DOMAIN|STANDARD|ALL]


netsh.exe firewall set notifications mode = ENABLE profile = ALL
