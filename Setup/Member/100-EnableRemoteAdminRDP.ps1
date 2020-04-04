# Enable RDP for Remote Administration
# https://docs.microsoft.com/en-us/windows-server/administration/server-core/server-core-manage


cscript.exe //nologo C:\Windows\System32\SCregEdit.wsf /ar 0 | Out-Null 

Set-Service -Name TermService -StartupType Automatic

#Start-Service -Name TermService 

