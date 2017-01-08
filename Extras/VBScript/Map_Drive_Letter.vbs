'**************************************************************************
' Script Name: Mapping_Network_Drives.vbs
'     Version: 1.3
'      Author: Jason Fossen, Enclave Consulting LLC ( www.ISAscripts.org )
'Last Updated: 2.June.2006
'     Purpose: Three functions in this file:
'               1) MapDrive() maps the first available letter to the UNC,
'                  returns False if an error, the letter+colon otherwise.
'               2) UnMapDrive() unmaps the specified letter, returns True
'                  if no errors or if that letter wasn't mapped to begin with.
'               3) UnMapAllDrives() unmaps are network drive letters, And
'                  returns True if no errors, False otherwise.
'      Legal:  Script provided "AS IS" without warranties or guarantees
'              of any kind.  USE AT YOUR OWN RISK.  Public domain.
'**************************************************************************



Function MapDrive(sUncPath)
    On Error Resume Next
    Dim oWshNetwork, cDrives, oDrive, i, sList
    sList = "E F G H I J K L M N O P Q R S T U V W X Y Z"
    
    Set oWshNetwork = WScript.CreateObject("WScript.Network")
    Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
    
    Set cDrives = oFileSystem.Drives
    
    For Each oDrive In cDrives
        sList = Replace(sList, oDrive.DriveLetter, "")
    Next

    sLetter = Left(LTrim(sList), 1) & ":"  'Will return something like "E:"

    oWshNetwork.MapNetworkDrive sLetter, sUncPath
    
    'Function returns False if an error, the drive letter+colon if no error.
    If Err.Number = 0 Then MapDrive = sLetter Else MapDrive = False
End Function




Function UnMapDrive(sDriveLetter)
    On Error Resume Next
    Dim oWshNetwork, cDrives, i
    Set oWshNetwork = WScript.CreateObject("WScript.Network")
    Set cDrives = oWshNetwork.EnumNetworkDrives

    'Make sure it's not just a plain letter, append a colon if necessary.
    sDriveLetter = UCase(Left(Trim(sDriveLetter),1)) & ":"
        
    For i = 0 to cDrives.Count - 1 Step 2 'Even items are letters, odds are UNCs.
        If cDrives.Item(i) = sDriveLetter Then 
            oWshNetwork.RemoveNetworkDrive sDriveLetter
        End If
    Next    
    
    'Return true whether the drive was unmapped or never mapped to begin with.
    If Err.Number = 0 Then UnMapDrive = True Else UnMapDrive = False
End Function



Function UnMapAllDrives()
    On Error Resume Next
    Dim oWshNetwork, cDrives, i
    
    Set oWshNetwork = WScript.CreateObject("WScript.Network")
    Set cDrives = oWshNetwork.EnumNetworkDrives
        
    For i = 0 to cDrives.Count - 1 Step 2  'Even items are letters, odds are UNCs.
        oWshNetwork.RemoveNetworkDrive cDrives.Item(i)
    Next    
    
    If Err.Number = 0 Then UnMapAllDrives = True Else UnMapAllDrives = False
End Function




'END OF SCRIPT *************************************************************




'Demo the functions:
WScript.Quit


sResult = MapDrive("\\127.0.0.1\c$") 

If sResult <> False Then
    WScript.Echo "Drive " & sResult & " successfully mapped!"
Else
    WScript.Echo "Failure. Drive letter not mapped."
End If

WScript.Quit



If UnMapDrive("g:") Then
    WScript.Echo "Network drive removed!"
Else
    WScript.Echo "Failure. Network drive not removed."
End If

WScript.Quit



If UnMapAllDrives() Then 
    WScript.Echo "All unmapped!"
Else
    WScript.Echo "Failure. One or more drives not unmapped."
End If 


