@ECHO OFF
REM Securing Windows Track :: SANS Institute :: Jason Fossen

REM Create exceptions for ports on the Exceptions tab, along with custom scopes.
REM Protocol can be TCP, UDP or ALL (ALL option adds two exceptions, one for UDP, one for TCP).
REM Custom scope can include subnet mask in either dotted-decimal or CIDR format.




netsh.exe firewall add portopening protocol = all port = 53 name = DNS mode = enable profile = current scope = custom addresses = 10.7.7.7,10.1.1.7,192.168.0.0/255.255.0.0

netsh.exe firewall add portopening protocol = tcp port = 22 name = SSH mode = enable profile = current scope = custom addresses = 52.23.113.3,10.0.0.0/8



REM Now remove the excepted ports.
pause


netsh.exe firewall delete portopening protocol = tcp port = 53 profile = current
netsh.exe firewall delete portopening protocol = udp port = 53 profile = current
netsh.exe firewall delete portopening protocol = tcp port = 22 profile = current



