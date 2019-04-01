# Retrieves just the warning events from the AppLocker logs.  These events are logged when
# AppLocker blocks or would have blocked (in audit mode) a process, script, DLL or package.

Get-WinEvent -Filterhashtable @{ LogName='Microsoft-Windows-AppLocker/EXE and DLL' ; Level=3 } -ErrorAction SilentlyContinue
Get-WinEvent -Filterhashtable @{ LogName='Microsoft-Windows-AppLocker/MSI and Script' ; Level=3 } -ErrorAction SilentlyContinue
Get-WinEvent -Filterhashtable @{ LogName='Microsoft-Windows-AppLocker/Packaged app-Deployment' ; Level=3 } -ErrorAction SilentlyContinue
Get-WinEvent -Filterhashtable @{ LogName='Microsoft-Windows-AppLocker/Packaged app-Execution' ; Level=3 } -ErrorAction SilentlyContinue


