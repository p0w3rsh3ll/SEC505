'*****************************************************
' Script Name: Find_Suspicious_Files.vbs
'     Version: 2.1
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 3/28/02
'     Purpose: Search all fixed drives on a system for suspicious files, and,
'              optionally, attempt to delete them.
'       Usage: Edit array of aBadFiles, run script as System.
'       Notes: The structure of this script is deliberately modeled on the ILOVEYOU
'              virus in order to prepare for an analysis of the virus in seminar.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantees.  Use
'              at your own risk and only on networks with prior written permission.      
'*****************************************************

'On Error Resume Next

'*****************************************************
' Create common objects and counters.
'*****************************************************
Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")

Set oRegExp = New RegExp                             
oRegExp.IgnoreCase = True
oRegExp.Global = False  'One match is good enough.

Dim sResult             'The output of the script.
Dim iDeletedCounter     'Count of suspicious files deleted.


'*****************************************************
' Define array of suspicious files.  Edit as desired.
'*****************************************************
Dim aBadFiles(20) 'Set to largest integer in array variables, not total number of elements.

aBadFiles(0) =  "^root\.exe"
aBadFiles(1) =  "mslom"
aBadFiles(2) =  "lsaprivs"
aBadFiles(3) =  "pwdump"
aBadFiles(4) =  "readsmb"
aBadFiles(5) =  "^serv\.exe$"
aBadFiles(6) =  "readme\.eml"
aBadFiles(7) =  "l0pht"
aBadFiles(8) =  "LOVE-LETTER-FOR-YOU\.TXT\.vbs"
aBadFiles(9) =  "sex.*\.(?:jpg|gif)" 
aBadFiles(10) = "secholed?\.exe"
aBadFiles(11) = "lsadump"
aBadFiles(12) = "brutusA2"
aBadFiles(13) = "getadmin"
aBadFiles(14) = "^nat\.exe"   'This pattern is too wide without the "^"!  False positives! 
aBadFiles(15) = "rhino9"
aBadFiles(16) = "dsniff"
aBadFiles(17) = "mailsnarf"
aBadFiles(18) = "nb.+pro\.exe"
aBadFiles(19) = "toneloc"
aBadFiles(20) = "lomscan"


'*****************************************************
' Call procedures to do work of script.
'*****************************************************
Call ListDrives()
'Call DeleteBadFiles()  'CAUTION!!! Dangerous!!  See below!
Call GenerateReport()   



'*****************************************************
' Procedures: ListDrives() and ListFolders()
' Purpose: These work together to recursively 
'          enumerate entire file system.  Calling
'          SearchFiles() as they go.
'*****************************************************
Sub ListDrives()
    Const FixedDrive = 2        
    Set cDrives = oFileSystem.Drives    
    For Each oDrive in cDrives
        If oDrive.DriveType = FixedDrive Then 
            Call SearchFiles(oDrive.Path) 'Search root of drive.
            Call ListFolders(oDrive.Path & "\") 'Search subfolders.
        End If 
    Next
End Sub 


'ListFolders() is called by ListDrives() and itself recursively.
Sub ListFolders(sFolderPath) 
    On Error Resume Next    'Required in case permission denied, e.g., Recycle Bins.
    Dim cSubFolders         'The subfolders to be searched.
    Dim oSubFolder          'Current subfolder in For-Next loop.

    Set oFolder = oFileSystem.GetFolder(sFolderPath)  
    Set cSubFolders = oFolder.SubFolders
    
    For Each oSubFolder In cSubFolders
        If Err.Number = 0 Then                  'Errors occur when permission denied.
            Call SearchFiles(oSubFolder.Path)   
            Call ListFolders(oSubFolder.Path)   'Recursion -- procedure is calling itself.
        End If
        Err.Clear
    Next  
End Sub 


'*****************************************************
' Procedures: SearchFiles() and IsSuspicious()
'    Purpose: Called by ListDrives() and ListFolders(),
'             they do the pattern-matching.
'*****************************************************
Sub SearchFiles(sSubFolderPath)  
    On Error Resume Next    'Required in case permission is denied to a file.
    Dim cFiles              'Collection of files in current folder.
    Dim oFile               'Current file being tested.

    Set oFolder = oFileSystem.GetFolder(sSubFolderPath)
    Set cFiles = oFolder.Files

    For Each oFile In cFiles
        If IsSuspicious(oFile.Name) Then 
            sResult = sResult & sSubFolderPath & "\" & oFile.Name & vbCrLf
        End If   
    Next 
End Sub 


'IsSuspicious() is invoked in SearchFiles().
Function IsSuspicious(sFileName)
    For Each sPattern In aBadFiles
        oRegExp.Pattern = sPattern
        If oRegExp.Test(sFileName) AND (sPattern <> "") Then 
            IsSuspicious = True
            Exit Function
        End If
    Next
    IsSuspicious = False
End Function



'*****************************************************
' Procedures: DeleteBadFiles()
'    Purpose: Attempts to delete the suspicious files.
'    CAUTION! You must VERY CAREFULLY define your regular 
'             expression patterns and conduct extensive 
'             testing before using this procedure!
'*****************************************************
Sub DeleteBadFiles()
    On Error Resume Next
    Dim sReport

    aTargetFiles = Split(sResult,vbCrLf)
    If aTargetFiles(UBound(aTargetFiles))= "" Then 
        ReDim Preserve aTargetFiles(UBound(aTargetFiles) - 1) 
    End If
    
    For Each sFile In aTargetFiles
        Set oFile = oFileSystem.GetFile(sFile)
        'oFile.Delete True       'Uncomment to activate.  The True option will delete Read-Only files too.
        If Err.Number <> 0 Then 
            sReport = sReport & "File NOT deleted: " &_ 
                      sFile & " (" & Err.Description & ")" & vbCrLf
            Err.Clear
        Else
            sReport = sReport & "File deleted: " & sFile & vbCrLf
            iDeletedCounter = iDeletedCounter + 1
        End If      
    Next
    
    sReport = sReport & vbCrLf & iDeletedCounter & " files deleted." & vbCrLf
    WScript.Echo sReport
End Sub



'*****************************************************
' Procedures: GenerateReport()
'    Purpose: Easy-to-modify reporting procedure.
'*****************************************************
Sub GenerateReport()
    aSuspiciousFiles = Split(sResult,vbCrLf)
    iBadFiles = UBound(aSuspiciousFiles)
    WScript.Echo vbCrLf & iBadFiles & " suspicious files detected:" & vbCrLf
    WScript.Echo sResult
End Sub


'END OF SCRIPT ***************************************
