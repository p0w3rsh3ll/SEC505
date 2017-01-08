'*****************************************************
' Script Name: Regular_Expressions.vbs
'     Version: 2.4
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 5.Feb.2004
'     Purpose: Demonstrate how to use regular expressions in VBScript.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*****************************************************

sMyPattern1 = "was"                                             'Captures only "was".
sMyPattern2 = "was|database"                                    'Captures "was" or "database".
sMyPattern3 = "([_A-Za-z0-9\-\.]+)@([A-Za-z0-9\.]+\.[A-Za-z]+)"     'Captures e-mail adddresses.
sMyPattern4 = "[0-9]*1st|[0-9]*2nd|[0-9]*3rd|[0-9]+th"          'Captures ranking numbers, e.g., 31st, 3342nd, 3rd, 998324th, etc.
sMyPattern5 = "1([789])79"                                      'Parentheses capture submatches.

sExampleText = "billy@corgan.edu was the 1979th address in the database."

Set oRegExp = New RegExp                             'Create a regular expression object.
oRegExp.Pattern = sMyPattern3                        'The regular expression search pattern.
oRegExp.IgnoreCase = True                            'Makes search case insensitive.
oRegExp.Global = True                                'Search for all matches, not just the first one.
'oRegExp.MultiLine = True                            'Potential matches can span across newline characters. Must have latest version of WSH for this.

Set cMatches = oRegExp.Execute(sExampleText)         'Execute search and return collection object.

sResult = "Total matches found: " & cMatches.Count     & vbCrLf & vbCrLf         'Number of matches after performing search.

For Each sMatch in cMatches                      
    sResult = sResult & "Match at character offset: "  & sMatch.FirstIndex & vbCrLf
    sResult = sResult & "Match length in characters: " & sMatch.Length     & vbCrLf
    sResult = sResult & "Matching text: "              & sMatch.Value      & vbCrLf

    If sMatch.SubMatches.Count <> "0" Then
        sResult = sResult & "There are " & sMatch.SubMatches.Count & " text submatches:" & vbCrLf
        For Each sSubMatch In sMatch.SubMatches
            sResult = sResult & vbTab & sSubMatch & vbCrLf
        Next
    End If
Next

MsgBox(sResult)


'*******************************************************************
' Other RegEx Methods
'*******************************************************************

'The Test() method returns boolean true if the Pattern is found at least once in the text.
bPresent = oRegExp.Test(sExampleText)   

'The Replace(s1, s2) method returns a copy of s1 after all instances of Pattern
'are replaced with s2.  If no matches were found with the Pattern, then it simply
'returns s1.  Hence, the Pattern property must be set before Replace() can be used.

sNewText = oRegExp.Replace(sExampleText, "Joel")       

