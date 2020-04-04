###############################################################################
#
#"[+] Copying more files into C:\Temp..."
#
###############################################################################

# Needed for lab on SAT stealing:
Copy-Item -Path ".\Resources\incognito\incognito.exe" -Destination C:\Temp -Force 
copy-item -Path ".\Resources\incognito\run-incognito.ps1" -Destination C:\Temp -Force 

# Needed for Get-FileHash lab in PKI manual:
Copy-Item -Path ".\Resources\Scripts\Compare-FileHashesList.ps1" -Destination C:\Temp -Force

# Not currently required for any labs?
Copy-Item -Path ".\Resources\MD5deep\md5deep.exe" -Destination C:\Temp -Force 
Copy-Item -Path ".\Resources\netcat\nc.exe" -Destination C:\Temp -Force 
Copy-Item -Path ".\Resources\chml\chml.exe" -Destination C:\Temp -Force  #Often demoed in class.

