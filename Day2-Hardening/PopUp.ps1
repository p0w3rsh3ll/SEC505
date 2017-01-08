########################################################################################
# Script Name: PopUp-DialogBox.ps1
#     Version: 1.0
#      Author: Jason Fossen
#Last Updated: 25.Jul.2013
#     Purpose: Demonstrate the PopUp() method, which displays a graphical dialog box
#              with user-defined buttons, icons, title and text.  PopUp() can also be
#              set with a time-out if the user doesn't click anything.  A return value
#              is sent back to the script depending on what was clicked.  The script
#              also provides an example of using a COM object within PowerShell.
#       Notes: PopUp(MessageText, TimeOutInSeconds, TitleText, ButtonAndIconValue)
#	    Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
#              This script is provided "AS IS" without warranty or guarantees.
########################################################################################


$WshShell = new-object -com "Wscript.Shell"
$Return = $WshShell.Popup("If you can see this pop-up message, it means the logon script ran successfully.  This message will disappear in 10 seconds!", 10, "SEC505 Is Great!", 64 + 3)

Switch ($Return)
{
    1  {"OK"} 
    2  {"Cancel"} 
    3  {"Abort"} 
    4  {"Retry"} 
    5  {"Ignore"} 
    6  {"Yes"} 
    7  {"No"} 
    -1 {"Nothing was clicked before the time-out"}
    default {"Should never get here"}
}

# The arguments to PopUp() are as follows:
# $WshShell.PopUp(MessageText, TimeOutInSeconds, TitleText, ButtonAndIconValue)
# If the TimeOutInSeconds is 0, then the timeout is infinite.
# Combine button type and icon type numbers to get what you want, e.g., 64 + 2.

# Button Types:
# 0 Show OK button. 
# 1 Show OK and Cancel buttons. 
# 2 Show Abort, Retry, and Ignore buttons. 
# 3 Show Yes, No, and Cancel buttons. 
# 4 Show Yes and No buttons. 
# 5 Show Retry and Cancel buttons. 
#
# Icon Types:
# 16 Show "Stop Mark" icon. 
# 32 Show "Question Mark" icon. 
# 48 Show "Exclamation Mark" icon. 
# 64 Show "Information Mark" icon. 


# The Return value is an integer mapped to a button clicked:
# 1 OK button 
# 2 Cancel button 
# 3 Abort button 
# 4 Retry button 
# 5 Ignore button 
# 6 Yes button 
# 7 No button 
# -1 The user did not click a button before the time-out.



