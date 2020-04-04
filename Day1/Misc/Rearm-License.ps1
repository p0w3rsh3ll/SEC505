# If the bottom right-hand corner of your desktop
# says "Licensed Expired" on your eval Windows 
# Server virtual machine, then run this script
# to extend the evaluation licensing period.  This
# also stops the hourly spontaneous reboots.


# Display current time remaining and rearm count:
cscript.exe C:\windows\system32\slmgr.vbs /dlv | select-string -Pattern 'rearm|remaining' 

# Extend eval license by 10 days:
cscript.exe c:\windows\system32\slmgr.vbs /rearm


"`n`n You will need to reboot after running this script.`n`n" 



