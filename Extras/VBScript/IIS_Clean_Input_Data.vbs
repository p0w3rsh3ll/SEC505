'***********************************************************************************
' Script Name: IIS_Clean_Input_Data.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 7/19/01
'     Purpose: Examples of functions which can be pasted into ASP pages
'              to clean user input of dangerous data.
'       Usage: Modify and paste into ASP pages which process user input.
'       Notes: Install latest WSH and Service Pack on IIS!
'    Keywords: IIS, ASP, regular expression, RegExp, clean, validate
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************
On Error Resume Next



'***********************************************************************************
' Function Name: CleanOutHTML()
'       Purpose: Removes all HTML tags from input string.
'       Returns: Input string minus HTML tagged content.
'***********************************************************************************
Function CleanOutHTML(sInput)
    If Not IsObject(oRegExp) Then Set oRegExp = New RegExp
    oRegExp.Global = True
    oRegExp.MultiLine = True                    'This require WSH 5.1 or later.
    oRegExp.Pattern = "<.*?>"                   'The ? makes it non-greedy.
    CleanOutHTML = oRegExp.Replace(sInput,"")   'Replace matches with nothing, i.e., delete matches.
End Function




'***********************************************************************************
' Function Name: CleanOutDangerousChars()
'       Purpose: Removes all single dangerous characters from input string.
'                Where dangerous includes  " ' < > % ; ) ( & + |
'                \x22 and \x27 are for the singlequote and doublequote characters.   
'       Returns: Input string minus chars.
'***********************************************************************************
Function CleanOutDangerousChars(sInput)
    If Not IsObject(oRegExp) Then Set oRegExp = New RegExp
    oRegExp.Global = True
    oRegExp.MultiLine = True
    oRegExp.Pattern = "\<|\>|\%|\;|\)|\(|\&|\+|\\|\x22|\x27"   
    CleanOutDangerousChars = oRegExp.Replace(sInput,"")
End Function





'***********************************************************************************
' Function Name: CleanOutDangerousWords()
'       Purpose: Removes dangerous words from a query string.
'                Where dangerous includes "select", "insert", "update"
'                "from", "where" and "cmd.exe".  Modify as needed.
'       Returns: Input string minus keywords.
'***********************************************************************************
Function CleanOutDangerousWords(sInput)
    If Not IsObject(oRegExp) Then Set oRegExp = New RegExp
    oRegExp.Global = True
    oRegExp.MultiLine = True
    oRegExp.IgnoreCase = True
    oRegExp.Pattern = "select|insert|update|from|where|cmd\.exe|tftp\.exe"
    CleanOutDangerousWords = oRegExp.Replace(sInput,"")
End Function




'***********************************************************************************
' Function Name: CleanOutTextAfterPipe()
'       Purpose: Removes all text after the first pipe "|" symbol.
'          Note: This is Michael Howard's example (MS) and it also nicely
'                demonstrates the use of a backreference, "$1".
'       Returns: Input string minus everything after first "|".
'***********************************************************************************
Function CleanOutTextAfterPipe(sInput)
    If Not IsObject(oRegExp) Then Set oRegExp = New RegExp
    oRegExp.Pattern = "^(.+)\|(.+)"                         'Parentheses are need to store match for backreference.
    CleanOutTextAfterPipe = oRegExp.Replace(sInput,"$1")    '$1 references to first stored match.
End Function






'END OF SCRIPT *********************************************************************



'The following merely demonstrates the functions.
sTest = "Hello <B>W</B>orld! <A HREF=""http://www.sans.org"">Click Here!</A>"
WScript.Echo CleanOutHTML(sTest)

sTest2 = "Hel<l>o W%o;rl)d! H(o&w ar'e y\ou\?"
WScript.Echo CleanOutDangerousChars(sTest2)

sTest3 = "cmd.exeHello WSELECTorld! Having selectaInSert niFROMce WhereduPdAtEay?"
WScript.Echo CleanOutDangerousWords(sTest3)

sTest4 = "Hello World!|The time has come for Ragnarok!"
WScript.Echo CleanOutTextAfterPipe(sTest4)

