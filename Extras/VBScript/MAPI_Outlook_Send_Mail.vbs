'***********************************************************************************
' Script Name: MAPI_Outlook_Send_Mail.vbs
'     Version: 2.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 1/28/03
'     Purpose: Sends a e-mail through Microsoft Outlook 98/2000.
'       Notes: Must have Outlook 98/2000 installed.  The message is not sent
'              until Outlook is opened, but Outlook does not have to be
'              running when the message is sent.  You can modify your script
'              to launch Outlook immediately if desired with oWshShell.Run().
'       Notes: If there are multiple recipients, use a semicolon-delimited list of them.
'              Also, the e-mail address can just be the full name of the recipient if
'              Outlook can map the name to an address from its address list(s). 
'       Notes: Just use two doublequotes "" if there is no attachment.  If there is an
'              attachment, the string must be a fully qualified path to a single file. 
'              If you want multiple attachments, use a semicolon-delimited list of files, 
'              each with its own full path.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************

bFlag = SendOutlookEmail("recipient@destination.com",_
                         "My Subject",_
                         "My text here.",_
                         "")
                         
If bFlag Then MsgBox("Message was sent!")




Function SendOutlookEmail(sTo,sSubject,sBody,sAttach)
    On Error Resume Next 
    
    Set oOutlook = WScript.CreateObject("Outlook.Application")
    Set oMsg = oOutlook.CreateItem(0)      'Item type 0 is a mail message.
    
    oMsg.Subject = sSubject
    oMsg.Body = sBody    
    oMsg.Recipients.Add(sTo)        
    
    If sAttach <> "" Then 
        oMsg.Attachments.Add(sAttach)
    End If

    oMsg.Send
        
    If Err.Number = 0 Then
        SendOutlookEmail = True
    Else
        SendOutlookEmail = False
    End If

    Set oMsg = Nothing
    Set oOutlook = Nothing
End Function




'END OF SCRIPT ***************************************
