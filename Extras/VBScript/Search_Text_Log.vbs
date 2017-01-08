'*********************************************************************
' Script Name: Search_Text_Log.vbs
'     Version: 5.1
'      Author: Jason Fossen, Enclave Consulting LLC (www.ISAscripts.org)
'     Updated: 17.Aug.2004
'     Purpose: Search text files, such as ASCII logs, for any matches defined
'              in another file containing regular expression patterns.  
'       Usage: Two arguments required.  The first argument is the text file to
'              be searched, the second is the file defining the regular expression
'              patterns to search for, i.e., the "signatures" file.  Each line of
'              the signatures file must begin with a regular expression pattern (not
'              including the doublequotes), a tab delimeter, then a description
'              of what the pattern is intended to indicate (without any doublequotes).
'              For example, the following line is valid:
'
'                    GET /default\.ida      probes by the Code Red Worm.
'
'    Keywords: regular expression, search, log, logs, signature, regexp
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND.
'*********************************************************************

On Error Resume Next

'*********************************************************************
'Declare constants, variables, common objects, etc..
'*********************************************************************
Const ForReading = 1         'These are oFileSystem object constants.
Const ForAppending = 8
Const ForOverWriting = 2
Const OpenAsASCII = 0
Const OpenAsUnicode = -1
Const OpenUsingDefault = -2

Dim aSignatures     'Array of regular expression signatures to search for.
Dim sFileToSearch   'Text file to search for pattern matches.
Dim sSignaturesFile 'Text file of regular expression signatures.
Dim sCurrentFolder  'Folder where the script is located.

Dim oFileSystem, oRegExp, iPosition, oTextStream, i, x, sData   'Misc variables.
Dim oFileToSearch, oFileStream, sHeader, sResult, iStartTime    'Misc variables.

iStartTime = Timer()  'Used to track how long the script runs.

Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
Set oRegExp = New REGEXP
    

'*********************************************************************
'Call procedures which do the work of the script.
'*********************************************************************
Call CheckArguments()
Call CreateSignaturesArray()
Call SearchTheFile()
Call GenerateReport()


'*********************************************************************
'Procedure: CheckArguments()
'  Purpose: Validate and manipulate command-line arguments to script.
'*********************************************************************
Sub CheckArguments()

    If WScript.Arguments.Count <> 2 Then Call ShowHelpAndQuit()

    For Each sArg In WScript.Arguments
        sArg = LCase(sArg)
        If (sArg = "/?") Or (sArg = "/h") Or (sArg = "-h") Or (sArg = "/help") Then Call ShowHelpAndQuit() 
    Next
    
    sFileToSearch = WScript.Arguments(0)
    sSignaturesFile = WScript.Arguments(1)

    sCurrentFolder = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\")) 
    If InStr(sFileToSearch, "\") = 0 Then sFileToSearch = sCurrentFolder & sFileToSearch 
    If InStr(sSignaturesFile, "\") = 0 Then sSignaturesFile = sCurrentFolder & sSignaturesFile   

    If Not oFileSystem.FileExists(sFileToSearch) Then 
        WScript.Echo vbCrLf & "The specified file to search does not exist: " & vbCrLf & sFileToSearch
        WScript.Quit
    End If 

    If Not oFileSystem.FileExists(sSignaturesFile) Then 
        WScript.Echo vbCrLf & "The signatures file does not exist: " & vbCrLf & sSignaturesFile
        WScript.Quit
    End If 
End Sub 


'*********************************************************************
' Procedure: CreateSignaturesArray()
'   Purpose: Parse signatures file into an array of SIGNATURE objects.
'*********************************************************************
Sub CreateSignaturesArray()
    Set oFileStream = oFileSystem.OpenTextFile(sSignaturesFile, ForReading)
    sSignaturesFileContents = oFileStream.ReadAll
    oFileStream.Close
    Set oFileStream = Nothing    

    oRegExp.Pattern = "([^\t\n\r]+)\t+([^\t\n\r]+)"             'regexp pattern <tabs> description
    oRegExp.Global = True
    oRegExp.IgnoreCase = False
    oRegExp.MultiLine = False                                   
    Set cMatches = oRegExp.Execute(sSignaturesFileContents)

    ReDim aSignatures(cMatches.Count - 1)                       'Array to hold SIGNATURE objects.
    i = 0
    For Each sMatch In cMatches
        Set aSignatures(i) = New SIGNATURE                      'Look a few lines lower for SIGNATURE class.
        aSignatures(i).Pattern =     sMatch.SubMatches.Item(0)
        aSignatures(i).Description = sMatch.SubMatches.Item(1) 
        i = i + 1
    Next

    sSignaturesFileContents = ""
End Sub


Class SIGNATURE
    Public Pattern              'RegExp pattern to search for.
    Public Description          'Description of what this pattern indicates.
    Public Count                'Count of matches found so far.
    
    Private pvtStart            'Private variables are visible only inside the class implementation.
    Private pvtSearchTime       'Number of seconds spent searching for this pattern.
            
    Private Sub Initialize()    'Initialize() can't take arguments.  Called when object created.
        Pattern = ""            'Not required to initialize class variables this way, but tidy to do so.
        Description = ""
        Count = 0
        SearchTime = 0
        pvtStart = 0
    End Sub
    
    Public Property Get SearchTime
        SearchTime = Round(pvtSearchTime,1)
    End Property
    
    Public Sub LookForMatches(ByRef sData)
        pvtStart = Timer()
        If Not IsObject(oRegExp) Then Set oRegExp = New REGEXP
        oRegExp.IgnoreCase = False
        oRegExp.Global = True
        oRegExp.MultiLine = False  
        oRegExp.Pattern = Pattern        
        Set cMatches = oRegExp.Execute(sData)
        Count = Count + cMatches.Count
        Set cMatches = Nothing
        pvtSearchTime = pvtSearchTime + (Timer() - pvtStart)
    End Sub
End Class


'*********************************************************************
'Procedure: SearchTheFile()
'  Purpose: Searches the input file for matches to the signatures.
'*********************************************************************
Sub SearchTheFile()
    Set oStreamToSearch = oFileSystem.OpenTextFile(sFileToSearch,ForReading)
            
    Do While Not oStreamToSearch.AtEndOfStream
        sData = oStreamToSearch.Read(10000000)    'Read in 10 million bytes.
        
        'If 10MB bisects a line, the full line must be read before searching takes place.   
        If Not oStreamToSearch.AtEndOfStream Then 
            sDataToFinishLine = oStreamToSearch.ReadLine        
        Else
            sDataToFinishLine = ""
        End If
        
        For Each oSignature In aSignatures
            oSignature.LookForMatches(sData & sDataToFinishLine)
        Next
    Loop
    
    oStreamToSearch.Close
    Set oStreamToSearch = Nothing 
End Sub


'*********************************************************************
'Procedure: GenerateReport()
'  Purpose: Output a summary of the matches found.  Add code as necessary
'           to, for example, e-mail the results or further process the matches,
'           import to a spreadshet, render to XML, etc.
'*********************************************************************
Sub GenerateReport()
    sResult = ""
    sHeader = "----------------------------------------------------------------" & vbCrLf &_
              " File: " & sFileToSearch  & vbCrLf &_
              " Date: " & Now()          & vbCrLf &_  
              "----------------------------------------------------------------" & vbCrLf
    
    For Each oSignature In aSignatures
        If oSignature.Count > 0 Then
            sResult = sResult & oSignature.Count & " " &_
                                oSignature.Description & " (" &_
                                oSignature.SearchTime & "s)" & vbCrLf 
        End If 
    Next

    If Len(sResult) > 1 Then
        WScript.Echo sHeader
        WScript.Echo sResult
        WScript.Echo "(" & Round(Timer() - iStartTime, 1) & " seconds to run.)"
    Else
        WScript.Echo sHeader & vbCrLf & " No matches found in " &_ 
                                          Round(Timer() - iStartTime, 1) & " seconds."& vbCrLf
    End If
    
End Sub


Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "SEARCH_TEXT_LOG.VBS logtosearch.log signatures.txt [/?]" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "   Purpose: Search a textual log file for regular expression" & vbCrLf
    sUsage = sUsage & "            matches, which are defined in another file, then" & vbCrLf
    sUsage = sUsage & "            print a report of the number of matches found" & vbCrLf
    sUsage = sUsage & "            along with their descriptions.  Useful for auto-" & vbCrLf
    sUsage = sUsage & "            mating the search for hacking and malware signs" & vbCrLf
    sUsage = sUsage & "            in HTTP, firewall, FTP and other types of logs." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "            logtosearch.log -- text log file to search." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "            signatures.txt  -- text file of regular expression" & vbCrLf
    sUsage = sUsage & "                               signatures and their descriptions" & vbCrLf
    sUsage = sUsage & "                               for the type of log searched." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "     Notes: Use the sample IIS.LOG and SIGNATURES.TXT files" & vbCrLf
    sUsage = sUsage & "            to test functionality and see the output. One use" & vbCrLf
    sUsage = sUsage & "            is to schedule the hourly or daily scanning of" & vbCrLf
    sUsage = sUsage & "            the prior hour's or day's logs and then e-mail" & vbCrLf
    sUsage = sUsage & "            any findings to network administrators.  Update" & vbCrLf
    sUsage = sUsage & "            your signatures files as new exploits come out." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "            Public domain, no rights reserved, USE AT YOUR OWN " & vbCrLf
    sUsage = sUsage & "            RISK, SCRIPT PROVIDED ``AS IS``. (www.ISAscripts.org)" & vbCrLf
    sUsage = sUsage & " " & vbCrLf
    sUsage = sUsage & vbCrLf    
    
    WScript.Echo sUsage
    WScript.Quit
End Sub


'*********************************************************************
' This procedure is not called by default, but is useful when optimizing your 
' regular expressions to see which ones are consuming the most time.  Poorly
' designed regexp's, as opposed to having a large number of regexp's, is the
' most likely cause of bad performance when searching large files.
'*********************************************************************

'Call ShowAllSearchTimes()

Sub ShowAllSearchTimes()
    iTotalSearchTime = 0
    WScript.Echo vbCrLf & "-----------------------------------------------"
    
    For Each oSignature In aSignatures
        iTotalSearchTime = iTotalSearchTime + oSignature.SearchTime
        WScript.Echo oSignature.SearchTime & "s : " & oSignature.Count & " " & oSignature.Description
    Next
    
    WScript.Echo vbCrLf & iTotalSearchTime & "s = Total Search Time"
End Sub



'END OF SCRIPT *****************************************************************

