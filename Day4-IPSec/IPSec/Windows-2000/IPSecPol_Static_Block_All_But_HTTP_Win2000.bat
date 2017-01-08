REM This is a static policy that does survive reboots.
REM IPsec policy created in local registry only, not AD.
REM This is intended only for Windows 2000 systems, not XP or 2003.

ipsecpol -w REG -p "MyPol" -y -o
ipsecpol -w REG -p "MyPol" -r "Blocker" -n BLOCK -x -f 0+*
ipsecpol -w REG -p "MyPol" -r "GoHTTP"  -n PASS  -x -f 0:80+*::TCP
ipsecpol -w REG -p "MyPol" -r "GoHTTPS" -n PASS  -x -f 0:443+*::TCP




