'*****************************************************
' Script Name: Trim_Array_Procedure.vbs
'     Version: 1.0
'Last Updated: 12/25/02
'      Author: Jason Fossen, Enclave Consulting LLC 
'     Purpose: Cleans an array of all uninitialized ("empty") and null elements, as
'              well as a variety of non-printing characters if these characters are
'              the only contents of the element.  The array will be resized to exclude 
'              these unwanted elements, but the original order of the desired elements 
'              will be preserved.
'       Notes: The unwanted elements can be scattered throughout the array, they
'              do not have to be grouped at the beginning or end.
'              Procedure only works with one-dimensional arrays.  If the array only
'              has one element (UBound(theArray) = 0) then the procedure simply exits.
'              The array to be trimmed must have been originally declared with "ReDim".
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************

Sub TrimArray(ByRef aArray)
    Dim iFreeElement, iCurrent, sTemp, iSize
    iFreeElement = 0
    iSize = UBound(aArray)
    For iCurrent = 0 To iSize
        sTemp = Trim(CStr(aArray(iCurrent)))
        If Not IsEmpty(aArray(iCurrent)) AND (Not IsNull(aArray(iCurrent))) AND (Not sTemp = "")_ 
           AND (Not sTemp = vbCr) AND (Not sTemp = vbLf) AND (Not sTemp = vbCrLf)_ 
           AND (Not sTemp = vbTab)AND (Not sTemp = vbNullString) AND (Not sTemp = vbNullChar) Then
           
                If iFreeElement <> iCurrent Then aArray(iFreeElement) = aArray(iCurrent)
                iFreeElement = iFreeElement + 1
        End If
    Next
    If iFreeElement > 0 Then iFreeElement = iFreeElement - 1
    If iFreeElement < iSize Then ReDim Preserve aArray(iFreeElement)
End Sub



'END OF SCRIPT ***************************************





'The following demonstrates the procedure:
ReDim aArray1(7777)
aArray1(4) = "cow"
aArray1(5) = "moose"
aArray1(6) = "cat"
aArray1(1400) = "dog"
aArray1(2345) = "pig"
aArray1(2346) = vbCr
aArray1(2347) = vbTab
aArray1(2348) = vbCrLf
aArray1(2349) = vbNullChar
aArray1(2350) = "  "
aArray1(7776) = "duck"

Call TrimArray(aArray1)
Dim sResult
sResult = "Largest array element number = " & Ubound(aArray1) & vbCrLf
For x = 0 to Ubound(aArray1)
    sResult = sResult & "Element number " & x & " is " & aArray1(x) & vbCrLf
Next
WScript.Echo sResult
