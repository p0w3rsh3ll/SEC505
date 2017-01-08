'*********************************************************************************
' Script Name: ADO_SELECT_Query.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 30.Mar.2005
'     Purpose: Pass an SQL SELECT query to a database and return the resulting 
'              data back as a two-dimensional array.  Only use SELECT queries.
'       Notes: Unfortunately, for backwards compatibility with earlier versions of
'              ADO, the columns are in the first dimension of the array and the
'              rows are in the second, e.g., aArray(5,3) is the fifth column and
'              the third row.  This is the reverse of what most humans expect...
'              The Flip2DArray() function below can be used to switch the column
'              and row dimensions of the array if desired. 
'       Notes: For an Access database, the path can be a full local drive path,
'              just the name of the MDB file (if it's in the same folder as the
'              script), or the full UNC path to a database in a shared folder.
'       Notes: The script is not designed to be compact or fault tolerant, but
'              to illustrate how the three main ADO objects work together.  
'    Keywords: ADO, SQL, database, Access, SELECT
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Use at your own risk.  Script provided "AS IS".
'*********************************************************************************

Function AccessSelectQuery(sDbPath, sSQL)
    Const adCmdText = &H0001
    Const adStateOpen = &H00000001
    Dim oConnection, oCommand, oRecordSet
    
    Set oConnection = CreateObject("ADODB.Connection")
    oConnection.ConnectionString = "DRIVER={Microsoft Access Driver (*.mdb)}; DBQ=" & sDbPath & ";" 
    oConnection.Open
    
    Set oCommand = CreateObject("ADODB.Command")
    Set oCommand.ActiveConnection = oConnection
    oCommand.CommandType = adCmdText
    oCommand.CommandText = sSQL
    
    Set oRecordSet = CreateObject("ADODB.Recordset")
    oRecordSet.Open oCommand
    AccessSelectQuery = oRecordSet.GetRows   'This returns the 2-D array in (columns,rows)
    
    If oRecordSet.State = adStateOpen Then oRecordSet.Close
    If oConnection.State = adStateOpen Then oConnection.Close
    Set oRecordSet = Nothing
    Set oCommand = Nothing 
    Set oConnection = Nothing
End Function




Function SqlServerSelectQuery(sIP, sDbName, sSQL)
    Const adCmdText = &H0001
    Const adStateOpen = &H00000001
    Dim oConnection, oCommand, oRecordSet, sConnectString
    
    sConnectString = "DRIVER={SQL Server};" &_ 
                     "SERVER=" & sIP & ";ADDRESS=" & sIP & ",1433;" &_ 
                     "NETWORK=DBMSSOCN; DATABASE=" & sDbName & "; UID=; PWD=;"    
    
    Set oConnection = CreateObject("ADODB.Connection")
    oConnection.ConnectionString = sConnectString 
    oConnection.Open
    
    Set oCommand = CreateObject("ADODB.Command")
    Set oCommand.ActiveConnection = oConnection
    oCommand.CommandType = adCmdText
    oCommand.CommandText = sSQL
    
    Set oRecordSet = CreateObject("ADODB.Recordset")
    oRecordSet.Open oCommand
    SqlServerSelectQuery = oRecordSet.GetRows   'This returns the 2-D array in (columns,rows)
    
    If oRecordSet.State = adStateOpen Then oRecordSet.Close
    If oConnection.State = adStateOpen Then oConnection.Close
    Set oRecordSet = Nothing
    Set oCommand = Nothing 
    Set oConnection = Nothing
End Function





'*********************************************************************************
' Function: Flip2DArray()
'  Purpose: In a two-dimensional array, each dimension can be thought of as
'           representing column or row data in a table or spreadsheet.  This 
'           function returns a new 2D array with the column and row
'           dimensions of the input array switched or flipped.
' Argument: Either a fixed (Dim) or redimensionable (ReDim) two-dimensional array.
'  Returns: A new redimensionable array with the original dimensions flipped. 
'*********************************************************************************
Function Flip2DArray(ByRef aArray)
    Dim c, r
    ReDim aNewArray( UBound(aArray,2) , UBound(aArray,1) ) 
    For c = 0 To UBound(aArray,1)
        For r = 0 To UBound(aArray,2)
            aNewArray(r,c) = aArray(c,r)
        Next
    Next 
    Flip2DArray = aNewArray
End Function





'END OF SCRIPT **********************************************************************************


a2DArray = AccessSelectQuery("states.mdb", "SELECT * FROM States")
'a2DArray = SqlServerSelectQuery("127.0.0.1", "Northwind", "SELECT BirthDate, HireDate, City FROM Employees")

aNewArray = Flip2DArray(a2DArray)

For iRow = 0 To UBound(aNewArray,1)
    For iColumn = 0 To UBound(aNewArray,2)
        sRowData = sRowData & aNewArray(iRow,iColumn) & vbTab
    Next
    WScript.Echo sRowData
    sRowData = ""
Next


