'*****************************************************
' Script Name: Log_Event.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 10/29/02
'     Purpose: Write a custom event to the Application event log.
'    Keywords: Event Log, event, events, log
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************


Const SUCCESS       	= 0     'You can simply use the number too.
Const ERROR         	= 1
Const WARNING       	= 2
Const INFORMATION   	= 4
Const AUDIT_SUCCESS 	= 8
Const AUDIT_FAILURE 	= 16
	

Set oWshShell = WScript.CreateObject("WScript.Shell")

oWshShell.LogEvent WARNING, "My custom text here."       'Defaults to local computer.

'When used as a function, returns True/False on the success of the operation.
'The remote computer's name or IP address can be used.

bFlag = oWshShell.LogEvent(0,"My custom text here.","127.0.0.1")   


'*****************************************************






SText = "It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (1)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (10)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (20)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (30)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (40)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (50)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (60)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (70)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (80)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (90)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (100)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (110)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (120)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (130)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (140)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (150)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (160)" & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted." & vbCrLf &_
"It is widely believed that the amount of data you can put " &_
"into an Event Log message is limited to only a few lines " &_
"of text.  But, as you can see, many paragraphs can be " &_
"inserted. (170: And it does work over the network!)" & vbCrLf 


bFlag = oWshShell.LogEvent(1,sText,"127.0.0.1")     


'END OF SCRIPT ***************************************
