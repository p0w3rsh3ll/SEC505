'*************************************************************************************
'   File Name: Regular_Expressions.vb
'     Version: 1.0
'      Author: Jason Fossen
'Last Updated: 5/1/2003
'     Purpose: Demonstrate some uses of regular expressions in VB.NET.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*************************************************************************************
Module Module1

    Sub Main()
        Dim sInput As System.String = "Eat carbohydrated carbs while fixing carburators can be carbolic!"
        Dim sPattern As System.String = "carb"

        System.Console.WriteLine(RegExpReplace(sInput, sPattern, "protein"))
        System.Console.WriteLine(RegExpFindFirstMatch(sInput, sPattern))
        System.Console.WriteLine(RegExpFindAllMatches2(sInput, sPattern))
    End Sub


    Function RegExpReplace(ByVal sInput As String, ByVal sPattern As String, ByVal sReplacement As String) As String
        Return System.Text.RegularExpressions.Regex.Replace(sInput, sPattern, sReplacement)
    End Function


    Function RegExpFindFirstMatch(ByVal sInput As String, ByVal sPattern As String) As String
        Dim oRegExp As New System.Text.RegularExpressions.Regex(sPattern, System.Text.RegularExpressions.RegexOptions.Compiled)
        Return oRegExp.Match(sInput).Value.ToString()
    End Function


    Function RegExpFindAllMatches(ByVal sInput As String, ByVal sPattern As String) As String
        Dim oRegExp As System.Text.RegularExpressions.Regex
        Dim oMatch As System.Text.RegularExpressions.Match
        Dim sOutput As System.String

        oRegExp = New System.Text.RegularExpressions.Regex(sPattern, System.Text.RegularExpressions.RegexOptions.Compiled)
        oMatch = oRegExp.Match(sInput)

        While oMatch.Success
            sOutput = sOutput & oMatch.Value.ToString() & System.Environment.NewLine
            oMatch = oMatch.NextMatch()
        End While

        Return sOutput
    End Function


    Function RegExpFindAllMatches2(ByVal sInput As String, ByVal sPattern As String) As String
        Dim oRegExp As System.Text.RegularExpressions.Regex
        Dim oMatch As System.Text.RegularExpressions.Match
        Dim cMatches As System.Text.RegularExpressions.MatchCollection
        Dim sOutput As System.String

        oRegExp = New System.Text.RegularExpressions.Regex(sPattern, System.Text.RegularExpressions.RegexOptions.Compiled)
        cMatches = oRegExp.Matches(sInput)

        For Each oMatch In cMatches
            sOutput = sOutput & oMatch.Value.ToString() & System.Environment.NewLine
        Next

        Return sOutput
    End Function

End Module
