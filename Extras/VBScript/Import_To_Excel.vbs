'**************************************************************************
' Script Name: Import_To_Excel.vbs
'     Version: 2.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 30.Mar.2005
'     Purpose: This function takes a one- or two-dimensional array and imports its
'              elements into a new Microsoft Excel spreadsheet.  Function returns
'              true if no errors, false otherwise.  Excel must be installed first.
'              Assumes that first dimension in a 2D array is for rows and the Second
'              dimension is for columns.  Use the Flip2DArray() function to put 
'              the array's data into (row,column) order if necessary.
'    Keywords: Excel, import, spreadsheet
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTIES OF ANY KIND.
'**************************************************************************

Function ImportToExcel(ByRef aDataArray)
    On Error Resume Next
    Dim oExcel, oSheet, iRow, iColumns, iColumn
    
    Set oExcel = WScript.CreateObject("Excel.Application")
    oExcel.Visible = True
    oExcel.Workbooks.Add
    Set oSheet = oExcel.ActiveWorkBook.WorkSheets(1)
    
    iColumns = UBound(aDataArray,2) 'Attempt to read second dimension size, catch error.
    
    If Err.Number = 0 Then
        For iRow = 0 To UBound(aDataArray,1)
            For iColumn = 0 To iColumns
                oSheet.Cells(iRow + 1, iColumn + 1).Value = aDataArray(iRow,iColumn)
            Next
        Next
    Else 'Err <> 0, hence, assume a one-dimensional array.
        Err.Clear
        For iRow = 0 To UBound(aDataArray,1)
            oSheet.Cells(iRow + 1, 1).Value = aDataArray(iRow)
        Next
    End If
            
    Set oSheet = Nothing
    Set oExcel = Nothing   
    If Err.Number = 0 Then ImportToExcel = True Else ImportToExcel = False
End Function



'*********************************************************************************
' Function: Flip2DArray()
'  Purpose: In a two-dimensional array, each dimension can be thought of as
'           representing column or row data in a table or spreadsheet.  This 
'           function returns a new 2D array with the column and row
'           dimensions of the input array switched or "flipped".
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





'END OF SCRIPT *******************************************************************




Dim bError

Dim aAtoms(5)
aAtoms(0) = "Hydrogen"
aAtoms(1) = "Oxygen" 
aAtoms(2) = "Carbon"
aAtoms(3) = "Helium"
aAtoms(4) = "Argon"
aAtoms(5) = "Neon"
'bError = ImportToExcel(aAtoms)  'Test a one-dimensional array.

Dim aNames(4,2)
aNames(0,0) = "First"
aNames(0,1) = "Last"
aNames(0,2) = "Pet Type"

aNames(1,0) = "Amy"
aNames(1,1) = "Carter"
aNames(1,2) = "Dog"

aNames(2,0) = "Karin"
aNames(2,1) = "Buck"
aNames(2,2) = "Cat"

aNames(3,0) = "Lara"
aNames(3,1) = "Rah"
aNames(3,2) = "Rabbit"

aNames(4,0) = "Carol"
aNames(4,1) = "Kramer"
aNames(4,2) = "Sea Monkey"

bError = ImportToExcel(aNames) 'Test a two-dimensional array.


