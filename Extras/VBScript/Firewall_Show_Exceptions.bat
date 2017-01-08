@ECHO OFF
REM Securing Windows Track :: SANS Institute :: Jason Fossen




REM Show list of unblocked/exceptioned ports:

netsh.exe firewall show portopening




REM Show list of unblocked/excepted programs:

netsh.exe firewall show allowedprogram



