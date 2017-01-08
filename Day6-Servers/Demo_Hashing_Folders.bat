@echo OFF
REM **********************************************
REM *** Don't run this script from the CD-ROM. ***
REM *** Copy it to your hard drive first, and  ***
REM *** put MD5DEEP.EXE into the same folder   ***
REM *** or into the %PATH% beforehand.         ***
REM ***                                        ***
REM *** Get MD5DEEP.EXE for free from:         ***
REM ***      http://md5deep.sourceforge.net    ***
REM **********************************************

cls
echo.
echo.
echo   This script demonstrates the use of MD5DEEP.EXE to create
echo   MD5 hashes of all files in the c:\temp folder.  Using
echo   tools like this, it is possible to detect new files, deleted
echo   files and files which have been changed.  Even if you do not
echo   plan to use a tool like this in your own scripts, the same
echo   techniques are used by other graphical or commercial products
echo   for the same purpose, namely, to detect file system changes.
echo.
echo   Get MD5DEEP.EXE for free from http://md5deep.sourceforge.net 
echo.
echo   If the c:\temp folder does not exist, please create it now with
echo   with Windows Explorer.  If c:\temp is empty, please create
echo   an empty text file in that folder now named "somefile.txt". 
echo   Do this before proceeding any further please, I'll wait...
echo.
echo.
pause

REM Test that c:\temp exists and that c:\temp\hashes.txt does not exist.
if not exist c:\temp cls && echo. && echo The c:\temp folder does not exist, quitting. && goto DONE
if exist c:\temp\hashes.txt cls && echo. && echo You already have a c:\temp\hashes.txt file, quitting. && goto DONE

cd c:\temp
md5deep.exe -s c:\temp\* > hashes.txt 
cls
echo.
echo.
echo   An MD5 snapshot was taken of the folder by running:
echo     "md5deep.exe -s c:\temp\* > hashes.txt"
echo.
echo   Hit any key to have the contents of the hashes.txt file
echo   printed here in the command shell.  Glance at the output
echo   and then hit any key again to proceed.
echo.
echo.
pause
cls
echo.
echo.
echo type c:\temp\hashes.txt
echo.
type c:\temp\hashes.txt
echo.
echo.
pause

cls
echo.
echo.
echo   Now add a text file to the c:\temp folder, press any 
echo   key to continue, and the script will show the new file.
echo   The -X switch does the comparison, the -s switch
echo   suppresses status messages about directories...
echo.
echo.
pause
echo.
echo.
echo md5deep.exe -s -X hashes.txt c:\temp\*
echo.
md5deep.exe -s -X hashes.txt c:\temp\*
echo.
echo.
echo  Why did it also show the hashes.txt file?
echo  Because that's a new file too!
echo.
echo.
pause

cls
echo.
echo.
echo   Now change a file in the c:\temp folder, press any key
echo   to continue, and the script will show the edited file.
echo   You can edit the same file you created a few moments
echo   ago if you wish, or edit a different file for grins.
echo.
echo.
pause
echo.
echo.
echo md5deep.exe -s -X hashes.txt c:\temp\*
echo.
md5deep.exe -s -X hashes.txt c:\temp\*
echo.
echo.
pause

cls
md5deep.exe -s c:\temp\* > hashes.txt 
echo.
echo.
echo   A new hashes.txt file was just made of the folder, overwriting the
echo   prior one you saw in Notepad.  The new hashes.txt includes your new
echo   file.  Now delete that new file you added, press any key to 
echo   continue, and the script will show the missing file (-n switch).
echo.
echo.
pause
echo.
echo.
echo md5deep.exe -s -n -X hashes.txt c:\temp\*
echo.
md5deep.exe -s -n -X hashes.txt c:\temp\*
echo.
echo.
pause


del hashes.txt
cls
echo md5deep.exe -h
echo.
md5deep.exe -h
echo.
echo.
echo.
echo   ******************************************************************
echo    That's it!  Look at the other command-line switches above, and
echo    perhaps experiment with hashing other (larger) folders too.
echo   ******************************************************************
echo.
echo.

:DONE
