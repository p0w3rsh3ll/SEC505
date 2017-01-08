@echo off
REM ********************************************************
REM  Just a silly batch script for quickly finding files or
REM  or folders in subdirectories. First argument is a
REM  string to find in the full paths of all files in the
REM  current folder and all subdirectories underneath it.
REM  Don't use any wildcards like "*" or "?", and don't put
REM  the search string inside of quotes even if there are
REM  space characters in the search string.  And, yes, I'm 
REM  too lazy to type in the full piped command every time...
REM  Put it in your PATH, such as in C:\windows\system32\
REM ********************************************************

if "%1"=="" goto HELPTEXT
if "%1"=="/?" goto HELPTEXT

echo.
dir /s /b | find.exe /i "%*"
echo.
goto END

:HELPTEXT
echo.
echo FINDFILES.BAT string
echo.
echo Enter a string to find in the names of folders or files
echo in the current directory and all subdirectories below it.
echo Don't use wildcards like "*" or "?", and don't put the 
echo string in quotes even though there might be spaces in it.
echo.

:END
