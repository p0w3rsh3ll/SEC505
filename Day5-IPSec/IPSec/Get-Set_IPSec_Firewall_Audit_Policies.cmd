@ECHO OFF 
REM This only works on Vista and later computers.
REM Displays and configures (if you un-REM the appropriate lines) audit policies related to IPSec and the Windows Firewall.




ECHO *********************************************************************
ECHO Show all audit policy subcategories:
ECHO *********************************************************************
auditpol.exe /get /category:*


ECHO.
ECHO.
ECHO *********************************************************************
ECHO Show audit subcategories related to IPSec and the Windows Firewall:
ECHO *********************************************************************
auditpol.exe /get /subcategory:"MPSSVC rule-level Policy Change,Filtering Platform policy change,IPsec Main Mode,IPsec Quick Mode,IPsec Extended Mode,IPsec Driver,Other System Events,Filtering Platform Packet Drop,Filtering Platform Connection"


REM Enable audit subcategories related to IPSec and the Windows Firewall:

REM auditpol.exe /set /subcategory:"MPSSVC rule-level Policy Change,Filtering Platform policy change,IPsec Main Mode,IPsec Quick Mode,IPsec Extended Mode,IPsec Driver,Other System Events,Filtering Platform Packet Drop,Filtering Platform Connection" /success:enable /failure:enable



REM Disable audit subcategories related to IPSec and the Windows Firewall (consumes drive space):

REM auditpol.exe /set /subcategory:"MPSSVC rule-level Policy Change,Filtering Platform policy change,IPsec Main Mode,IPsec Quick Mode,IPsec Extended Mode,IPsec Driver,Other System Events,Filtering Platform Packet Drop,Filtering Platform Connection" /success:disable /failure:disable



