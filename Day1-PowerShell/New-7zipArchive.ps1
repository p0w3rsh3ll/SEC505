####################################################################################
#.Synopsis
#    Crude wrapper for 7-Zip to make a password-encrypted archive.
#
#.Description
#    First uses RoboCopy.exe to make a copy of the folders and files to be
#    added to a 7-Zip (www.7-zip.org) archive encrypted with a password.
#    User will be prompted to paste in the password.  By design, the password
#    cannot be entered as an argument and the script cannot run hands-free, so 
#    no scheduled jobs (feel free to edit the script).  Supports backing up
#    only the files modified after a given date for the sake of differential
#    backups.  The script is just a crude wrapper for RoboCopy and 7-Zip,
#    originally intended for backing up to Amazon Glacier.  Please use a
#    password manager program like KeePass (www.keepass.info) to store your
#    25+ character password and to easily copy it to the clipboard.
#
#.Parameter DifferentialDate
#    For making differential backups, the file modification date after which
#    a file will be included in the archive.  Formatting must be YYYYMMDD.
#
#.Parameter SourceFolder
#    Folder which will be added to the archive.  Includes subfolders too.
#    Defaults to C:\Data as a place-holder and for testing.
#
#.Parameter ArchivePath
#    Full path and name of the 7z archive to be created.  Defaults to
#    .\BackupArchive.7z in the same folder as this script.  If the specified
#    file already exists, it will not be overwritten or modified.
#
#.Parameter TempFolder
#    Temp folder used to gather files to be added to the archive.  This
#    folder and its subfolders will be deleted afterwards, but not wiped.
#    The temp files are not moved into the Recycle Bin when deleted.
#    Defaults to $env:Temp\7ZipTempDirDeleteMe.
#
#.Parameter ExcludeFolder
#    Full path, folder name, or folder name with wildcard(s) which will
#    be excluded from the archive.  This is the argument given to the
#    /XD parameter of robocopy.exe when the temp folder is filled.
#    Defaults to nothing excluded. Only one folder path is allowed.
#
#.Example
#    New-7zipArchive.ps1 -SourceFolder C:\Data
#
#    Creates an archive named BackupArchive.7z in the present working
#    directory after prompting the user for a differential date and a
#    a password at least 25 characters long.  Source folder and all
#    subfolders will be included.  Only the files after the differential
#    date will be archived (just press enter to skip the date request).
#
#Requires -Version 2.0
#
#.Notes
#  Author: Jason Fossen, Enclave Consulting LLC (http://www.sans.org/sec505) 
# Version: 1.1
# Updated: 14.Jan.2014
#   LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF
#          ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
#          A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
#          THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
#          ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
#          LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
####################################################################################

param ($DifferentialDate = "0", $SourceFolder = "c:\data", $ArchivePath = ".\BackupArchive.7z", $TempFolder = "$env:Temp\7ZipTempDirDeleteMe", $ExcludeFolder = "js83iy23osmxoiu2mb1373czx83673ehs73hd73h8")


#Preliminary checks.
if (test-path $TempFolder) { cls ; "`nWARNING! The temp folder was not deleted last time: $TempFolder `n`nDelete it manually!`n" } 
if ( -not (test-path -Path "C:\Progra~1\7-Zip\7z.exe")) {"`nCannot find C:\Program Files\7-Zip\7z.exe, exiting...`n" ; exit }
if (test-path -path $ArchivePath) { "`n$ArchivePath already exists, it will not be overwritten, exiting...`n" ; exit }


#Get date for differential backups.
if ($DifferentialDate -eq "0")
{
    [string] $response = read-host "`nEnter the date (YYYYMMDD) for the differential backup, or just press Enter for a full backup"
    if ($response.length -ne 0)
    {
        if ($response -notmatch '^20[0-2][0-9][01][0-9][0-3][0-9]$') { "`nDifferentialDate must be in the form of YYYYMMDD, e.g., 20140809, exiting...`n" ; exit }
        $DifferentialDate = $response
    }
}


#Get encryption password, hide chars, test for length and illegal chars.
"`nYour encryption password must be 25+ characters."
"It should include numbers, uppercase letters and lowercase letters,"
"but it cannot include spaces or punctuation marks, except for the"  
"following marks, which are acceptable: % ^ * - _ = ! : # "   
"It's best if the password is stored in a password manager program,"
"copied into the clipboard, then pasted here into the shell."

$password = read-host -assecurestring -prompt "`nPaste the encryption password here"

if (test-path $env:systemroot\system32\clip.exe) { "Try to overwrite clipboard contents" | clip.exe } 

$password = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)  #Convert from "secure" string to plaintext.
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($password)     

if ($password -match '[^a-zA-Z0-9\%\-\=\!\:\#\^\*_]') { "`nIllegal character in password, exiting...`n" ; $password = "blank" ; exit }
if ($password.length -le 24) { "`nPassword too short, make it at least 25 characters, exiting...`n" ; $password = "blank" ; exit } 


#Copy files to be added to the archive to a temp folder so that robocopy can
#handle retries, locking issues, backup mode, excluded folders, etc.  Choose
#a temp folder carefully to avoid exposing files accidentally.  Feel free to
#change robocopy's arguments to copy permissions, use backup mode, EFS support, etc.
"`nRunning: robocopy.exe $SourceFolder $TempFolder /S /MAXAGE:$DifferentialDate /XD $ExcludeFolder"
robocopy.exe $SourceFolder $TempFolder /S /MAXAGE:$DifferentialDate /XD $ExcludeFolder


# Now encrypt with 7-Zip and these arguments:
#    a        = add to or create a new 7z archive.
#    -mx=1    = fastest compression.
#    -mhe     = encrypt file names too, not just file contents.
#    -p       = the encryption password (don't worry, quotes not included).
#    -t7z     = explicitly set archive type to 7z, not zip.
#    -r       = recurse subdirectories.

C:\Progra~1\7-Zip\7z.exe a $ArchivePath $($TempFolder + '\*') -r -t7z -mx=1 -mhe -p"$password"  

$password = "blank" #Not really necessary here or above, but it doesn't hurt.
dir $ArchivePath    #Show user the new 7z archive as a reminder.

#This could be a wipe instead of delete, but at least they don't go into the Recycle Bin.
del $TempFolder -Recurse -Force 

#Confirm that the temp folder really was deleted.
if (test-path $TempFolder) { Start-Sleep -Seconds 3 ; del $TempFolder -Recurse -Force }  #Maybe just a timing problem.
if (test-path $TempFolder) { cls ; "`nWARNING! The temp folder was NOT deleted: $TempFolder `n`n Delete it manually!`n`n" } 

"`nAre you sure you can open the archive in 7-Zip with your password?"
"This might be a good time to double-check...`n"

