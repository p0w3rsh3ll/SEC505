'*************************************************************************************
' Script Name: ISA_MSDE_Max_Memory.vbs
'     Version: 1.0
'      Author: Jason Fossen ( www.ISAscripts.org )
'Last Updated: 16.Oct.2005
'     Purpose: When ISA Server logs to local MSDE database files, the SQL Server/MSDE
'              service (sqlservr.exe) can sometimes consume too much memory.  This 
'              script gets or sets the MSDE option to limit the amount of memory it is 
'              permitted to use.  You must be a local Administrator or, strictly
'              speaking, have the sysadmin fixed server role in SQL Server/MSDE.  
'       Notes: The script uses the SQL Distributed Management Objects (SQL-DMO):
'                 http://msdn.microsoft.com/library/en-us/sqldmo/dmoref_con01_2yi7.asp
'              The script does not require OSQL.EXE or creating any .sql scripts.
'              For more information about this memory issue, see the following:
'                 http://www.google.com/search?hl=en&q=site%3Aisaserver.org+msde+memory
'              Run the script within a CMD shell using CSCRIPT.EXE.  
'      Credit: Script idea came from a tip in an article by Adar Greenshpon at Microsoft.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK.  Don't use this script if you don't have any
'              idea what it does or what you are doing or why you are doing it...OK?
'              And generally don't set your memory limit to anything smaller than 32 MB.
'*************************************************************************************
Option Explicit
On Error Resume Next

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
    Dim sArg
    
    If WScript.Arguments.Count <> 1 Then Call ShowHelpAndQuit()

    sArg = LCase(WScript.Arguments.Item(0))
    
    If (sArg = "/?") Or (sArg = "-?") Or (sArg = "/h") Or (sArg = "/help") Or (sArg = "--help") Then Call ShowHelpAndQuit()
   
    'If argument is a number, set memory to that number; otherwise, just show current value.
    
    If IsNumeric(sArg) Then
        If SetCurrentMaxServerMemoryValue(sArg) Then
            WScript.Echo vbCrLf & "SUCCESS: Maximum database server memory successfully set to " & sArg & " MB." & vbCrLf
            WScript.Echo "Current maximum database server memory = " & GetCurrentMaxServerMemoryValue() & vbCrLf
        Else 'Function returned False, there was a problem...
            WScript.Echo vbCrLf & "ERROR: There was a problem setting the value!" & vbCrLf & Err.Description
            WScript.Echo "Are you a local administrator?  Are you running this script on the ISA Server itself?"
            WScript.Echo "Is logging to a local MSDE database even enabled?"
        End If
    Else 'The argument was not numeric, so just show current value.
        WScript.Echo vbCrLf & "Current maximum database server memory = " & GetCurrentMaxServerMemoryValue() & vbCrLf
    End If

End Sub




Function GetCurrentMaxServerMemoryValue()
	On Error Resume Next
	Dim oSQLserver, oConfiguration, bCurrentState, oConfigValue
	GetCurrentMaxServerMemoryValue = "ERROR" 'Function's return will either start with "ERROR" or the value number. 
	
	Set oSQLserver = CreateObject("SQLDMO.SQLServer")
	oSQLserver.LoginSecure = True       'Use Windows Authentication instead of SQL Authentication.
	oSQLserver.Connect("(LOCAL)\MSFW")  'ISA Server logging MSDE database on local machine.
	
    If Err.Number <> 0 Then 
        GetCurrentMaxServerMemoryValue = "ERROR : Cannot connect to (Local)\MSFW database : " & Err.Description
        Exit Function
    End If
	
	Set oConfiguration = oSQLserver.Configuration
	bCurrentState = oConfiguration.ShowAdvancedOptions
	oConfiguration.ShowAdvancedOptions = True
	
	Set oConfigValue = oSQLServer.Configuration.ConfigValues("max server memory (MB)")
	GetCurrentMaxServerMemoryValue = oConfigValue.CurrentValue
	
	If Err.Number <> 0 Then 
        GetCurrentMaxServerMemoryValue = "ERROR : Cannot read current value : " & Err.Description
    End If
	
	oConfiguration.ShowAdvancedOptions = bCurrentState
	oSQLserver.DisConnect()
End Function



Function SetCurrentMaxServerMemoryValue(iMB)
	On Error Resume Next
    Dim oSQLserver, oConfiguration, bCurrentState, oConfigValue
	SetCurrentMaxServerMemoryValue = False          'Function returns True or False, hence, assume False for now.
	
	iMB = Abs(Round(CDbl(Trim(Replace(CStr(iMB), ",", "")))))   'Clean the input a bit, just in case.
	If iMB < 4 Then iMB = 4                         '4 MB is minimum permitted value, but don't set it this low!
	If iMB > 2147483647 Then iMB = 2147483647       '2,147,483,647 MB is the maximum permitted value.
	iMB = CStr(iMB)                                 'It actually needs to be a string, not an integer...
	
	Set oSQLserver = CreateObject("SQLDMO.SQLServer")
	oSQLserver.LoginSecure = True                   'Use Windows Authentication instead of SQL Authentication.
	oSQLserver.Connect("(LOCAL)\MSFW")              'The ISA Server logging MSDE database on local machine.
		
	Set oConfiguration = oSQLserver.Configuration
	bCurrentState = oConfiguration.ShowAdvancedOptions  'Will set current state of this value back afterwards.
	oConfiguration.ShowAdvancedOptions = True
	
	Set oConfigValue = oSQLServer.Configuration.ConfigValues("max server memory (MB)") 
	oConfigValue.CurrentValue = iMB 
	        
	'No need to restart SQL Server, this value is True for DynamicReconfigure.
	oConfiguration.ShowAdvancedOptions = bCurrentState
	oConfiguration.ReconfigureWithOverride()
	
	If Err.Number = 0 Then SetCurrentMaxServerMemoryValue = True Else SetCurrentMaxServerMemoryValue = False
	oSQLserver.DisConnect()
End Function



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_MSDE_Max_Memory.vbs [value] | [/show] | [/?]" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "This script will query or configure the maximum amount of memory" & vbCrLf
    sUsage = sUsage & "the SQL/MSDE service is permitted to use for logging on the" & vbCrLf
    sUsage = sUsage & "local ISA Server.  It does not limit the size of your database" & vbCrLf
    sUsage = sUsage & "logs, only the amount of memory the SQL/MSDE service can use." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "       value = Number of megabytes of memory to which the SQL/MSDE" & vbCrLf
    sUsage = sUsage & "               service will be limited.  Makes changes to the system." & vbCrLf
    sUsage = sUsage & "               Example: cscript.exe ISA_MSDE_Max_Memory.vbs 512" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "       /show = Shows the current upper memory limit. Makes no changes." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "          /? = Shows this help. Makes no changes." & vbCrLf
    sUsage = sUsage & "  " & vbCrLf
    sUsage = sUsage & "The script does not require OSQL.EXE, SQL Server Enterprise Manager, " & vbCrLf
    sUsage = sUsage & "or the SQL Query Analyzer in order to run, but you must be a " & vbCrLf
    sUsage = sUsage & "local Administrators group member.  Do not set a memory limit if" & vbCrLf
    sUsage = sUsage & "you don't know what you are doing or why you are doing it!  The " & vbCrLf
    sUsage = sUsage & "default Microsoft setting is 2147483647 MB.  In general, do not set" & vbCrLf
    sUsage = sUsage & "the value smaller than 32 MB, and 512 MB is an OK setting if you " & vbCrLf
    sUsage = sUsage & "have 2 GB or more of RAM." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "Script is public domain. No rights reserved. SCRIPT PROVIDED ""AS IS"" " & vbCrLf
    sUsage = sUsage & "WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.  USE AT YOUR OWN RISK." & vbCrLf
    sUsage = sUsage & "No technical support provided.  ( www.ISAscripts.org )" & vbCrLf
    sUsage = sUsage & vbCrLf

    WScript.Echo sUsage
    WScript.Quit
End Sub

'*************************************************************************************
