'*******************************************************************************
' Script Name: ADO_Simple_Query.vbs
'     Version: 2.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 11/11/02
'     Purpose: Demonstrate basic ADO query of a Microsoft Access database.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*******************************************************************************


Set oConnection = CreateObject("ADODB.Connection")
oConnection.Open("DRIVER={Microsoft Access Driver (*.mdb)}; DBQ=STATES.MDB;")

Set oRecordSet = oConnection.Execute("SELECT Code,Name FROM StatesTable")

Do Until oRecordSet.EOF
    WScript.Echo oRecordSet("Code") & vbTab & oRecordSet("Name")
    oRecordSet.MoveNext
Loop



oConnection.Execute("INSERT INTO StatesTable (Code,Name) VALUES ('SANS','State Of SANS')")
oConnection.Execute("UPDATE StatesTable SET Name = 'WisconSANS' WHERE Code = 'SANS'")
oConnection.Execute("DELETE FROM StatesTable WHERE Code = 'SANS'")


'END OF SCRIPT******************************************************************

