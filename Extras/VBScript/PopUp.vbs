'*****************************************************
' Script Name: PopUp.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 24.June.2004
'     Purpose: Demonstrate the PopUp() method, which displays a graphical dialog box
'              with user-defined buttons, icons, title and text.  PopUp() can also be
'              set with a time-out if the user doesn't click anything.  A return value
'              is sent back to the script depending on what was clicked.
'       Notes: PopUp(MessageText, TimeOutInSeconds, TitleText, ButtonAndIconValue)
'	    Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              This script is provided "AS IS" without warranty or guarantees.
'*****************************************************


Set oWshShell = Wscript.CreateObject("Wscript.Shell")
iReturn = oWshShell.Popup("Message text here and wait 5 seconds.", 5, "Title", 48 + 3)

WScript.Echo iReturn  

Select Case iReturn
    Case 1    : WScript.Echo "OK" 
    Case 2    : WScript.Echo "Cancel" 
    Case 3    : WScript.Echo "Abort" 
    Case 4    : WScript.Echo "Retry" 
    Case 5    : WScript.Echo "Ignore" 
    Case 6    : WScript.Echo "Yes" 
    Case 7    : WScript.Echo "No" 
    Case -1   : WScript.Echo "Nothing was clicked before the time-out"
    Case Else : WScript.Echo "Should never get here"
End Select




' Combine button type and icon type numbers to get what you want, e.g., 64 + 2:
' Button Types:
' 0 Show OK button. 
' 1 Show OK and Cancel buttons. 
' 2 Show Abort, Retry, and Ignore buttons. 
' 3 Show Yes, No, and Cancel buttons. 
' 4 Show Yes and No buttons. 
' 5 Show Retry and Cancel buttons. 
'
' Icon Types:
' 16 Show "Stop Mark" icon. 
' 32 Show "Question Mark" icon. 
' 48 Show "Exclamation Mark" icon. 
' 64 Show "Information Mark" icon. 


' The iReturn value is an integer mapped to a button clicked:
' 1 OK button 
' 2 Cancel button 
' 3 Abort button 
' 4 Retry button 
' 5 Ignore button 
' 6 Yes button 
' 7 No button 
' -1 The user did not click a button before the time-out.



