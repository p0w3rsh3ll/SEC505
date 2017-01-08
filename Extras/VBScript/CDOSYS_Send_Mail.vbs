'***********************************************************************************
' Script Name: CDOSYS_Send_Email.vbs
'     Version: 3.0
'      Author: Jason Fossen, Enclave Consulting LLC ( www.ISAscripts.org )
'Last Updated: 14.Sep.2005
'
'     Purpose: Send an e-mail message using SMTP or SMTPS.
'
'       Notes: This script uses CDOSYS 2.0+, so it will only work on Windows 2000 and later.
'              The script does not require or use a local IIS SMTP service.
'              If the username field is blank, anonymous authentication to the SMTP
'              server is used; if the username is "ntlm", then NTLM or Kerberos is used with the
'              credentials of the WSH process; otherwise, the submitted username/password
'              will be used with cleartext basic authentication to the SMTP server.
'              Use SMTPS to encrypt session with SSL whenever possible, but remember that your
'              computer must trust the CA issuer of the SMTPS certificate at the server.
'
'   Arguments: sSmtpServer =    IP address or FQDN of out-going SMTP server.
'              bUseSSL =        True or False. Determines whether SMTP (TCP/25) or SMTPS (TCP/465) will be used.
'              sUsername =      May be blank. Username for Basic authentication; set blank for Anonymous; set ntlm for NTLM.
'              sPassword =      May be blank. Password for Basic authentication; ignored for Anonymous and NTLM.
'              sTo =            Recipient. Semicolon-delimited for multiple addresses.
'              sCC =            May be blank. CC recipient. Semicolon-delimited for multiple addresses.
'              sBCC =           May be blank. Blind CC recipient. Semicolon-delimited for multiple addresses.
'              sFrom =          Single e-mail address for the sender.  
'              sSubject =       May be blank. Subject line.
'              sBody =          May be blank. Body of message.
'              sAttach =        May be blank. Full path to local file to attach. Semicolon-delimited for multiple addresses.
'
'     Returns: Function returns True if no problems, False otherwise.
'
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK. NO TECHNICAL SUPPORT PROVIDED.
'***********************************************************************************


bFlag = CDOSYS_Send_Email("smtp.comcast.net",False,"","","to@address.com","cc@address.com","bcc@address.com","from@address.com","My Subject","My body text here.","c:\autoexec.bat")

If bFlag = True Then 
    WScript.Echo "Success!" 
Else 
    WScript.Echo Err.Description & " (ErrNum = " & Err.Number & " )" 
End If




Function CDOSYS_Send_Email(sSmtpServer,bUseSSL,sUsername,sPassword,sTo,sCC,sBCC,sFrom,sSubject,sBody,sAttach)
    On Error Resume Next
    'These weird constants do NOT cause any communications with schemas.microsoft.com.  They are just naming conventions.
    Const cdoSendUsingMethod =        "http://schemas.microsoft.com/cdo/configuration/sendusing"
    Const cdoSMTPServer =             "http://schemas.microsoft.com/cdo/configuration/smtpserver"
    Const cdoSMTPServerPort =         "http://schemas.microsoft.com/cdo/configuration/smtpserverport"
    Const cdoSMTPUseSSL =             "http://schemas.microsoft.com/cdo/configuration/smtpusessl"
    Const cdoSMTPConnectionTimeout =  "http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout"
    Const cdoSMTPAuthenticate =       "http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"
    Const cdoSendUserName =           "http://schemas.microsoft.com/cdo/configuration/sendusername"
    Const cdoSendPassword =           "http://schemas.microsoft.com/cdo/configuration/sendpassword"
    Const cdoSendUsingPickup =        1    'Use the local IIS-SMTP service for delivery.
    Const cdoSendUsingPort =          2    'Use a remote SMTP server for delivery.
    
    Set oMessage = WScript.CreateObject("CDO.Message")
    Set oConfiguration = WScript.CreateObject("CDO.Configuration")
    Set cFields = oConfiguration.Fields
    
    cFields.Item(cdoSendUsingMethod) = cdoSendUsingPort     'cdoSendUsingPort = Send to remote SMTP server (2), cdoSendUsingPickup = Send using local SMTP service (1).
    cFields.Item(cdoSMTPServer) = sSmtpServer               'IP address or DNS name of the remote SMTP server.   
    cFields.Item(cdoSMTPConnectionTimeout) = 30             'Timeout in seconds for connection.

    If bUseSSL = True Then
        cFields.Item(cdoSMTPUseSSL) = True                  'Will use SSL for SMTPS. 
        cFields.Item(cdoSMTPServerPort) = 465               'Default TCP port for SMTPS is 465.        
    Else
        cFields.Item(cdoSMTPUseSSL) = False                 'Will not use SSL. Regular cleartext SMTP.
        cFields.Item(cdoSMTPServerPort) = 25                'Default TCP port for cleartext SMTP is 25.
    End If

    If LCase(sUsername) = "ntlm" Then                       'Assumes no one would have a username of "ntlm".
        cFields.Item(cdoSMTPAuthenticate) = 2               '2 = Integrated Windows authentication, i.e., single sign-on, uses the credentials of the WSH process itself.
    ElseIf sUsername <> "" Then                             'If not blank, then use provided username for Basic authentication.
        cFields.Item(cdoSMTPAuthenticate) = 1               '1 = Basic authentication.
        cFields.Item(cdoSendUserName) = sUsername           'Username for Basic authentication, ignored for anonymous or NTLM authentication.
        cFields.Item(cdoSendPassword) = sPassword           'Password for Basic authentication, ignored for anonymous or NTLM authentication.
    Else                                                    'Otherwise, assume no authentication required.
        cFields.Item(cdoSMTPAuthenticate) = 0               '0 = Anonymous authentication.
    End If
    
    cFields.Update                                          'Save data so far.
    Set oMessage.Configuration = oConfiguration             'Link the config and message objects.
                                       
    oMessage.To = sTo
    oMessage.CC = sCC
    oMessage.BCC = sBCC
    oMessage.From = sFrom
    oMessage.Subject = sSubject
    oMessage.TextBody = sBody
    
    If sAttach <> "" Then 
        aFiles = Split(sAttach,";")
        For Each sFile In aFiles
            oMessage.AddAttachment sFile
        Next
    End If
    
    oMessage.Send
    
    If Err.Number = 0 Then
        CDOSYS_Send_Email = True
    Else
        CDOSYS_Send_Email = False
    End If
    
End Function


'END OF SCRIPT *********************************************************************


