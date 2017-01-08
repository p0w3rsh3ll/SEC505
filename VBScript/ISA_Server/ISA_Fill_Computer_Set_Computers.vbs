'*************************************************************************************
' Script Name: ISA_Fill_Computer_Set_Computers.vbs
'     Version: 1.1
'      Author: Jason Fossen ( www.ISAscripts.org )
'Last Updated: 1.Sep.2005
'     Purpose: Create or update an ISA Server Computer Set with computer objects.
'              The current computer objects in the Set are all deleted before the
'              new ones from the file are added, but only computer objects are deleted.
'   Arguments: First arg is the name of Computer Set, in double-quotes if necessary.   
'              The second arg is the local full path or file name (if in 
'              same folder as script) of a text file containing the computers and IP
'              addresses.  Each line should consist of a computer host name or FQDN
'              followed by a delimeter and then the IP address.  The delimeter can
'              be a space, comma, tab, semicolon, colon, forwardslash or backslash.  
'              Any comments must begin with a "#" or ";" or "<".  Blank lines are
'              ignored and will not cause problems.  Previously existing Computer
'              Sets will be updated, not completely deleted.
'       Notes: Works on both ISA Standard and Enterprise.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Test on non-production servers first.
'*************************************************************************************

Option Explicit
On Error Resume Next

ReDim aComputersArray(0)    'Array of computers to be added to the Computer Set.
Dim sComputerSetName        'Name of Computer Set to be created and/or updated.
Dim sComputersFilePath      'A local filesystem path to a file of computers.
Dim oFPC                    'See MakeIsaObjects()
Dim oIsaArray               'See MakeIsaObjects()

Dim oFileSystem :  Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
Call CatchAnyErrorsAndQuit("Problems creating the FileSystemObject.")



'*************************************************************************************
' Main()
'*************************************************************************************
Call ProcessCommandLineArguments()
Call CreateComputerSet()
Call CreateComputers()




'*************************************************************************************
' Procedures
'*************************************************************************************


Sub ProcessCommandLineArguments()
    On Error Resume Next
    'Get command line arguments, show Help if necessary.
    If WScript.Arguments.Count <> 2 Then Call ShowHelpAndQuit()
    sComputerSetName = WScript.Arguments.Item(0)
    sComputersFilePath = WScript.Arguments.Item(1)
    Call CatchAnyErrorsAndQuit("Problems processing command line arguments.")
    
    'Create global ISA objects and puke on any errors.
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Call CatchAnyErrorsAndQuit("Problems connecting to ISA Server array.")

    'Now parse the text file into an array or puke.
    If Not ParseInputFile(sComputersFilePath, aComputersArray) Then
        Err.Raise -1
        Call CatchAnyErrorsAndQuit("Problems reading the file: " & sComputersFilePath)
    End If
End Sub



Sub CreateComputerSet()
    On Error Resume Next 
    Dim cComputerSets    'FPCComputerSets collection.
    Dim cComputerSet     'FPCComputerSet collection.

    Set cComputerSets = oIsaArray.RuleElements.ComputerSets
    Set cComputerSet = cComputerSets.Add(sComputerSetName)
    
    If Err.Number = 0 Then
        cComputerSet.Description = "Only add computers to this Computer Set with the script. Items added by hand will be removed the next time the script is run."
        cComputerSet.Save
    Else
        If Err.Number = -2147024713 Then Err.Clear  'The Computer Set already exists, so ignore error.
    End If
    
    Call CatchAnyErrorsAndQuit("Problems creating the Computer Set named " & sComputerSetName)
End Sub



Sub CreateComputers()
    On Error Resume Next
    Dim cComputers      'FPCURLSets collection.
    Dim oComputer       'FPCComputer object.
    Dim cComputerSet    'FPCComputerSet collection.
    Dim cComputerSets   'FPCComputerSets collection.
    Dim sLine, sDelimeter, sComputerName, sIPaddress
    
    Set cComputerSets = oIsaArray.RuleElements.ComputerSets
    Set cComputerSet = cComputerSets.Item(sComputerSetName)
    Set cComputers = cComputerSet.Computers
    
    'Delete any computer objects in the set.  Notice that only computer objects are deleted, 
    'hence, you can fill the set with other types of objects with other scripts.
    For Each oComputer In cComputers
        cComputers.Remove(oComputer.Name)        
    Next
    Call CatchAnyErrorsAndQuit("Problems deleting current computers in " & sComputerSetName)

    'Parse the array of lines from text file and create new computer objects.
    For Each sLine In aComputersArray
        If ((Left(sLine, 1) <> "#") And (Left(sLine, 1) <> ";") And (Left(sLine, 1) <> "<")) Then 
        
            'Assume delimeter is a single space character, but check for other common delimeters.
            sDelimeter = " "  
            If InStr(sLine, vbTab) <> 0 Then sDelimeter = vbTab
            If InStr(sLine, ",") <> 0   Then sDelimeter = ","
            If InStr(sLine, ";") <> 0   Then sDelimeter = ";"
            If InStr(sLine, ":") <> 0   Then sDelimeter = ":" 
            If InStr(sLine, "/") <> 0   Then sDelimeter = "/" 
            If InStr(sLine, "\") <> 0   Then sDelimeter = "\" 
            
            'Extract the two elements of each line, given the delimeter.
            sComputerName  = Trim( Left(sLine, InStrRev(sLine, sDelimeter) - 1))
            sIPaddress = Trim(Right(sLine, Len(sLine) - InStrRev(sLine, sDelimeter)))

            Set oComputer = cComputers.Add(sComputerName, sIPaddress)

            If Err.Number = -1073478910 Then 
                WScript.Echo sIPaddress & " is not a valid IP address (entered with " & sComputerName & ")."
                Err.Clear
            End If

            If Err.Number = -2147024713 Then 
                WScript.Echo sComputerName & " already exists, not added again (entered with " & sIPaddress & ")." 
                Err.Clear 
            End If
            
        End If
    Next
    
    cComputers.Save

    Call CatchAnyErrorsAndQuit("Problems creating new computer objects in " & sComputerSetName)
End Sub



Sub CatchAnyErrorsAndQuit(sMessage)
    Dim oStdErr
    If Err.Number <> 0 Then
        Set oStdErr  = WScript.StdErr  'Write to standard error stream.
        oStdErr.WriteLine vbCrLf
        oStdErr.WriteLine ">>>>>> ERROR: " & sMessage 
        oStdErr.WriteLine "Error Number: " & Err.Number 
        oStdErr.WriteLine " Description: " & Err.Description 
        oStdErr.WriteLine "Error Source: " & Err.Source  
        oStdErr.WriteLine " Script Name: " & WScript.ScriptName 
        oStdErr.WriteLine vbCrLf
        WScript.Quit Err.Number
    End If 
End Sub 



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_FILL_COMPUTER_SET_COMPUTERS.VBS setname file.txt [/?]" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Purpose: Create or update a Computer Set in ISA Server with hostnames and" & vbCrLf
    sUsage = sUsage & "         IP addresses from a text file. Clears current computers in the" & vbCrLf
    sUsage = sUsage & "         Computer Set before the new ones are added." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   Args: setname  -- Name of the Computer Set to be created or updated." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "         file.txt -- Text file of computernames or FQDNs along with their" & vbCrLf
    sUsage = sUsage & "                     IP addresses.  Each line must be a hostname, a" & vbCrLf
    sUsage = sUsage & "                     delimeter, then an IP address.  The delimeter can be" & vbCrLf
    sUsage = sUsage & "                     a space, comma, semicolon, colon, tab, backslash," & vbCrLf
    sUsage = sUsage & "                     or forwardslash. Comment lines must begin with ""#""," & vbCrLf
    sUsage = sUsage & "                     "";"" or ""<"".  Blank lines are ignored.  The hostname" & vbCrLf
    sUsage = sUsage & "                     can be a simple computername or a fully qualified" & vbCrLf
    sUsage = sUsage & "                     domain name." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "  Legal: Public domain. No rights reserved. SCRIPT PROVIDED ""AS IS"" WITH- " & vbCrLf
    sUsage = sUsage & "         OUT WARRANTIES OR GUARANTEES OF ANY KIND. USE AT YOUR OWN RISK." & vbCrLf
    sUsage = sUsage & "         ( www.ISAscripts.org )" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & " " & vbCrLf
    sUsage = sUsage & vbCrLf
    
    WScript.Echo sUsage
    WScript.Quit
End Sub




'*********************************************************************************
' Script Name: Parse_Input_File.vbs
'     Version: 1.1
'      Author: Jason Fossen
'Last Updated: 29.Mar.2004
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


'END OF SCRIPT************************************************************************

