'**********************************************************************************
' Script Name: Command-Line_Arguments.vbs
'     Version: 2.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'     Purpose: Shows count and text of arguments to the script.
'       Usage: Drag one or more files onto this script's icon.
'	           The dragged-and-dropped files will not be altered
'	           in any way.  Or execute the script from the command line
'              with some number of arguments.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'**********************************************************************************
On Error Resume Next


'Arguments to the script are added to the Arguments collection, a property of WScript:

s1stArg = WScript.Arguments(0)
s2ndArg = WScript.Arguments(1)
s3rdArg = WScript.Arguments(2)


'To get the total number of arguments to the script and then print them out:

iCount = WScript.Arguments.Count
sResult = iCount & " arguments to the script:" & vbCrLf & vbCrLf

For Each sArg In WScript.Arguments  
	sResult = sResult &  sArg  & vbCrLf
Next

MsgBox sResult








'You can also cycle through the arguments with a For loop like this:
'   For i = 0 to WScript.Arguments.Count - 1
'       sMsg = sMsg & WScript.Argument.Item(i)
'   Next
'   MsgBox sMsg 
'
'Strictly speaking, the "Item" property does not have to be included because
'it is the default property of the object.  Hence, the following two statements
'are identical in meaning:
'
'   sFirstArg = WScript.Arguments(0)
'   sFirstArg = WScript.Arguments.Item(0)
'

'END OF SCRIPT ***************************************************************
