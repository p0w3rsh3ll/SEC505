'***********************************************************************************
' Script Name: CheckReverseLookup.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 2/26/02
'     Purpose: Demonstrate how a registered custom DLL can be invoked from a script.
'              This DLL is merely a COM wrapper for the GetHostByAddr() and
'              GetHostByName() methods from the WSock32 library in the OS.
'       Usage: Pass script a single IP address as a command-line argument.  The 
'              IP address will be sent to the local machine's DNS server for 
'              reverse resolution.  The returned hostname will then be sent to
'              the DNS server for a standard forward lookup.  The returned IP
'              address, if any, will be compared with the original input.
'       Notes: You must register the DLL which provides the ASPDNS object below.
'              Register the DLL by executing "regsvr32.exe aspdns.dll" in a 
'              command-prompt window or at the Run line.  You can download the DLL
'              for free --and optionally pay the donationware fee-- from
'              http://www.internext.co.za/stefan/aspdns/.
'    Keywords: regsvr32, DNS, reverse lookup, aspdns
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'              The ASPDNS.DLL source code is NOT provided and there is no guarantee
'              the DLL does not contain a virus or Trojan.  Use DLL at your own risk.
'***********************************************************************************



Function PerformReverseLookup(sInput)
    On Error Resume Next
    Set oDNS = WScript.CreateObject("ASPDNS.DNSLookup")
    PerformReverseLookup = oDNS.GetNameFromIP(CStr(sInput)) 'Need to cast from Variant to String.
    Set oDNS = Nothing
End Function



Function PerformForwardLookup(sInput)
    On Error Resume Next
    Set oDNS = WScript.CreateObject("ASPDNS.DNSLookup")
    PerformForwardLookup = oDNS.GetIPFromName(CStr(sInput)) 'Need to cast from Variant to String.
    Set oDNS = Nothing
End Function






'***********************************************************************************

On Error Resume Next

sIP = WScript.Arguments.Item(0)

sHostname  =  PerformReverseLookup(sIP)
sResolvedIP = PerformForwardLookup(sHostname)

If sIP = sResolvedIP Then
    sResult = "DNS reverse lookup confirms IP address " & sIP & ":" & vbCrLf &_
               vbTab & sHostname & " ---> " & sResolvedIP 
Else
    sResult = "DNS reverse lookup FAILED to confirm IP address " & sIP & ":" & vbCrLf &_
               vbTab & sHostname &   " ---> " & sResolvedIP & vbCrLf &_
               vbTab & sResolvedIP & " ---> " & PerformReverseLookup(sResolvedIP)
End If

WScript.Echo vbCrLf & sResult



'***********************************************************************************
' If you want even more control over the DNS query, download ASPDNSX.DLL, 
' an alternative DLL, from the same website above.
'***********************************************************************************
