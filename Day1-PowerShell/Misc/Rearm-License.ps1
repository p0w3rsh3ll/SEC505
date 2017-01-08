# If the bottom right-hand corner of your desktop
# says "Licensed Expired" on your eval Windows 
# Server virtual machine, then run this script
# to extend the evaluation licensing period.  This
# also stops the hourly spontaneous reboots.


cscript.exe c:\windows\system32\slmgr.vbs /rearm


# You will need to reboot after running this script.

