'
' Use this script to safely test GPO-assigned scripts.  It doesn't really do 
' anything, it just demos how and when GPO-assigned scripts are run.
'


Set oNetwork = WScript.CreateObject("WScript.Network")
sUserName = oNetwork.UserName

MsgBox "This script was executed automatically at " & Now() &_
       " under the context of the " & sUserName & " account.  " & vbCrLf & vbCrLf &_  
       "It was assigned through a Group Policy Object, and " &_  
       "the script's full path in the GPO is " & WScript.ScriptFullName,_
       vbInformation,"GPO-Assigned Script"
       


