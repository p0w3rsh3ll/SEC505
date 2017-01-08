'*************************************************************************************
' Script Name: ISA_Manage_Subnets.vbs
'     Version: 1.0
'      Author: Jason Fossen (www.isascripts.org)
'Last Updated: 20.May.2005
'     Purpose: Demonstrate a variety of functions for creating, deleting, listing and
'              modifying Subnet objects in ISA Server.
'       Notes: You should download the free ISA Server SDK from Microsoft's web site
'              to understand the objects and collections referenced below:
'              http://www.microsoft.com/isaserver/downloads/
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'*************************************************************************************


Sub PrintListOfSubnets()
    '
    ' First, make sure we're using CSCRIPT.EXE to avoid Death By MsgBox...
    '
    Dim iPosition : iPosition = InStr( LCase(WScript.FullName) , "cscript.exe" )
    If iPosition = 0 Then 
        Set oWshShell = CreateObject("WScript.Shell")
        oWshShell.Run "cmd.exe /k cscript.exe //nologo " & """" & WScript.ScriptFullName & """"
        WScript.Quit(0)
    End If
    '
    ' OK, we're using CSCRIPT, now proceed...
    '

    Dim oFPC		'Root COM object for ISA admin.
    Dim oIsaArray	'The local ISA Server or ISA Array. 
    Dim cSubnets	'FPCSubnets collection.
    Dim oSubnet     'FPCSubnet object.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cSubnets = oIsaArray.RuleElements.Subnets

    WScript.Echo vbCrLf
    
	For Each oSubnet In cSubnets
	    WScript.Echo "--------------------------------------------------"
		WScript.Echo "   Subnet Name: " & oSubnet.Name 
		WScript.Echo "   Description: " & oSubnet.Description 
		WScript.Echo "    IP Address: " & oSubnet.IPAddress
		WScript.Echo "   Subnet Mask: " & oSubnet.IPMask 
	Next
    
    WScript.Echo "--------------------------------------------------" & vbCrLf
End Sub



Function CreateSubnet(sSubnetName, sIPaddress, sMask)
    Dim oFPC        'Root COM object for ISA admin.
    Dim oIsaArray   'The local ISA Server or ISA Array. 
    Dim cSubnets    'FPCSubnets collection.
    Dim oSubnet     'FPCSubnet object.
    Dim iMask       'Used when sMask arg is a number of bits.
    
    'If sMask is not dotted decimal, convert bit number to it.
    If InStr(sMask, ".") = 0 Then
        iMask = CInt(Trim(sMask))
        Select Case iMask
            Case 0  sMask = "0.0.0.0"
            Case 1  sMask = "128.0.0.0"
            Case 2  sMask = "192.0.0.0"
            Case 3  sMask = "224.0.0.0"
            Case 4  sMask = "240.0.0.0" 
            Case 5  sMask = "248.0.0.0"
            Case 6  sMask = "252.0.0.0"
            Case 7  sMask = "254.0.0.0"
            Case 8  sMask = "255.0.0.0"
            Case 9  sMask = "255.128.0.0"
            Case 10 sMask = "255.192.0.0"
            Case 11 sMask = "255.224.0.0"
            Case 12 sMask = "255.240.0.0"
            Case 13 sMask = "255.248.0.0"
            Case 14 sMask = "255.252.0.0"
            Case 15 sMask = "255.254.0.0"
            Case 16 sMask = "255.255.0.0"
            Case 17 sMask = "255.255.128.0"
            Case 18 sMask = "255.255.192.0"
            Case 19 sMask = "255.255.224.0"
            Case 20 sMask = "255.255.240.0"
            Case 21 sMask = "255.255.248.0"
            Case 22 sMask = "255.255.252.0"
            Case 23 sMask = "255.255.254.0"
            Case 24 sMask = "255.255.255.0"
            Case 25 sMask = "255.255.255.128"
            Case 26 sMask = "255.255.255.192"
            Case 27 sMask = "255.255.255.224"
            Case 28 sMask = "255.255.255.240"
            Case 29 sMask = "255.255.255.248"
            Case 30 sMask = "255.255.255.252"
            Case 31 sMask = "255.255.255.254"
            Case 32 sMask = "255.255.255.255"                                                                                                                    
        End Select
    End If
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cSubnets = oIsaArray.RuleElements.Subnets
    Set oSubnet = cSubnets.Add(sSubnetName, sIPaddress, sMask)

    oSubnet.Save    
    
    If Err.Number = 0 Then CreateSubnet = True Else CreateSubnet = False
End Function



Function DeleteSubnet(sSubnetName)
    Dim oFPC        'Root COM object for ISA admin.
    Dim oIsaArray   'The local ISA Server or ISA Array. 
    Dim cSubnets    'FPCSubnets collection.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cSubnets = oIsaArray.RuleElements.Subnets
	cSubnets.Remove(sSubnetName)
    cSubnets.Save    
    
    If Err.Number = 0 Then DeleteSubnet = True Else DeleteSubnet = False
End Function



Function DeleteAllSubnets()
    Dim oFPC		'Root COM object for ISA admin.
    Dim oIsaArray	'The local ISA Server or ISA Array. 
    Dim cSubnets    'FPCURLSets collection.
    Dim oSubnet     'FPCSubnet object.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cSubnets = oIsaArray.RuleElements.Subnets
    
    For Each oSubnet In cSubnets
        cSubnets.Remove(oSubnet.Name)        
    Next
    
    cSubnets.Save   
    
    If Err.Number = 0 Then DeleteAllSubnets = True Else DeleteAllSubnets = False
End Function




'END OF SCRIPT************************************************************************








'If CreateSubnet("TestingSubnet3", "0.0.0.0", "254.0.0.0") Then WScript.Echo "Good create"
'Call PrintListOfSubnets()
'If DeleteSubnet("TestingSubnet2") Then WScript.Echo "Good delete"
'If DeleteAllSubnets() Then WScript.Echo "Good wipe."



