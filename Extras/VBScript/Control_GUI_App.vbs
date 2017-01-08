'*****************************************************
' Script Name: Control_GUI_App.vbs
'     Version: 1.2
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 29.Apr.2004
'     Purpose: Demonstrates use of SendKeys(), Sleep() and AppActivate(), which
'              are all used to script control of graphical applications.
'       Notes: This script will open Event Viewer and save the System log to the
'              desktop as a file named "MyLogFile.evt".  It will also open Notepad,
'              show a drawing, then close.  See the end of this script file for 
'              help on formatting special keystrokes for SendKeys().
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************
On Error Resume Next

Set oWshShell = WScript.CreateObject("WScript.Shell")
sMyDesktop = oWshShell.ExpandEnvironmentStrings("%USERPROFILE%\Desktop\")

'Launch the MMS snap-in for Event Viewer.
oWshShell.Run("%SystemRoot%\system32\eventvwr.msc /s")

'Make the script pause for two seconds (2000 milliseconds) to let the snap-in show.
'If you try to send keystrokes to an application that has not yet fully 
'launched, the application will simply miss the keystrokes.
WScript.Sleep(3000) 

'Though Event Viewer should be in the foreground, this helps to ensure it.
'AppActivate() looks for the exact titlebar name of a running application and
'then brings that application to the foreground and gives it the focus.
'You can use this method to switch between different applications.  You can also
'give AppActivate() a process ID number (PID) to bring to the foreground.  Programs
'launched with oWshShell.Exec() can be queried for their .ProcessID properties.
oWshShell.AppActivate("Event Viewer")

'Now send keystrokes to Event Viewer.  The Sleep commands are not really needed,
'but slowing the execution down a bit looks better!  Set the sleep timer to one (1)
'millisecond to see how fast you can go or if timing errors occur.
oWshShell.SendKeys("{PGUP}")     'Hit Page Up key to put focus at top of tree.
oWshShell.SendKeys("{DOWN}")     'Hit the down-arrow key.
WScript.Sleep(300) 
oWshShell.SendKeys("{DOWN}")
WScript.Sleep(300) 
oWshShell.SendKeys("{DOWN}")
WScript.Sleep(600) 
oWshShell.SendKeys("%A")         'Hit Alt-A for the Action menu.
WScript.Sleep(500) 
oWshShell.SendKeys("{DOWN}")
WScript.Sleep(500) 
oWshShell.SendKeys("{ENTER}")    'Hit Enter key.
WScript.Sleep(1000) 
oWshShell.SendKeys(sMyDesktop & "EventLog.evt")
WScript.Sleep(600) 
oWshShell.SendKeys("{TAB}")      'Tab over to Save button.
WScript.Sleep(100) 
oWshShell.SendKeys("{TAB}")
WScript.Sleep(600) 
oWshShell.SendKeys("{ENTER}")
WScript.Sleep(600) 
oWshShell.SendKeys("%{F4}")      'Alt-F4 closes the MMC window.


'Now just to do something fun....  But also notice that parentheses (()), the
'tilde character (~), the percentage sign (%), the power sign (^), and the plus
'sign (+) must be placed inside of curly brackets into order to be sent to the
'application because these characters are meaningful to the SendKeys() method.
oWshShell.Run("notepad.exe")
WScript.Sleep(500) 
'And, again, the following Sleep commands are just for effect.  Otherwise, the
'picture would show up so fast as to appear to have been from a file that was opened.
oWshShell.AppActivate("Untitled")
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("        /\_/\")
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("       / 0 0 \")
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("      ====v====")
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("       \  W  /")
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("       |     |     _")
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("       / ___ \    /")
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("      / /   \ \  |")
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("     {(}{(}{(}-----{)}{)}{)}-'") 'Notice the curly brackets.
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("     /         \")
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("     {(}      ___{)}") 'More curly brackets.
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("      \__.=|___E")
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("             /")
WScript.Sleep(200)
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("And we haven't even talked about scripting NetCat yet!")
oWshShell.SendKeys("{ENTER}")
oWshShell.SendKeys("http://www.l0pht.com/{~}weld/netcat/") 'Curly brackets here too.
WScript.Sleep(3000)
oWshShell.SendKeys("%{F4}")  'To close Notepad.
oWshShell.SendKeys("%N")     'To say No to saving.


'The following is the syntax for sending special keystrokes with SendKeys().
'Shift Key      +
'Ctrl Key       ^
'Alt Key        %
'Backspace      {BACKSPACE}, {BS} or {BKSP}
'Break          {BREAK}
'Caps Lock      {CAPSLOCK}
'Delete         {DELETE} or {DEL}
'Cursor Up      {UP}
'Cursor Down    {DOWN}
'Cursor Right   {RIGHT}
'Cursor Left    {LEFT}
'End            {END}
'Enter          {ENTER} or ~
'Esc            {ESC}
'Home           {HOME}
'Insert         {INSERT} or {INS}
'Num Lock       {NUMLOCK}
'Page Down      {PGDN}
'Page Up        {PGUP}
'Scroll Lock    {SCROLLOCK}
'Tab            {TAB}
'F1, F2, F3...  {F1}, {F2}, {F3}...
'
'To close a program, use Alt-F4 = %{F4}
'
'To access menu commands, look for the underlined letters on the menus, then
'enter Alt-letter, e.g., %F to pull down the File menu, then %X to Exit.
'
'Note: It's not possible to script Ctrl-Alt-Del.
'
'To hold down one key and press others, the symbol for the held key should
'be followed with parentheses in which the other keys should be listed.  For 
'example, to send Shift-A-B, enter +(AB), or to send Alt-C-D-E, enter %(CDE).
'
'To repeat a keystroke multiple times, inside curley brackets place the keystroke,
'a space character, and the multiple number.  For example, to enter the letter R
'tenty times, use {R 20}.


'END OF SCRIPT ***************************************
