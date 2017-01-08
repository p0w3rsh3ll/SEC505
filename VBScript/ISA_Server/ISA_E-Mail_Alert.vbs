'***********************************************************************************
' Script Name: ISA_E-Mail_Alert.vbs
'     Version: 1.0
'      Author: Jason Fossen ( www.ISAscripts.org )
'Last Updated: 15.Sep.2005
'
'     Purpose: Sends an e-mail message using SMTP or SMTPS with the output of a
'              specified command, such as "ipconfig /all", but allows you to
'              set a username and password for authenticating to the SMTP server.
'              Also writes to the local Application event log to indicate the
'              success or failure of the message being sent.  The first argument
'              to the script, if any, is also put into the e-mail message; hence,
'              enclose a sentence in double-quotes and pass in that sentence as
'              the first argument to have it included in the message (but you
'              don't have to pass in anything at all, just edit the variables below).
'
'       Notes: ISA Server can send e-mail alerts, but you can't have a command run,
'              capture its output, then put that output into the e-mail message.
'              Moreover, you can't set a username and password, or require the use
'              of SSL for SMTPS, with the built-in message alert feature in ISA Server.
'              You can do these things by editing the variables below and then running
'              this script as the alert action.  This script does not require any
'              special software or services to be installed or running, such as Outlook
'              or the IIS-SMTP service; it uses a built-in DLL from Microsoft.
'              Don't forget to modify the firewall policy on your ISA Server to allow
'              the SMTP (TCP/25) or SMTPS (TCP/465) channel to the specified gateway.
'              If you plan to use this script to alert you to IP address changes,
'              have the "Network Configuration Changed" alert action run it in ISA.
'
'     Warning: The password you enter below is in plaintext. The command you enter
'              below will be executed on the ISA Server itself, perhaps as the
'              local System account (depending on how you configure the alert action).
'              If an adversary can edit the script, the command can be changed to
'              something unpleasant. Only allow NTFS access to the local Administrators
'              group and to the local System account, set NTFS auditing, and consider
'              digitally signing the script with your own code-signing certificate:
'              see http://www.microsoft.com/technet/scriptcenter/, and also
'              http://msdn.microsoft.com/library/en-us/script56/html/wscontrustpolicy.asp
' 
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              SCRIPT PROVIDED "AS IS" WITHOUT WARRANTIES OR GUARANTEES OF ANY KIND.
'              USE AT YOUR OWN RISK. NO TECHNICAL SUPPORT PROVIDED.
'***********************************************************************************
On Error Resume Next




''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Edit the following variables before running the script:
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'E-mail address(es) to send the message to (separate addresses with semicolons):
sToAddress  = "me@mycompany.com"
sCcAddress  = ""
sBccAddress = ""

'Sender's e-mail address that will appear in the From line:
sFromAddress = "isaserver@mycompany.com"

'Subject line of the e-mail message to be sent:
sSubjectLine = "ISA Server Alert!"

'FQDN or IP address of the SMTP gateway to route the message through:
sSMTPserver = "smtp.comcast.net"

'Do you want to use SSL for SMTPS?  Set this to True or False:
bUseSSL = False

'Username and password for authenticating to the SMTP gateway, or just
'leave them as empty double-quotes if no authentication required:
sUserName = ""
sPassword = ""

'Command whose output you want to put into the body of the message,
'or just leave blank if you don't want any command executed:
sCommand = "ipconfig.exe /all"


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''





Dim sOutput, oWshShell, bFlag, sText, sBitBucket

'Any additional text you want to add to the top of the e-mail message
'should be passed in *inside double-quotes* as the first argument to
'the script (ten words un-enclosed by double-quotes is ten arguments,
'not one, and only the first word would be included in the message).

If WScript.Arguments.Count > 0 Then
    sText = WScript.Arguments.Item(0)
    If (sText = "/?") Or (sText = "/h") Or (sText = "-h") Or (sText = "--help") Then WScript.Quit
Else
    sText = "Sent " & Now() 'Edit this default text for when no arg is passed in, if you wish.
End If


'Sometimes CDO times out if the FQDN of the SMTP gateway isn't resolved 
'quickly enough, hence, use NSLOOKUP.EXE to get the default DNS server going 
'on resolving the FQDN now so that it'll have the answer cached later.

Set oWshShell = CreateObject("WScript.Shell")
Set oExec = oWshShell.Exec("nslookup.exe -timeout=30 -retry=10 " & sSMTPserver)
Do While Not oExec.StdOut.AtEndOfStream
    sBitBucket = oExec.StdOut.ReadLine
Loop
Set oExec = Nothing     'We don't care what the output is, we're just priming the DNS pump.


'Now execute the command above and capture its output.
If Len(Trim(sCommand)) > 1 Then
    Set oExec = oWshShell.Exec(sCommand)
    Do While Not oExec.StdOut.AtEndOfStream
        sOutput = sOutput & oExec.StdOut.ReadLine
    Loop
End If


'Prepend the text passed in as an arg to the output of the command.
sOutput = sText & vbCrLf & sOutput


'Send the message; see function below for details.
bFlag = CDOSYS_Send_Email(sSMTPserver,bUseSSL,sUserName,sPassword,sToAddress,sCcAddress,sBccAddress,sFromAddress,sSubjectLine,sOutput,"")


'Write status of message to the Application event log.
If (Err.Number = 0) And (bFlag = True) Then
    'No errors in running command or sending message, write an Information event to the Application log.
    oWshShell.LogEvent 4, "ISA Server e-mail alert was successfully submitted to " & sSMTPserver & vbCrLf &_
                          "Subject line: " & sSubjectLine & vbCrLf &_
                          "Recipients: " & sToAddress & " " & sCcAddress & " " & sBccAddress 
Else
    'Error in running command or sending message, write a Warning event to the Application log.
    oWshShell.LogEvent 2, "ISA Server e-mail alert was *NOT* successfully submitted to " & sSMTPserver & vbCrLf &_ 
                          "There was a problem either in running the command for creating the message body (" &_ 
                          sCommand & ") or in sending the message." & vbCrLf & vbCrLf &  "Error Description: " &_
                          Err.Description & vbCrLf & " Error Number = " & Err.Number & vbCrLf & vbCrLf &_
                          "Subject line: " & sSubjectLine & vbCrLf & vbCrLf &_
                          "Recipients: " & sToAddress & " " & sCcAddress & " " & sBccAddress                           
End If





'***********************************************************************************
' Script Name: CDOSYS_Send_Email.vbs
'     Version: 3.0
'      Author: Jason Fossen ( www.ISAscripts.org )
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
    cFields.Item(cdoSMTPConnectionTimeout) = 60             'Timeout in seconds for connection.

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
    
    Set oMessage = Nothing
End Function


'END OF SCRIPT *********************************************************************


