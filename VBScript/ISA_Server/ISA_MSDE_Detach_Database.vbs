'*************************************************************************************
' Script Name: ISA_MSDE_Detach_Database.vbs
'     Version: 1.0
'      Author: Jason Fossen ( www.ISAscripts.org )
'Last Updated: 20.Oct.2005
'     Purpose: List or detach MSDE logging database files used by ISA Server 2004.
'              Run the script with the "/?" switch for usage details.  Detached
'              database files (.mdf and .ldf) can be safely deleted, moved or copied.
'       Notes: If you need to detach a database, but ISA Server is still using it, stop
'              the Firewall service, detach the database, then restart the Firewall
'              service and a new database will be automatically created as necessary.
'              Do NOT delete database files (.mdf or .ldf) until you successfully
'              detach the database with this script, SQL Enterprise Manager, OSQL.EXE, etc.
'              Detached databases do not appear in the list when using the /list switch.
'              Just because you can delete .mdf or .ldf files with Windows Explorer does
'              not mean their corresponding database(s) have been detached.  This script
'              does not delete any database files, it only lists or detaches them;
'              hence, you will have to manually delete files if you want to make more
'              free hard drive space.  The default location for your MSDE logging
'              database files is %Program Files%\Microsoft ISA Server\ISALogs\.
'              See KB838707 and the ISA Server SDK for more information.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Don't use this script if you don't have any
'              idea what it does or what you are doing or why you are doing it...OK?
'*************************************************************************************
Option Explicit
On Error Resume Next

Dim oSQLserver    'Global SQLDMO.SQLServer object, set in CreateObjectsDMO()

Call ReLaunchWithCscriptIfNecessary()
Call ProcessCommandLineArguments()


'*************************************************************************************
' Procedures and Functions 
'*************************************************************************************


Sub ReLaunchWithCscriptIfNecessary()
    Dim iPosition, oWshShell
    iPosition = InStr( LCase(WScript.FullName) , "cscript.exe" )
    If iPosition = 0 Then 
        Set oWshShell = CreateObject("WScript.Shell")
        oWshShell.Run "cmd.exe /k cscript.exe //nologo " & """" & WScript.ScriptFullName & """"
        WScript.Quit(0)
    End If
End Sub



Sub ProcessCommandLineArguments()
    On Error Resume Next
    Dim sArg, sArg2
    
    If WScript.Arguments.Count = 0 Then Call ShowHelpAndQuit()

    sArg = LCase(WScript.Arguments.Item(0))
    
    If (sArg = "/?") Or (sArg = "-?") Or (sArg = "/h") Or (sArg = "/help") Or (sArg = "--help") Then Call ShowHelpAndQuit()
    
    If (sArg = "/list") Or (sArg = "list") Or (sArg = "/l") Or (sArg = "l") Then
        Call CreateObjectsDMO()
        Call ListDatabases()
        WScript.Quit
    End If

    If (sArg = "/detach") Then
        If WScript.Arguments.Count <> 2 Then Call ShowHelpAndQuit()
        sArg2 = WScript.Arguments.Item(1)
        Call CreateObjectsDMO()
        Call DetachDatabase(sArg2)
        WScript.Quit
    End If
    
    If (sArg = "/detachall") Then
        If WScript.Arguments.Count <> 1 Then Call ShowHelpAndQuit()
        Call CreateObjectsDMO()
        Call DetachAllIsaServerDatabases()
        oSQLserver.DisConnect 'Not needed, just being tidy...
        WScript.Quit        
    End If
    
    'Should never get to this point.
    WScript.Echo "Invalid argument(s)." & vbCrLf
    Call ShowHelpAndQuit()
End Sub



Sub CreateObjectsDMO()
    On Error Resume Next
    
	Set oSQLserver = CreateObject("SQLDMO.SQLServer")
	oSQLserver.LoginSecure = True       'Use Windows Authentication instead of SQL Authentication.
	oSQLserver.Connect("(LOCAL)\MSFW")  'ISA Server logging MSDE database on local machine.
	
	If Err.Number <> 0 Then
	    WScript.Echo "ERROR: Problem when connecting to (local)\MSFW MSDE database!"
	    WScript.Echo Err.Description
	    WScript.Quit
	End If
End Sub



Sub ListDatabases()
	On Error Resume Next
	Dim cDatabases, oDB
		
    Set cDatabases = oSQLserver.Databases	
    WScript.Echo vbCrLf
    WScript.Echo "-------------------------------------------"    
    WScript.Echo " Attached Online Databases In (Local)\MSFW"
    WScript.Echo "-------------------------------------------"
    
    For Each oDB In cDatabases
        If oDB.SystemObject = False Then
            WScript.Echo oDB.Name   '& " (" & oDB.Size & "MB)"
        End If
    Next 

	oSQLserver.DisConnect()
End Sub



Sub DetachDatabase(sDatabaseName)
	On Error Resume Next
	Dim cDatabases, oDB, sExtension
	
    'Chop off trailing ".mdf" or ".ldf" on the database name, if present. Database name is not case sensitive.
    sExtension = LCase(Right(sDatabaseName,4))
    If (sExtension = ".mdf") Or (sExtension = ".ldf") Then 
        sDatabaseName = Left(sDatabaseName, Len(sDatabaseName) - 4) 
    End If
    
    oSQLserver.DetachDB(sDatabaseName)

    If Err.Number = 0 Then
        WScript.Echo vbCrLf & "Successfully detached database: " & sDatabaseName
    Else
        WScript.Echo vbCrLf & "ERROR: Failed to detach database: " & sDatabaseName & vbCrLf
        WScript.Echo Err.Description
    End If
End Sub



Sub DetachAllIsaServerDatabases()
	On Error Resume Next
	Dim cDatabases, oDB, i, iCounter
		
    Set cDatabases = oSQLserver.Databases	

    'The rest of this sub is strange, but it's the only way I could coax SQL-DMO into actually
    'detaching all databases not in use.  I don't know if this is due to my poor coding skills
    'or if it's a problem with SQL-DMO...but, it works, so I stopped monkeying around with it.

    For Each oDB In cDatabases
        If oDB.SystemObject = False Then
            If UCase(Left(oDB.Name,6)) = "ISALOG" Then iCounter = iCounter + 1   
        End If
    Next 
    
    Do Until iCounter = 0
        For Each oDB In cDatabases
            If oDB.SystemObject = False Then
                If UCase(Left(oDB.Name,6)) = "ISALOG" Then Call DetachDatabase(oDB.Name)
                iCounter = iCounter - 1
                Exit For
            End If
        Next
        cDatabases.Refresh(True)
    Loop

	oSQLserver.DisConnect()
End Sub



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_MSDE_DETACH_DATABASE.VBS /list | /detach dbname | /detachall" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "List or detach ISA Server MSDE logging databases.  Detached" & vbCrLf
    sUsage = sUsage & "database files can be safely deleted, copied or moved." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "           /list = List attached online logging databases. Makes" & vbCrLf
    sUsage = sUsage & "                   no changes to the system." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "  /detach dbname = Detaches the database named ""dbname"" from" & vbCrLf
    sUsage = sUsage & "                   the local MSDE service. The database names" & vbCrLf
    sUsage = sUsage & "                   are shown with the /list option." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "      /detachall = Detaches all ISA Server logging databases" & vbCrLf
    sUsage = sUsage & "                   from the local MSDE service, except for" & vbCrLf
    sUsage = sUsage & "                   the ones currently being used. No other" & vbCrLf
    sUsage = sUsage & "                   databases will be detached." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Stop the ISA Server firewall service if you wish to detach all" & vbCrLf
    sUsage = sUsage & "MSDE logging databases.  When you restart the firewall service," & vbCrLf
    sUsage = sUsage & "new databases will automatically be created as necessary.  See" & vbCrLf
    sUsage = sUsage & "KB838707 and the ISA Server SDK for more information." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Public domain. No rights reserved. Redistribute freely. SCRIPT" & vbCrLf
    sUsage = sUsage & "PROVIDED ""AS IS"" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND." & vbCrLf
    sUsage = sUsage & "USE AT YOUR OWN RISK.  ( www.ISAscripts.org )" & vbCrLf
    sUsage = sUsage & vbCrLf

    WScript.Echo sUsage
    WScript.Quit
End Sub

'*************************************************************************************
