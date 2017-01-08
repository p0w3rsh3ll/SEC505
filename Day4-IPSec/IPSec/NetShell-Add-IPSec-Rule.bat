@ECHO OFF
REM # The following command will created, but not enable, a new IPSec connection security rule 
REM # on Windows Vista and later operating systems.  It uses a pre-shared key to authenticate.
REM # It applies only to TCP ports 3389,139,135,445,21,20,23 on the local subnet only.
REM # If you want to test using the rule, enable it in the Windows Firewall graphical tool.


netsh.exe advfirewall consec add rule name=Testing-IPSec-NETSH endpoint1=any port1=any endpoint2=localsubnet port2=3389,135,139,445,21,20,23 protocol=tcp profile=any action=requireinrequestout interfacetype=any auth1=computerpsk auth1psk=ThePreSharedKey enable=no





REM # To delete the above rule, run the following command:
REM # netsh.exe advfirewall consec delete rule name=Testing-IPSec



