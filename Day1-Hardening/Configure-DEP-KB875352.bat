REM To check the system-wide DEP status from the command line on Vista/2008 and later:

bcdedit.exe | findstr.exe nx


REM To set the system-wide DEP status to OptOut on Vista/2008 and later:

bcdedit.exe /set nx optout





REM To check DEP status in the Control Panel, 
REM   open the System applet > 
REM   Advanced System Settings link > 
REM   Advanced tab > 
REM   Performance Settings button > 
REM   Data Execution Prevention tab.  


