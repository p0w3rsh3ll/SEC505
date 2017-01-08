'***********************************************************************************
' Script Name: DumpEventLog.vbs
'     Version: 2.0.1
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 16.Nov.2004
'     Purpose: Dumps the contents of a local/remote Event Log to a local CSV file.
'              Optionally dump all logs at once.  Optionally clear one/all logs.
'              Comma-separated value (CSV) files can be opened directly in Excel or
'              imported into Access, SQL Server or any other database application;
'              a CSV file is easy to parse, compress, search, store, etc. and is 
'              therefore the preferred format for archiving Event Log data.
'       Notes: Requires RPC access to the Windows Management Instrumention (WMI)
'              service at the target Windows 2000 or later machine.  
'    Keywords: WMI, WBEM, log, event log, dump, CSV, clear, comma, ADO, recordset
'       LEGAL: PUBLIC DOMAIN.  SCRIPT PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF 
'              ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR
'              A PARTICULAR PURPOSE.  ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF
'              THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF
'              ANY SUCH DAMAGE.  IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF
'              LIABILITY, THEN DELETE THIS FILE SINCE YOU ARE NOW PROHIBITED TO HAVE IT.
'***********************************************************************************
Option Explicit
Dim bDebug : bDebug = False   'Flag to turn on/off debugging output (true turns on).
If Not bDebug Then On Error Resume Next




'***********************************************************************************
'  Constants, Global Variables and Common Objects.
'***********************************************************************************

Const ForAppending =      8                  'These are constants for the FileSystemObject.
Const ForOverWriting =    2
Const ForReading =        1
Const OpenAsASCII =       0     
Const OpenAsUnicode =    -1
Const OpenUsingDefault = -2

Dim oWMI                                     'The WMI connection to the remote system.
Dim sIPaddress  : sIPaddress = "127.0.0.1"   'IP address or name of machine to pull Event Log data from. 
Dim sFile       : sFile = "eventlog.csv"     'Local file to write Event Log data to in CSV format.
Dim sLogName    : sLogName = "System"        'Log to dump.
Dim bVerbose    : bVerbose = False           'Assume that InsertionStrings and Data aren't dumped.
Dim bDumpHex    : bDumpHex = False           'Assume that hex of Data isn't dumped.
Dim bAllLogs    : bAllLogs = False           'Assume that all logs aren't going to be dumped.
Dim bClearLogs  : bClearLogs = False         'Don't clear logs by default.
Dim bDone       : bDone = False              'Controls a wait loop for the async data collection.
Dim iStart      : iStart = Timer()           'Track how long the script runs.
Dim iCount      : iCount = 0                 'Count of event log items being processed.
Dim sCleared    : sCleared = "Logs Cleared:" 'List of log names that were successfully cleared.
Dim iTimeWithObject : iTimeWithObject = 0    'A debugging timer.

Dim oFileSystem : Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
Dim oWshShell   : Set oWshShell = WScript.CreateObject("WScript.Shell")
Dim oRegExp     : Set oRegExp = New RegExp
Dim oStdErr     : Set oStdErr = WScript.StdErr
Dim oRecordSet  : Set oRecordSet = CreateObject("ADODB.Recordset")

Call CatchAnyErrorsAndQuit("Problem declaring variables and creating common objects.") 


'***********************************************************************************
' MAIN(): Call procedures to do the work, write some stats to StdErr. 
'***********************************************************************************

Call ProcessCommandLineArguments()
Call BuildConnectionlessRecordSet()
Call ProcessEachLog()  'This calls ClearLog() when required. 
Call WriteRecordSetToFile() 

If Err.Number = 0 Then
    oStdErr.WriteLine "" 
    oStdErr.WriteLine "Completed Successfully: " & Now()
    oStdErr.WriteLine "   CSV File Written To: " & sFile
    oStdErr.WriteLine "   Run Time In Seconds: " & Timer() - iStart
    oStdErr.WriteLine "     Records Retrieved: " & iCount
    oStdErr.WriteLine "    Records Per Second: " & CInt(iCount / (Timer() - iStart))
    oStdErr.WriteLine "          " & RTrimCommas(sCleared)
Else
    oStdErr.WriteLine "ERROR: Did NOT complete successfully." 
    oStdErr.WriteLine Err.Description
End If



'***********************************************************************************
'  Procedures.
'***********************************************************************************

Sub ProcessCommandLineArguments()
    If Not bDebug Then On Error Resume Next
    Dim sArg, sCurrentFolder
    Dim cComputerData, oItem
    
    If Not IsUsingCscript() Then
        oWshShell.Popup "Only use CSCRIPT.EXE to run this script.", 20, "Try Again Please"
        WScript.Quit
    End If


    If WScript.Arguments.Count < 3 Then
        Call ShowUsageAndQuit()
    Else
        sIPaddress = WScript.Arguments.Item(0)
        sFile = WScript.Arguments.Item(1)
        sLogName = WScript.Arguments.Item(2)  
    End If
    
    
    For Each sArg In WScript.Arguments
        Select Case UCase(sArg)
        	Case "/?", "-?", "/H", "-H", "-HELP", "--HELP" 
        	    Call ShowUsageAndQuit()
        	Case "/V", "-V", "/VERBOSE", "-VERBOSE" 
        	    bVerbose = True
            Case "/DUMPHEX", "-DUMPHEX", "/DUMP", "-DUMP", "/D", "-D"
                bDumpHex = True
                bVerbose = True  'Required for the WQL query to work, and seems logical.
            Case "/ALL", "-ALL", "ALL" 
                bAllLogs = True
            Case "/CLEAR", "-CLEAR", "CLEAR"
                bClearLogs = True
        End Select        
    Next 
    
    Call CatchAnyErrorsAndQuit("Problem processing command-line arguments.") 


    'Don't force the user to have the "manage auditing and security log" 
    'user right (SeSecurityPrivilege) when not dumping the Security log.
    If (bAllLogs = True) Or (InStr(UCase(sLogName),"SECURITY") <> 0) Then    
        Set oWMI = GetObject("WinMgmts:{(Security)}!//" & sIPaddress & "/root/cimv2")
    Else
        Set oWMI = GetObject("WinMgmts://" & sIPaddress & "/root/cimv2")
    End If

    'The computername is needed because sometimes Microsoft writes "MACHINENAME"
    'in the computer field of log entries...which isn't very useful.    
    Set cComputerData = oWMI.ExecQuery("SELECT Name FROM Win32_ComputerSystem")
    For Each oItem In cComputerData
        sIPaddress = oItem.Name
    Next        
    Set cComputerData = Nothing    
    
    Call CatchAnyErrorsAndQuit("Problem connecting to WMI on " & sIPaddress)    
    
    
    'Now build the full path to the CSV file.
    If InStr(sFile, "%") <> 0 Then
        sFile = oWshShell.ExpandEnvironmentStrings(sFile)
    End If 
    
    If InStr(sFile, "\") = 0 Then
        sCurrentFolder = WScript.ScriptFullName 
        sCurrentFolder = Left(sCurrentFolder, InstrRev(sCurrentFolder, "\"))
        sFile = sCurrentFolder & sFile
    End If    
    
    If bDebug Then oStdErr.WriteLine vbCrLf & "Exited ProcessCommandLineArguments: " & Timer() - iStart
End Sub



Sub BuildConnectionlessRecordSet()
    If Not bDebug Then On Error Resume Next
    
    Const adUseClient =         3       'Client-side cursor required for connectionless RS.
    Const adOpenForwardOnly =   0       'Cursor type, fast.
    Const adBSTR =	            8 	    'Null-terminated character string
    Const adDBDate =	        133 	'YYYYMMDD date format
    Const adDBTime =	        134 	'HHMMSS time format
    Const adDBTimeStamp =	    135 	'YYYYMMDDHHMMSS date/time format
    Const adVariant =	        12 	    'Automation variant
    Const adUnsignedInt =	    19 	    '4-byte unsigned integer
    Const adUnsignedBigInt =	21 	    '8-byte unsigned integer
    
    oRecordSet.CursorLocation = adUseClient
    oRecordSet.CursorType = adOpenForwardOnly
    
    oRecordSet.Fields.Append "Computer", adBSTR
    oRecordSet.Fields.Append "Date", adDBDate                 'Can't be string, that's not ADO-sortable.
    oRecordSet.Fields.Append "Time", adDBTimeStamp            'Can't be string, that's not ADO-sortable.
    oRecordSet.Fields.Append "RecordNumber", adUnsignedBigInt 'Can't be string, that's not ADO-sortable.       
    oRecordSet.Fields.Append "TheRestOfTheData", adBSTR

    oRecordSet.Open
        
    Call CatchAnyErrorsAndQuit("Problem building connectionless ADO recordset.")    
    If bDebug Then oStdErr.WriteLine "Exited BuildConnectionlessRecordSet: " & CDbl(Timer() - iStart)
End Sub



Sub ProcessEachLog()
    If Not bDebug Then On Error Resume Next
    Dim aLogs, sLog, cLogFiles, oLog
    
    'If the /ALL switch was used, build list of event log names at target.
    If bAllLogs Then 
        Set cLogFiles = oWMI.ExecQuery("SELECT LogFileName FROM Win32_NTEventLogFile")
        sLogName = ""
        For Each oLog In cLogFiles
            sLogName = sLogName & oLog.LogFileName & ","    'Some log names contain spaces.
        Next
        Set cLogFiles = Nothing
    End If
        
    If bDebug Then oStdErr.WriteLine "Log Names At " & sIPaddress & ": " & RTrimCommas(sLogName)
            
    aLogs = Split(RTrimCommas(sLogName), ",")
    For Each sLog In aLogs
        sLog = Trim(sLog)  'In case a comma-delimited list of logs with spaces is passed in.
        If bDebug Then oStdErr.WriteLine "Starting The Processing Of The " & sLog & " Log At " & Timer() - iStart
        Call FillRecordSet(sLog)
        
        Do While Not bDone
            WScript.Sleep(1)
        Loop
        
        If bClearLogs Then Call ClearLog(sLog)
    Next
    
End Sub



Sub FillRecordSet(sLog)
    If Not bDebug Then On Error Resume Next
    Dim cLogs, sList, sLine, iError, oError, iHResult, sWQL
    Dim cEventData, oItem, oAsyncContext, oSWbemSink

    bDone = False 'Necessary when calling this Sub multiple times from ProcessEachLog().
    
    If bVerbose Then
        sWQL = "SELECT * FROM Win32_NTLogEvent WHERE Logfile = " & "'" & sLog & "'"
    Else
        sWQL = "SELECT Logfile,TimeGenerated,Recordnumber,User," &_
               "EventCode,SourceName,EventIdentifier,CategoryString,EventType," &_
               "Message FROM Win32_NTLogEvent WHERE Logfile = " & "'" & sLog & "'"  'Everything except Computer, InsertionStrings and Data.
    End If
    

    'Asynchronous WMI queries are significantly faster than synchronous ones. An SWebmSink COM object
    'will be given to the remote system so that it can control the data handling (this is what makes
    'it asynchronous).  The object represents the local receiving end of the execution flow.
    Set oSWbemSink = WScript.CreateObject("WbemScripting.SWbemSink")
    
    'When the remote system passes data into the SWebmSink object's methods, "events" are raised on
    'the local machine which are ultimately handled by this script.  The subprocedures which handle 
    'these events must all begin with "EVENTSINK_" (or whatever is entered here) because now these
    'procedures are connected to the oSWbemSink object by that prefix name, e.g., "EVENTSINK_OnObjectReady".
    WScript.ConnectObject oSWbemSink, "EVENTSINK_"
    
    Call CatchAnyErrorsAndQuit("Problem creating WMI event sink or connecting to it.")    
    

    'Calling the ExecQuery() method returns a collection that must be Set to a variable, but calling 
    'ExecQueryAsync() will run the same WQL query and serve up the SWebmSink object for access by 
    'the remote system.  Now the script must wait for the data to come, but it doesn't do this by
    'blocking, it does it simply by not exiting and allowing the EVENTSINK_ methods to be called.
    oWMI.ExecQueryAsync oSWbemSink, sWQL 

    Call CatchAnyErrorsAndQuit("Problem executing WMI query to select data.")


    'Now prevent the script from exiting or continuing on until the remote system is done sending us
    'data.  bDone will be set to true by EVENTSINK_OnCompleted() when the remote box is finished.
    Do While Not bDone
        WScript.Sleep(1)
    Loop
    
    WScript.DisconnectObject(oSWbemSink)  
    If bDebug Then oStdErr.WriteLine "Exited FillRecordSet For The " & sLog & " Log: " & Timer() - iStart
End Sub



Sub EVENTSINK_OnCompleted(iHResult, oError, oAsyncContext)  
    'EVENTSINK_OnCompleted() is called automatically by oSWbemSink when the WQL query is completed.
    bDone = True  'Terminates the Sleep() loop in FillRecordSet().
    If bDebug Then oStdErr.WriteLine "Time Spent Processing WMI Data (Instead Of Just Waiting): " & CDbl(iTimeWithObject)
End Sub



Sub EVENTSINK_OnObjectReady(oItem, oAsyncContext)
    'EVENTSINK_OnObjectReady() is called automatically by oSWbemSink each time a new __Event object
    'is handed off to oSWbemSink.  oItem refers to the object that raised the event to call this procedure.

    If Not bDebug Then On Error Resume Next
    Dim sInsertions, sByteDataInASCII, sByteDataInHex, sComputerName, iTimeInObject
    If bDebug Then iTimeInObject = Timer()
        
    sInsertions = ""
    sByteDataInASCII = ""
    sByteDataInHex = ""

    With oItem
        If bVerbose Then sInsertions = MakeCleanLine(JoinStringsArray(.InsertionStrings)) 'Mostly overlaps with the Message data.
        If bVerbose Then sByteDataInASCII = ByteArrayToASCII(.Data) 'Usually not needed, often overlaps with .Message and .InsertionStrings data.
        If bDumpHex Then sByteDataInHex = ByteArrayToHex(.Data)     'Very rarely needed, can produce tons of data, so watch out. 

        oRecordSet.AddNew 
        oRecordSet.Fields("Computer").Value = sIPaddress
        oRecordSet.Fields("Date").Value = Quote(GetDate(.TimeGenerated))  'Need to sort on these date/time fields, but ADO reformats them when GetString-ing the data.
        oRecordSet.Fields("Time").Value = Quote(GetTime(.TimeGenerated))
        oRecordSet.Fields("RecordNumber").Value = Quote(.RecordNumber)
        oRecordSet.Fields("TheRestOfTheData").Value =   QuoteComma(.Logfile) &_
                                                        QuoteComma(.User) &_ 
                                                        QuoteComma(.EventCode) &_ 
                                                        QuoteComma(.SourceName) &_ 
                                                        QuoteComma(.EventIdentifier) &_ 
                                                        QuoteComma(.CategoryString) &_ 
                                                        QuoteComma(MapEventType(.EventType)) &_ 
                                                        QuoteComma(MakeCleanLine(.Message)) &_
                                                        QuoteComma(sInsertions) &_ 
                                                        QuoteComma(sByteDataInASCII) &_ 
                                                        Quote(sByteDataInHex)
    End With
    
    Call CatchAnyErrorsAndQuit("Problem constructing a record.")
    iCount = iCount + 1    'Keep track of the number of event log items.
    If bDebug Then iTimeWithObject = iTimeWithObject + (Timer() - iTimeInObject)
End Sub



Sub ClearLog(sLog)
    If Not bDebug Then On Error Resume Next
    Dim cLogFiles, iError, oLog
    
    Set cLogFiles = oWMI.ExecQuery("SELECT LogFileName FROM Win32_NTEventLogFile WHERE LogFileName = " & "'" & sLog & "'")

    For Each oLog In cLogFiles
        iError = oLog.ClearEventlog()
        Call CatchAnyErrorsAndQuit("Problem clearing " & sLog & " log: " & iError)
        sCleared = sCleared & " " & oLog.LogFileName & ","   
        If bDebug Then oStdErr.WriteLine "Cleared The " & sLog & " Log (" & iError & ") At " & Timer() - iStart
    Next
End Sub



Sub WriteRecordSetToFile()    
    If Not bDebug Then On Error Resume Next
    Dim sData, oFile, oTextStream, iTimer

    'Open CSV file, if it exists, or create a new one with appropriate collumn headers row if it doesn't.
    If oFileSystem.FileExists(sFile) Then 
        Set oFile = oFileSystem.GetFile(sFile)
        Set oTextStream = oFile.OpenAsTextStream(ForAppending, OpenUsingDefault)
    Else
        Set oTextStream = oFileSystem.CreateTextFile(sFile)
        oTextStream.WriteLine("Computer,Date,Time,RecordNumber,Log,User,EventCodeID,SourceName,EventIdentifier,Category,EventType,Message,InsertionStrings,ByteDataInASCII,ByteDataInHex")
    End If

    'Ensure that insertion point in CSV file is at the beginning of a new line.
    If oTextStream.Column <> 1 Then oTextStream.WriteBlankLines(1)
    
    If bDebug Then iTimer = Timer()

    oRecordSet.Sort = "Date ASC, Time ASC, RecordNumber ASC"  
    If Not oRecordSet.EOF Then oRecordSet.MoveFirst 'Log may be empty. 

    Do While Not oRecordSet.EOF  
        oTextStream.Write(oRecordSet.GetString(2, 75, ",", vbCrLf, ""))  '2 is an ADO constant (adClipString), 75 is number of lines to process, then field delimeter, row delimeter, null char.
    Loop
    
    If bDebug Then oStdErr.WriteLine "Time Spent Sorting And Appending Data: " & Timer() - iTimer

    oRecordSet.Close
    oTextStream.Close
    Set oRecordSet = Nothing
    Set oTextStream = Nothing   
    Set oFile = Nothing
    
    Call CatchAnyErrorsAndQuit("Problem writing to file.")
    If bDebug Then oStdErr.WriteLine "Exited WriteRecordSetToFile: " & Timer() - iStart
End Sub



Sub CatchAnyErrorsAndQuit(sMessage)
    'Do not use "On Error Resume Next" within this procedure.
    If Err.Number <> 0 Then
        If Not IsObject(oStdErr) Then Set oStdErr  = WScript.StdErr  'Write to standard error stream.
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



Sub ShowUsageAndQuit()
    If Not bDebug Then On Error Resume Next
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & "DumpEventLog.vbs target file.csv ""logname(s)"" [/clear] [/v] [/dumphex] " & vbCrLf
    sUsage = sUsage & "DumpEventLog.vbs target file.csv /all [/clear] [/v] [/dumphex] " & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    target        IP address or computername of local or remote system." & vbCrLf
    sUsage = sUsage & "    file.csv      Name or full path to local CSV file to save data." & vbCrLf
    sUsage = sUsage & "    logname(s)    Name(s) of log(s) to dump (comma-delimited, inside quotes)." & vbCrLf
    sUsage = sUsage & "    /all          Process all of the Event Logs at target." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    /clear        Clears log(s) after dumping." & vbCrLf
    sUsage = sUsage & "    /v            Verbose mode dumps more data." & vbCrLf
    sUsage = sUsage & "    /dumphex      Output byte array data as hex; implies verbose mode." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    *** Notes: *** " & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    Purpose of the script is to dump the contents of local or remote Event" & vbCrLf
    sUsage = sUsage & "    Log(s) to a local textual CSV file for archival, search, import, etc." & vbCrLf
    sUsage = sUsage & "    Both local and remote systems should be Windows 2000 or later." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    If logname contains a space character, enclose name in double-quotes. If" & vbCrLf
    sUsage = sUsage & "    you don't use the /all switch and you specify a logname that doesn't exist" & vbCrLf
    sUsage = sUsage & "    at the target, you will NOT get an error message (and no data will be" & vbCrLf
    sUsage = sUsage & "    written to the CSV file).  The logname is not case sensitive.  If you want" & vbCrLf
    sUsage = sUsage & "    multiple logs, put them in a comma-separated, double-quoted list." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    file.csv may be a simple filename or a full local path.  Simple filename" & vbCrLf
    sUsage = sUsage & "    will use the script's working folder.  File will be created if it does" & vbCrLf
    sUsage = sUsage & "    not already exist.  Path may include environmental variables.  Column" & vbCrLf
    sUsage = sUsage & "    header is added only when the script creates the file, hence, pre-create" & vbCrLf
    sUsage = sUsage & "    an empty file if you don't want a first row added with column names." & vbCrLf
    sUsage = sUsage & "    Appending data to an existing file does not write the headers again." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    Verbose mode includes insertion strings and byte array data in ASCII." & vbCrLf
    sUsage = sUsage & "    Byte data is filtered to exclude carriage returns, nulls, and line feeds." & vbCrLf
    sUsage = sUsage & "    Verbose mode is rarely necessary because of the redundancy of the data." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    Dumphex implies verbose mode and dumps unfiltered byte array data in hex." & vbCrLf
    sUsage = sUsage & "    Dumphex is VERY rarely necessary and increases CSV file size substantially." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    Example: the following will dump the Application and System logs to a file" & vbCrLf
    sUsage = sUsage & "    named output.csv from a computer named server1, then clear just those logs:" & vbCrLf
    sUsage = sUsage & "        DumpEventLog.vbs server1 output.csv ""application,system"" /clear" & vbCrLf    
    sUsage = sUsage & "    Example: the following will dump all logs from server1 to output.csv:" & vbCrLf
    sUsage = sUsage & "        DumpEventLog.vbs server1 output.csv /all" & vbCrLf    

    WScript.Echo sUsage
    WScript.Quit(Err.Number)
End Sub



'***********************************************************************************
'  Functions.
'***********************************************************************************


Function IsUsingCscript()
    Dim iPosition
    iPosition = InStr( LCase(WScript.FullName) , "cscript.exe" )
    If iPosition = 0 Then IsUsingCscript = False Else IsUsingCscript = True 
End Function



Function RTrimCommas(sData)
    RTrimCommas = RTrim(sData)
    Dim iLength : iLength = Len(sData)

    If iLength = 0 Then
        RTrimCommas = ""
        Exit Function
    End If

    If InStrRev(sData, ",,,") = (iLength - 2) Then
        RTrimCommas = Left(RTrimCommas, iLength - 3)
    ElseIf InStrRev(sData, ",,") = (iLength - 1) Then
        RTrimCommas = Left(RTrimCommas, iLength - 2)
    ElseIf InStrRev(sData, ",") = iLength Then
        RTrimCommas = Left(RTrimCommas, iLength - 1)    
    End If
    
    iLength = Len(RTrimCommas)
    If InStrRev(RTrimCommas, ",") = iLength Then 
        RTrimCommas = RTrimCommas(RTrimCommas)      'Recursive.
    End If
End Function



Function MapEventType(iNum)
    Select Case CInt(iNum)
    	Case 0 : MapEventType = "<Success>"    
    	Case 1 : MapEventType = "<Error>"
    	Case 2 : MapEventType = "<Warning>"
        Case 3 : MapEventType = "<Information>"
    	Case 4 : MapEventType = "<Audit-Success>"
    	Case 5 : MapEventType = "<Audit-Failure>"
    	Case Else : MapEventType = "<???>"  'Should never get here.
    End Select
End Function



Function JoinStringsArray(ByRef aArray)
    If VarType(aArray) = vbNull Then
        JoinStringsArray = ""
        Exit Function
    Else
        JoinStringsArray = Join(aArray)
        JoinStringsArray = Replace(JoinStringsArray, "(NULL)", "")
    End If
End Function



Function MakeCleanLine(sText)
    If (VarType(sText) = vbNull) Or (sText = "") Or (Len(sText) = 0) Then
        MakeCleanLine = ""
        Exit Function
    Else
        If Not IsObject(oRegExp) Then Set oRegExp = New RegExp
        oRegExp.Global = True
        oRegExp.MultiLine = True  
        oRegExp.Pattern = "\s+"     'One or more whitespaces.   
        MakeCleanLine = oRegExp.Replace(sText," ")
        MakeCleanLine = Trim(MakeCleanLine)
    End If
End Function



Function ByteArrayToHex(ByRef aArray)
    Dim i
    If VarType(aArray) = vbNull Then
        ByteArrayToHex = ""
        Exit Function
    Else
        For i = 0 To UBound(aArray)
            ByteArrayToHex = ByteArrayToHex & Right("0" & Hex(aArray(i)), 2) & " "
        Next
    End If
    ByteArrayToHex = RTrim(ByteArrayToHex)  'Trim off trailing space character.
End Function



Function ByteArrayToASCII(ByRef aArray)
    Dim i, iNum
    If VarType(aArray) = vbNull Then
        ByteArrayToASCII = ""
        Exit Function
    Else
        For i = 0 To UBound(aArray)
            iNum = CInt(aArray(i))
            If (iNum <> 0) And (iNum <> 10) and (iNum <> 13) Then '0=Null, 10=LF, 13=CR.
                ByteArrayToASCII = ByteArrayToASCII & Chr(iNum)
            End If
        Next
    End If
End Function



Function QuoteComma(sData)
    If (sData = "") Or (VarType(sData) = vbNull) Or (Len(sData) = 0) Then
        QuoteComma = ","                   
        Exit Function
    End If

    QuoteComma = CStr(sData)    
    QuoteComma = Replace(QuoteComma, """", "``")  'Replace double-quotes with two backticks.
    QuoteComma = Replace(QuoteComma, vbCrLf, "")  'Delete the weird extra newlines MS adds for no sane reason...
    QuoteComma = Trim(QuoteComma)                 '    ...and better to do it here than with a RegExp later (expensive)
    
    If InStr(QuoteComma, ",") = 0 Then
        QuoteComma = QuoteComma & ","
    Else
        QuoteComma = """" & QuoteComma & """" & ","  'Double-quote the string because of the comma(s) inside it.
    End If
End Function



Function Quote(sData)
    If (sData = "") Or (VarType(sData) = vbNull) Or (Len(sData) = 0) Then
        Quote = ""          
        Exit Function
    End If

    Quote = CStr(sData)    
    Quote = Replace(Quote, """", "``")  'Replace double-quotes with two backticks.
    Quote = Replace(Quote, vbCrLf, "")  'Delete the weird extra newlines MS adds for no sane reason...
    Quote = Trim(Quote)                 '    ...and better to do it here than with a RegExp later (expensive)
    
    If InStr(Quote, ",") <> 0 Then
        Quote = """" & Quote & """"     'Double-quote the string because of the comma(s) inside it.
    End If
End Function


Function GetTime(sWmiDate)
    'Pass in a WMI date like "20041229114458.000000-360"
    'Returns in military hour:min:sec format, with hours from 0 to 23.
    'Does NOT set to UTC or Zulu time; this is local time at the machine.
    GetTime = Mid(sWmiDate,9,2) & ":" & Mid(sWmiDate,11,2) & ":" & Mid(sWmiDate,13,2)
    GetTime = TimeValue(GetTime) 'RecordSet needs a VB Date value.
End Function



Function GetDate(sWmiDate)
    'Pass in a WMI date like "20041229114458.000000-360"    
    '_____________MONTH_____________________DAY_______________________YEAR_________
    GetDate = Mid(sWmiDate,5,2) & "/" & Mid(sWmiDate,7,2) & "/" & Mid(sWmiDate,3,2) 
    GetDate = DateValue(GetDate)  'RecordSet needs a VB Date value.  
End Function


'END OF SCRIPT************************************************************************
