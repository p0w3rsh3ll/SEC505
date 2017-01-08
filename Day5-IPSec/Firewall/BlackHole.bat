@ECHO OFF
REM **************************************************************************
REM     Name: BlackHole.bat
REM  Version: 1.0 (24.Aug.2005)
REM   Author: Jason Fossen (http://www.sans.org/windows-security) 
REM  Purpose: Manages "blackholed" IP address routes in the route table.  Such
REM           routes point to a non-existent gateway, thus preventing access
REM           to the blackholed IP address from or through the local machine.
REM           Requires Windows XP or later.
REM     Note: None of the routes added are persistent.  You must edit the
REM           variable named BLACKHOLE below to make the script work.
REM    Legal: SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY 
REM           KIND. USE AT YOUR OWN RISK.  Public domain.  No rights reserved. 
REM **************************************************************************
SETLOCAL


REM **************************************************************************
REM The BLACKHOLE variable is the bogus gateway to which blackholed packets will 
REM be unsuccessfully sent, thus making those packets just disappear.

SET BLACKHOLE=172.16.218.99

REM You must change it to an IP address which is not in use on your network and
REM which is on the same subnet as one of the interfaces of the computer.  For
REM example, if the computer has an internal IP address and subnet mask of
REM 10.82.0.1/255.255.0.0 then you could choose 10.82.99.1, assuming that this IP
REM address is not in use and will not be leased out through DHCP/BOOTP.  If you
REM find that your selected IP address has become active, just run the script with
REM the /removeall switch first, then modify the BLACKHOLE variable with the new IP
REM address and add the entries backagain.  Note that a bogus ARP entry will be 
REM created for the blackhole IP address, but the /removeall switch will remove it. 
REM **************************************************************************









IF "%1" == "/l"              GOTO LISTROUTES
IF "%1" == "/list"           GOTO LISTROUTES
IF "%1" == "/LIST"           GOTO LISTROUTES
IF "%1" == "list"            GOTO LISTROUTES

IF "%1" == "/a"              CALL :ADDROUTE %2 %3
IF "%1" == "/add"            CALL :ADDROUTE %2 %3
IF "%1" == "/ADD"            CALL :ADDROUTE %2 %3
IF "%1" == "add"             CALL :ADDROUTE %2 %3

IF "%1" == "/r"              CALL :REMOVEROUTE %2 %3
IF "%1" == "/remove"         CALL :REMOVEROUTE %2 %3
IF "%1" == "/REMOVE"         CALL :REMOVEROUTE %2 %3
IF "%1" == "remove"          CALL :REMOVEROUTE %2 %3

IF "%1" == "/fileadd"        GOTO FILEADD
IF "%1" == "/FILEADD"        GOTO FILEADD
IF "%1" == "fileadd"         GOTO FILEADD

IF "%1" == "/fileremove"     GOTO FILEREMOVE
IF "%1" == "/FILEREMOVE"     GOTO FILEREMOVE
IF "%1" == "fileremove"      GOTO FILEREMOVE

IF "%1" == "/removeall"      GOTO REMOVEALL
IF "%1" == "/REMOVEALL"      GOTO REMOVEALL
IF "%1" == "removeall"       GOTO REMOVEALL

IF "%1" == "/?"              GOTO SHOWHELPANDQUIT
IF "%1" == "/h"              GOTO SHOWHELPANDQUIT
IF "%1" == "-h"              GOTO SHOWHELPANDQUIT
IF "%1" == "/help"           GOTO SHOWHELPANDQUIT
IF "%1" == "-help"           GOTO SHOWHELPANDQUIT
IF "%1" == "--help"          GOTO SHOWHELPANDQUIT

GOTO QUIT



REM **************************************************************************
:LISTROUTES
ECHO.
ECHO The following IP addresses are currently being blackholed (list may be empty):
ECHO. > %TEMP%\tmp-safetodelete-1.txt
ECHO. > %TEMP%\tmp-safetodelete-2.txt
route.exe print|find.exe "%BLACKHOLE%" >> %TEMP%\tmp-safetodelete-1.txt 
FOR /F "tokens=1,2" %%i IN (%TEMP%\tmp-safetodelete-1.txt) DO ECHO %%i %%j >> %TEMP%\tmp-safetodelete-2.txt
sort.exe %TEMP%\tmp-safetodelete-2.txt
ECHO.
ECHO The BLACKHOLE variable in this script is set to %BLACKHOLE%
arp.exe -a | find.exe "%BLACKHOLE%" 
ping.exe -n 1 -w 50 %BLACKHOLE% 1>nul 2>nul
IF %ERRORLEVEL% == 0 ECHO. && ECHO WARNING! Your blackhole IP address is PINGable!! && ECHO This is NOT how you should use this script. && ECHO Change the BLACKHOLE variable to an inactive IP address!
DEL /F %TEMP%\tmp-safetodelete-1.txt 1>nul 2>nul
DEL /F %TEMP%\tmp-safetodelete-2.txt 1>nul 2>nul
GOTO QUIT



REM **************************************************************************
:FILEADD
FOR /F "eol=# tokens=1,2 delims=/ " %%i IN (%2) DO CALL :ADDROUTE %%i %%j
GOTO QUIT



REM **************************************************************************
:FILEREMOVE
FOR /F "eol=# tokens=1,2 delims=/ " %%i IN (%2) DO CALL :REMOVEROUTE %%i %%j
GOTO QUIT



REM **************************************************************************
REM ADDROUTE is only called as a procedure, hence, %1 is the first argument passed in.
REM **************************************************************************
:ADDROUTE
SET IP=%1
SET MASK=%2 
IF "%MASK%" == " " SET MASK=255.255.255.255
REM  Add/update a static ARP entry for the blackhole IP address where the hardware address couldn't
REM  exist based on the list of vendors from http://standards.ieee.org/regauth/oui/oui.txt
arp.exe -s %BLACKHOLE% e9-f2-9b-12-c3-77 1>nul 2>nul
REM  Check that the route doesn't already exist.
route.exe print | find.exe "%IP%" | find.exe "%MASK%" 1>nul 2>nul 
IF %ERRORLEVEL% == 0 ECHO. && ECHO %IP% %MASK% already exists in the route table. Nothing changed. && GOTO QUIT
route.exe add %IP% mask %MASK% %BLACKHOLE% 1>nul 2>%TEMP%\tmp-safetodelete-3.txt 
FOR /F %%i IN (%TEMP%\tmp-safetodelete-3.txt) DO ECHO. && ECHO Problem adding the blackhole route. && TYPE %TEMP%\tmp-safetodelete-3.txt && SET DUDE=x
IF NOT DEFINED DUDE ECHO. && ECHO %IP% %MASK% successfully blackholed in the route table.
SET DUDE=
DEL /F %TEMP%\tmp-safetodelete-3.txt
GOTO QUIT



REM **************************************************************************
REM REMOVEROUTE is only called as a procedure, hence, %1 is the argument passed in.
REM **************************************************************************
:REMOVEROUTE
SET IP=%1
SET MASK=%2 
IF "%MASK%" == " " SET MASK=255.255.255.255
REM  Check that the route exists first.
route.exe print | find.exe "%IP%" | find.exe "%MASK%" | find.exe "%BLACKHOLE%" 1>nul 2>nul
IF NOT %ERRORLEVEL% == 0 ECHO. && ECHO %IP% %MASK% does not appear to be blackholed. Nothing changed. && GOTO QUIT
route.exe delete %IP% mask %MASK% %BLACKHOLE%
IF %ERRORLEVEL% == 0 ECHO. && ECHO %IP% %MASK% successfully un-blackholed from the route table.
GOTO QUIT



REM **************************************************************************
:REMOVEALL
ECHO. > %TEMP%\tmp-safetodelete-1.txt
route.exe print | find.exe "%BLACKHOLE%" >> %TEMP%\tmp-safetodelete-1.txt 
FOR /F "eol=# tokens=1,2" %%i IN (%TEMP%\tmp-safetodelete-1.txt) DO CALL :REMOVEROUTE %%i %%j 
arp.exe -d "%BLACKHOLE%" 1>nul 2>nul 
del /F %TEMP%\tmp-safetodelete-1.txt 1>nul 2>nul
GOTO QUIT



REM **************************************************************************
:SHOWHELPANDQUIT
REM First try to ping BLACKHOLE and complain if it is pingable, then show help.
ping.exe -n 1 -w 200 %BLACKHOLE% 1>nul 2>nul
IF %ERRORLEVEL% == 0 ECHO. && ECHO NOTICE! The blackhole IP address configured in this script is PINGable! && ECHO Change it to an inactive IP address before using. Open this script in && ECHO a text editor to change the BLACKHOLE variable. && ECHO.

ECHO. 
ECHO BLACKHOLE.BAT /list
ECHO BLACKHOLE.BAT /add ipaddress
ECHO BLACKHOLE.BAT /add ipaddress netmask  
ECHO BLACKHOLE.BAT /remove ipaddress 
ECHO BLACKHOLE.BAT /remove ipaddress netmask 
ECHO BLACKHOLE.BAT /fileadd file.txt
ECHO BLACKHOLE.BAT /fileremove file.txt
ECHO BLACKHOLE.BAT /removeall
ECHO BLACKHOLE.BAT /?
ECHO. 
ECHO Purpose: Manages "blackholed" IP addresses in the route table. Blackholed IP 
ECHO          addresses are routed to a non-existent gateway, hence, packets
ECHO          sent to these addresses do not reach their destination.  Blackholing
ECHO          an address is a quick, easy and temporary way to stop communication
ECHO          to an unwanted internal or external host.  It is easily reversible
ECHO          and does not disrupt any other on-going communications.  None of the
ECHO          routes added by this script are persistent.  
ECHO.          
ECHO    Note: You must edit the BLACKHOLE variable at the top of the script to set
ECHO          the IP address for your non-existent gateway.  Just choose any IP
ECHO          address that is not in use, will not be used, and appears to be on
ECHO          the same subnet as one of the interfaces of the local machine.  If 
ECHO          you don't know how to examine your IP addresses and subnet masks in
ECHO          order to do this, you probably should not use this script.
ECHO.          
ECHO    Args: /LIST -- Lists all currently blackholed IP address routes.
ECHO.    
ECHO          /ADD ipaddress -- Adds ipaddress to the list of blackholed routes with
ECHO                            a netmask of 255.255.255.255 (i.e., single IP) or
ECHO                            specify a different netmask, e.g., 255.255.0.0.
ECHO.    
ECHO          /REMOVE ipaddress -- Removes ipaddress from list of blackholed routes
ECHO                               with a netmask of 255.255.255.255, or specify a
ECHO                               different netmask as the third argument.
ECHO.          
ECHO          /FILEADD file.txt -- Parses file.txt and adds each IP address in it
ECHO                               to the list of blackholed routes.  Any blank
ECHO                               and commented lines (#) are ignored. If no  
ECHO.                              netmask is specified, 255.255.255.255 is
ECHO                               assumed. Specify a netmask by separating it from
ECHO                               the IP address with a space or forward slash,
ECHO                               e.g., 10.0.0.0 255.0.0.0, or, 10.0.0.0/255.0.0.0
ECHO. 
ECHO          /FILEREMOVE file.txt -- Parses file.txt and removes each IP address
ECHO                                  found from the list of blackholed routes.
ECHO                                  Blank and commented lines (#) are ignored.
ECHO                                  If no netmask is specified, 255.255.255.255
ECHO                                  is assumed. Specify a different netmask by
ECHO                                  separating it from the IP address with a
ECHO                                  space or forwardslash.
ECHO.                                      
ECHO          /REMOVEALL -- Removes all blackholed routes and removes the static
ECHO                        arp.exe entry for the bogus BLACKHOLE IP address. Use
ECHO                        this before changing the BLACKHOLE variable again.
ECHO.          
ECHO   Legal: SCRIPT PROVIDED "AS IS" AND WITHOUT WARRANTIES OR GUARANTEES OF ANY
ECHO          KIND. USE AT YOUR OWN RISK. Public domain. No rights reserved.      
ECHO          ( www.sans.org )
GOTO QUIT   

REM **************************************************************************
:QUIT
ENDLOCAL
ECHO.
