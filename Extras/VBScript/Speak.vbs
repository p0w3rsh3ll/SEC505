'**************************************************************************************************
' Script Name: Speak.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 22.Apr.2004
'     Purpose: Use speech synthesis to read text aloud through
'              the computer's sound card and speakers.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'**************************************************************************************************

If WScript.Arguments.Count = 0 Then
    Speak "Today is " & Date()  
Else
    Speak WScript.Arguments.Item(0)
End If



Sub Speak(sText)
    Set oVoice = WScript.CreateObject("SAPI.SpVoice")
    oVoice.Rate = 1  'Valid Range: -10 to 10, slowest to fastest, 0 default.
    oVoice.Speak(sText)
End Sub



'**************************************************************************************************
