<# 
#######################################################################
.SYNOPSIS
Manage PowerShell script block and transcription logging.

.DESCRIPTION
Windows PowerShell 5.0 and later includes enhanced logging capabilities,
but they are not enabled by default.  This script simplifies setting
the necessary registry values for script block logging and transcription
logging, but not other types of logging, such as module logging.  

PowerShell Core 7.0 and later can read and use these same values if it 
is configured to do so; by default, PowerShell Core does not do this.

.PARAMETER DisableLogging
Disables script block logging and transcription logging only.

.PARAMETER OutputDirectory
An optional directory path where all transcription logs will be written 
for all users of the machine.  By default, the transcription logging path 
is $env:USERPROFILE\Documents\<Date>\ for each user separately.  This
is also the default for this script.  If a directory path is given and
the directory does not exist, this script will create that directory
and attempt to enable NTFS compression on it.  
 
.NOTES
When the $DisableLogging switch is used, the current output directory
for transcription logging is not modified, just in case transcription
logging is enabled again later.

Why does this script use REG.EXE instead of the *-Item* cmdlets?
Because REG.EXE is simpler and safer.  Simpler, because REG.EXE can
create an entire path to a new value, or set that existing value, with
one short command.  Safer, because you can accidentally delete other
keys and values with New-Item.  REG.EXE is better in other ways too
for bulk registry management (see REG.EXE /?).  The main hassle of
REG.EXE, though, is dealing with quotes when it is invoked.

Legal: Public Domain, no warranties or guarantees whatsoever.
Author: JF@Enclave
Date: 22.Jan.2020
TODO: Switch set recommended NTFS ACL too?
#######################################################################
#>

Param ([Switch] $DisableLogging,
       [String] $OutputDirectory = "") 


if ($DisableLogging)
{
    # Disable script block logging:
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 0 /f 1>$null
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockInvocationLogging /t REG_DWORD /d 0 /f 1>$null

    # Disable transcription logging with invocation header:
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableTranscripting /t REG_DWORD /d 0 /f 1>$null
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableInvocationHeader /t REG_DWORD /d 0 /f 1>$null

    # Do not change the transcription logging output directory value here.

    Exit
}


# Enable script block logging, but not invocations:
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f 1>$null
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockInvocationLogging /t REG_DWORD /d 0 /f 1>$null


# Enable transcription logging with invocation header:
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableTranscripting /t REG_DWORD /d 1 /f 1>$null
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableInvocationHeader /t REG_DWORD /d 1 /f 1>$null

# Set the output directory for transcription logging:
if ($OutputDirectory.Trim().Length -eq 0)
{
    reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /f /v OutputDirectory *>$null
}
else
{
    # If the folder doesn't exist, create it and enable NTFS compression on it:
    if (-not (Test-Path -Path $OutputDirectory))
    {
        $Folder = New-Item -ItemType Directory -Path $OutputDirectory -ErrorAction Stop 

        $Folder = $Folder.FullName -Replace "\\","\\"
        $Folder = "'" + $Folder + "'"
        $Folder = Get-CimInstance -ClassName Win32_Directory -Filter ("Name = $Folder") -ErrorAction SilentlyContinue
        Invoke-CimMethod -InputObject $Folder -MethodName Compress -ErrorAction SilentlyContinue *>$null
    }

    #If directory path ends with a "\", trim that off so the registry value created is clean:
    if ($OutputDirectory -match'\\$')
    { $OutputDirectory = $OutputDirectory.Substring(0, ($OutputDirectory.Length - 1) ) }

    #Might include space characters:
    $OutputDirectory = '"' + $OutputDirectory + '"'

    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v OutputDirectory /t REG_SZ /f /d $OutputDirectory 1>$null
}

