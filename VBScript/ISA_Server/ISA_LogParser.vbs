'*******************************************************************************
' Script Name: ISA_LogParser.vbs
'     Version: 1.2
'      Author: Jason Fossen (www.ISAscripts.org)
'Last Updated: 23.Jan.2006
'     Purpose: Demonstrates use of the wonderful Log Parser tool for querying
'              ISA Server logs, IIS logs, etc. (see www.logparser.com).  Use the 
'              script by uncommenting the query and input format you want to run,
'              then pass in any necessary command-line arguments, e.g., the name
'              of a logfile (or use wildcards to specify a set of logfiles).  If
'              you run a particular query regularly, make a copy of the script and
'              rename it after the query you've selected in it.
'       Notes: You must install the free Log Parser tool (www.logparser.com) from
'              Microsoft in order for the script to work.  You can also just 
'              register the necessary DLL (regsvr32.exe logparser.dll).
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'*******************************************************************************
On Error Resume Next
Dim sFirstArg : sFirstArg = WScript.Arguments.Item(0) 
If (WScript.Arguments.Count <> 1) Or (LCase(sFirstArg) = "/?") Or (LCase(sFirstArg) = "-h") Then Call ShowHelpAndQuit()
On Error Goto 0  'If the query chokes, we want to see the error.



'--------------------------------------------------------------------
' Choose a query by uncommenting it from one of the many sample
' queries below.  Queries are divided into categories based On
' on input type.  (oInputFormat necessary shown in parentheses.)
' Then choose an sInputFormat after that, appropriate to your query.
'--------------------------------------------------------------------


'--------------------------------------------------------------------
' ISA Web Proxy Logs in W3C format (MSUtil.LogQuery.W3CInputFormat) 
'--------------------------------------------------------------------

' Count of unique IP addresses NOT accessing a particular file or filetype from the External network in Web Proxy logs.
'sQuery = "SELECT COUNT(DISTINCT c-ip) FROM " & sFirstArg & " WHERE cs-uri Not Like '%robots.txt' AND cs-Network = 'External' AND rule Like '%www.isascripts.org' "  

' Count of unique client IP addresses from the External network in Web Proxy logs.
'sQuery = "SELECT COUNT(DISTINCT c-ip) FROM " & sFirstArg & " WHERE cs-Network = 'External' AND rule Like '%www.isascripts.org' "

' Count of unique IP addresses accessing a particular file or filetype from the External network in Web Proxy logs.
'sQuery = "SELECT COUNT(DISTINCT c-ip) FROM " & sFirstArg & " WHERE cs-uri Like '%.zip' AND cs-Network = 'External' "   

' Count of unique IP addresses accessing the robots.txt file from the External network in Web Proxy logs.
'sQuery = "SELECT COUNT(DISTINCT c-ip) FROM " & sFirstArg & " WHERE cs-uri Like '%robots.txt' AND cs-Network = 'External' "   

' List of unique client IP addresses in ISA Web Proxy or IIS W3C Extended logs.
'sQuery = "SELECT DISTINCT c-ip FROM " & sFirstArg & " ORDER BY c-ip DESC"

' Count of HTTP Filter error messages from Web Proxy logs.
'sQuery = "SELECT COUNT(*),FilterInfo FROM " & sFirstArg & " WHERE FilterInfo <> Null GROUP BY FilterInfo ORDER BY Count(*) DESC "

' Top 20 external IP addresses that have generated Denied entries in Web Proxy logs.
'sQuery = "SELECT TOP 20 COUNT(*),c-ip FROM " & sFirstArg & " WHERE (Action = 'Denied') AND (cs-Network = 'External') AND (c-ip Not Like '172.16.%') GROUP BY c-ip ORDER BY Count(*) DESC"

' Top 10 external FQDNs that have generated Denied entries in Web Proxy logs (reverse DNS lookups).
'sQuery = "SELECT TOP 10 COUNT(*),REVERSEDNS(c-ip) As fqdn FROM " & sFirstArg & " WHERE (Action = 'Denied') AND (cs-Network = 'External') AND (c-ip Not Like '172.16.%') GROUP BY fqdn ORDER BY Count(*) DESC"

' Top 20 users based on total bytes sent or received as shown from Web Proxy logs.
'sQuery = "SELECT TOP 20 SUM(ADD(cs-bytes,sc-bytes)) As Bytes,TO_LOWERCASE(cs-username) As User FROM " & sFirstArg & " GROUP BY User ORDER BY Bytes DESC "

' IPs and FQDNs accessed by each user as shown from the Web Proxy logs.
sQuery = "SELECT DISTINCT TO_LOWERCASE(cs-username) As User, r-host FROM " & sFirstArg & " WHERE s-svcname = 'w3proxy' ORDER BY User"

' Percentage of log lines specifically Denied, categorized by governing rule in both Firewall and Web Proxy logs.
'sQuery = "SELECT rule,MUL(PROPCOUNT(*),100) As Percent FROM " & sFirstArg & " WHERE action = 'Denied' GROUP BY rule ORDER BY Percent DESC"

' Percentage of log lines with Allowed or Establish actions, categorized by governing rule in both Firewall and Web Proxy log.
'sQuery = "SELECT rule,MUL(PROPCOUNT(*),100) As Percent FROM " & sFirstArg & " WHERE (action = 'Establish' Or action = 'Allowed') GROUP BY rule ORDER BY Percent DESC"



'--------------------------------------------------------------------
' ISA Firewall Logs in W3C format (MSUtil.LogQuery.W3CInputFormat) 
'--------------------------------------------------------------------
' Top 20 external IP addresses that have generated Denied entries in Firewall logs.
'sQuery = "SELECT TOP 20 COUNT(*),EXTRACT_TOKEN(source,0,':') As IpAddr FROM " & sFirstArg & " WHERE (Action = 'Denied') AND ([source network] = 'External') AND (source Not Like '172.16.%') GROUP BY IpAddr ORDER BY Count(*) DESC"

' Percentage of each type of status code in Firewall logs.
'sQuery = "SELECT status,MUL(PROPCOUNT(*),100) As Percent FROM " & sFirstArg & " GROUP BY status ORDER BY Percent DESC"

' Top 20 external IP addresses that have sent Ping of Death packets as shown in Firewall logs.
' In general, use this query to extract Top X list for any status error message type: SYN attacks, LAND attacks, etc.
'sQuery = "SELECT TOP 20 COUNT(*),EXTRACT_TOKEN(source,0,':') As IpAddr FROM " & sFirstArg & " WHERE (status Like '0xc0040019') AND ([source network] = 'External') GROUP BY IpAddr ORDER BY Count(*) DESC"

' Top 20 external IP addresses that have sent packets whose headers were logged as raw hex in Firewall logs (bad sign).
'sQuery = "SELECT TOP 20 COUNT(*),EXTRACT_TOKEN(source,0,':') As IpAddr FROM " & sFirstArg & " WHERE ([IP header] <> Null) AND ([source network] = 'External') GROUP BY IpAddr ORDER BY Count(*) DESC"

' Count of agent applications from Firewall logs.
'sQuery = "SELECT COUNT(*),agent FROM " & sFirstArg & " GROUP BY agent ORDER BY Count(*) DESC "

' Top 20 users based on total bytes sent or received as shown from Firewall logs.
'sQuery = "SELECT TOP 20 SUM(ADD([bytes received],[bytes sent])) As Bytes,TO_LOWERCASE(username) As User FROM " & sFirstArg & " GROUP BY User ORDER BY Bytes DESC "

' Percentage of log lines specifically Denied, categorized by governing rule in both Firewall and Web Proxy logs.
'sQuery = "SELECT rule,MUL(PROPCOUNT(*),100) As Percent FROM " & sFirstArg & " WHERE action = 'Denied' GROUP BY rule ORDER BY Percent DESC"

' Percentage of log lines with Allowed or Establish actions, categorized by governing rule in both Firewall and Web Proxy log.
'sQuery = "SELECT rule,MUL(PROPCOUNT(*),100) As Percent FROM " & sFirstArg & " WHERE (action = 'Establish' Or action = 'Allowed') GROUP BY rule ORDER BY Percent DESC"



'--------------------------------------------------------------------
' IIS Logs in W3C format (MSUtil.LogQuery.IISW3CInputFormat) 
'--------------------------------------------------------------------
' Unique referrer URLs in IIS logs with some qualifiers to filter out noise in W3C Extended format for IIS.
'sQuery = "SELECT COUNT(c-ip),cs(Referer) FROM " & sFirstArg & " WHERE (c-ip Not Like '172.16%') AND (c-ip <> '68.93.110.249') AND (cs(Referer) Not Like '%isascripts.org%') AND (cs(Referer) Not Like '%microsoft.public.%') GROUP BY cs(Referer) ORDER BY Count(c-ip) DESC "

' Unique user-agents in IIS logs with some qualifiers to filter out noise in W3C Extended format for IIS.
'sQuery = "SELECT COUNT(*),cs(User-Agent) FROM " & sFirstArg & " WHERE (c-ip Not Like '172.16%') AND (c-ip <> '68.93.110.249') GROUP BY cs(User-Agent) ORDER BY Count(*) DESC "

' List of unique client IP addresses in ISA Web Proxy or IIS W3C Extended logs.
'sQuery = "SELECT DISTINCT c-ip FROM " & sFirstArg & " ORDER BY c-ip DESC"

' Unique referrer FQDNs in IIS logs with some qualifiers to filter out noise in W3C Extended format for IIS.
'sQuery = "SELECT COUNT(c-ip),EXTRACT_TOKEN(cs(Referer),2,'/') As fqdn FROM " & sFirstArg & " WHERE (c-ip Not Like '172.16%') AND (c-ip <> '68.93.110.249') AND (cs(Referer) Not Like '%isascripts.org%') AND (cs(Referer) Not Like '%microsoft.public.%') GROUP BY fqdn HAVING Count(*) > 1 ORDER BY Count(c-ip) DESC "




'--------------------------------------------------------------------
' Depending on the sQuery you've chosen above, now choose an input 
' format by uncommenting it.
'--------------------------------------------------------------------
sInputFormat = "MSUtil.LogQuery.W3CInputFormat"        'W3C
'sInputFormat = "MSUtil.LogQuery.ADSInputFormat"        'ADS
'sInputFormat = "MSUtil.LogQuery.IISBINInputFormat"     'BIN
'sInputFormat = "MSUtil.LogQuery.CSVInputFormat"        'CSV
'sInputFormat = "MSUtil.LogQuery.ETWInputFormat"        'ETW
'sInputFormat = "MSUtil.LogQuery.EventLogInputFormat"   'EVT
'sInputFormat = "MSUtil.LogQuery.FileSystemInputFormat" 'FS
'sInputFormat = "MSUtil.LogQuery.HttpErrorInputFormat"  'HTTPERR
'sInputFormat = "MSUtil.LogQuery.IISIISInputFormat"     'IIS
'sInputFormat = "MSUtil.LogQuery.IISODBCInputFormat"    'IISODBC
'sInputFormat = "MSUtil.LogQuery.IISW3CInputFormat"     'IISW3C
'sInputFormat = "MSUtil.LogQuery.IISNCSAInputFormat"    'NCSA
'sInputFormat = "MSUtil.LogQuery.NetMonInputFormat"     'NETMON
'sInputFormat = "MSUtil.LogQuery.RegistryInputFormat"   'REG
'sInputFormat = "MSUtil.LogQuery.TextLineInputFormat"   'TEXTLINE
'sInputFormat = "MSUtil.LogQuery.TextWordInputFormat"   'TEXTWORD
'sInputFormat = "MSUtil.LogQuery.TSVInputFormat"        'TSV
'sInputFormat = "MSUtil.LogQuery.URLScanLogInputFormat" 'URLSCAN
'sInputFormat = "MSUtil.LogQuery.XMLInputFormat"        'XML



'--------------------------------------------------------------------
' The following are output formats available, but it's unlikely that
' you'll need to uncomment one in this script.  Just for reference.
' If you're uncertain, don't uncomment anything in this section.
'--------------------------------------------------------------------
'oOutputFormat = "MSUtil.LogQuery.ChartOutputFormat"    'CHART
'oOutputFormat = "MSUtil.LogQuery.CSVOutputFormat"      'CSV
'oOutputFormat = "MSUtil.LogQuery.DataGridOutputFormat" 'DATAGRID
'oOutputFormat = "MSUtil.LogQuery.IISOutputFormat"      'IIS
'oOutputFormat = "MSUtil.LogQuery.NativeOutputFormat"   'NAT
'oOutputFormat = "MSUtil.LogQuery.SQLOutputFormat"      'SQL
'oOutputFormat = "MSUtil.LogQuery.SYSLOGOutputFormat"   'SYSLOG
'oOutputFormat = "MSUtil.LogQuery.TemplateOutputFormat" 'TPL
'oOutputFormat = "MSUtil.LogQuery.TSVOutputFormat"      'TSV
'oOutputFormat = "MSUtil.LogQuery.W3COutputFormat"      'W3C
'oOutputFormat = "MSUtil.LogQuery.XMLOutputFormat"      'XML









' The rest of the script... 

WScript.Echo "-------------------------------------------------------------------------------"
WScript.Echo MakeNiceParagraph(sQuery, 77, 1)
WScript.Echo "-------------------------------------------------------------------------------"
Call PrintLogQuery(sQuery, sInputFormat)



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Procedures & Functions
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub PrintLogQuery(sQuery, sInputFormat)
    Dim oLogQuery, oInputFormat, oRecordSet, oRecord

    Set oLogQuery    = CreateObject("MSUtil.LogQuery")        
    Set oInputFormat = CreateObject(sInputFormat)
    Set oRecordSet   = oLogQuery.Execute(sQuery, oInputFormat)
    
    Do While Not oRecordSet.AtEnd
        Set oRecord = oRecordSet.GetRecord
        WScript.Echo oRecord.ToNativeString(",")
        oRecordSet.MoveNext
    Loop
    
    oRecordSet.close
End Sub



Function MakeNiceParagraph(sText, iMaxLength, iIndent)
    '
    'Note: iMaxLength is the max length of each line of output, including
    '      the prepended space characters.  80 is the usual CMD shell width.
    'Note: iIndent is the number of space characters prepended to each line.
    '    
    Dim sOutput, iChunkSize, iStart, iTextLength
    
    If (Len(sText) + iIndent) <= iMaxLength Then
        MakeNiceParagraph = Space(iIndent) & sText
        Exit Function
    End If
    
    iChunkSize = iMaxLength - iIndent
    iStart = 1
    iTextLength = Len(sText)
    sOutput = ""
    
    Do Until iStart > iTextLength
        sOutput = sOutput & Space(iIndent) & LTrim(Mid(sText, iStart, iChunkSize)) & vbCrLf
        iStart = iStart + iChunkSize
    Loop
    
    If sOutput <> "" Then
        MakeNiceParagraph = Left(sOutput, Len(sOutput) - 1) 'Trim off last vbCrLf
    Else
        MakeNiceParagaph = ""
    End If
End Function



Sub ShowHelpAndQuit()
    Dim sUsage : sUsage = vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "ISA_LOG_PARSER.VBS logfile [/?]" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "    Purpose: Demonstrates use of the wonderful Log Parser tool for querying" & vbCrLf
    sUsage = sUsage & "             ISA Server logs, IIS logs, etc. (see www.logparser.com).  Use the " & vbCrLf
    sUsage = sUsage & "             script by uncommenting the query and input format you want to run," & vbCrLf
    sUsage = sUsage & "             then pass in any necessary command-line arguments, e.g., the name" & vbCrLf
    sUsage = sUsage & "             of a logfile (or use wildcards to specify a set of logfiles).  If" & vbCrLf
    sUsage = sUsage & "             you run a particular query regularly, make a copy of the script and" & vbCrLf
    sUsage = sUsage & "             rename it after the query you've selected in it." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "      Notes: You must install the free Log Parser tool (www.logparser.com) from" & vbCrLf
    sUsage = sUsage & "             Microsoft in order for the script to work.  The Log Parser tool" & vbCrLf
    sUsage = sUsage & "             also includes extensive help for creating your own new queries." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "       Args: logfile -- Most likely you'll use or devise SQL queries for ISA" & vbCrLf
    sUsage = sUsage & "             or IIS logfiles, hence, the script requires at least one " & vbCrLf
    sUsage = sUsage & "             argument (logfile) to run.  Pass in a logfile name with wildcards" & vbCrLf
    sUsage = sUsage & "             to run the query against the data from all the logs, e.g.," & vbCrLf
    sUsage = sUsage & "             you can use ""ISALOG_200508*_WEB_*.w3c"" to process all the Web " & vbCrLf
    sUsage = sUsage & "             Proxy logs on ISA for the Month of August, 2005." & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & "      Legal: SCRIPT PROVIDED ""AS IS"" WITHOUT WARRANTIES OR GUARANTEES OF ANY" & vbCrLf
    sUsage = sUsage & "             KIND. USE AT YOUR OWN RISK.  ( www.ISAscripts.org )" & vbCrLf
    sUsage = sUsage & vbCrLf
    sUsage = sUsage & vbCrLf

    WScript.Echo sUsage
    WScript.Quit
End Sub


'EOF ***************************************************************************
