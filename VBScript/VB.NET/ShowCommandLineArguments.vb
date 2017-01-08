'*************************************************************************************
'   File Name: ShowCommandLineArguments.vb
'     Version: 1.0
'      Author: Jason Fossen
'Last Updated: 03/30/03
'     Purpose: Demonstrate how to access command-line arguments in VB.NET.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*************************************************************************************
Module ShowCommandLineArguments

    Sub Main()
        Dim strArg As String
        Dim i As Integer

        Dim strAllArgsInOneString As String = System.Environment.CommandLine
        System.Console.WriteLine(strAllArgsInOneString)

        Dim arrArguments() As String = System.Environment.GetCommandLineArgs()
        For i = 0 To arrArguments.GetUpperBound(0)
            System.Console.WriteLine(arrArguments(i))
        Next

        For Each strArg In System.Environment.GetCommandLineArgs()
            System.Console.WriteLine(strArg)
        Next
    End Sub

End Module




