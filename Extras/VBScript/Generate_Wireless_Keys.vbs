'*****************************************************
'   Script Name: Generate_Wireless_Keys.vbs
'        Author: Jason Fossen, Enclave Consulting LLC
'       Version: 2.0.1
' Last Modified: 11.Jun.04
'       Purpose: Generates random hex and ASCII characters appropriate for use as WEP/TKIP/AES keys 
'                in 802.11 wireless networking.  Prefer hex keys over ASCII, longer over shorter.
'         Notes: Will use CAPICOM.DLL to generate the random number if that DLL has 
'                been registered with REGSVR32.EXE.  Get CAPICOM.DLL for free from
'                http://www.microsoft.com/msdownload/platformsdk/sdkupdate/psdkredist.htm
'                Use of CAPICOM increases both speed and randomness.
'         Notes: Why the weird Sleep(22) call?  See http://blogs.msdn.com/gstemp/archive/2004/02/33/78434.aspx#FeedBack
'         Legal: Public domain.  Modify and redistribute freely.  No rights reserved. 
'                Use at your own risk and only on networks with prior written permission.
'*****************************************************



WScript.Echo vbCr

WScript.Echo "WEP Encryption Keys:"
WScript.Echo "05 random hex bytes (40-bit)   : " & RandomHex(5)
WScript.Echo "13 random hex bytes (104-bit)  : " & RandomHex(13)
WScript.Echo "05 random ASCII chars (40-bit) : " & RandomPassword(5)
WScript.Echo "13 random ASCII chars (104-bit): " & RandomPassword(13)

WScript.Echo vbCr

WScript.Echo "TKIP or AES Encryption Keys:"
WScript.Echo "16 random hex bytes (128-bit)  : " & RandomHex(16)
WScript.Echo "32 random hex bytes (256-bit)  : " & RandomHex(32)
WScript.Echo "16 random ASCII chars (128-bit): " & RandomPassword(16)
WScript.Echo "32 random ASCII chars (256-bit): " & RandomPassword(32)

WScript.Echo vbCr



Function RandomHex(iLength)
    On Error Resume Next
    Err.Clear    
    If Not IsObject(oCapiUtil) Then Set oCapiUtil = WScript.CreateObject("CAPICOM.Utilities")

    If Err.Number = 0 Then 
        bUseCapicom = True
    Else 
        bUseCapicom = False
        WScript.Sleep(52)     'This helps to ensure more variation when this function is called multiple times in the same script.  Probably overkill given all the looping...
        Call Randomize()      'This initializes the random number generator for the sake of Rnd(), but is unneeded for oCapiUtil.GetRandom()
    End If
    
    If bUseCapicom Then
        RandomHex = oCapiUtil.BinaryToHex(oCapiUtil.GetRandom(iLength))
    Else
        iLength = iLength * 2     'Function assumes you want pairs of hex, i.e., bytes not nibbles.
        Do While iLength > 0
            x = Int((((70 - 48) + 1) * Rnd()) + 48)
            If ((x >= 48) And (x <= 57)) Or ((x >= 65) And (x <= 70)) Then 
                RandomHex = RandomHex & Chr(x)
                iLength = iLength - 1
            End If
        Loop
    End If
End Function





Function RandomPassword(iLength)
    Dim sPassword,bHasUpper,bHasLower,bHasNumber,bHasNonAlpha,bIsStrong,i,x,oCapiUtil,bUseCapicom
    
    On Error Resume Next
    Err.Clear    
    If Not IsObject(oCapiUtil) Then Set oCapiUtil = WScript.CreateObject("CAPICOM.Utilities")

    If Err.Number = 0 Then 
        bUseCapicom = True
    Else 
        bUseCapicom = False
        WScript.Sleep(52)     'This helps to ensure more variation when this function is called multiple times in the same script.  Probably overkill given all the looping...
        Call Randomize()      'This initializes the random number generator for the sake of Rnd(), but is unneeded for oCapiUtil.GetRandom()
    End If
    
    If iLength < 4 Then iLength = 4     'Password must be at least 4 characters long in order to satisfy complexity requirements.
    
    Do
        sPassword = ""        
        bHasUpper =     False   'Has uppercase letter character flag.
        bHasLower =     False   'Has lowercase letter character flag.
        bHasNumber =    False   'Has number character flag.
        bHasNonAlpha =  False   'Has non-alphanumeric character flag.
        bIsStrong =     False   'Assume password is not strong until tested otherwise.
        
        For i = 1 To iLength
            If bUseCapicom Then
                Do
                    x = AscB(oCapiUtil.GetRandom(1))
                Loop Until (x <= 126) And (x >= 34)         'The valid range of useful ASCII numbers.
            Else     
                x = Int((((126 - 34) + 1) * Rnd()) + 34)    'Random ASCII number for valid range of password characters.
            End If
            
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

            If bHasUpper And bHasLower And bHasNumber And bHasNonAlpha Then bIsStrong = True
        Next
    Loop Until bIsStrong
    
    RandomPassword = sPassword
End Function





'*****************************************************



' The formula for generating a random number within a certain
' range is x = Int((((upperbound - lowerbound) + 1) * Rnd()) + lowerbound)
'
'
' ASCII code numbers for characters:
' 0 = 48
' 1 = 49
' 2 = 50
' 3 = 51
' 4 = 52
' 5 = 53
' 6 = 54
' 7 = 55
' 8 = 56
' 9 = 57
' : = 58
' ; = 59
' < = 60
' = = 61
' > = 62
' ? = 63
' @ = 64
' A = 65
' B = 66
' C = 67
' D = 68
' E = 69
' F = 70

