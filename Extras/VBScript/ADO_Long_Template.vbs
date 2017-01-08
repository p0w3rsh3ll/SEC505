'*********************************************************************************
' Script Name: ADO_Long_Template.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 3/22/03
'     Purpose: Provides a starting point for writing ADO scripts.  It is not 
'              intended to be as compact as possible, but to show properties
'              and methods in an illustrative way.
'       Notes: Three websites you should definitely visit when learning ADO:
'                 http://www.w3schools.com/ado/
'                 http://www.devguru.com/Technologies/ado/quickref/ado_intro.html
'                 http://www.able-consulting.com/ADO_Conn.htm
'       Notes: Not all ADO constants are listed here.  Search Google for a file
'              named "adovbs.inc" to get a complete listing in one file.
'    Keywords: ADO, SQL, database
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Use at your own risk.  Do not scan networks for which you do not have written permission to do so.
'*********************************************************************************

Dim oConnection, oCommand, oRecordSet

Set oConnection = CreateObject("ADODB.Connection")
oConnection.ConnectionString = "DRIVER={Microsoft Access Driver (*.mdb)}; DBQ=states.mdb; UID=; PWD=;" 
'oConnection.Provider = "Microsoft.Jet.OLEDB.4.0"    'Don't specify if provider implied in ConnectionString.
oConnection.Open

Set oCommand = CreateObject("ADODB.Command")
Set oCommand.ActiveConnection = oConnection
oCommand.CommandType = adCmdUnknown
oCommand.CommandTimeout = 30                        'Max seconds for command to complete.
oCommand.CommandText = "SELECT Code,Name FROM StatesTable"      

Set oRecordSet = CreateObject("ADODB.Recordset")
oRecordSet.CursorLocation = adUseServer
oRecordSet.CursorType = adOpenForwardOnly
oRecordSet.LockType = adLockReadOnly
oRecordSet.Open oCommand


' Now do something with the populated recordset...
Do Until oRecordSet.EOF
    WScript.Echo oRecordSet("Code") & vbTab & oRecordSet("Name")
    oRecordSet.MoveNext
Loop


' And then clean up afterwards...
If oRecordSet.State = adStateOpen Then oRecordSet.Close
If oConnection.State = adStateOpen Then oConnection.Close
Set oRecordSet = Nothing
Set oCommand = Nothing 
Set oConnection = Nothing



'*********************************************************************************
' A partial listing of available ADO constants and a few connection strings.
'*********************************************************************************

'oConnection.Provider 
'   Don't specify a provider if one is set/implied in the ConnectionString.
'   "ADSDSOObject"              'Active Directory.
'   "Microsoft.Jet.OLEDB.4.0"   'Microsoft Jet Databases, like MS Access.
'   "MSDAIPP.DSO.1"             'Microsoft Internet Publishing.  
'   "MSDAORA"                   'Oracle Databases.  
'   "MSDAOSP"                   'Simple Text Files (*.txt, *.csv).  
'   "MSDASQL"                   'Microsoft OLE DB Provider for ODBC (default).
'   "MSDataShape"               'Microsoft Data Shape.  
'   "MSPersist"                 'Locally Saved Files.  
'   "SQLOLEDB"                  'Microsoft SQL Server.  

'oCommand.CommandType 
Const adCmdUnknown = &H0008             'Default.  When in doubt, use this.  Provider is queried.
Const adCmdUnspecified = -1             'Command type unspecified.
Const adCmdText = &H0001                'Textual definition of a SQL command or stored procedure call.
Const adCmdStoredProc = &H0004          'For stored procedures at server.  Set parameters first!
Const adCmdTable = &H0002               'Table name whose columns are all returned by an internally generated SQL query.
Const adCmdFile = &H0100                'File name of a persistently stored recordset. Used with Recordset.Open or Requery only.
Const adCmdTableDirect = &H0200         'Table name whose columns are all returned. Used with Recordset.Open or Requery only. To use the Seek method, the recordset must be opened with this.

'oRecordSet.CursorLocation
Const adUseServer = 2                   'Default. Server handles the cursor.
Const adUseClient = 3                   'Client handles the cursor for versatility.

'oRecordSet.CursorType
Const adOpenForwardOnly = 0             'Default. Forward scrolling only. Fast.
Const adOpenKeyset = 1                  'Like a dynamic cursor, except that you can't see records that other users add, although records that other users delete are inaccessible from your Recordset. Data changes by other users are still visible.
Const adOpenDynamic = 2                 'Additions, changes, and deletions by other users are visible, and all types of movement through the Recordset are allowed.
Const adOpenStatic = 3                  'A static copy of a set of records that you can use to find data or generate reports. Additions, changes, or deletions by other users are not visible.
Const adOpenUnspecified = -1            'Cursor type unspecified.

'oRecordSet.LockType
Const adLockReadOnly = 1                'Default. Read-only records.
Const adLockPessimistic = 2             'Pessimistic locking, record by record. The provider lock records immediately after editing. The provider locks each record before and after you edit, and prevents other users from modifying the data.
Const adLockOptimistic = 3              'Optimistic locking, record by record. The provider lock records only when calling update. Multiple users can modify the data which is not locked until Update is called.
Const adLockBatchOptimistic = 4         'Optimistic batch updates. Required for batch update mode. Multiple users can modify the data and the changes are cached until BatchUpdate is called.
Const adLockUnspecified = -1            'Lock type unspecified.

'oADO_Object.State
Const adStateClosed = &H00000000
Const adStateOpen = &H00000001
Const adStateConnecting = &H00000002
Const adStateExecuting = &H00000004
Const adStateFetching = &H00000008

'oConnection.ConnectionString
    'Connect to a local Microsoft Access database without a DSN:
    '   "DRIVER={Microsoft Access Driver (*.mdb)}; DBQ=C:\Path\db.mdb; UID=; PWD=;"

    'Connect to a remote Access database in a shared folder:
    '   "DRIVER={Microsoft Access Driver (*.mdb)}; DBQ=\\Server\Share\db.mdb; UID=; PWD=;"

    'Connect to a local Microsoft SQL Server:
    '   "DRIVER={SQL Server}; SERVER=(local); DATABASE=myDatabaseName; UID=; PWD=;"

    'Connect to a remote Microsoft SQL Server by its IP address:
    '   "DRIVER={SQL Server}; SERVER=xxx.xxx.xxx.xxx; ADDRESS=xxx.xxx.xxx.xxx,1433; NETWORK=DBMSSOCN; DATABASE=myDatabaseName; UID=; PWD=;"

    'Connect to a database by an ODBC Data Source Name (DSN):
    '   "DSN=mySystemDSNname; UID=; PWD=;"

    'Connect to a database by an ODBC file DSN:
    '   "FILEDSN=C:\Path\File.dsn; UID=; PWD=;"

    'Connect to a database using a UDL file:
    '   "FILE NAME=C:\Path\File.udl;"

    'Connect to an Excel spreadsheet:
    '   "DRIVER={Microsoft Excel Driver (*.xls)}; DRIVERID=790; DBQ=C:\Path\file.xls; DEFAULTDIR=C:\Path;"
    

'END OF SCRIPT **********************************************************************************

