###############################################################################
#
#"[+] Creating C:\Classified-Files and placing some files there..."
#
# Needed for Dynamic Access Control (DAC).
#
###############################################################################

new-item -type directory -path C:\Classified-Files -force | out-null 
icacls.exe 'C:\Classified-Files' /grant 'Everyone:(OI)(CI)F' | out-null

"Do not edit the properties of this file please."   | out-file -filepath C:\Classified-Files\TradeSecrets.txt
"Do not edit the properties of this file please."   | out-file -filepath C:\Classified-Files\HumanResources.txt
"Feel free to do anything you wish with this file." | out-file -filepath C:\Classified-Files\ExperimentalData.txt

