'**************************************************************************************************
' Script Name: Map_Drive_Letters.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 26.Mar.2004
'     Purpose: Demonstrate various ways to map/unmap network drive letters.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'**************************************************************************************************



'
' Returns a vbCrLf-delimited string of drive<tab>UNCpath pairings.  Empty return if none.
' Can be immediately parsed in an array like this:  aArray = Split(ListOfMappedNetworkDrives(),vbCrLf) 
' Note: the weird-looking For..Next is because cDrives has two items for each mapped drive,
'       namely, the drive letter (first item) and its UNC path (second item).  Why did MS do this???  
'
Function ListOfMappedNetworkDrives()
    If Not IsObject(oWshNetwork) Then Set oWshNetwork = WScript.CreateObject("WScript.Network")
    ListOfMappedNetworkDrives = ""   'Assume there are no network drives mapped.  
    Set cDrives = oWshNetwork.EnumNetworkDrives
    If cDrives.Count <> 0 Then
        For i = 0 To (cDrives.Count - 1) Step 2
            ListOfMappedNetworkDrives = ListOfMappedNetworkDrives & cDrives.Item(i) & vbTab & cDrives.Item(i + 1) 
            If (i + 2) <> cDrives.Count Then ListOfMappedNetworkDrives = ListOfMappedNetworkDrives & vbCrLf  'Ensures there's not trailing vbCrLf to foil Split()
        Next
    End If
    Set cDrives = Nothing
End Function



'
' Returns drive letter that was mapped if successful, returns False if an error occurs.
' Will attempt mapping with a currently unused letter, you don't have to specify.
' Test output either for "not false" or the presense of a colon, e.g., "Z:".
'
Function MapNetworkDriveLetter(sUncPath, sUsername, sPassword)
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
    If Not IsObject(oWshNetwork) Then Set oWshNetwork = WScript.CreateObject("WScript.Network")

    Set cDrives = oFileSystem.Drives
    For Each oDrive In cDrives
        sDrivesInUse = sDrivesInUse & UCase(oDrive.DriveLetter)
    Next
    Set cDrives = Nothing
    
    aDriveLettersToTry = Split("Z Y X W V U T S R Q P O N M L K J I H G F E D")
    For Each sLetter In aDriveLettersToTry
        If InStr(sDrivesInUse, sLetter) = 0 Then
            sDriveLetter = sLetter 
            Exit For
        End If
    Next

    If sUsername = "" Then
        oWshNetwork.MapNetworkDrive sDriveLetter & ":", sUncPath  'Use Integrated Windows authentication.
    Else
        oWshNetwork.MapNetworkDrive sDriveLetter & ":", sUncPath, False, sUsername, sPassword
    End If

    If Err.Number = 0 Then MapNetworkDriveLetter = sDriveLetter & ":" Else MapNetworkDriveLetter = False
End Function



'
' Returns True if letter successfully unmapped, False if an error occurs.
'
Function UnmapNetworkDriveLetter(sLetter)
    If Not IsObject(oWshNetwork) Then Set oWshNetwork = WScript.CreateObject("WScript.Network")
    If InStr(sLetter,":") = 0 Then sLetter = sLetter & ":"
    oWshNetwork.RemoveNetworkDrive sLetter, True, False     'True to force, and False to leave profile unchanged.
    If Err.Number = 0 Then UnmapNetworkDriveLetter = True Else UnmapNetworkDriveLetter = False
End Function



'
' Returns True if all network drives unmapped, False if an error occurs.
' If no drives are currently mapped, function still returns True.
'
Function UnmapAllNetworkDriveLetters()
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
    If Not IsObject(oWshNetwork) Then Set oWshNetwork = WScript.CreateObject("WScript.Network")

    Set cDrives = oFileSystem.Drives
    For Each oDrive In cDrives
        If oDrive.DriveType = 3 Then   '3 = Network Drive
            oWshNetwork.RemoveNetworkDrive oDrive.DriveLetter & ":", True, False     'True to force, and False to leave profile unchanged.
        End If 
    Next
    Set cDrives = Nothing
    
    If Err.Number = 0 Then UnmapAllNetworkDriveLetters = True Else UnmapAllNetworkDriveLetters = False
End Function





'**************************************************************************************************

'WScript.Echo ListOfMappedNetworkDrives()
'WScript.Echo MapNetworkDriveLetter("\\10.4.3.3\h$","","")
'WScript.Echo UnmapNetworkDriveLetter("z")
'WScript.Echo UnmapAllNetworkDriveLetters()

