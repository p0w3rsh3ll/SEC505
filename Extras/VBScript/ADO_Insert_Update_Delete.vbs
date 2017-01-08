'*********************************************************************************
' Script Name: ADO_Insert_Update_Delete.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 3/5/03
'     Purpose: Pass a SQL INSERT, DELETE or UPDATE command to Microsoft Access 
'              or SQL Server.  Any SQL command will work as long as it does not
'              return a recordset (and is supported by the underlying DBMS).  
'              Function returns true if no errors, false otherwise.  
'       Notes: For an Access database, the path can be a full local drive path,
'              just the name of the MDB file (if it's in the same folder as the
'              script), or the full UNC path to a database in a shared folder.
'       Notes: The script is not designed to be compact, fast, or fault tolerant, 
'              but to illustrate how ADO works.  
'    Keywords: ADO, SQL, database, Access, INSERT, UPDATE, DELETE 
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Use at your own risk.  Do not scan networks for which you do not have written permission to do so.
'*********************************************************************************



Function AccessSqlCommand(sDbPath, sSQL)
    On Error Resume Next
    Const adCmdText = &H0001
    Const adStateOpen = &H00000001
    Dim oConnection, oCommand, sText
    
    Set oConnection = CreateObject("ADODB.Connection")
    oConnection.ConnectionString = "DRIVER={Microsoft Access Driver (*.mdb)}; DBQ=" & sDbPath & ";" 
    oConnection.Open
    
    Set oCommand = CreateObject("ADODB.Command")
    Set oCommand.ActiveConnection = oConnection
    oCommand.CommandType = adCmdText
    oCommand.CommandText = sSQL    
    oCommand.Execute

    If oConnection.State = adStateOpen Then oConnection.Close
    Set oCommand = Nothing 
    Set oConnection = Nothing
    
    If Err.Number = 0 Then AccessSqlCommand = True Else AccessSqlCommand = False
End Function





Function SqlServerCommand(sIP, sDbName, sSQL)
    On Error Resume Next
    Const adCmdText = &H0001
    Const adStateOpen = &H00000001
    Dim oConnection, oCommand, sText, sConnectString

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
    oCommand.Execute   

    If oConnection.State = adStateOpen Then oConnection.Close
    Set oCommand = Nothing 
    Set oConnection = Nothing
    
    If Err.Number = 0 Then SqlServerCommand = True Else SqlServerCommand = False
End Function


'END OF SCRIPT **********************************************************************************





WScript.Echo AccessSqlCommand("states.mdb", "DELETE FROM States WHERE StateCode = 'SANS'") 
WScript.Echo AccessSqlCommand("states.mdb", "INSERT INTO States VALUES ('SANS','State Of SANS')") 
WScript.Echo AccessSqlCommand("states.mdb", "UPDATE States SET StateName='SANS Institute' WHERE StateName='State Of SANS'") 

'WScript.Echo SqlServerCommand("127.0.0.1", "Pubs", "DELETE FROM Jobs WHERE job_desc = 'Testing Here!'")
'WScript.Echo SqlServerCommand("127.0.0.1", "Pubs", "INSERT INTO Jobs (job_desc, min_lvl, max_lvl) VALUES ('Testing Here!','100','175')")



