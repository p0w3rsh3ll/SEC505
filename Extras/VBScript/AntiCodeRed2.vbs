'***********************************************************************************
' Script Name: AntiCodeRed2.vbs
'     Version: 1.7
'      Author: Jason Fossen, Enclave Consulting LLC, The SANS Institute
'Last Updated: 8/11/01
'     Purpose: Reverse out changes made by Code Red 2 worm on IIS 5.0 servers.
'       Usage: The script is independent of CSCRIPT.EXE or WSCRIPT.EXE, so it can
'              be simply double-clicked or run from the command-line.  Use the
'              "/?" switch at the command-line to get more options.
'       Notes: This script is part of the 5-day "Securing Windows 2000" series of
'              seminars provided by the SANS Institute (www.sans.org).
'    Keywords: IIS, Code Red, CodeRed2, worm, SANS, Fossen
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Be
'              aware that further server compromise may have occured subsequent to
'              the first infection since Code Red 2 installs a Trojan.  You should 
'              reformat all drives on infected systems and reinstall the OS if
'              you have any concerns.  Note that the SANS Institute cannot provide
'              technical support for the myriad different configurations of systems
'              for tens of thousands of users on the Internet who have been infected.
'***********************************************************************************
'     Details: This script can do the following, depending on options selected:
'                Prompt the user with a GUI pop-up dialog box to automatically
'                    print on the default printer information about patch URLs, etc.
'                Give the user an easy-to-read summary of "Worm Signs" remaining, i.e.,
'                    the user should see "Worm Signs Count = 0" when the script is done.
'                Delete c:\explorer.exe
'                Delete d:\explorer.exe
'                Delete c:\Inetpub\scripts\root.exe
'                Delete d:\Inetpub\scripts\root.exe
'                Delete c:\progra~1\common~1\system\MSADC\root.exe
'                Delete d:\progra~1\common~1\system\MSADC\root.exe
'                Delete any /C or /D virtual IIS folders from registry.
'                Delete any /C or /D virtual IIS folders from metabase,
'                    by enumerating through all installed websites, no limit.
'                Reset the default permissions on /Scripts and /MSADC in
'                    every website enumerated.  The script does not simply
'                    delete the mappings because people are using them!  Besides,
'                    a fix is supposed to return a box to its configuration
'                    before the infection, not re-configure the box.
'                Resets the SFCDisable registry value to its default (0, or "On")
'                    but only if it had been set to 0xFFFFFF9D.  There are 
'                    legitimate reasons to sometimes change the default, so this
'                    script will not override the user's decision to change the default.
'                Write an event to the Application event log with results summary.
'                Write to standard-out a summary of results (can be redirected).
'                Supports a "/silent" command-line switch suitable for Group Policy use.
'                Supports a "/disable" switch to stop and disable the IIS service.
'***********************************************************************************
On Error Resume Next


'***********************************************************************************
' sPatchInfo displays instructions and URLs to patches.
'***********************************************************************************
             sPatchInfo = vbCrLf & vbCrLf
sPatchInfo = sPatchInfo & "Code Red II Information and Patches:" & vbCrLf
sPatchInfo = sPatchInfo & "------------------------------------------" & vbCrLf
sPatchInfo = sPatchInfo & "At a minimum, you must obtain two patches from Microsoft in order to" & vbCrLf
sPatchInfo = sPatchInfo & "defend your servers against the Code Red worm, version 2 and earlier." & vbCrLf
sPatchInfo = sPatchInfo & "These patches are free and easy to install.  The URL's below give" & vbCrLf
sPatchInfo = sPatchInfo & "instructions and additional information.  You can also visit" & vbCrLf
sPatchInfo = sPatchInfo & "http://www.digitalisland.com/codered/ for more information and help," & vbCrLf
sPatchInfo = sPatchInfo & "including a free 30-minute PowerPoint presentation with audio." & vbCrLf
sPatchInfo = sPatchInfo & " " & vbCrLf
sPatchInfo = sPatchInfo & " " & vbCrLf
sPatchInfo = sPatchInfo & "PATCH ONE: " & vbCrLf 
sPatchInfo = sPatchInfo & "   http://www.microsoft.com/technet/security/bulletin/MS01-033.asp" & vbCrLf
sPatchInfo = sPatchInfo & "   Microsoft Security Bulletin MS01-033" & vbCrLf
sPatchInfo = sPatchInfo & "   Unchecked Buffer In Index ISAPI Extension Could Enable Web Server Compromise" & vbCrLf
sPatchInfo = sPatchInfo & " " & vbCrLf
sPatchInfo = sPatchInfo & "PATCH TWO:" & vbCrLf
sPatchInfo = sPatchInfo & "   http://www.microsoft.com/technet/security/bulletin/MS00-052.asp" & vbCrLf
sPatchInfo = sPatchInfo & "   Microsoft Security Bulletin MS00-052" & vbCrLf
sPatchInfo = sPatchInfo & "   Patch Available for Relative Shell Path Vulnerability" & vbCrLf
sPatchInfo = sPatchInfo & " " & vbCrLf
sPatchInfo = sPatchInfo & " " & vbCrLf
sPatchInfo = sPatchInfo & "INSTRUCTIONS:" & vbCrLf
sPatchInfo = sPatchInfo & "1) Disconnect server from the Internet immediately." & vbCrLf
sPatchInfo = sPatchInfo & "2) Obtain both of the above patches." & vbCrLf
sPatchInfo = sPatchInfo & "3) Run script on server." & vbCrLf
sPatchInfo = sPatchInfo & "4) Reboot server." & vbCrLf
sPatchInfo = sPatchInfo & "5) Apply both patches, rebooting as necessary, but reboot at least" & vbCrLf
sPatchInfo = sPatchInfo & "   once after both patches have been applied." & vbCrLf
sPatchInfo = sPatchInfo & "6) Run script again." & vbCrLf
sPatchInfo = sPatchInfo & "7) Reboot again." & vbCrLf
sPatchInfo = sPatchInfo & "8) Run script again.  It should report ""Worm Sign Count = 0""" & vbCrLf
sPatchInfo = sPatchInfo & "9) Update your virus definition file for your virus scanner." & vbCrLf
sPatchInfo = sPatchInfo & " " & vbCrLf
sPatchInfo = sPatchInfo & "IMPORTANT:" & vbCrLf
sPatchInfo = sPatchInfo & "Do not forget that you are choosing to ATTEMPT to clean your server" & vbCrLf
sPatchInfo = sPatchInfo & "of all worms, Trojan Horses, and other hostile software.  If an" & vbCrLf
sPatchInfo = sPatchInfo & "attacker has already executed commands on your server through the" & vbCrLf
sPatchInfo = sPatchInfo & "Trojan installed by Code Red, then this script and the above patches" & vbCrLf
sPatchInfo = sPatchInfo & "will NOT secure your server.  By not reformatting your hard drives" & vbCrLf
sPatchInfo = sPatchInfo & "and reinstalling, you are essentially BETTING your server and your" & vbCrLf
sPatchInfo = sPatchInfo & "network's security against the odds that you have not been further" & vbCrLf
sPatchInfo = sPatchInfo & "compromised by other attackers or worms that are using the Trojan" & vbCrLf
sPatchInfo = sPatchInfo & "installed by Code Red.  THE RESPONSIBILITY IS YOURS!" & vbCrLf
sPatchInfo = sPatchInfo & " " & vbCrLf
sPatchInfo = sPatchInfo & "LEGAL:" & vbCrLf
sPatchInfo = sPatchInfo & "The SANS Institute provides no warranties or guarantees of the " & vbCrLf
sPatchInfo = sPatchInfo & "effectiveness of this script or the procedures and patches" & vbCrLf
sPatchInfo = sPatchInfo & "discussed above.  This script is provided as a free convenience" & vbCrLf
sPatchInfo = sPatchInfo & "to the IT community.  The SANS Institute cannot and does not" & vbCrLf
sPatchInfo = sPatchInfo & "accept liability for your decisions concerning how to best cope" & vbCrLf
sPatchInfo = sPatchInfo & "with the threat and damage caused by Internet worms and viruses." & vbCrLf
sPatchInfo = sPatchInfo & "Nor do we have the unlimited resources necessary to provide" & vbCrLf
sPatchInfo = sPatchInfo & "technical support for all the possible different configurations" & vbCrLf
sPatchInfo = sPatchInfo & "which may cause the script to fail.  When in doubt, reformat drives." & vbCrLf
sPatchInfo = sPatchInfo & "Good luck, and best wishes.  Together we can beat this thing." & vbCrLf


'***********************************************************************************
' sUsageInfo is the Help and Legal page.
'***********************************************************************************
             sUsageInfo = vbCrLf 
sUsageInfo = sUsageInfo &  "AntiCodeRed2.vbs (v.1.7) Written by Jason Fossen, Enclave Consulting LLC, The SANS Institute" & vbCrLf
sUsageInfo = sUsageInfo & " " & vbCrLf
sUsageInfo = sUsageInfo & "CSCRIPT.EXE AntiCodeRed2.vbs [/<option>] " & vbCrLf
sUsageInfo = sUsageInfo & " " & vbCrLf
sUsageInfo = sUsageInfo & "    /silent      = Suppresses all output whatsoever. (Implies /nopatchinfo)" & vbCrLf
sUsageInfo = sUsageInfo & "    /nopatchinfo = Suppress GUI dialog box for patches, but not script results." & vbCrLf
sUsageInfo = sUsageInfo & "    /printusage  = Causes patch information to print out on default printer." & vbCrLf
sUsageInfo = sUsageInfo & "    /disable     = Stops and disables the IIS WWW Publishing Service." & vbCrLf
sUsageInfo = sUsageInfo & "    /?           = This information." & vbCrLf
sUsageInfo = sUsageInfo & " " & vbCrLf
sUsageInfo = sUsageInfo & "Notes: " & vbCrLf
sUsageInfo = sUsageInfo & "    With no command-line switches, i.e., the user simply double-clicks it," & vbCrLf
sUsageInfo = sUsageInfo & "    the script does not automatically print the patch information," & vbCrLf
sUsageInfo = sUsageInfo & "    is not silent, and the user will receive the pop-up dialog box" & vbCrLf
sUsageInfo = sUsageInfo & "    prompting him/her to obtain the necessary patches and, optionally," & vbCrLf
sUsageInfo = sUsageInfo & "    to choose to immediately print this information." & vbCrLf
sUsageInfo = sUsageInfo & " " & vbCrLf
sUsageInfo = sUsageInfo & "    Run the script repeatedly until the ""Worm Sign Count"" equals zero (0)." & vbCrLf
sUsageInfo = sUsageInfo & " " & vbCrLf
sUsageInfo = sUsageInfo & "    If you want a log of the script's actions, redirect the output of the" & vbCrLf
sUsageInfo = sUsageInfo & "    script to a file, e.g., CSCRIPT.EXE AntiCodeRed2.vbs /nopatchinfo > log.txt" & vbCrLf
sUsageInfo = sUsageInfo & " " & vbCrLf
sUsageInfo = sUsageInfo & "    The /disable switch stops and disables the IIS World Wide Web Publishing Service." & vbCrLf
sUsageInfo = sUsageInfo & "    You can easily re-enable it again with the Services applet." & vbCrLf
sUsageInfo = sUsageInfo & " " & vbCrLf
sUsageInfo = sUsageInfo & "    When using Group Policy to distribute the script, make sure" & vbCrLf
sUsageInfo = sUsageInfo & "    to use the /silent switch in your GPO.  Group Policy can be used" & vbCrLf
sUsageInfo = sUsageInfo & "    to automatically distribute this script to your Windows 2000 boxes." & vbCrLf & vbCrLf



'***********************************************************************************
' Declare common objects and a few global variables.
'***********************************************************************************
Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
    Call CatchAnyErrorsAndQuit("Problem with Windows Script Host components (FSO).  Reinstall latest WSH.")
Set oWshShell = WScript.CreateObject("WScript.Shell")
    Call CatchAnyErrorsAndQuit("Problem with Windows Script Host components (WSH).  Reinstall latest WSH.")
Set oWshShellNet = WScript.CreateObject("WScript.Network")
    Call CatchAnyErrorsAndQuit("Problem with Windows Script Host components (WSHnet).  Reinstall latest WSH.")


bNoPatchInfo    = False     'By default, patch info is displayed.
bPrintPatchInfo = False     'By default, do not print patch info to the default printer.
bSilent         = False     'By default, the script will echo text back to the user.
bShowUsage      = False     'By default, do not simply show usage and quit.
bDisable        = False     'By default, do not stop and disable IIS (WWW Publishing Service).
sReport         = "Results of AntiCodeRed2.vbs Script" & vbCrLf & "Computer Name: " & oWshShellNet.ComputerName & vbCrLf & "-----------------------------------------------------------" & vbCrLf        'This value will hold the report output.




'***********************************************************************************
' Call procedures to do the work of the script.  This is the "Main()" section.
'***********************************************************************************
Call CheckCommandLineArguments(bNoPatchInfo, bPrintPatchInfo, bSilent)
Call DeleteUnwantedFiles(sReport)
Call ResetWindowsFileProtection(sReport)
Call CheckVirtualFoldersInRegistry(sReport)
Call CheckVirtualFoldersInMetabase(sReport)
Call WriteResultToEventLog(sReport)
Call StopAndDisableWWW(sReport, bDisable)
Call GenerateReport(sReport)




'***********************************************************************************
' Process the optional command-line arguments and show Info pages as necessary.
'***********************************************************************************
Sub CheckCommandLineArguments(ByRef bNoPatchInfo, ByRef bPrintPatchInfo, ByRef bSilent)
    On Error Resume Next
    For Each sArg In WScript.Arguments  
    	sArg = LCase(sArg)
    	If (sArg = "?") OR (sArg = "-?") OR (sArg = "/?") OR (sArg = "h") OR (sArg = "-h") OR (sArg = "/h") Then bShowUsage = True
        If (sArg = "nopatchinfo") OR (sArg = "-no") OR (sArg = "/no") OR (sArg = "-nopatchinfo") OR (sArg = "/nopatchinfo") Then bNoPatchInfo = True
        If (sArg = "print") OR (sArg = "-print") OR (sArg = "/print") Then bPrintPatchInfo = True
        If (sArg = "silent") OR (sArg = "-silent") OR (sArg = "/silent") Then bSilent = True
        If (sArg = "disable") OR (sArg = "-disable") OR (sArg = "/disable") Then bDisable = True
    Next
    
    If bShowUsage Then
        WScript.Echo sUsageInfo
        WScript.Echo sPatchInfo
        WScript.Quit
    End If
    
    If bPrintPatchInfo Then 
        Call ShowPatchWebsites() 'Launches two IE's to show Microsoft's patch pages.
        Call PrintPatchInfoAndQuit(sPatchInfo)
    End If
    
    If Not(bNoPatchInfo OR bSilent) Then     
        sText = "Anti-Code Red II Script" & vbCrLf & vbCrLf & "You must also obtain two patches from Microsoft to attempt to fix your server.  If you have a default printer for this computer, click Yes to automatically print information about these patches, click No to proceed with the script without patch information (definitely not recommended), or click Cancel to stop the script.  You can run the script in a command-prompt window with the ""/?"" switch to get the same information (and a little more)."
        sButton = MsgBox(sText,3 + 32,"Anti-Code Red II Script")

        If sButton = vbYes Then 
            Call ShowPatchWebsites()
            Call PrintPatchInfoAndQuit(sPatchInfo)
        End If
        
        If sButton = vbCancel Then 
            MsgBox sUsageInfo,0,"Command-Line Switches"
            WScript.Quit
        End If
        'If they click No, then ignore and continue.
    End If
End Sub




'***********************************************************************************
' Delete the copies of CMD.EXE (i.e., the ROOT.EXE's) and the Trojan EXPLORER.EXE's
'***********************************************************************************
Sub DeleteUnwantedFiles(ByRef sReport)
    On Error Resume Next
    ReDim aUnwantedFiles(7) 'An array of the files to be deleted.  Edit when Code Red version 3, 4, 5, etc. are found.
    aUnwantedFiles(0) = "c:\inetpub\scripts\root.exe"
    aUnwantedFiles(1) = "d:\inetpub\scripts\root.exe"
    aUnwantedFiles(2) = "c:\progra~1\common~1\system\MSADC\root.exe"
    aUnwantedFiles(3) = "d:\progra~1\common~1\system\MSADC\root.exe"
    aUnwantedFiles(4) = "c:\explorer.exe"
    aUnwantedFiles(5) = "d:\explorer.exe"
    aUnwantedFiles(6) = "c:\Program Files\Common Files\System\msadc\root.exe" 'Redundant, but may disabling 8.3 name generation requires this? (better safe than sorry)
    aUnwantedFiles(7) = "d:\Program Files\Common Files\System\msadc\root.exe"
    

    For Each sFile In aUnwantedFiles
        If (oFileSystem.FileExists(sFile)) Then
            Set oFile = oFileSystem.GetFile(sFile)
            oFile.Delete True   'The True option will delete Read-Only files too.
            If Err.Number <> 0 Then 
                sReport = sReport & "Trojan found but NOT (REPEAT, NOT) deleted: " & sFile & " (" & Err.Description & ")" & " (Bad)" & vbCrLf
                Err.Clear
            Else
                sReport = sReport & "Trojan found! " & sFile & " (FYI)" & vbCrLf
                sReport = sReport & "Trojan successfully deleted: " & sFile & " (Good)" & vbCrLf
            End If      
        Else
            sReport = sReport & "Trojan not found here: " & sFile & " (Good)" & vbCrLf
        End If      
    Next
End Sub




'***********************************************************************************
' Reset the registry value for Windows File Protection service back to default (On).
' Also, it only changes the registry value if it has been set to the 100% Disabled
' setting.  If the user has configured this value differently than the default for 
' some valid reason --as long as it has not been completely disabled-- then the script
' will not change it. 
'***********************************************************************************
Sub ResetWindowsFileProtection(ByRef sReport)
    On Error Resume Next
    sKey = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SFCDisable"
    sValueData = oWshShell.RegRead(sKey)
    If Err.Number = 0 Then
        If LCase(Hex(sValueData)) = "ffffff9d" Then
            oWshShell.RegWrite sKey,0,"REG_DWORD"
            If Err.Number = 0 Then
                sReport = sReport & "Windows File Protection was disabled! (FYI)" & vbCrLf
                sReport = sReport & "Windows File Protection has been re-enabled. (Good)" & vbCrLf
            Else
                sReport = sReport & "Windows File Protection was NOT (REPEAT, NOT) re-enabled successfully. (Bad)" & vbCrLf
                Err.Clear
            End If
        Else
            sReport = sReport & "Windows File Protection service is not disabled. (Good)" & vbCrLf
        End If
    Else
        sReport = sReport & "Error reading Windows File Protection registry value. (Possibly Bad)" & vbCrLf
        oWshShell.RegWrite sKey,0,"REG_DWORD"
        If Err.Number = 0 Then
            sReport = sReport & "Confirmed that Windows File Protection was enabled after error reading data. (Good)" & vbCrLf
        Else
            sReport = sReport & "Error writing to Windows File Protection registry value (check permissions on key). (Bad)" & vbCrLf
            Err.Clear
        End If
    End IF
End Sub




'***********************************************************************************
' Look for and delete registry values that create IIS virtual folders: /C, /D, etc..
'***********************************************************************************
Sub CheckVirtualFoldersInRegistry(ByRef sReport)
    On Error Resume Next
    sKey        = "HKLM\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots\"
    sKeyScripts = sKey & "/scripts"   
    sKeyMsadc   = sKey & "/msadc"     
    sKeyC       = sKey & "/c"         
    sKeyD       = sKey & "/d"
    
    sValueData = oWshShell.RegRead(sKeyScripts)
    If Err.Number = 0 Then
        aValueDataArray = Split(sValueData,",")
        If aValueDataArray(2) = "217" Then
            sReport = sReport & "/Scripts folder found with unsafe permissions in registry. (FYI)" & vbCrLf
            oWshShell.RegWrite sKeyScripts,aValueDataArray(0) & ",," & "201","REG_SZ"
            If Err.Number = 0 Then
                sReport = sReport & "/Scripts folder permissions successfully reset in registry. (Good)" & vbCrLf
            Else
                sReport = sReport & "/Scripts folder permissions NOT (REPEAT, NOT) successfully reset in registry. (Bad)" & vbCrLf
                Err.Clear
            End If
        End If
    Else
        sReport = sReport & "/Scripts folder not present in registry. (That's OK)" & vbCrLf
    End IF


    sValueData = oWshShell.RegRead(sKeyMsadc)
    If Err.Number = 0 Then
        aValueDataArray = Split(sValueData,",")
        If aValueDataArray(2) = "217" Then
            sReport = sReport & "/MSADC folder with unsafe permissions in registry. (FYI)" & vbCrLf
            oWshShell.RegWrite sKeyMsadc,aValueDataArray(0) & ",," & "205","REG_SZ"
            If Err.Number = 0 Then
                sReport = sReport & "/MSADC folder permissions successfully reset in registry. (Good)" & vbCrLf
            Else
                sReport = sReport & "/MSADC folder permissions NOT (REPEAT, NOT) successfully reset in registry. (Bad)" & vbCrLf
                Err.Clear
            End If
        End If
    Else
        sReport = sReport & "/MSADC folder not present in registry. (That's OK)" & vbCrLf
    End IF


    sValueData = oWshShell.RegRead(sKeyC)
    If Err.Number = 0 Then
        sReport = sReport & "/C IIS virtual folder found in registry. (FYI)" & vbCrLf
        oWshShell.RegDelete sKeyC
        If Err.Number = 0 Then
            sReport = sReport & "/C IIS virtual folder successfully deleted from registry. (Good)" & vbCrLf
        Else
            sReport = sReport & "/C IIS virtual folder NOT (REPEAT, NOT) successfully deleted from registry. (Bad)" & vbCrLf
            Err.Clear
        End If
    Else
        sReport = sReport & "/C IIS virtual folder not present in registry. (Good)" & vbCrLf
    End IF
    

    sValueData = oWshShell.RegRead(sKeyD)
    If Err.Number = 0 Then
        sReport = sReport & "/D IIS virtual folder found in registry. (FYI)" & vbCrLf
        oWshShell.RegDelete sKeyD
        If Err.Number = 0 Then
            sReport = sReport & "/D IIS virtual folder successfully deleted from registry. (Good)" & vbCrLf
        Else
            sReport = sReport & "/D IIS virtual folder NOT (REPEAT, NOT) successfully deleted from registry. (Bad)" & vbCrLf
            Err.Clear
        End If
    Else
        sReport = sReport & "/D IIS virtual folder not present in registry. (Good)" & vbCrLf
    End IF
End Sub




'***********************************************************************************
' More importantly, delete the /C and /D folders from the IIS metabase, but only
' reset the permissions on /Scripts and /MSADC back to their defaults.
'***********************************************************************************
Sub CheckVirtualFoldersInMetabase(ByRef sReport)
    On Error Resume Next
    Set oW3SVC = GetObject("IIS://localhost/W3SVC")
    If Err.Number <> 0 Then
        sReport = sReport & "*****************************************" & vbCrLf
        sReport = sReport & " ERROR WHEN CONNECTING TO IIS SERVICE!" & vbCrLf
        sReport = sReport & " No virtual directories have been checked!" & vbCrLf
        sReport = sReport & " Examine your IIS folders! (BAD)" & vbCrLf
        sReport = sReport & "*****************************************" & vbCrLf
        Err.Clear
    End If
    
    For Each oContainer In oW3SVC
        If oContainer.Class = "IIsWebServer" Then 
            Set oWebSite = GetObject("IIS://localhost/W3SVC/" & oContainer.Name & "/Root")
            
            oWebSite.Delete "IisWebVirtualDir","c"
            If Err.Number = 0 Then
                sReport = sReport & "/C virtual directory found in website number " & oContainer.Name & " (FYI)" & vbCrLf
                sReport = sReport & "/C virtual directory removed from website number " & oContainer.Name & " (Good)" & vbCrLf
            Else
                sReport = sReport & "/C virtual directory not found in website number " & oContainer.Name & " (Good)" & vbCrLf
                Err.Clear
            End If
            oWebSite.SetInfo
            
            oWebSite.Delete "IisWebVirtualDir","d"
            If Err.Number = 0 Then
                sReport = sReport & "/D virtual directory found in website number " & oContainer.Name & " (FYI)" & vbCrLf
                sReport = sReport & "/D virtual directory removed from website number " & oContainer.Name & " (Good)" & vbCrLf
            Else
                sReport = sReport & "/D virtual directory not found in website number " & oContainer.Name & " (Good)" & vbCrLf
                Err.Clear
            End If
            oWebSite.SetInfo
            
            Set oWebSite = Nothing
            
            Set oScriptsFolder = GetObject("IIS://localhost/W3SVC/" & oContainer.Name & "/Root/Scripts")
            If Err.Number = 0 Then
                oScriptsFolder.Put "AccessFlags","513"
                If Err.Number = 0 Then
                    sReport = sReport & "/Scripts virtual directory permissions reset in website number " & oContainer.Name & " (Good)" & vbCrLf
                Else
                    sReport = sReport & "/Scripts virtual directory permissions NOT (REPEAT, NOT) reset in website number " & oContainer.Name & " (Bad)" & vbCrLf
                    Err.Clear
                End If
            Else
                Err.Clear
            End If
            oScriptsFolder.SetInfo
            Set oScriptsFolder = Nothing
            
            
            Set oMsadcFolder = GetObject("IIS://localhost/W3SVC/" & oContainer.Name & "/Root/MSADC")
            If Err.Number = 0 Then
                oMsadcFolder.Put "AccessFlags","517"
                If Err.Number = 0 Then
                    sReport = sReport & "/Msadc virtual directory permissions reset in website number " & oContainer.Name & " (Good)" & vbCrLf
                Else
                    sReport = sReport & "/Msadc virtual directory permissions NOT (REPEAT, NOT) reset in website number " & oContainer.Name & " (Bad)" & vbCrLf
                    Err.Clear
                End If
            Else
                Err.Clear
            End If
            oMsadcFolder.SetInfo
            Set oMsadcFolder = Nothing
            
        End If
    Next
End Sub




'***********************************************************************************
' Write the sReport to an event in the Application log (Source: WSH, Type: Warning).
' This will help to fix a date, time, computer, user, etc. for auditing later on.
' Change the IP address where the event will be written if you wish.
'***********************************************************************************
Sub WriteResultToEventLog(ByVal sReport)
    On Error Resume Next
    oWshShell.LogEvent 2,sReport,"127.0.0.1"    
End Sub




'***********************************************************************************
' Print results to command-prompt window or GUI dialog box, depending on whether
' the user is running CScript.exe or WScript.exe.
'***********************************************************************************
Sub GenerateReport(ByVal sReport)
    On Error Resume Next
    If Not bSilent Then
        Set oRegExp = New RegExp
        oRegExp.Pattern = "\(Bad\)"
        oRegExp.Global = True
        Set cMatches = oRegExp.Execute(sReport)
        iWormSign = cMatches.Count   'Shai Hulud!
        WScript.Echo vbCrLf & "Worm Sign Count = " & iWormSign & vbCrLf & vbCrLf & "(The count should be zero after you run the script, but, if it is not, you can run the script again after trying each or all of the following: 1) applying both patches, 2) logging off, and 3) rebooting.  If you are not patched, you will simply be infected again.  If you do not reboot after patching and running the script, you will not clean out the Trojan.  Also, it is best if these steps can all be performed in under 10 minutes, since the Trojan attempts to reinfect the machine every 10 minutes.)" & vbCrLf
        WScript.Echo sReport
    End If
End Sub




'***********************************************************************************
' It's handy to have the directions and URL on paper.  This trick will pump out
' a hardcopy if a printer is attached to the computer and it is marked as default.
'***********************************************************************************
Sub PrintPatchInfoAndQuit(ByRef sPatchInfo)
    'On Error Resume Next
    sTempFile = oFileSystem.GetSpecialFolder(2) & "\" & oFileSystem.GetTempName()
    Set oFile = oFileSystem.OpenTextFile(sTempFile,2,True)
    oFile.Write sPatchInfo
    oFile.Close
    Set oFile = Nothing
    
    If Err.Number = 0 Then
        oWshShell.Run "notepad.exe /p " & sTempFile,7,True
    Else
        WScript.Echo "Print problems.  You might not have CScript.exe or Notepad.exe available."
    End If 
    
    oFileSystem.DeleteFile sTempFile, True
    WScript.Quit
End Sub




'***********************************************************************************
' Attempt to load two Internet Explorers with the patch webpages.
'***********************************************************************************
Sub ShowPatchWebsites()
    Set oIE = WScript.CreateObject("InternetExplorer.Application")
    oIE.Navigate("http://www.microsoft.com/technet/security/bulletin/MS01-033.asp")
    oIE.Visible = 1
            
    Set oIE2 = WScript.CreateObject("InternetExplorer.Application")
    oIE2.Navigate("http://www.microsoft.com/technet/security/bulletin/MS00-052.asp")
    oIE2.Visible = 1
End Sub




'***********************************************************************************
' Stop and disable the WWW Publishing Service (see Services applet to re-enable).
'***********************************************************************************
Sub StopAndDisableWWW(ByRef sReport, ByVal bDisable)
    On Error Resume Next
    
    If Not bDisable Then Exit Sub 'Check to see if /disable switch was used.
    
    sComputerName = oWshShellNet.ComputerName    
    Set oWWWservice = GetObject("WinNT://" & sComputerName & "/W3SVC")
    If Err.Number = 0 Then
        oWWWservice.StartType = 4  'Disabled.
        oWWWservice.SetInfo
        If Err.Number = 0 Then 
            sReport = sReport & "WWW Publishing Service set to disabled. (Good)" & vbCrLf
        Else
            sReport = sReport & "ERROR in disabling WWW Publishing Service. (Bad)" & vbCrLf
            Err.Clear
        End If
        
        oWWWservice.Stop  'This will raise an error if already stopped, so we'll ignore any errors here.
       
        'Check that it really did stop...
        WScript.Sleep(10000) 'Give it 10 seconds to stop before testing its status.
        Set oWinNT = GetObject("WinNT://" & sComputerName)
        oWinNT.Filter = Array("Service")
    
        bIsReallyStopped = False
        For Each oService In oWinNT
            If (oService.Name = "W3SVC" and oService.Status = 1) Then bIsReallyStopped = True  'Status of 1 means "Stopped"
        Next
    
        If bIsReallyStopped Then sReport = sReport & "WWW Publishing Service stopped. (Good)" & vbCrLf  
        If Not bIsReallyStopped Then sReport = sReport & "ERROR when stopping WWW Publishing Service. (Bad)" & vbCrLf  
    
        Set oWinNT = Nothing
    Else
        sReport = sReport & "ERROR in connecting to WWW Publishing Service.  Is it installed? (FYI)" & vbCrLf
        Err.Clear
    End If
End Sub


'***********************************************************************************
' Helper Procedures.
'***********************************************************************************
Sub CatchAnyErrorsAndQuit(ByVal sMsg)
	If Err.Number <> 0 Then
		sOutput = vbCrLf
		sOutput = sOutput &  "ERROR:             " & sMsg & vbCrLf 
		sOutput = sOutput &  "Error Number:      " & Err.Number & vbCrlf
		sOutput = sOutput &  "Error Description: " & Err.Description & vbCrLf
		sOutput = sOutput &  "Error Source:      " & Err.Source & vbCrLf 
		sOutput = sOutput &  "Script Name:       " & WScript.ScriptName & vbCrLf 
		sOutput = sOutput &  vbCrLf
		
        WScript.Echo sOutput
		WScript.Quit Err.Number
	End If 
End Sub 

'END OF SCRIPT *********************************************************************
