'*****************************************************
'   Script Name: Test_Random_Number_Generator.vbs 
'        Author: Jason Fossen, Enclave Consulting LLC 
'       Version: 1.0
' Last Modified: 6/25/02
'       Purpose: Perform a crude test of the random number 
'                generator, and waste some time...
'         Notes: See http://blogs.msdn.com/gstemp/archive/2004/02/33/78434.aspx#FeedBack
'                for why you should only call Randomize() once in a script or wait 
'                at least 10ms between Randomize() calls.  Even better, use CAPICOM.DLL.  
'*****************************************************
Dim iNum,iCount,iTotal,sResult,iStart
Dim iOnes,iTwos,iThrees,iFours,iFives,iSixes,iSevens,iEights,iNines,iZeros

iOnes   = 0 
iTwos   = 0 
iThrees = 0 
iFours  = 0 
iFives  = 0 
iSixes  = 0 
iSevens = 0 
iEights = 0 
iNines  = 0 
iZeros  = 0

If WScript.Arguments.Count <> 1 Then
	iCount = InputBox("Enter the number of random numbers to generate and test, e.g., 1000, 10000, 100000, 1000000, etc..","Enter Number","1000000")
Else
	iCount = WScript.Arguments.Item(0)
End If

iTotal = iCount
iStart = Timer()

Call Randomize()  ' This initializes the random number generator 
                  ' with a number based on the system timer.  If
                  ' you call Rnd() without first initializing the
                  ' the generator, the same initial seed number 
                  ' will be used every time you run the script.
                  ' You can pass your own seed value into Randomize()
                  ' if you wish, e.g., Randomize(Tan(Timer()))

Do Until iCount = 0 
	iCount = iCount - 1
	
	'iNum = Round(10 * Rnd())                       'Don't Use This.  Notice the low number of zeros when using this method.
	'iNum = Int((((9 - 0) + 1) * Rnd()) + 0)        'A common way of computing a random number from a range:  Int((((max - min) + 1) * Rnd()) + min)
	iNum = Int((10 * Rnd()))                        'Same thing.
	'iNum = Fix((10 * Rnd()))                       'Same thing?  :-)
	'iNum = Mid(Rnd(),4,1)                          'Works well enough for 0-9, but less efficient.
			
	Select Case iNum
		Case 1
			iOnes = iOnes + 1
		Case 2
			iTwos = iTwos + 1
		Case 3
			iThrees = iThrees + 1
		Case 4
			iFours = iFours + 1
		Case 5
			iFives = iFives + 1
		Case 6
			iSixes = iSixes + 1
		Case 7
			iSevens = iSevens + 1
		Case 8
			iEights = iEights + 1
		Case 9
			iNines = iNines + 1
		Case 0
			iZeros = iZeros + 1
	End Select
Loop

sResult = vbCrLf & "Percentage occurrence of each number:" & vbCrLf & vbCrLf
sResult = sResult & vbTab & "Ones   = " & MakeNice(iOnes,iTotal)   & vbTab & iOnes   & vbCrLf
sResult = sResult & vbTab & "Twos   = " & MakeNice(iTwos,iTotal)   & vbTab & iTwos   & vbCrLf
sResult = sResult & vbTab & "Threes = " & MakeNice(iThrees,iTotal) & vbTab & iThrees & vbCrLf
sResult = sResult & vbTab & "Fours  = " & MakeNice(iFours,iTotal)  & vbTab & iFours  & vbCrLf
sResult = sResult & vbTab & "Fives  = " & MakeNice(iFives,iTotal)  & vbTab & iFives  & vbCrLf
sResult = sResult & vbTab & "Sixes  = " & MakeNice(iSixes,iTotal)  & vbTab & iSixes  & vbCrLf
sResult = sResult & vbTab & "Sevens = " & MakeNice(iSevens,iTotal) & vbTab & iSevens & vbCrLf
sResult = sResult & vbTab & "Eights = " & MakeNice(iEights,iTotal) & vbTab & iEights & vbCrLf
sResult = sResult & vbTab & "Nines  = " & MakeNice(iNines,iTotal)  & vbTab & iNines  & vbCrLf
sResult = sResult & vbTab & "Zeros  = " & MakeNice(iZeros,iTotal)  & vbTab & iZeros  & vbCrLf

sResult = sResult & vbCrLf & "Time To Run: " & (Timer() - iStart) & " seconds."

MsgBox(sResult)

'*****************************************************
'Helper Functions and Procedures.
'*****************************************************
Function MakeNice(iNumber,iDenom)
	sOut = (iNumber/iDenom) * 100
	sOut = Round(sOut,6)
	
	If sOut < 10 Then
		DeviationFrom10 = "-" & Round(10 - sOut,6) 
	Elseif sOut = 10 Then
		DeviationFrom10 = " 0.0000"
	Else
		DeviationFrom10 = "+" & Round(sOut - 10,6)
	End If
	
	sOut = "000" & sOut	
	iDot = InStr(sOut,".")
	If iDot = 0 Then 
		sOut = sOut & ".000000"
	Else
		sOut = sOut & "000000"
	End If
	iDot = InStr(sOut,".")
	sOut = Mid(sOut,(iDot - 2),9)
	If Left(sOut,1) = "0" Then sOut = " " & Mid(sOut,2,8)
	MakeNice = sOut & "% (" & DeviationFrom10 & ")"
End Function


'END OF SCRIPT ****************************************



'' The following is sample output after having generated 
'' 100 million random numbers using "Int((10 * Rnd()))":
''
' Percentage occurrence of each number:
'
'        Ones   = 10.000141% (+0.000141) 10000141
'        Twos   =  9.999817% (-0.000183) 9999817
'        Threes = 10.000022% (+0.000022) 10000022
'        Fours  =  9.999859% (-0.000141) 9999859
'        Fives  =  9.999855% (-0.000145) 9999855
'        Sixes  = 10.000167% (+0.000167) 10000167
'        Sevens = 10.000220% (+0.00022)  10000220
'        Eights =  9.999891% (-0.000109) 9999891
'        Nines  =  9.999507% (-0.000493) 9999507
'        Zeros  = 10.000521% (+0.000521) 100005210
'
' Time To Run: 592.3438 seconds.
'


