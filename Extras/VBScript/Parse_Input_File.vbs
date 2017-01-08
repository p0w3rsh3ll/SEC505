'*********************************************************************************
' Script Name: Parse_Input_File.vbs
'     Version: 1.2
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 15.Jul.2006
'     Purpose: Sorts lines of a text file into an array.
'       Usage: Function returns true if no problems, false otherwise.  Pass global
'              variable of an array into second argument of function; this will be
'              resized and populated with lines from text file.  Blank and empty
'              trailing lines from file, if any, are excluded from the array.  The
'              array global variable must be declared with "ReDim", not just "Dim".
'              The file can be passed in with full path or just the file name if
'              the file is in the same folder as the script.
'        Note: You must declare the global array variable with "ReDim" before 
'              passing it into the function; make it of size one because it
'              will be ReDim-ed without preservation again anyway.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Use at your own risk.  Do not run on networks for which you do not 
'              have prior written permission to do so.  Script provided "AS IS".
'*********************************************************************************


Function ParseInputFile(ByVal sFile, ByRef aArray)
    On Error Resume Next
    Const ForReading = 1
    Const OpenUsingDefault = -2
    Dim sCurrentFolder, oFileSystem, oInputFile, i, iCurrentSize
    Dim iPreserveCounter, oFile, oTextStream, iLineCount, sLine


    'Expand environmental variables, if any.
    If InStr(sFile, "%") <> 0 Then
        If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell")
        sFile = oWshShell.ExpandEnvironmentStrings(sFile)
    End If 


    'Assume input file is in current folder if a full path is not given.
    If InStr(sFile, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sFile = sCurrentFolder & sFile
    End If    


    'Verify that file exists and is readable, return false if not.
    If Not IsObject(oFileSystem) Then Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
    Set oFile = oFileSystem.GetFile(sFile)
    Set oTextStream = oFile.OpenAsTextStream(ForReading, OpenUsingDefault)  
    If Err.Number <> 0 Then
        'WScript.Echo "Problem opening " & sFile & " (" & Err.Description & ")"
        ParseInputFile = False
        Exit Function
    End If


    'Count the number of lines in file, not including an empty line at the very end (if present).
    iLineCount = 0
    Do While Not oTextStream.AtEndOfStream
        oTextStream.SkipLine
        iLineCount = iLineCount + 1
    Loop


    'ReDim the array to be equal to expected size of the input from file.
    If iLineCount <> 0 Then
        ReDim aArray(iLineCount - 1)  
        oTextStream.Close
        Set oTextStream = Nothing
    Else 'The input file was empty!
        ReDim aArray(0)
        'aArray(0) = ""    'Assign default here if desired.
        oTextStream.Close
        Set oTextStream = Nothing
        Set oFile = Nothing
        Set oFileSystem = Nothing
        If Err.Number = 0 Then 
            ParseInputFile = True
        Else
            ParseInputFile = False
        End If
        Exit Function
    End If


    'Read each line of file into an element of the array, excluding blank lines.
    Set oTextStream = oFile.OpenAsTextStream(ForReading, OpenUsingDefault)  
    i = 0
    iPreserveCounter = 0
    Do While Not oTextStream.AtEndOfStream
        sLine = Trim(oTextStream.ReadLine)    'Note the trimming here.   
        If Len(sLine) <> 0 Then 
            aArray(i) = sLine
            i = i + 1
        Else
            iPreserveCounter = iPreserveCounter + 1   'Keep track of blank lines.
        End If
    Loop
    oTextStream.Close
    Set oTextStream = Nothing
    
    
    'If there were blank lines in the file, trim the array of empty elements.
    If iPreserveCounter <> 0 Then
        iCurrentSize = UBound(aArray)
        ReDim Preserve aArray(iCurrentSize - iPreserveCounter)
    End If

    Set oFile = Nothing
    Set oFileSystem = Nothing
    
    If Err.Number = 0 Then
        ParseInputFile = True
    Else
        ParseInputFile = False
    End If
End Function


'END OF SCRIPT **********************************************************************************




'The following code demonstrates the procedure above.
ReDim aArray(1)  'MUST be a ReDim, not just a Dim of the array.
Dim x, sResult
If ParseInputFile(WScript.ScriptFullName, aArray) Then
    sResult = "Largest array element number = " & UBound(aArray) & vbCrLf
    For x = 0 to Ubound(aArray) 
        sResult = sResult & x & ": " & aArray(x) & vbCrLf
    Next
    WScript.Echo sResult
End If

