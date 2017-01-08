'*************************************************************************************
' Script Name: ISA_Fill_Domain_Name_Set.vbs
'     Version: 1.2
'      Author: Jason Fossen ( www.ISAscripts.org ) 
'Last Updated: 18.Feb.2008
'     Purpose: Automatically update an ISA Server Domain Name Set with domains; for example,
'              these could be domains of spammers, pornographers, hacking sites, etc.
'   Arguments: First arg is name of Domain Name Set, in double-quotes if necessary.  The 
'              second arg is the HTTP URL, local full path, or file name (if in same
'              folder as script) of a text file containing the domain data.  This file,
'              if it contains comments, must use #-marks or semicolons to denote comments.  
'              Each line must be just a domain name, but if IP addresses are in the list, they
'              will be ignored automatically.  This script is compatible with, but does not
'              require or depend on, the lists at:
'                   http://urlblacklist.com
'                   http://www.squidguard.org/blacklists/
'              It also works if a listed domain begins or ends with a period, or begins 
'              with "*." as a wildcard.  The file with the domains can use either 
'              Windows-style or UNIX-style newlines, it's compatible with both.  Note that
'              each domain will be added twice: once with a prepended "*." and another
'              without the leading "*." wildcard, since ISA won't match on just the plain
'              domain name in a URL if the domain has "*." prepended to it in the set.
'        Note: Depending on the speed of the ISA box, importing a 10MB file with 500,000
'              domains can take between two and four hours.  This is a bottleneck imposed
'              by ISA, not the Windows Script Host or VBScript.  Hence, schedule your
'              imports during off-peak hours and run the script with the Start command
'              to launch it with a lower multi-tasking priority; for example, like this:
'                    "start /belownormal cscript.exe ImportBlacklist.vbs Bad-Sites domains"
'        Note: The fastest way to see that the Domain Name Set had been filled correctly
'              is to close and open the ISA MMC console again, not by refreshing.
'              Works on both ISA Standard and Enterprise.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Test on non-production servers first!  
'*************************************************************************************

Option Explicit
On Error Resume Next

ReDim aDomainsArray(0)      'Array of Domains to be added to the Domain Name Set.
Dim sDomainNameSetName      'Name of Domain Name Set to be created and/or updated.
Dim bUseLocalDomainsFile    'If true, use local file.  If false, get domains from http URL.
Dim sDomainsFilePath        'An HTTP URL or a local filesystem path to a file of domains.
Dim oFPC                    'See MakeIsaObjects()
Dim oIsaArray               'See MakeIsaObjects()

Dim oFileSystem :  Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
Call CatchAnyErrorsAndQuit("Problems creating the FileSystemObject.")



'*************************************************************************************
' Main()
'*************************************************************************************
Call ProcessCommandLineArguments()
Call CreateIsaObjects()
Call MakeArrayOfDomains()
Call CreateDomainNameSet()
Call EmptyTheDomainNameSet()
Call CreateNewDomains()




'*************************************************************************************
' Procedures
'*************************************************************************************


Sub ProcessCommandLineArguments()
    On Error Resume Next
    '
    ' First arg...
    '
    sDomainNameSetName = WScript.Arguments.Item(0)
    Dim sArg  : sArg  = LCase(sDomainNameSetName)      
    If (WScript.Arguments.Count = 0) Or (WScript.Arguments.Count => 3) Or (sArg = "/?")_ 
        Or (sArg = "-?") Or (sArg = "/h") Or (sArg = "/help") Or (sArg = "--help") Then
        Call ShowHelpAndQuit()
    End If
    
    '
    ' Second arg...
    '
    sDomainsFilePath = WScript.Arguments.Item(1)
        
    If InStr(LCase(sDomainsFilePath), "http://") = 0 Then 
        bUseLocalDomainsFile = True   'Use a local text file.
    Else
        bUseLocalDomainsFile = False  'Use an http URL.
    End If
    On Error Goto 0     
End Sub



Sub CreateIsaObjects()
    'This sub is just a placeholder for something to add later on...
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Call CatchAnyErrorsAndQuit("Problems connecting to ISA Server or ISA Array.")
End Sub



Sub MakeArrayOfDomains()
    If bUseLocalDomainsFile Then
        If Not ParseInputFile(sDomainsFilePath, aDomainsArray) Then
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems reading the local domains file: " & sDomainsFilePath)
        End If
    Else 'Get the domains file from the http URL...
        Dim sUrlText : sUrlText = HttpGetText(sDomainsFilePath)
        If InStr(sUrlText, "GET-Error!") <> 0 Then     ' "GET-Error!" would be returned by HttpGetText() function, not the web server.
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems getting domains file from " & sUrlToDomainsFile)
        End If
        
        If oFileSystem.FileExists("domains-downloaded-from-url.txt") Then 
            oFileSystem.DeleteFile "domains-downloaded-from-url.txt", True   'Delete prior domains file, if it exists.
        End If
        
        If Not AppendToFile(sUrlText, "domains-downloaded-from-url.txt") Then
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems writing to the domains-downloaded-from-url.txt file.")
        End If
        
        If Not ParseInputFile("domains-downloaded-from-url.txt", aDomainsArray) Then
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems reading file: domains-downloaded-from-url.txt")
        End If        
    End If

End Sub



Sub CreateDomainNameSet()
    On Error Resume Next
    Dim cDomainNameSets    'FPCDomainNameSets collection.
    Dim oDomainNameSet     'FPCDomainNameSet object.
    
    'Set oFPC = CreateObject("FPC.Root")
    'Set oIsaArray = oFPC.GetContainingArray
    Set cDomainNameSets = oIsaArray.RuleElements.DomainNameSets 
    
    Set oDomainNameSet = cDomainNameSets.Add(sDomainNameSetName)
    
	If Err.Number = -2147024713 Then
	    Err.Clear  'Already exists, so ignore error. 
	Else
        cDomainNameSets.Save    
    End If

    Call CatchAnyErrorsAndQuit("Problems recreating Domain Name Set named " & sDomainNameSetName)
    On Error Goto 0
End Sub



Sub EmptyTheDomainNameSet()
    'Note: Clear the Domain Name Set instead of deleting it because it may be used in rules already.
    Dim cDomainNameSets    'FPCDomainNameSets collection.
    Dim cDomainNameSet     'FPCDomainNameSet collection.
    Dim sDomain
    
    'Set oFPC = CreateObject("FPC.Root")
    'Set oIsaArray = oFPC.GetContainingArray
    Set cDomainNameSet = oIsaArray.RuleElements.DomainNameSets.Item(sDomainNameSetName) 
    
    For Each sDomain In cDomainNameSet
        cDomainNameSet.Remove(sDomain)
    Next
    
    cDomainNameSet.Save    

    Call CatchAnyErrorsAndQuit("Problems emptying Domain Name Set named " & sDomainNameSetName)
End Sub



Sub CreateNewDomains()
    On Error Resume Next
    Dim cDomains        'FPCURLSets collection.
    Dim oDomain         'FPCDomain object.
    Dim cDomainNameSet  'FPCDomainNameSet collection.
    Dim cDomainNameSets 'FPCDomainNameSets collection.
    Dim sIPaddress, sMask, sDomain, sDomainName
    
    Set cDomainNameSet = oIsaArray.RuleElements.DomainNameSets.Item(sDomainNameSetName)

    For Each sDomain In aDomainsArray
        If (Left(sDomain, 1) <> "#") And (Left(sDomain, 1) <> ";") And (Left(sDomain, 1) <> "<") And (Len(sDomain) <> 0) And Not IsIpAddress(sDomain) Then
            If Right(sDomain,1) = "." Then sDomain = Left(sDomain, Len(sDomain) - 1) 'Trim off a trailing period, if present.
            If Left(sDomain,2) <> "*." Then sDomain = "*." & sDomain                 'Prepend "*." if not already there.
            sDomain = Replace(sDomain, "..", ".")                                    'Correct if first char was already a period.
            cDomainNameSet.Add(sDomain)
            If Err.Number = -2147024713 Then Err.Clear                               'Domain already added, so ignore error.
            
            'Comment out the next three lines if you don't want the plain "domain.com" entries added too (the ones without the leading "*.").  
            sDomain = Trim(Replace(sDomain, "*.", ""))
            cDomainNameSet.Add(sDomain)
            If Err.Number = -2147024713 Then Err.Clear                               'Domain already added, so ignore error.
        End If
    Next
    
    cDomainNameSet.Save

    Call CatchAnyErrorsAndQuit("Problems creating new domain objects in " & sDomainNameSetName)
    On Error Goto 0
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
    sUsage = sUsage & "ISA_FILL_DOMAIN_NAME_SET.VBS DomainNameSetName FilePath" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Creates or updates an ISA Server Domain Name Set (`DomainNameSet`)" & vbCrLf
    sUsage = sUsage & "with the domains from a text file (`FilePath`) obtained from" & vbCrLf
    sUsage = sUsage & "either an HTTP URL or a local filesystem path." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    DomainNameSet      Name of Domain Name Set to be created or" & vbCrLf
    sUsage = sUsage & "                       updated with domain entries.  Will be" & vbCrLf
    sUsage = sUsage & "                       created in the local ISA Server or" & vbCrLf
    sUsage = sUsage & "                       current ISA Server Array." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    FilePath           A full HTTP URL or local filesystem path" & vbCrLf
    sUsage = sUsage & "                       to a text file containing domains.  All" & vbCrLf
    sUsage = sUsage & "                       comments must start with # or ;. Examples" & vbCrLf
    sUsage = sUsage & "                       might be `filename.txt`, `c:\filename.txt`," & vbCrLf
    sUsage = sUsage & "                       or `http://www.fqdn.com/filename.asp`." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Note that all domains defined in the Domain Name Set are deleted" & vbCrLf
    sUsage = sUsage & "prior to importing the domains from the text file.  If necessary," & vbCrLf
    sUsage = sUsage & "the Domain Name Set object will be created.  Place double-quotes" & vbCrLf
    sUsage = sUsage & "around the DomainNameSet and FilePath arguments if they contain" & vbCrLf
    sUsage = sUsage & "any space characters.  When providing an HTTP URL, the downloaded" & vbCrLf
    sUsage = sUsage & "file will be saved as 'domains-downloaded-from-url.txt` in the " & vbCrLf
    sUsage = sUsage & "same folder as the script; it will be overwritten whenever a URL" & vbCrLf
    sUsage = sUsage & "path is used again.  Script must be run on the ISA Server itself." & vbCrLf
    sUsage = sUsage & vbCrLf     
    sUsage = sUsage & "SCRIPT PROVIDED ""AS IS"" AND WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND." & vbCrLf
    sUsage = sUsage & "USE AT YOUR OWN RISK.  ( www.ISAscripts.org )" & vbCrLf
    sUsage = sUsage & vbCrLf

    WScript.Echo sUsage
    WScript.Quit
End Sub



'*************************************************************************************
' Functions
'*************************************************************************************

Function IsIpAddress(sInput)
    'Regular expression would be more accurate, but slower...quick-n-dirty will do since
    'having a "*.dottedIPaddress" domain doesn't break anything if an IP address sneaks by...
    
    IsIpAddress = False
    
    Dim sEnd
    sInput = LCase(sInput)
    sEnd = Right(sInput,1) 'This will catch 98% of cases, so it's faster than RegEx.
    If (sEnd = "m") Or (sEnd = "u") Or (sEnd = "l") Or (sEnd = "v") Or (sEnd = "g")_
        Or (sEnd = "t") Or (sEnd = "z") Or (sEnd = "o") Or (sEnd = "e") Or (sEnd = "s")_
        Or (sEnd = "r") Or (sEnd = "n") Or (sEnd = "c") Or (sEnd = "k") Or (sEnd = "e") Then Exit Function

    Dim aArray, x
    aArray = Split(sInput,".") 
    If UBound(aArray) <> 3 Then Exit Function
    
    If Not (IsNumeric(aArray(0)) And IsNumeric(aArray(1)) And IsNumeric(aArray(2)) And IsNumeric(aArray(3))) Then Exit Function
    
    IsIpAddress = True
End Function



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
'              file one line at a time. Many megs of text can be appended in one shot.
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

