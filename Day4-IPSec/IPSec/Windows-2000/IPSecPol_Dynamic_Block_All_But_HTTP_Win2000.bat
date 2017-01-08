REM You can also put the filter items on a single line if preferred.
REM Use "ipsecpol.exe -u" to remove the settings.
REM This is intended only for Windows 2000, not XP or 2003.

ipsecpol.exe \\127.0.0.1 -u
ipsecpol.exe \\127.0.0.1 -f [0+*]
ipsecpol.exe \\127.0.0.1 -f (0:80+*::TCP)
ipsecpol.exe \\127.0.0.1 -f (0:443+*::TCP)

