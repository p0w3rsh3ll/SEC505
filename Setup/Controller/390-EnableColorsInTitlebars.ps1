###############################################################################
#
#"[+] Enabling color in titlebars..."
#
###############################################################################

reg.exe add HKCU\Software\Microsoft\Windows\DWM /v ColorPrevalence /t REG_DWORD /d 1 /f | Out-Null

