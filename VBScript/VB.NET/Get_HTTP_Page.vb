'*************************************************************************************
'   File Name: Get_HTTP_Page.vb
'     Version: 1.0
'      Author: Jason Fossen
'Last Updated: 04/15/2003
'     Purpose: A function to return the text of a file retrieved via HTTP.
'       Notes: "ERROR" is at the beginning of the function's return if there
'              is a problem; otherwise, it returns text of requested file.
'              The server's HTTP headers are not included in the output.
'       Notes: URL can be either HTTP or HTTPS, but you'll have to trust the
'              issuer if HTTPS is used (and the cert must be valid, etc.).
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*************************************************************************************
Module Get_HTTP_Page

    Sub Main()
        Dim sURL As String
        If System.Environment.GetCommandLineArgs.Length = 2 Then  'First arg is this executable.
            sURL = System.Environment.GetCommandLineArgs(1)
            System.Console.Write(GetHttpPage(sURL))
        Else
            System.Console.WriteLine(System.Environment.NewLine & "Enter target URL as an argument.")
        End If
    End Sub


    Public Function GetHttpPage(ByVal sURL As String) As String
        Dim sOutput As String
        Dim oWebRequest As System.Net.WebRequest
        Dim oWebResponse As System.Net.WebResponse
        Dim oStream As System.IO.Stream
        Dim oStreamReader As System.IO.StreamReader

        Try
            oWebRequest = System.Net.WebRequest.Create(sURL)
            oWebResponse = oWebRequest.GetResponse()
            oStream = oWebResponse.GetResponseStream()
            oStreamReader = New System.IO.StreamReader(oStream)
            sOutput = oStreamReader.ReadToEnd()

        Catch e As System.UriFormatException 'Thrown by WebRequest
            sOutput = "ERROR: System.UriFormatException: " & e.Message
        Catch e As System.NotSupportedException 'Thrown by WebRequest or WebResponse
            sOutput = "ERROR: System.NotSupportedException: " & e.Message
        Catch e As System.ArgumentNullException 'Thrown by WebRequest
            sOutput = "ERROR: System.ArgumentNullException: " & e.Message
        Catch e As System.Net.WebException 'Thrown by WebRequest or WebResponse
            sOutput = "ERROR: System.Net.WebException: " & e.Message
        Catch e As System.Exception 'Base of exception class; must be last.
            sOutput = "ERROR: " & e.ToString
        Finally
            If Not IsNothing(oStreamReader) Then oStreamReader.Close()
            If Not IsNothing(oStream) Then oStream.Close()
            If Not IsNothing(oWebResponse) Then oWebResponse.Close()
            GetHttpPage = sOutput
        End Try
    End Function

End Module
