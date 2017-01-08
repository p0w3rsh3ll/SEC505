# http://technet.microsoft.com/en-us/magazine/2007.01.cableguy.aspx





# To disable TCP/IP autotunning, in an elevated CMD shell run:

netsh.exe interface tcp set global autotuninglevel=disabled



# To see current TCP global settings and to confirm 
# that "Receive Window Auto-Tuning Level" is disabled:

netsh.exe interface tcp show global



# To reset the default:
# netsh.exe interface tcp set global autotuninglevel=normal





