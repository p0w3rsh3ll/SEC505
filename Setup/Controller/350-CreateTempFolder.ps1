###############################################################################
#
#"[+] Creating C:\Temp and placing some files there..."
#
# The existence of C:\Temp is mentioned in the PowerShell profile script.
# The *-Integrity files are used for Mandatory Integrity Control.
# The *-Integrity files are used in the Get-FileHash lab too.
# 
###############################################################################

new-item -type directory -path C:\Temp -force | out-null 

icacls.exe 'C:\Temp' /grant 'Everyone:(OI)(CI)F' | out-null

"This file has the Low integrity label." | out-file -filepath C:\Temp\Low-Integrity.txt
icacls.exe C:\Temp\Low-Integrity.txt /setintegritylevel low | out-null

"This file has the Medium integrity label." | out-file -filepath C:\Temp\Medium-Integrity.txt
icacls.exe C:\Temp\Medium-Integrity.txt /setintegritylevel medium | out-null 

"This file has the High integrity label." | out-file -filepath C:\Temp\High-Integrity.txt
icacls.exe C:\Temp\High-Integrity.txt /setintegritylevel high | out-null

