'*****************************************************
' Script Name: ADSI_Scan_and_Enumerate_RootDSE.vbs
'     Version: 1.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 3/15/03
'     Purpose: Enumerates the entire contents of the RootDSE naming
'              context on any vendor's LDAPv3 server, including a Windows 2000 DC.
'       Usage: Enter the beginning IP address and the ending IP address to scan.
'        Note: Run this with CSCRIPT.EXE. Also, you are MUCH better off using a
'              standard port scanner to find TCP 389's open, then pumping those
'              IP addresses into ADSI_Enumerate_RootDSE.vbs-- this script is SLOW!
'              ADSI will attempt to connect to each target IP for 11 seconds before
'              giving up and moving on to the next target address.  On the other
'              hand, maybe this is a "stealth feature"  :-)
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*****************************************************


On Error Resume Next

If WScript.Arguments.Count <> 2 Then 
    WScript.Echo vbCrLf & "Enter the beginning IP address and the ending IP address to "
    WScript.Echo "define the range of addresses to scan for LDAP servers."
    WScript.Echo "For example: thisscript.vbs 10.0.0.1 10.255.255.254"
    WScript.Quit
End If
 
sUser = ""      'Optional username with which to authenticate to the LDAP server.
sPass = ""      'Optional password with which to authenticate to the LDAP server.

Set oNamespace = GetObject("LDAP:")          

iStart = IP2Number(WScript.Arguments.Item(0))
iEnd   = IP2Number(WScript.Arguments.Item(1))

For iIPaddress = iStart To iEnd        
    sIPaddress = Number2IP(iIPaddress)
    sPath = "LDAP://" & sIPaddress & "/RootDSE"   
    
    WScript.Echo "Scanning " & sIPaddress & " ..." & vbCr
    
    Set oContainer = oNamespace.OpenDSObject(sPath,sUser,sPass,0)
    If Err.Number = 0 Then
        WScript.Echo "Found an LDAP server at " & sIPaddress & vbCrLf    'This line may seem redundant, but some (older) LDAP servers don't have a RootDSE.
        Call EnumerateContainer(sIPaddress,oContainer)
    End If 
    Err.Clear 
Next




Sub EnumerateContainer(ByVal sTargetIP, ByRef oContainer)
    On Error Resume Next
    
    oContainer.GetInfo
    
    for i = 0 to oContainer.PropertyCount - 1
        sItemName = oContainer.Item(i).Name
        sResult = sResult & "LDAP://" & sTargetIP & "/RootDSE." & sItemName & vbCrLf

        aValues = oContainer.GetEx(sItemName)
        For Each sThing In aValues
            sResult = sResult & vbTab & sThing & vbCrLf
        Next
        
        sResult = sResult & vbCrLf
    Next
    
    Wscript.Echo sResult
End Sub



Function IP2Number(ByVal sIP)
	aOctets = Split(sIP,".")
	IP2Number = (Int(aOctets(0)) * 16777216) + _
	            (Int(aOctets(1)) * 65536   ) + _ 
	            (Int(aOctets(2)) * 256     ) + _
	            (Int(aOctets(3))           )      
End Function



Function Number2IP(ByVal iNumber)
	Dim aOctets(4)
	aOctets(0) = Int(iNumber / 16777216)
    	iNumber = iNumber - (aOctets(0) * 16777216)
	aOctets(1) = Int(iNumber / 65536)
    	iNumber = iNumber - (aOctets(1) * 65536)   
	aOctets(2) = Int(iNumber / 256)
	aOctets(3) = iNumber - (aOctets(2) * 256)
	Number2IP = CStr(aOctets(0) & "." & aOctets(1) & "." & aOctets(2) & "." & aOctets(3))
End Function


'END OF SCRIPT*******************************************************************
