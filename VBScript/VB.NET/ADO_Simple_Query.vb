'*************************************************************************************
'   File Name: ADO_Simple_Query.vb
'     Version: 1.0
'      Author: Jason Fossen
'Last Updated: 04/15/2003
'     Purpose: Demonstrate a query using ADO.NET.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*************************************************************************************
Module Module1

    Sub Main()
        Dim sConnectionString As String = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=states.mdb;"
        Dim oConnection As New System.Data.OleDb.OleDbConnection(sConnectionString)
        oConnection.Open()

        Dim sSQL As String = "SELECT Code,Name FROM StatesTable"
        Dim oDataAdapter As New System.Data.OleDb.OleDbDataAdapter(sSQL, oConnection)
        Dim oDataSet As New System.Data.DataSet()
        oDataAdapter.Fill(oDataSet, "TempTableName")

        oConnection.Close()

        Dim oTable As System.Data.DataTable
        oTable = oDataSet.Tables("TempTableName")
        Call WriteTableToConsole(oTable)
    End Sub


    Sub WriteTableToConsole(ByRef oTable As System.Data.DataTable)
        Dim oRow As System.Data.DataRow
        Dim oColumn As System.Data.DataColumn
        Dim i, j As Integer

        For i = 0 To oTable.Rows.Count - 1
            oRow = oTable.Rows(i)
            For j = 0 To oTable.Columns.Count - 1
                System.Console.Write(oRow.Item(j) & ControlChars.Tab)
            Next
            System.Console.WriteLine()
        Next
    End Sub

End Module




