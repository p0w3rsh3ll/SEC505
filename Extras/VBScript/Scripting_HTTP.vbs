'*****************************************************
' Script Name: Scripting_HTTP.vbs
'     Version: 1.1.2
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 25.Oct.2006
'     Purpose: Demonstrate how to use the XMLHTTP object to send GET and POST
'              requests to HTTP servers and capture the output programmatically. 
'       Notes: The XMLHTTP object can also parse XML using MS's XMLDOM.
'              And all of the functions can be modified to accept a username/password
'              for OS-layer authentication, e.g., Basic, Digest, NTLM, etc.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without implied warranties or guarantees.  Use
'              at your own risk and only on networks with prior written permission.
'*****************************************************


Function HttpGetText(sURL)
    On Error Resume Next
    
    If Not IsObject(oHTTP) Then _
        Set oHTTP = WScript.CreateObject("Microsoft.XMLHTTP")

    oHTTP.Open "GET", sURL, False       'False = Script waits until the full HTTP response is received.
    oHTTP.Send                          'Send the HTTP command as defined with the Open method.
    
    If Err.Number = 0 Then
        HttpGetText = oHTTP.ResponseText
    Else
        HttpGetText = "Error! " & Err.Number
    End If
End Function



'Same function as HttpGetText(), but also accepts a username and password.
'In fact, all of the functions here can do this...
Function HttpGetTextAuth(sURL, sUsername, sPassword)
    On Error Resume Next
    
    If Not IsObject(oHTTP) Then _
        Set oHTTP = WScript.CreateObject("Microsoft.XMLHTTP")

    oHTTP.Open "GET", sURL, False, sUsername, sPassword       
    oHTTP.Send                          
    
    If Err.Number = 0 Then
        HttpGetTextAuth = oHTTP.ResponseText
    Else
        HttpGetTextAuth = "Error! " & Err.Number
    End If
End Function



Function HttpPost(sURL, sMessage)
    On Error Resume Next
    
    If Not IsObject(oHTTP) Then _
        Set oHTTP = WScript.CreateObject("Microsoft.XMLHTTP")

    oHTTP.Open "POST", sURL, False
    oHTTP.SetRequestHeader "Content-Type", "application/x-www-form-urlencoded"   'Some sites will require that certain request headers be present (optional).
    oHTTP.Send sMessage                           
    
    If Err.Number = 0 Then
        HttpPost = oHTTP.ResponseText
    Else
        HttpPost = "Error! " & Err.Number
    End If
End Function



'This is for retrieving the raw bytes of a text or binary file from the
'web server.  The function returns an array of these raw, unsigned bytes.
Function HttpGetBytes(sURL)
    On Error Resume Next
    
    If Not IsObject(oHTTP) Then _
        Set oHTTP = WScript.CreateObject("Microsoft.XMLHTTP")

    oHTTP.Open "GET", sURL, False       
    oHTTP.Send                          
    
    If Err.Number = 0 AND oHTTP.Status = "200" Then
        HttpGetBytes = oHTTP.ResponseBody    'Returns an array of raw bytes.
    Else
        HttpGetBytes = Array()
    End If
End Function



'Lists all the HTTP headers returned by the server.  If the HEAD verb
'is being blocked, use GET instead (it will still work).
Function HttpHeaders(sVerb, sURL)
    On Error Resume Next
    
    If Not IsObject(oHTTP) Then _
        Set oHTTP = WScript.CreateObject("Microsoft.XMLHTTP")

    oHTTP.Open sVerb, sURL, False
    oHTTP.Send

    If Err.Number = 0 Then
        HttpHeaders = oHTTP.GetAllResponseHeaders
    Else
        HttpHeaders = "Error! " & Err.Number
    End If
End Function



'See the status codes at the bottom of this script...
Function HttpResponseCode(sVerb, sURL)
    On Error Resume Next
    
    If Not IsObject(oHTTP) Then _
        Set oHTTP = WScript.CreateObject("Microsoft.XMLHTTP")

    oHTTP.Open sVerb, sURL, False
    oHTTP.Send

    If Err.Number = 0 Then
        HttpResponseCode = oHTTP.Status
    Else
        HttpResponseCode = "Error! " & Err.Number
    End If
End Function



'The sServer argument can either be an IP address or Fully Qualified Domain Name.
Function HttpServerString(sServer)
    On Error Resume Next

    If Not IsObject(oHTTP) Then _
        Set oHTTP = WScript.CreateObject("Microsoft.XMLHTTP")

    oHTTP.Open "HEAD", "http://" & sServer, False
    oHTTP.Send
    
    If Err.Number = 0 Then
        HttpServerString = oHTTP.GetResponseHeader("Server")
    Else
        HttpServerString = "Error! " & Err.Number
    End If
End Function



'END OF SCRIPT ****************************************************************************


'WScript.Echo HttpGetText("http://www.sans.org/surveys/web.php")
'WScript.Echo HttpHeaders("HEAD","http://www.sans.org/surveys/web.php")
'WScript.Echo HttpServerString("63.100.47.46")
'WScript.Echo HttpServerString("www.microsoft.com")
'WScript.Echo HttpResponseCode("GET","http://www.microsoft.com")
'WScript.Echo UBound(HttpGetBytes("http://www.sans.org/images/Research.gif"))
'WScript.Echo HttpPost("http://www.imdb.com/Find","select=All&for=Star Wars")
'WScript.Echo HttpPost("http://weather.noaa.gov/cgi-bin/mgetmetar.pl","cccc=kads")
'WScript.Echo HttpPost("http://adds.aviationweather.gov/metars/index.php","metarIds=kads&hoursStr=most recent only&std_trans=standard")
'WScript.Echo HttpPost("http://adds.aviationweather.gov/metars/index.php","metarIds=kads")
'WScript.Echo HttpPost("http://ws.arin.net/cgi-bin/whois.pl","queryinput=%2B68.93.110.20+")
'WScript.Quit

'The following is a sample of how you might use these functions.  Of course, had
'these sites published their data as XML web services, the code would be much
'cleaner and stable (if they change their pages, these line won't work anymore).
sTime = HttpGetText("http://www.timeanddate.com/worldclock/results.html?query=dallas")
sUtcTime = sTime

sTime = Mid(sTime,InStr(sTime,"<th>Current time</th><td><strong id=""ct"">") + 41, 50) 
sTime = Left(sTime,InStr(sTime,"<") - 1)

sUtctime = Mid(sUtcTime,InStr(sUtcTime,"<tr><td>Current <strong>UTC</strong> (or GMT/Zulu)-time used: <strong") + 79, 50)
sUtcTime = Left(sUtcTime,InStr(sUtcTime,"<") - 1)

sMETAR = HttpPost("http://adds.aviationweather.gov/metars/index.php","station_ids=kads+ktki+kdfw+kdal&std_trans=standard&chk_metars=on&hoursStr=most+recent+only&submit=Submit")
sMETAR = Mid(sMETAR, InStr(sMETAR,"KADS") )
sMETAR = Left(sMETAR, InStr(sMETAR,"</TD>") - 5)
sMETAR = Replace(sMETAR,"<BR>",vbCr)
sMETAR = Replace(sMETAR,"</FONT>","")
sMETAR = Replace(sMETAR,"<FONT FACE=""Monospace,Courier"">","")

sTAF = HttpPost("http://adds.aviationweather.gov/cgi-bin/adds_tafs","station_ids=kdfw&submit_taf=TAF+Only")
sTAF = Mid(sTAF, InStr(sTAF,"<PRE>") + 5)
sTAF = Left(sTAF, InStr(sTAF,"</PRE>") - 1)

MsgBox "Dallas: " & sTime & vbCr &_
       "   UTC: " & sUtcTime & vbCrLf & vbCrLf &_ 
           sMETAR & vbCrLf &_
             sTAF,,"Dallas Time and Weather"




'******************************************
'            HTTP STATUS CODES
'******************************************
'http://www.rfc-editor.org/rfc/rfc2616.txt
'******************************************
'Successful 2xx
'200 OK
'201 Created
'202 Accepted
'203 Non-Authoritative Information
'204 No Content
'205 Reset Content
'206 Partial Content
'
'Redirection 3xx
'300 Multiple Choices
'301 Moved Permanently
'302 Found
'303 See Other
'304 Not Modified
'305 Use Proxy
'306 (Unused) 
'307 Temporary Redirect
'
'Client Error 4xx
'400 Bad Request
'401 Unauthorized 
'402 Payment Required 
'403 Forbidden 
'404 Not Found 
'405 Method Not Allowed
'406 Not Acceptable 
'407 Proxy Authentication Required
'408 Request Timeout
'409 Conflict
'410 Gone 
'411 Length Required
'412 Precondition Failed
'413 Request Entity Too Large
'414 Request-URI Too Long
'415 Unsupported Media Type
'416 Requested Range Not Satisfiable
'417 Expectation Failed 
'
'Server Error 5xx
'500 Internal Server Error
'501 Not Implemented
'502 Bad Gateway
'503 Service Unavailable
'504 Gateway Timeout
'505 HTTP Version Not Supported 
