'**************************************************************************************************
' Script Name: File_System_Object.vbs
'     Version: 1.3
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 14.Dec.2006
'     Purpose: Demonstrate various uses of the FileSystemObject.  
'              Almost all the functions are designed to return True if they
'              complete successfully, False otherwise.  Functions included are:
'                   AppendToFile()    <-- Use to create files too.
'                   CreateFolder()
'                   DeleteFolder()
'                   ReadEntireTextFile()
'                   GetDrivesOfType()
'                   GetFreeMBonDrive()
'                   GetCreatedFiles()
'                   GetModifiedFiles()
'                   
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'**************************************************************************************************

Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")



Function AppendToFile(sData, sFile)
    On Error Resume Next

    Const ForAppending =      8     'Request NTFS appending permission.
    Const ForOverWriting =    2     'Request NTFS writing permission.
    Const ForReading =        1     'Request NTFS read permission.
    Const OpenAsASCII =       0     'ASCII text format.
    Const OpenAsUnicode =    -1     'Unicode text format.
    Const OpenUsingDefault = -2     'ASCII is default for FAT32, Unicode default for NTFS.

    Dim sCurrentFolder, oTextStream, sFullPathToScript    
   
    Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
    Set oWshShell = WScript.CreateObject("WScript.Shell")

    'Expand any environmental variables to their full paths.
    sFile = oWshShell.ExpandEnvironmentStrings(sFile) 
    
    'Use current folder of script for output file path, if not path is given.    
    If InStr(sFile, "\") = 0 Then
        sFullPathToScript = WScript.ScriptFullName 
        sCurrentFolder = Left(sFullPathToScript, InStrRev(sFullPathToScript, "\"))
        sFile = sCurrentFolder & sFile
    End If    

    
    'Get output file if it exists, or create one if it doesn't.
    If oFileSystem.FileExists(sFile) Then 
        Set oFile = oFileSystem.GetFile(sFile)
        Set oTextStream = oFile.OpenAsTextStream(ForAppending, OpenUsingDefault)     
    Else
        Set oTextStream = oFileSystem.CreateTextFile(sFile)
    End If

    
    'Must write data to a new line, so check the column number first.
    If oTextStream.Column = 1 Then
        oTextStream.Write(sData)  
    Else
        oTextStream.WriteBlankLines(1)
        oTextStream.Write(sData)  
    End If

    oTextStream.Close
    
    If Err.Number = 0 Then 
        AppendToFile = True  
    Else  
        AppendToFile = False
    End If
End Function



Function FileExists(sFile)
    On Error Resume Next
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")

    If InStr(sFile, "%") <> 0 Then
        If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell")
        sFile = oWshShell.ExpandEnvironmentStrings(sFile)
    End If 
        
    If InStr(sFile, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sFile = sCurrentFolder & sFile
    End If    

    If oFileSystem.FileExists(sFile) Then 
        FileExists = True
    Else
        FileExists = False
    End If
End Function




Function CreateFolder(sPath)
    On Error Resume Next
    Err.Clear
    
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")

    If InStr(sPath, "%") <> 0 Then
        If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell")
        sPath = oWshShell.ExpandEnvironmentStrings(sPath)
    End If 
    
    If InStr(sPath, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sPath = sCurrentFolder & sPath
    End If    
    
    If oFileSystem.FolderExists(sPath) Then
       'WScript.Echo "Folder '" & sPath & "' already exists."
       CreateFolder = True
       Exit Function
    Else
       Set oFolder = oFileSystem.CreateFolder(sPath)
       Set oFolder = Nothing
    End If
    
    If Err.Number = 0 Then
       'WScript.Echo "Successfully created folder '" & sPath & "'"
       CreateFolder = True
    Else
       'WScript.Echo "Failed to create folder '" & sPath & "' " & Err.Description 
       CreateFolder = False
    End If
End Function



Function DeleteFolder(sPath)
    On Error Resume Next
    Err.Clear
    
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")

    If InStr(sPath, "%") <> 0 Then
        If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell")
        sPath = oWshShell.ExpandEnvironmentStrings(sPath)
    End If 
    
    If InStr(sPath, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sPath = sCurrentFolder & sPath
    End If    
    
    If oFileSystem.FolderExists(sPath) Then oFileSystem.DeleteFolder(sPath)
    
    If Err.Number = 0 Then
       'WScript.Echo "Successfully deleted folder '" & sPath & "'"
       DeleteFolder = True
    Else
       'WScript.Echo "Failed to delete folder '" & sPath & "' " & Err.Description 
       DeleteFolder = False
    End If
End Function



Function DeleteFile(sPath)
    On Error Resume Next
    Err.Clear
    
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")

    If InStr(sPath, "%") <> 0 Then
        If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell")
        sPath = oWshShell.ExpandEnvironmentStrings(sPath)
    End If 
    
    If InStr(sPath, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sPath = sCurrentFolder & sPath
    End If    
    
    If oFileSystem.FileExists(sPath) Then oFileSystem.DeleteFile sPath, True 'True to delete read-only files too.
    
    If Err.Number = 0 Then
       'WScript.Echo "Successfully deleted file '" & sPath & "'"
       DeleteFile = True
    Else
       'WScript.Echo "Failed to delete file '" & sPath & "' " & Err.Description 
       DeleteFile = False
    End If
End Function




'
' Declare a global variable to hold file contents and pass in as second argument.
'
Function ReadEntireTextFile(sPath, ByRef sContents)
    On Error Resume Next
    Err.Clear
    Const ForReading = 1
    Const UseDefault = -2  'Unicode or ASCII.
    
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")

    If InStr(sPath, "%") <> 0 Then
        If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell")
        sPath = oWshShell.ExpandEnvironmentStrings(sPath)
    End If 

    
    If InStr(sPath, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sPath = sCurrentFolder & sPath
    End If    
        
    
    If oFileSystem.FileExists(sPath) Then
        Set oFile = oFileSystem.OpenTextFile(sPath, ForReading, False, UseDefault)   'False to not create the file.
        sContents = oFile.ReadAll
        oFile.Close
        Set oFile = Nothing
    Else
        ReadEntireTextFile = False
        'WScript.Echo "File '" & sPath & "' does not exist."
        Exit Function
    End If
    
    If Err.Number = 0 Then ReadEntireTextFile = True Else ReadEntireTextFile = False
End Function



'
' See function body for what sType argument it's expecting.
' Returns a space-character-delimited list of drives of that type.
' Parse the return with Split() for further processing
'
Function GetDrivesOfType(sType)
    On Error Resume Next
    sType = Trim(UCase(CStr(sType)))
    
    If sType = "UNKNOWN" Or sType = "0" Then 
        sType = CInt(0)
    ElseIf sType = "REMOVABLE" Or sType = "1" Then 
        sType = CInt(1)
    ElseIf sType = "FIXED" Or sType = "2" Then 
        sType = CInt(2) 
    ElseIf sType = "NETWORK" Or sType = "3" Then 
        sType = CInt(3)
    ElseIf sType = "CDROM" Or sType = "4" Then 
        sType = CInt(4)
    ElseIf sType = "RAMDISK" Or sType = "5" Then 
        sType = CInt(5)
    Else 
        sType = CInt(2) 'Assume fixed.
    End If
    
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
    
    Set cDrives = oFileSystem.Drives
    
    For Each oDrive In cDrives
        If oDrive.DriveType = sType AND oDrive.IsReady Then
            sList = sList & oDrive.DriveLetter & ": "
        End If
    Next
    
    Set cDrives = Nothing
    GetDrivesOfType = Trim(sList) 
End Function



Function GetFreeMBOnDrive(sDrive)
    On Error Resume Next
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
    Set oDrive = oFileSystem.GetDrive(Left(sDrive,1) & ":")   'Argument can have colon or not.  
    GetFreeMBOnDrive = FormatNumber((oDrive.FreeSpace/1024)/1024, 1)
    Set oDrive = Nothing
End Function




Function GetCreatedFiles(ByRef aArrayToFill, sFolder, iHoursAgoFrom, iHoursAgoTo)
    On Error Resume Next
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
        
    If InStr(sFolder, "%") <> 0 Then
        If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell")
        sFolder = oWshShell.ExpandEnvironmentStrings(sFolder)
    End If 

    If InStr(sFolder, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sFolder = sCurrentFolder & sFolder
    End If    
 
    If oFileSystem.FolderExists(sFolder) Then
        Set oFolder = oFileSystem.GetFolder(sFolder)
        Set cFiles = oFolder.Files
    Else
        GetCreatedFiles = False
        'Err.Raise(-1)
        'WScript.Echo "Error: Folder does not exist."
        Exit Function
    End If
    
    dateFrom = DateAdd("h", iHoursAgoFrom * -1, Now())
    dateTo =   DateAdd("h", iHoursAgoTo * -1, Now())    
    ReDim aArrayToFill(cFiles.Count - 1)
    x = 0
    
    For Each oFile In cFiles
        dateCreated = CDate(oFile.DateCreated)
        If ((dateCreated >= dateFrom) And (dateCreated <= dateTo)) Then
            aArrayToFill(x) = oFile.Path & vbTab & oFile.DateCreated & vbTab & oFile.Size
            x = x + 1
        End If 
    Next
    
    If x >= 1 Then 
        ReDim Preserve aArrayToFill(x - 1)
    Else
        ReDim aArrayToFill(0)
    End If
    
    If Err.Number = 0 Then GetCreatedFiles = True Else GetCreatedFiles = False
    
    Set cFiles = Nothing
    Set oFolder = Nothing
End Function





Function GetModifiedFiles(ByRef aArrayToFill, sFolder, iHoursAgoFrom, iHoursAgoTo)
    On Error Resume Next
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")

    If InStr(sFolder, "%") <> 0 Then
        If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell")
        sFolder = oWshShell.ExpandEnvironmentStrings(sFolder)
    End If 

    If InStr(sFolder, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sFolder = sCurrentFolder & sFolder
    End If    
 
    If oFileSystem.FolderExists(sFolder) Then
        Set oFolder = oFileSystem.GetFolder(sFolder)
        Set cFiles = oFolder.Files
    Else
        GetModifiedFiles = False
        'Err.Raise(-1)
        'WScript.Echo "Error: Folder does not exist."
        Exit Function
    End If
    
    dateFrom = DateAdd("h", iHoursAgoFrom * -1, Now())
    dateTo =   DateAdd("h", iHoursAgoTo * -1, Now())    
    ReDim aArrayToFill(cFiles.Count - 1)
    x = 0
    
    For Each oFile In cFiles
        dateModified = CDate(oFile.DateLastModified)
        If ((dateModified >= dateFrom) And (dateModified <= dateTo)) Then
            aArrayToFill(x) = oFile.Path & vbTab & oFile.DateLastModified & vbTab & oFile.Size
            x = x + 1
        End If 
    Next
    
    If x >= 1 Then 
        ReDim Preserve aArrayToFill(x - 1)
    Else
        ReDim aArrayToFill(0)
    End If
    
    If Err.Number = 0 Then GetModifiedFiles = True Else GetModifiedFiles = False
    
    Set cFiles = Nothing
    Set oFolder = Nothing
End Function











'********************************************************************************************
' The following lines demonstrate use of the functions above.
'********************************************************************************************


If CreateFolder("C:\testfolderhere") Then WScript.Echo "Folder created!"
If DeleteFolder("C:\testfolderhere") Then WScript.Echo "Folder deleted!"



Dim sContents 
If ReadEntireTextFile(WScript.ScriptFullName, sContents) Then WScript.Echo "This script read!"



WScript.Echo "Fixed drive(s) = " & GetDrivesOfType("fixed")

For Each sDrive In Split(GetDrivesOfType("fixed"))
    WScript.Echo sDrive & " has " & GetFreeMBOnDrive(sDrive) & "MB of free space." 
Next



ReDim aWantedFiles(0)
WScript.Echo vbCrLf & "Files Created In %SystemRoot% During Last Three Days:"
bFlag = GetCreatedFiles(aWantedFiles,"%SystemRoot%",24*3,0)
If bFlag Then
    For Each sLine In aWantedFiles
        WScript.Echo sLine
    Next
Else
    WScript.Echo "No created files found (or folder doesn't exist)."
End If



ReDim aWantedFiles2(0)
WScript.Echo vbCrLf & "Files Modified In %SystemRoot% During Last Three Days:"
bFlag = GetModifiedFiles(aWantedFiles2,"%SystemRoot%",24*3,0)
If bFlag Then
    For Each sLine In aWantedFiles2
        WScript.Echo sLine
    Next
Else
    WScript.Echo "No modified files found (or folder doesn't exist)."
End If



'END OF SCRIPT*******************************************************************************
