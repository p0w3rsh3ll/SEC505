'*****************************************************
' Function Name: RandomPassword(x) 
'        Author: Jason Fossen, Enclave Consulting LLC
'       Version: 2.0
' Last Modified: 26.Mar.2004
'   Argument(s): A single argument, an integer for the desired length of password.
'       Returns: Pseudo-random complex password that has at
'                least one of each of the following character types:
'                uppercase letter, lowercase letter, number, and
'                legal non-alphanumeric.  The variety of characters
'                is legal on Windows NT/2000/XP/2003, but
'                perhaps not on other operating systems (test it).
'          Note: ' and " and <space> are excluded to make the 
'                function play nice with other scripts.  Extended
'                ASCII characters are not included either.
'          Note: If the argument/password is less than 4 characters 
'                long, the function will return a 4-character password
'                anyway.  Otherwise, the complexity requirements won't
'                be satisfiable.
'          Note: Script uses CAPICOM.DLL to generate the random number if that DLL has 
'                been registered with REGSVR32.EXE.  Get CAPICOM.DLL for free from
'                http://www.microsoft.com/downloads/details.aspx?displaylang=en&FamilyID=860EE43A-A843-462F-ABB5-FF88EA5896F6
'                Use of CAPICOM increases both speed and randomness.
'          Note: Why the weird Sleep(22) call?  See http://blogs.msdn.com/gstemp/archive/2004/02/33/78434.aspx#FeedBack
'         Legal: Public domain.  Modify and redistribute freely.  No rights reserved. 
'                Use at your own risk and only on networks with prior written permission.
'*****************************************************


Function RandomPassword(iLength)
    Dim sPassword,bHasUpper,bHasLower,bHasNumber,bHasNonAlpha,bIsStrong,i,x,oCapiUtil,bUseCapicom
    
    On Error Resume Next
    Err.Clear    
    If Not IsObject(oCapiUtil) Then Set oCapiUtil = WScript.CreateObject("CAPICOM.Utilities")

    If Err.Number = 0 Then 
        bUseCapicom = True
    Else 
        bUseCapicom = False
        WScript.Sleep(22)     'This helps to ensure more variation when this function is called multiple times in the same script.  Probably overkill given all the looping...
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
' Similar technique to generate random Hex characters.
'*****************************************************

Function RandomHex(iLength)
    On Error Resume Next
    Err.Clear    
    If Not IsObject(oCapiUtil) Then Set oCapiUtil = WScript.CreateObject("CAPICOM.Utilities")

    If Err.Number = 0 Then 
        bUseCapicom = True
    Else 
        bUseCapicom = False
        WScript.Sleep(22)     'This helps to ensure more variation when this function is called multiple times in the same script.  Probably overkill given all the looping...
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





'********************************************************
' This demonstrates the function.
'********************************************************
str = "Here's 20 pseudo-random passwords:" & vbCrLf & vbCrLf
For m = 1 to 20
    str = str & RandomPassword(140) & vbCrLf
Next
'MsgBox str
WScript.Echo str



'********************************************************
' Here are the characters and ASCII codes for the password
' characters as a reference.  The excluded ones are noted.
' It also shows why the range of random numbers generated
' only starts at 34:  if 34 is generated, then the function
' converts it to 33 because 34 is an excluded character.
'********************************************************
'   = 32  Excluded (the space character)
' ! = 33  
' " = 34  Excluded
' # = 35
' $ = 36
' % = 37
' & = 38
' ' = 39  Excluded
' ( = 40
' ) = 41
' * = 42
' + = 43
' , = 44
' - = 45
' . = 46
' / = 47
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
' G = 71
' H = 72
' I = 73
' J = 74
' K = 75
' L = 76
' M = 77
' N = 78
' O = 79
' P = 80
' Q = 81
' R = 82
' S = 83
' T = 84
' U = 85
' V = 86
' W = 87
' X = 88
' Y = 89
' Z = 90
' [ = 91
' \ = 92
' ] = 93
' ^ = 94
' _ = 95
' ` = 96
' a = 97
' b = 98
' c = 99
' d = 100
' e = 101
' f = 102
' g = 103
' h = 104
' i = 105
' j = 106
' k = 107
' l = 108
' m = 109
' n = 110
' o = 111
' p = 112
' q = 113
' r = 114
' s = 115
' t = 116
' u = 117
' v = 118
' w = 119
' x = 120
' y = 121
' z = 122
' { = 123
' | = 124
' } = 125
' ~ = 126
'
' The formula for generating a random number within a certain
' range is x = Int((((upperbound - lowerbound) + 1) * Rnd()) + lowerbound)


