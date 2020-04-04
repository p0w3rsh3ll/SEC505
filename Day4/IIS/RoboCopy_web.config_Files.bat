REM   Backing up just the web.config files is easy with the built-in
REM   robocopy.exe command-line tool.  This tool can recreate the
REM   directory structure of the website in order to make back up
REM   copies of the web.config files in their correct folders; the
REM   folders which do not contain a web.config file (directly or
REM   in any subdirectories) will not be recreated.

robocopy.exe C:\inetpub\wwwroot c:\backups\wwwroot web.config /S /PURGE



REM   You can also use network paths with shared folders:

robocopy.exe \\webserver\c$\inetpub \\backupserver\backups web.config /S /PURGE



REM   It's usually best to back up to a new folder named after the
REM   the source server, with a subdirectory named for the year, month, 
REM   day, hour and minute:

FOR /F "TOKENS=1*  EOL=/ DELIMS= "  %%A IN ('DATE.EXE /t') DO SET STARTDATE=%%B
FOR /F "TOKENS=1,2 EOL=/ DELIMS=/ " %%A IN ('DATE.EXE /t') DO SET MM=%%B
FOR /F "TOKENS=1,2 EOL=/ DELIMS=/"  %%A IN ('echo %STARTDATE%') DO SET DD=%%B
FOR /F "TOKENS=2,3 EOL=/ DELIMS=/ " %%A IN ('echo %STARTDATE%') DO SET YYYY=%%B
FOR /F "TOKENS=1,2 EOL=/ DELIMS=:"  %%A IN ('TIME.EXE /t') DO SET HH=%%A
FOR /F "TOKENS=1,2 EOL=/ DELIMS=: " %%A IN ('TIME.EXE /t') DO SET MIN=%%B

SET FOLDER=%YYYY%-%MM%-%DD%-%HH%-%MIN%

robocopy.exe \\webserver\c$\inetpub \\backupserver\backups\webserver\%%FOLDER%% web.config /S /PURGE



REM   Then at the backup server you could have a scheduled script run
REM   which deletes any backup set older than, say, 90 days.  This is
REM   much easier in PowerShell, so the following is PowerShell code
REM   using multiple where-object's to make it easier to read:

dir c:\backups\webserver | 
where { ($_.gettype().name -eq "DirectoryInfo") } |
where { ($_.creationtime -lt (get-date).adddays(-90)) } | 
remove-item -recurse -force 


REM   If you have multiple webservers who web.config files are being
REM   backed up, modify the above PowerShell code to work through each
REM   webserver's backup subdirectories separately.  
