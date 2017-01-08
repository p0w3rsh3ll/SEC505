'***********************************************************************************
' Script Name: CrackCisco7.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 4/17/02
'     Purpose: Crack "Type-7" Cisco passwords.
'       Usage: Script takes one argument, the type-7 Cisco password to be cracked.
'              Run without arguments to use GUI input/output instead.
'       Notes: This is a VBScript version of work already done by Mudge, Hobbit, 
'              SPHiXe, Gary Kessler and John Bashinski.  See the following:
'                    http://www.l0pht.com/research/tools/cisco.zip
'                    http://www.garykessler.net/download/cisco7.zip
'              It is different in that I've added the final IV element so that
'              it works with passwords of any valid length (not all versions do).
'              Note that this version of the script does no error checking or 
'              input validation so the code will be easy to follow in seminar.  
'              When you enter the password, do not enter the leading "7 ".
'    Keywords: Cisco, password, crack, type 7, 7, router
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************


If WScript.Arguments.Count = 0 Then
    sInput = InputBox("Enter the Cisco Type-7 password to be cracked, or "& _
                      "click OK to crack the encrypted password already entered:", _
                      "Crack Cisco Type-7 Passwords","0722387F4B0A0B0003220A1F173D24362C")
    MsgBox CrackCisco7(sInput),vbOkOnly,"Cleartext Password"
Else
    WScript.Echo CrackCisco7(WScript.Arguments.Item(0))
End If



'***********************************************************************************
' CrackCisco7() function.
'***********************************************************************************
Function CrackCisco7(sPassword)
    aCiscoIV = Split("&H64 &H73 &H66 &H64 &H3B &H6B &H66 &H6F " & _ 
                     "&H41 &H2C &H2E &H69 &H79 &H65 &H77 &H72 " & _ 
                     "&H6B &H6C &H64 &H4A &H4B &H44 &H48 &H53 " & _ 
                     "&H55 &H42 &H73 &H67 &H76 &H63 &H61 &H36 " & _ 
                     "&H39 &H38 &H33 &H34 &H6E &H63 &H78")           'Added &H78 to deal with 24-character long passwords (the max usable; the IOS 12.0 "25 character" error message is incorrect...)
    
    iOffset = CInt(Left(sPassword,2))            'The offset into the Cisco Initialization Vector (IV).
    sPasswordBody = Mid(sPassword,3)             'The Hex password stripped of its leading offset information.
    iPasswordChars = Len(sPasswordBody) / 2      'Two Hex password characters equals one ASCII character.
    ReDim aHexPasswordBody(iPasswordChars - 1)   'An array to hold the password chars in Hex.
    ReDim aPlainText(iPasswordChars - 1)         'An array to hold the password chars in plaintext.

    For i = 0 To (iPasswordChars - 1)
        aHexPasswordBody(i) = "&H" & Mid(sPasswordBody, (i * 2) + 1, 2)     
        aPlainText(i) = Chr(aHexPasswordBody(i) XOR aCiscoIV(i + iOffset))      
    Next
        
    CrackCisco7 = Join(aPlainText,"")
End Function


'END OF SCRIPT *********************************************************************



 
'Here are some passwords and plaintexts with which to test the script:
'
' 0722387F4B0A0B0003220A1F173D24362C                    MySecretPassword
' 152503090A0325102036162D061505062E50714D5E5500260E    WhenInTheCourseOfHumanEv
' 1543595F507F7D73706A1373415442565701010175055C504C    123456789F123456789F1234
' 0976410C3D0C16012A180107320827312636161557            ZoeDiasAteMyLobster!
' 141A0B1B0D17393C2B3A37                                mypassword


