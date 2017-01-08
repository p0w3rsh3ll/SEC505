'*************************************************************************************
' Script Name: ISA_Fill_URL_Set.vbs
'     Version: 1.3
'      Author: Jason Fossen ( www.ISAscripts.org ) 
'Last Updated: 10.Jun.2008
'     Purpose: Automatically update an ISA Server URL Set with URLs; for example,
'              these could be URLs of spammers, pornographers, hacking sites, etc.
'   Arguments: First arg is name of URL Set, in double-quotes if necessary.  The 
'              second arg is the HTTP URL, local full path, or file name (if in same
'              folder as script) of a text file containing the URL data.  This file,
'              if it contains comments, must use #-marks or semicolons to denote comments.  
'              Each line must be just one URL.  
'              This script is compatible with the lists at www.urlblacklist.com and 
'              with other similarly-formatted lists of URLs.  The file with URLs can 
'              use either Windows-style or UNIX-style newlines, both work fine.
'        Note: The fastest way to see that the URL Set had been filled correctly
'              is to close and open the ISA MMC console again, not by refreshing.
'              Works on both ISA Standard and Enterprise editions.
'               Thanks to Alexander Willacker for the /*pendstar switches!
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Test on non-production servers first!  
'*************************************************************************************

Option Explicit
On Error Resume Next

ReDim aURLsArray(0)                     'Array of URLs to be added to the URL Set.
Dim sUrlSetName                         'Name of URL Set to be created and/or updated.
Dim bUseLocalURLsFile                   'If true, use local file.  If false, get URLs from http URL.
Dim sURLsFilePath                       'An HTTP URL or a local filesystem path to a file of URLs.
Dim oFPC                                'See MakeIsaObjects()
Dim oIsaArray                           'See MakeIsaObjects()
Dim bAppendStar : bAppendStar = False   'Assume that a trailing asterisk should not be added.
Dim bPrependStar : bPrependStar = False   'Assume that a leading asterisk & dot should not be added.

Dim oFileSystem :  Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
Call CatchAnyErrorsAndQuit("Problems creating the FileSystemObject.")



'*************************************************************************************
' Main()
'*************************************************************************************
Call ProcessCommandLineArguments()
Call CreateIsaObjects()
Call MakeArrayOfURLs()
Call CreateUrlSet()
Call EmptyTheUrlSet()
Call CreateNewURLs()


'*************************************************************************************
' Procedures
'*************************************************************************************


Sub ProcessCommandLineArguments()
    On Error Resume Next
    '
    ' First arg...
    '
    sUrlSetName = WScript.Arguments.Item(0)
    Dim sArg  : sArg  = LCase(sUrlSetName)      
    If (WScript.Arguments.Count = 0) Or (WScript.Arguments.Count > 4) Or (sArg = "/?")_ 
        Or (sArg = "-?") Or (sArg = "/h") Or (sArg = "/help") Or (sArg = "--help") Then
        Call ShowHelpAndQuit()
    End If
    
    '
    ' Second arg...
    '
    sURLsFilePath = WScript.Arguments.Item(1)
        
    If InStr(LCase(sURLsFilePath), "http://") = 0 Then 
        bUseLocalURLsFile = True   'Use a local text file.
    Else
        bUseLocalURLsFile = False  'Use an http URL.
    End If
    
    '
    ' Check to see whether a trailing asterisk should be added if not already present.
    '
    For Each sArg In WScript.Arguments 
        If LCase(sArg) = "/appendstar" Then bAppendStar = True
    Next

    '
    ' Check to see whether a leading asterisk should be added if not already present.
    '
    For Each sArg In WScript.Arguments 
        If LCase(sArg) = "/prependstar" Then bPrependStar = True
    Next

    On Error Goto 0     
End Sub



Sub CreateIsaObjects()
    'This sub is just a placeholder for something to add later on...
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Call CatchAnyErrorsAndQuit("Problems connecting to ISA Server or ISA Array.")
End Sub



Sub MakeArrayOfURLs()
    If bUseLocalURLsFile Then
        If Not ParseInputFile(sURLsFilePath, aURLsArray) Then
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems reading the local URLs file: " & sURLsFilePath)
        End If
    Else 'Get the URLs file from the http URL...
        Dim sUrlText : sUrlText = HttpGetText(sURLsFilePath)
        If InStr(sUrlText, "GET-Error!") <> 0 Then     ' "GET-Error!" would be returned by HttpGetText() function, not the web server.
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems getting URLs file from " & sUrlToURLsFile)
        End If
        
        If oFileSystem.FileExists("URLs-downloaded-from-url.txt") Then 
            oFileSystem.DeleteFile "URLs-downloaded-from-url.txt", True   'Delete prior URLs file, if it exists.
        End If
        
        If Not AppendToFile(sUrlText, "URLs-downloaded-from-url.txt") Then
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems writing to the URLs-downloaded-from-url.txt file.")
        End If
        
        If Not ParseInputFile("URLs-downloaded-from-url.txt", aURLsArray) Then
            Err.Raise -1
            Call CatchAnyErrorsAndQuit("Problems reading file: URLs-downloaded-from-url.txt")
        End If        
    End If

End Sub



Sub CreateUrlSet()
    On Error Resume Next
    Dim cUrlSets    'FPCUrlSets collection.
    Dim oUrlSet     'FPCUrlSet object.
    
    'Set oFPC = CreateObject("FPC.Root")
    'Set oIsaArray = oFPC.GetContainingArray
    Set cUrlSets = oIsaArray.RuleElements.UrlSets 
    
    Set oUrlSet = cUrlSets.Add(sUrlSetName)
    
                If Err.Number = -2147024713 Then
                    Err.Clear  'Already exists, so ignore error. 
                Else
        cUrlSets.Save    
    End If

    Call CatchAnyErrorsAndQuit("Problems recreating URL Set named " & sUrlSetName)
    On Error Goto 0
End Sub



Sub EmptyTheUrlSet()
    'Note: Clear the URL Set instead of deleting it because it may be used in rules already.
    Dim cUrlSets    'FPCUrlSets collection.
    Dim cUrlSet     'FPCUrlSet collection.
    Dim sURL
    
    'Set oFPC = CreateObject("FPC.Root")
    'Set oIsaArray = oFPC.GetContainingArray
    Set cUrlSet = oIsaArray.RuleElements.UrlSets.Item(sUrlSetName) 
    
    For Each sURL In cUrlSet
        cUrlSet.Remove(sURL)
    Next
    
    cUrlSet.Save    

    Call CatchAnyErrorsAndQuit("Problems emptying URL Set named " & sUrlSetName)
End Sub



Sub CreateNewURLs()
    On Error Resume Next
    Dim cURLs        'FPCURLSets collection.
    Dim oURL         'FPCURL object.
    Dim cUrlSet  'FPCUrlSet collection.
    Dim cUrlSets 'FPCUrlSets collection.
    Dim sIPaddress, sMask, sURL, sURLName, sLeftChar
    
    Set cUrlSet = oIsaArray.RuleElements.UrlSets.Item(sUrlSetName)

    For Each sURL In aURLsArray
        If Len(sURL) <> 0 Then
            sLeftChar = Left(sURL,1)
            If (sLeftChar <> "#") And (sLeftChar <> ";") And (sLeftChar <> "<") Then
            
                If bAppendStar Then
                    'It might seem strange, but appending an asterisk to the end seems not to interfere with any
                    'other matching, and is probably the behavior most admins want anyway.  It even works fine 
                    'when you get entries like "www.domain.com*" and "www.domain.com/folder/file.html*".
                    
                    sURL = sURL & "*"                   'Append an asterisk to the end.
                    sURL = Replace(sURL, "**", "*")     'Correct if last char was already an asterisk.
                End If
                
                cUrlSet.Add(sURL)
                
                If Err.Number = -2147024713 Then Err.Clear     'URL already added, so ignore error.
                'WScript.Echo sURL & " was added."    'For debugging...            


                If bPrependStar Then
                    'Blocking devil.com will not block www.devil.com and vice versa. So every Domain 
                                   'should be added as *.devil.com and devil.com
                    
                    sURL = "*." & sURL                   'Preppend an asterisk & dot at the beginning.
                    sURL = Replace(sURL, "*.*.", "*.")     'Correct if first chars were already an asterisk & dot.

                    cUrlSet.Add(sURL)
                
                    If Err.Number = -2147024713 Then Err.Clear     'URL already added, so ignore error.
                            'WScript.Echo sURL & " was added."    'For debugging...            

                End If
            End If
        End If
    Next
    
    cUrlSet.Save

    Call CatchAnyErrorsAndQuit("Problems creating new URL objects in " & sUrlSetName)
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
    sUsage = sUsage & "ISA_FILL_URL_SET.VBS UrlSetName FilePath [/appendstar] [/prependstar]" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Creates or updates an ISA Server URL Set (`UrlSet`)" & vbCrLf
    sUsage = sUsage & "with the URLs from a text file (`FilePath`) obtained from" & vbCrLf
    sUsage = sUsage & "either an HTTP URL or a local filesystem path." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    UrlSet             Name of URL Set to be created or" & vbCrLf
    sUsage = sUsage & "                       updated with URL entries.  " & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    FilePath           A full HTTP URL or local filesystem path" & vbCrLf
    sUsage = sUsage & "                       to a text file containing URLs.  All" & vbCrLf
    sUsage = sUsage & "                       comments must start with # or ;. Examples" & vbCrLf
    sUsage = sUsage & "                       might be `filename.txt`, `c:\filename.txt`," & vbCrLf
    sUsage = sUsage & "                       or `http://www.fqdn.com/filename.asp`." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   /appendstar         Optional. Will automatically append an asterisk" & vbCrLf    
    sUsage = sUsage & "                       to every URL imported (which is probably what" & vbCrLf    
    sUsage = sUsage & "                       you want).  Don't worry, this doesn't break" & vbCrLf    
    sUsage = sUsage & "                       URL matching when no path, or a full path, is" & vbCrLf    
    sUsage = sUsage & "                       specified in the URL, e.g., isascripts.org* and" & vbCrLf
    sUsage = sUsage & "                       isascripts.org/index.html* still match fine." & vbCrLf        
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   /prependstar        Optional. Will automatically prepend an asterisk & dot" & vbCrLf    
    sUsage = sUsage & "                       to every URL imported. (e.g. Blocking devil.com will" & vbcrlf
    sUsage = sUsage & "                       not block www.devil.com and vice versa. So every Domain" & vbcrlf
    sUsage = sUsage & "                       will be added as *.devil.com and devil.com" & vbCrLf 
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Note that all URLs defined in the URL Set are deleted" & vbCrLf
    sUsage = sUsage & "prior to importing the URLs from the text file.  If necessary," & vbCrLf
    sUsage = sUsage & "the URL Set object will be created first.  Place double-quotes" & vbCrLf
    sUsage = sUsage & "around the UrlSet and FilePath arguments if they contain" & vbCrLf
    sUsage = sUsage & "any space characters.  When providing an HTTP URL, the downloaded" & vbCrLf
    sUsage = sUsage & "file will be saved as 'URLs-downloaded-from-url.txt` in the " & vbCrLf
    sUsage = sUsage & "same folder as the script; it will be overwritten whenever a URL" & vbCrLf
    sUsage = sUsage & "path is used again." & vbCrLf
    sUsage = sUsage & vbCrLf     
    sUsage = sUsage & "Public domain. No rights reserved. SCRIPT PROVIDED ""AS IS"" WITHOUT WARRANTIES" & vbCrLf
    sUsage = sUsage & "OR GUARANTEES OF ANY KIND.  USE AT YOUR OWN RISK.  ( www.ISAscripts.org )" & vbCrLf
    sUsage = sUsage & vbCrLf

    WScript.Echo sUsage
    WScript.Quit
End Sub



'*************************************************************************************
' Functions
'*************************************************************************************

Function IsIpAddress(sInput)
    'Regular expression would be more accurate, but slower...quick-n-dirty will do since
    'having a "*.dottedIPaddress" URL doesn't break anything if an IP address sneaks by...
    
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

