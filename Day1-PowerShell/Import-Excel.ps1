#**************************************************************************
# Script Name: Import-Excel.ps1
#     Version: 2.3
#      Author: Jason Fossen 
#Last Updated: 5.Sep.2010
#     Purpose: This function takes a one- or two-dimensional array and imports its
#              elements into a new Excel spreadsheet. Excel must be installed.
#              Assumes that first dimension in a 2D array is for rows and the second
#              dimension is for columns.  Use the Flip2DArray() function below to put 
#              the array's data into (row,column) order if necessary.  It's
#              probably easier to export to a CSV file and then open that file in
#              Excel, but the aim here is to demo some Excel scripting. 
#       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
#              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTIES OF ANY KIND.
#**************************************************************************


Function Import-Excel ( [System.Object[]] $DataArray )
{    
    $Excel = new-object -ComObject "Excel.Application" 
    $Excel.Visible = $True
    $Excel.Workbooks.Add() | out-null 
    $Sheet = $Excel.ActiveWorkBook.WorkSheets.Item(1)
    
    # If empty array, exit.
    if ($DataArray.Length -eq 0) { exit }
    
    # If only a one-dimensional array, simply import into column A.
    if ($DataArray[0].GetType().FullName -ne "System.Object[]")
    {
        For ($Row = 0; $Row -le $DataArray.Length; $Row++)
            { $Sheet.Cells.Item($Row + 1,1) = $DataArray[$Row] }
    }
    else # Assume two-dimensional array.
    {   
        For ($Row = 0; $Row -lt $DataArray.Length; $Row++)
        {
            For ($Col = 0; $Col -le $DataArray[$Row].Length; $Col++)
            { $Sheet.Cells.Item($Row + 1, $Col + 1) = $DataArray[$Row][$Col] }
        }
    }        
}




#*********************************************************************************
# Function: Flip2DArray()
#  Purpose: In a two-dimensional array, each dimension can be thought of as
#           representing column or row data in a table or spreadsheet.  This 
#           function returns a new 2D array with the column and row
#           dimensions of the input array switched or "flipped", so that the
#           rows become columns, and the columns become rows, in the output.
#*********************************************************************************

Function Flip2DArray ( [System.Object[]] $Array )
{
    If ($Array[0].GetType().FullName -ne "System.Object[]") 
    { Throw "This is not a two-dimensional array!" ; Return } 
    
    $NewArray = New-Object System.Array[] -ArgumentList $Array[0].Length
    $TempArray = @()
    For ($j = 0 ; $j -lt $NewArray.Length ; $j++)
    {
        For ($k = 0 ; $k -lt $Array.Length ; $k++)
        {
            $TempArray += $Array[$k][$j] 
        }
        $NewArray[$j] = $TempArray
        $TempArray = @()
    }     
    $NewArray
} 



#END OF SCRIPT *******************************************************************





#Test importing a one-dimensional array.
$Elements = @("Hydrogen","Oxygen","Carbon","Helium","Argon","Neon")
Import-Excel $Elements  


#Test importing a two-dimensional array.
$Names = @(
("First","Last","Pet Type"), 
("Amy","Carter","Cat"),
("Carol","Kramer","Turtle"),
("Zoe","Dias","Dog") )

Import-Excel $Names


#And do it again, but flip the 2D array. 
Import-Excel @( Flip2DArray($Names) )

