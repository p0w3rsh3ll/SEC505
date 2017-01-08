'**********************************************************************************
' Script Name: Append_To_File.vbs
'     Version: 1.3
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 28.Jul.2004
'     Purpose: Function to append line(s) to the end of a text file.  
'              If the file does not exist, it will be created.  If the full
'              path to the file is not supplied, it is assumed to be in the
'              same folder as the script.  Function returns true if no
'              errors, false otherwise.  
'       Notes: Because this function would repeatedly open and close the file,
'              this function is not appropriate for writing many lines to a single
'              file one line at a time.  Use the code chunk at the bottom for this,
'              or bundle the lines together before calling the function.  Many 
'              megabytes of text can be appended in one shot.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'**********************************************************************************


Function AppendToFile(sData, sFile)
    On Error Resume Next

    Const ForAppending =      8     'Request NTFS appending permission.
    Const ForOverWriting =    2     'Request NTFS writing permission.
    Const ForReading =        1     'Request NTFS read permission.
    Const OpenAsASCII =       0     'ASCII text format.
    Const OpenAsUnicode =    -1     'Unicode text format.
    Const OpenUsingDefault = -2     'ASCII is default for FAT32, Unicode default for NTFS.
    
    
    'Create FileSystemObject if it doesn't exist yet.
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")


    'Expand any environmental variables to their full paths.
    If InStr(sFile, "%") <> 0 Then
        If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell")
        sFile = oWshShell.ExpandEnvironmentStrings(sFile)
    End If 
    
    
    'Use current folder of script for output file path, if not path is given.    
    If InStr(sFile, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sFile = sCurrentFolder & sFile
    End If    

    
    'Get output file if it exists, or create one if it doesn't.
    If Not oFileSystem.FileExists(sFile) Then 
        Set oTextStream = oFileSystem.CreateTextFile(sFile)
    Else
        Set oFile = oFileSystem.GetFile(sFile)
        Set oTextStream = oFile.OpenAsTextStream(ForAppending, OpenUsingDefault)     
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



'END OF SCRIPT ********************************************************************



'The following demonstrates the function above.
sText = "Debugging scripts is like Zen while starving."
bFlag = AppendToFile(sText, "c:\test.txt")

For x = 1 to 100
    AppendToFile sText & x, "c:\test.txt"
Next


'If you will be writing many lines to a file, one line at a time, 
'then use something like this:
'
'   Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
'   Set oTextStream = oFileSystem.CreateTextFile("C:\test.txt")
'   For i = 0 to 1000
'       oTextStream.WriteLine("Debugging scripts is like Zen")
'   Next
'   oTextStream.Close
'
'Alternatively, bundle the lines together and write them all at
'once using the function above.  In any case, it is not efficient
'to call this function over-and-over again in short succession.  



