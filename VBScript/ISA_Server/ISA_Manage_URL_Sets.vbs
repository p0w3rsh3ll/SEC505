'*************************************************************************************
' Script Name: ISA_Manage_URL_Sets.vbs
'     Version: 1.0
'      Author: Jason Fossen (www.isascripts.org)
'Last Updated: 20.May.2005
'     Purpose: Demonstrate a variety of functions for creating, deleting, listing and
'              modifying URL Sets in ISA Server.
'       Notes: You should download the free ISA Server SDK from Microsoft's web site
'              to understand the objects and collections referenced below:
'              http://www.microsoft.com/isaserver/downloads/
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'*************************************************************************************



Sub PrintListOfUrlSetsAndUrls()
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
    Dim cUrlSets	'FPCURLSets collection.
    Dim cUrlSet     'FPCURLSet collection.
    Dim oUrl        
        
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cUrlSets = oIsaArray.RuleElements.URLSets

    WScript.Echo vbCrLf
    
	For Each cUrlSet In cUrlSets
	    WScript.Echo "--------------------------------------------------"
            WScript.Echo "  URL Set Name: " & cUrlSet.Name 
            WScript.Echo "Number of URLs: " & cUrlSet.Count 
            WScript.Echo "   Description: " & cUrlSet.Description 

            For Each oUrl In cUrlSet
                WScript.Echo "           URL: " & oUrl
            Next
        Next
 
    WScript.Echo "--------------------------------------------------" & vbCrLf
End Sub



Function CreateUrlSet(sUrlSetName)
    On Error Resume Next
    Dim oFPC		'Root COM object for ISA admin.
    Dim oIsaArray	'The local ISA Server or ISA Array. 
    Dim cUrlSets	'FPCURLSets collection.
    Dim cUrlSet     'FPCURLSet collection.
        
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cUrlSets = oIsaArray.RuleElements.URLSets
    Set cUrlSet = cUrlSets.Add(sUrlSetName)
    cUrlSet.Save    'cUrlSet inherits from FPCPersist object.
    If Err.Number = 421 Then Err.Clear  'URL Set already exists.
    If Err.Number = 0 Then CreateUrlSet = True Else CreateUrlSet = False
End Function



Function DeleteUrlSet(sUrlSetName)
    Dim oFPC		'Root COM object for ISA admin.
    Dim oIsaArray	'The local ISA Server or ISA Array. 
    Dim cUrlSets	'FPCURLSets collection.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cUrlSets = oIsaArray.RuleElements.URLSets
    cUrlSets.Remove(sUrlSetName)
    cUrlSets.Save    
    
    If Err.Number = 0 Then DeleteUrlSet = True Else DeleteUrlSet = False
End Function



Function DeleteAllUrlsInUrlSet(sUrlSetName)
    Dim oFPC		'Root COM object for ISA admin.
    Dim oIsaArray	'The local ISA Server or ISA Array. 
    Dim cUrlSets	'FPCURLSets collection.
    Dim cUrlSet     'FPCURLSet collection.
    Dim sUrl
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cUrlSets = oIsaArray.RuleElements.URLSets
    Set cUrlSet = cUrlSets.Item(sUrlSetName)
    
    For Each sUrl In cUrlSet
        cUrlSet.Remove(sUrl)        
    Next
    
    cUrlSet.Save   
    
    If Err.Number = 0 Then DeleteAllUrlsInUrlSet = True Else DeleteAllUrlsInUrlSet = False
End Function



'*************************************************************************
' Function: AppendUrlListToUrlSet(sUrlSetName, sUrlList)
'    Notes: sUrlList should be a string, not array, of the URLs you wish
'           to append, each URL separated by a space, vbCrLf, vbCr, or vbTab.
'    Notes: It is OK to try to append URLs that are already in the set, no
'           duplicate URLs will be created, and only new URLs will be added.
'  Returns: True if no errors, False if problems.
'*************************************************************************
Function AppendUrlListToUrlSet(sUrlSetName, sUrlList)
    On Error Resume Next 
    Dim oFPC            'Root COM object for ISA admin.
    Dim oIsaArray       'The local ISA Server or ISA Array. 
    Dim cUrlSets        'FPCURLSets collection.
    Dim aUrlArray       'Array of URLs split() from sUrlList arg.
    Dim cUrlSet         'FPCURLSet collection.
        
    sUrlList = Replace(sUrlList, vbTab, " ")
    sUrlList = Replace(sUrlList, vbCrLf, " ")
    sUrlList = Replace(sUrlList, vbCr, " ")
    aUrlArray = Split(Trim(sUrlList))	'Single space delimiter.
    
    Set oFPC = CreateObject("FPC.Root")
    Set oIsaArray = oFPC.GetContainingArray
    Set cUrlSets = oIsaArray.RuleElements.URLSets
    Set cUrlSet = cUrlSets.Item(sUrlSetName)
    
    For Each sUrl In aUrlArray
        sUrl = Trim(sUrl)  'There may be extra spaces creating blank URLs.
        If Len(sUrl) > 1 Then cUrlSet.Add(sUrl)
        If Err.Number = -2147024713 Then Err.Clear  'URL was already in the set. 
    Next
    
    cUrlSet.Save   
    
    If Err.Number = 0 Then AppendUrlListToUrlSet = True Else AppendUrlListToUrlSet = False
End Function



'END OF SCRIPT************************************************************************








'If CreateUrlSet("TestingUrlSets") Then WScript.Echo "Good create"
'Call PrintListOfUrlSetsAndUrls()
'If DeleteUrlSet("TestingUrlSets") Then WScript.Echo "Good delete"
'If AppendUrlListToUrlSet("Yahoo", "http://mail.yahoo2.com     ftp://ftp.yahoo2.com" & vbCrLf & vbCr & vbTab & "*.personals.yahoo2.com") Then WScript.Echo "Good append."
'If DeleteAllUrlsInUrlSet("Yahoo") Then WScript.Echo "Good empty."



