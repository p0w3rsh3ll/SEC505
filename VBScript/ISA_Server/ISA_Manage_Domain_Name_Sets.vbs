'*************************************************************************************
' Script Name: ISA_Manage_Domain_Name_Sets.vbs
'     Version: 1.0
'      Author: Jason Fossen (www.isascripts.org)
'Last Updated: 9.Aug.2005
'     Purpose: Demonstrate a variety of functions for creating, deleting, listing and
'              modifying Domain Name Sets in ISA Server.
'       Notes: You should download the free ISA Server SDK from Microsoft's web site
'              to understand the objects and collections referenced below:
'              http://www.microsoft.com/isaserver/downloads/
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'*************************************************************************************


Sub PrintListOfDomainNameSets()
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

    Dim oFPC		    'Root COM object for ISA admin.
    Dim oIsaArray	    'The local ISA Server or ISA Array. 
    Dim cDomainNameSets	'FPcDomainNameSets collection.
    Dim oDomainNameSet  'FPCDomainNameSet object.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cDomainNameSets = oIsaArray.RuleElements.DomainNameSets

    WScript.Echo vbCrLf
    
	For Each oDomainNameSet In cDomainNameSets
	    WScript.Echo "--------------------------------------------------"
		WScript.Echo " DomainNameSet: " & oDomainNameSet.Name 
		WScript.Echo "   Description: " & oDomainNameSet.Description 
		WScript.Echo "    Predefined: " & oDomainNameSet.Predefined 'Hence, cannot be deleted.
		
		For Each oDomain In oDomainNameSet
		    WScript.Echo "                " & oDomain  'no property name?
		Next
	Next
    
    WScript.Echo "--------------------------------------------------" & vbCrLf
End Sub



Function CreateDomainNameSet(sDomainNameSetName)
    On Error Resume Next
    Dim oFPC               'Root COM object for ISA admin.
    Dim oIsaArray          'The local ISA Server or ISA Array. 
    Dim cDomainNameSets    'FPCDomainNameSets collection.
    Dim oDomainNameSet     'FPCDomainNameSet object.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cDomainNameSets = oIsaArray.RuleElements.DomainNameSets 
    Set oDomainNameSet = cDomainNameSets.Add(sDomainNameSetName)

    If Err.Number = -2147024713 Then 
        Err.Clear  'Domain Name Set already existed.
    Else
        oDomainNameSet.Save    
    End If
    
    If Err.Number = 0 Then CreateDomainNameSet = True Else CreateDomainNameSet = False
    On Error Goto 0
End Function



Function DeleteDomainNameSet(sDomainNameSetName)
    On Error Resume Next
    Dim oFPC        'Root COM object for ISA admin.
    Dim oIsaArray   'The local ISA Server or ISA Array. 
    Dim cDomainNameSets    'FPcDomainNameSets collection.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cDomainNameSets = oIsaArray.RuleElements.DomainNameSets
	cDomainNameSets.Remove(sDomainNameSetName)

	If Err.Number = -2147024894 Then
	    Err.Clear  'Could not find set to delete, but note that function returns True anyway!
	Else
        cDomainNameSets.Save    
    End If
    
    If Err.Number = 0 Then DeleteDomainNameSet = True Else DeleteDomainNameSet = False
    On Error Goto 0
End Function



Function DeleteAllDomainNameSets()
    Dim oFPC		       'Root COM object for ISA admin.
    Dim oIsaArray	       'The local ISA Server or ISA Array. 
    Dim cDomainNameSets    'FPCDomainNameSets collection.
    Dim oDomainNameSet     'FPCDomainNameSet object.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cDomainNameSets = oIsaArray.RuleElements.DomainNameSets
    
    For Each oDomainNameSet In cDomainNameSets
        'Note: Predefined Domain Name Sets, such as for System Policy sites, cannot be deleted.
        If Not oDomainNameSet.Predefined Then cDomainNameSets.Remove(oDomainNameSet.Name)        
    Next
    
    cDomainNameSets.Save   
    
    If Err.Number = 0 Then DeleteAllDomainNameSets = True Else DeleteAllDomainNameSets = False
End Function



Function AddDomainToDomainNameSet(sDomainNameSetName, sDomainToAdd)
    On Error Resume Next
    Dim oFPC               'Root COM object for ISA admin.
    Dim oIsaArray          'The local ISA Server or ISA Array. 
    Dim cDomainNameSets    'FPCDomainNameSets collection.
    Dim oDomainNameSet     'FPCDomainNameSet object.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set oDomainNameSet = oIsaArray.RuleElements.DomainNameSets.Item(sDomainNameSetName)
    oDomainNameSet.Add(sDomainToAdd)
    
    If Err.Number = -2147024713 Then 
        Err.Clear  'Domain already existed.
    Else
        oDomainNameSet.Save    
    End If
    
    If Err.Number = 0 Then AddDomainToDomainNameSet = True Else AddDomainToDomainNameSet = False
    On Error Goto 0
End Function



'
' Remove a single domain from a Domain Name Set, but not delete the Set or the other domains in it.
'
Function RemoveDomainFromDomainNameSet(sDomainNameSetName, sDomainToRemove)
    On Error Resume Next
    Dim oFPC               'Root COM object for ISA admin.
    Dim oIsaArray          'The local ISA Server or ISA Array. 
    Dim cDomainNameSets    'FPCDomainNameSets collection.
    Dim oDomainNameSet     'FPCDomainNameSet object.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set oDomainNameSet = oIsaArray.RuleElements.DomainNameSets.Item(sDomainNameSetName)
    oDomainNameSet.Remove(sDomainToRemove)
    
    If Err.Number = -2147024894 Then 
        Err.Clear  'Domain already not in set.
    Else
        oDomainNameSet.Save    
    End If
    
    If Err.Number = 0 Then RemoveDomainFromDomainNameSet = True Else RemoveDomainFromDomainNameSet = False
    On Error Goto 0
End Function



'
' Remove all domains from a Domain Name Set, but don't delete the Set itself.
'
Function EmptyDomainNameSet(sDomainNameSetName)
    On Error Resume Next
    Dim oFPC               'Root COM object for ISA admin.
    Dim oIsaArray          'The local ISA Server or ISA Array. 
    Dim cDomainNameSets    'FPCDomainNameSets collection.
    Dim cDomainNameSet     'FPCDomainNameSet collection.
    Dim sDomain
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cDomainNameSet = oIsaArray.RuleElements.DomainNameSets.Item(sDomainNameSetName) 
    
    For Each sDomain In cDomainNameSet
        cDomainNameSet.Remove(sDomain)
    Next
    
    cDomainNameSet.Save    
    
    If Err.Number = 0 Then EmptyDomainNameSet = True Else EmptyDomainNameSet = False
End Function




'END OF SCRIPT************************************************************************




'If CreateDomainNameSet("TestingDomainNameSet4") Then WScript.Echo "Good create" Else WScript.Echo Err.Number
'Call PrintListOfDomainNameSets()
'If DeleteDomainNameSet("TestingDomainNameSet4") Then WScript.Echo "Good delete"
'If DeleteAllDomainNameSets() Then WScript.Echo "Good wipe."
'If AddDomainToDomainNameSet("TestingDomainNameSet4", "*.isascripts.org") Then WScript.Echo "Good add"
'If RemoveDomainFromDomainNameSet("TestingDomainNameSet4", "*.isascripts.org") Then WScript.Echo "Good remove"
'If EmptyDomainNameSet("TestingDomainNameSet4") Then WScript.Echo "Good empty"

