'*************************************************************************************
' Script Name: ISA_Fill_Computer_Set_Subnets.vbs
'     Version: 1.1
'      Author: Jason Fossen (www.ISAscripts.org)
'Last Updated: 24.Aug.2005
'     Purpose: Automatically update an ISA Server Computer Set with subnets; for example,
'              this could be used to regularly update the subnets in a Computer Set with
'              bogon routes or routes to unfriendly countries.
'   Arguments: First arg is name of Computer Set, in double-quotes if necessary.  The 
'              second arg is the HTTP URL, local full path, or file name (if in same
'              folder as script) of a text file containing the subnet data.  This file,
'              if it contains comments, must use #-marks or semicolons to denote comments.  
'              Each line can contain subnet data in one of two formats: 1) IP address space-char
'              dotted decimal mask, e.g., "10.0.0.0 255.0.0.0", or 2) IP address slash
'              CIDR bit number, e.g., "10.0.0.0/8".  For example, both of the following
'              files are in proper format and are regularly updated with bogon routes:
'                   http://www.completewhois.com/bogons/data/bogons-cidr-all.txt
'                   http://www.cymru.com/Documents/bogon-bn-agg.txt
'       Notes: Visit http://www.completewhois.com/bogons/ for bogon routes FAQ.
'              Take care that you do not block routes that you use inside your LAN!
'              Works on both ISA Standard and Enterprise.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Test on non-production servers first!  
'*************************************************************************************

Option Explicit
On Error Resume Next

ReDim aSubnetsArray(0)      'Array of subnets to be added to the Computer Set.
Dim sComputerSetName        'Name of Computer Set to be created and/or updated.
Dim bUseLocalSubnetsFile    'If true, use local file.  If false, get subnets from http URL.
Dim sSubnetsFilePath        'An HTTP URL or a local filesystem path to a file of subnets.
Dim oFPC                    'See MakeIsaObjects()
Dim oIsaArray               'See MakeIsaObjects()

Dim oFileSystem :  Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
Call CatchAnyErrorsAndQuit("Problems creating the FileSystemObject.")



'*************************************************************************************
' Main()
'*************************************************************************************
Call ProcessCommandLineArguments()
Call CreateIsaObjects()
Call MakeArrayOfSubnets()
Call CreateComputerSet()
Call DeleteCurrentSubnets()
Call CreateNewSubnets()




'*************************************************************************************
' Procedures
'*************************************************************************************


Sub ProcessCommandLineArguments()
    On Error Resume Next
    '
    ' First arg...
    '
    sComputerSetName = WScript.Arguments.Item(0)
    Dim sArg  : sArg  = LCase(sComputerSetName)      
    If (WScript.Arguments.Count = 0) Or (WScript.Arguments.Count => 3) Or (sArg = "/?")_ 
        Or (sArg = "-?") Or (sArg = "/h") Or (sArg = "/help") Or (sArg = "--help") Then
        Call ShowHelpAndQuit()
    End If
    
    '
    ' Second arg...
    '
    sSubnetsFilePath = WScript.Arguments.Item(1)
        
    If InStr(LCase(sSubnetsFilePath), "http://") = 0 Then 
        bUseLocalSubnetsFile = True   'Use a local text file.
    Else
        bUseLocalSubnetsFile = False  'Use an http URL.
    End If
    On Error Goto 0     'Error handling is not global, it's per-procedure.
End Sub



Sub CreateIsaObjects()
    'This sub is just a placeholder for something I'm adding later on...
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Call CatchAnyErrorsAndQuit("Problems connecting to ISA Server or ISA Array.")
End Sub



Sub MakeArrayOfSubnets()
    If bUseLocalSubnetsFile Then
        If Not ParseInputFile(sSubnetsFilePath, aSubnetsArray) Then
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems reading the local subnets file: " & sSubnetsFilePath)
        End If
    Else 'Get the subnets file from the http URL...
        Dim sUrlText : sUrlText = HttpGetText(sSubnetsFilePath)
        If InStr(sUrlText, "GET-Error!") <> 0 Then     ' "GET-Error!" would be returned by HttpGetText() function, not the web server.
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems getting subnets file from " & sUrlToSubnetsFile)
        End If
        
        If oFileSystem.FileExists("subnets-downloaded-from-url.txt") Then 
            oFileSystem.DeleteFile "subnets-downloaded-from-url.txt", True   'Delete prior subnets file, if it exists.
        End If
        
        If Not AppendToFile(sUrlText, "subnets-downloaded-from-url.txt") Then
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems writing to the subnets-downloaded-from-url.txt file.")
        End If
        
        If Not ParseInputFile("subnets-downloaded-from-url.txt", aSubnetsArray) Then
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems reading file: subnets-downloaded-from-url.txt")
        End If        
    End If

End Sub



Sub CreateComputerSet()
    On Error Resume Next 
    Dim cComputerSets    'FPCComputerSets collection.
    Dim cComputerSet     'FPCComputerSet collection.

    Set cComputerSets = oIsaArray.RuleElements.ComputerSets
    Set cComputerSet = cComputerSets.Add(sComputerSetName)
    cComputerSet.Description = "Only add subnets to this Computer Set with the script.  Subnets added by hand will be removed the next time the script is run."
    cComputerSet.Save
    If Err.Number = 424 Then Err.Clear  'The Computer Set already exists, so ignore error.
    Call CatchAnyErrorsAndQuit("Problems creating the Computer Set named " & sComputerSetName)    
End Sub



Sub DeleteCurrentSubnets()
    Dim cSubnets      'FPCURLSets collection.
    Dim oSubnet       'FPCSubnet object.
    Dim cComputerSet  'FPCComputerSet collection.
    Dim cComputerSets 'FPCComputerSets collection.
    
    Set cComputerSets = oIsaArray.RuleElements.ComputerSets
    Set cComputerSet = cComputerSets.Item(sComputerSetName)
    Set cSubnets = cComputerSet.Subnets
    
    For Each oSubnet In cSubnets
        cSubnets.Remove(oSubnet.Name)        
    Next

    cSubnets.Save

    Call CatchAnyErrorsAndQuit("Problems deleting current subnets in " & sComputerSetName)
End Sub



Sub CreateNewSubnets()
    Dim cSubnets    'FPCURLSets collection.
    Dim oSubnet     'FPCSubnet object.
    Dim cComputerSet  'FPCComputerSet collection.
    Dim cComputerSets 'FPCComputerSets collection.
    Dim sIPaddress, sMask, sLine, sSubnetName
    
    Set cComputerSets = oIsaArray.RuleElements.ComputerSets
    Set cComputerSet = cComputerSets.Item(sComputerSetName)
    Set cSubnets = cComputerSet.Subnets

    Dim i : i = 1
    For Each sLine In aSubnetsArray
        If ((Left(sLine, 1) <> "#") And (Left(sLine, 1) <> ";") And (Left(sLine, 1) <> "<")) Then
            sSubnetName = "Subnet_" & i

            If InStr(sLine,"/") = 0 Then   
                sIPaddress = Trim(Left(sLine, InStrRev(sLine, " ") - 1))
                sMask = Trim(Right(sLine, Len(sLine) - InStrRev(sLine, " ")))  'Mask is dotted decimal, e.g., "10.0.0.0 255.0.0.0"
            Else
                sIPaddress = Trim(Left(sLine, InStrRev(sLine, "/") - 1))
                sMask = Trim(Right(sLine, Len(sLine) - InStrRev(sLine, "/")))  'Mask is bit notation, e.g, "10.0.0.0/8"
                If InStr(sMask,".") = 0 Then sMask = BitCountToDottedDecimal(sMask) 
            End If

            Set oSubnet = cSubnets.Add(sSubnetName, sIPaddress, sMask)
            i = i + 1
        End If
    Next
    
    cSubnets.Save

    Call CatchAnyErrorsAndQuit("Problems creating new subnet objects in " & sComputerSetName)
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
    sUsage = sUsage & "ISA_FILL_COMPUTER_SET_SUBNETS.VBS ComputerSetName FilePath" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Creates or updates an ISA Server Computer Set (`ComputerSetName`)" & vbCrLf
    sUsage = sUsage & "with the subnets from a text file (`FilePath`) obtained from" & vbCrLf
    sUsage = sUsage & "either an HTTP URL or a local filesystem path." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    ComputerSetName    Name of Computer Set to be created or" & vbCrLf
    sUsage = sUsage & "                       updated with subnet entries.  Will be" & vbCrLf
    sUsage = sUsage & "                       created in the local ISA Server or" & vbCrLf
    sUsage = sUsage & "                       current ISA Server Array." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    FilePath           A full HTTP URL or local filesystem path" & vbCrLf
    sUsage = sUsage & "                       to a text file containing subnets.  All" & vbCrLf
    sUsage = sUsage & "                       comments must start with # or ;, and subnets" & vbCrLf
    sUsage = sUsage & "                       must be formatted either like `10.0.0.0/8`" & vbCrLf
    sUsage = sUsage & "                       or `10.0.0.0 255.0.0.0`.  Example paths" & vbCrLf
    sUsage = sUsage & "                       might be `filename.txt`, `c:\filename.txt`," & vbCrLf
    sUsage = sUsage & "                       or `http://www.fqdn.com/filename.asp`." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Note that all subnets defined in the Computer Set are deleted" & vbCrLf
    sUsage = sUsage & "prior to importing the subnets from the text file.  If necessary," & vbCrLf
    sUsage = sUsage & "the Computer Set object will be created.  Place double-quotes" & vbCrLf
    sUsage = sUsage & "around the ComputerSetName and FilePath arguments if they contain" & vbCrLf
    sUsage = sUsage & "any space characters.  When providing an HTTP URL, the downloaded" & vbCrLf
    sUsage = sUsage & "file will be saved as 'subnets-downloaded-from-url.txt` in the " & vbCrLf
    sUsage = sUsage & "same folder as the script; it will be overwritten whenever a URL" & vbCrLf
    sUsage = sUsage & "path is used.  Script must be run on the ISA Server itself." & vbCrLf
    sUsage = sUsage & vbCrLf     
    sUsage = sUsage & "Script is public domain, like all the scripts at www.ISAscripts.org" & vbCrLf
    sUsage = sUsage & "SCRIPT PROVIDED ""AS IS"" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND." & vbCrLf    
    sUsage = sUsage & vbCrLf

    WScript.Echo sUsage
    WScript.Quit
End Sub



'*************************************************************************************
' Functions
'*************************************************************************************



Function HttpGetText(sURL)
    On Error Resume Next
    
    If Not IsObject(oHTTP) Then Dim oHTTP : Set oHTTP = WScript.CreateObject("Microsoft.XMLHTTP")

    oHTTP.Open "GET", sURL, False       'False = Script waits until the full HTTP response is received.
    oHTTP.Send                          'Send the HTTP command as defined with the Open method.
    
    If Err.Number = 0 Then
        HttpGetText = oHTTP.ResponseText
        HttpGetText = Replace(HttpGetText, vbLf, vbCrLf)  'Flip UNIX new lines to DOS, if necessary.
    Else
        HttpGetText = "GET-Error! Error Number: " & Err.Number
    End If
End Function



Function BitCountToDottedDecimal(iBits)
    ' Convert a CIDR bit notation number to dotted decimal subnet mask.
    ' For example, convert "8" in 10.0.0.0/8 to "255.0.0.0". 
    Dim iMask, sMask 
    iMask = CInt(Trim(CStr(iBits)))
    Select Case iMask
        Case 0  : sMask = "0.0.0.0"
        Case 1  : sMask = "128.0.0.0"
        Case 2  : sMask = "192.0.0.0"
        Case 3  : sMask = "224.0.0.0"
        Case 4  : sMask = "240.0.0.0" 
        Case 5  : sMask = "248.0.0.0"
        Case 6  : sMask = "252.0.0.0"
        Case 7  : sMask = "254.0.0.0"
        Case 8  : sMask = "255.0.0.0"
        Case 9  : sMask = "255.128.0.0"
        Case 10 : sMask = "255.192.0.0"
        Case 11 : sMask = "255.224.0.0"
        Case 12 : sMask = "255.240.0.0"
        Case 13 : sMask = "255.248.0.0"
        Case 14 : sMask = "255.252.0.0"
        Case 15 : sMask = "255.254.0.0"
        Case 16 : sMask = "255.255.0.0"
        Case 17 : sMask = "255.255.128.0"
        Case 18 : sMask = "255.255.192.0"
        Case 19 : sMask = "255.255.224.0"
        Case 20 : sMask = "255.255.240.0"
        Case 21 : sMask = "255.255.248.0"
        Case 22 : sMask = "255.255.252.0"
        Case 23 : sMask = "255.255.254.0"
        Case 24 : sMask = "255.255.255.0"
        Case 25 : sMask = "255.255.255.128"
        Case 26 : sMask = "255.255.255.192"
        Case 27 : sMask = "255.255.255.224"
        Case 28 : sMask = "255.255.255.240"
        Case 29 : sMask = "255.255.255.248"
        Case 30 : sMask = "255.255.255.252"
        Case 31 : sMask = "255.255.255.254"
        Case 32 : sMask = "255.255.255.255" 
        Case Else sMask = "ERROR"
    End Select
    BitCountToDottedDecimal = sMask
End Function



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



'**********************************************************************************
' Script Name: Append_To_File.vbs
'     Version: 1.3
'      Author: Jason Fossen 
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
    
    Dim sCurrentFolder, oTextStream
    
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



'END OF SCRIPT************************************************************************











