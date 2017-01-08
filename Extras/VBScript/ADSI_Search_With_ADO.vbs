'**************************************************************************************************
' Script Name: ADSI_Search_With_ADO.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 07/23/03
'     Purpose: Function returns true if the supplied username already exists in the forest,
'              false if the account does not exist.  However, the main purpose of this function
'              is to show how to use ADO to perform Active Directory searches with SQL.
'       Notes: The sOuDomainPath argument must be the full AD path to the OU or domain 
'              where the object exists.  For example, it could be "dc=usa,dc=sans,dc=org".  
'              The sUserName is the sAMAccountName name of the user, i.e., its generic username.
'       Notes: This is modeled on the ADO_Long_Template.vbs script and the constants defined there.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'**************************************************************************************************


Function UserAlreadyExists(sOuDomainPath, sUserName)
    'There are two ways to specify the search: 1) with LDAP syntax or 2) SQL syntax.
    
    '****** LDAP Syntax ******
    'Base gives the moniker (either LDAP: or GC:) and the initial container at which to begin
    'the search, e.g., the top-level domain container or a single OU beneath it.  It is 
    'always placed inside of chevrons, i.e., greater-than and less-than signs.
    sBase = "<GC://" & sOuDomainPath & ">"
    
    'Filters limit which objects are returned by the search and have an important impact on
    'script performance and bandwidth usage.  Each Filter is placed inside parentheses and has the
    'form of (property = value), e.g., (objectClass = user).  When multiple filters are used together,
    'place them all inside another set of parentheses and include either '&', '|' or '!' after the 
    'opening parenthesis to indicate AND, OR or NOT, e.g.,(&(objectClass = user)(sAMAccountName = Guest)).  
    'When using a filter to capture just user accounts, use (&(objectCategory = person)(objectClass = user))
    'because objectCategory is indexed in the GC.  The objectCategory property lets you limit the 
    'query to all account types that were derived from a class whose defaultObjectCategory is "person".
    'Tip: avoid having unnecessary spaces in your filter definition or else an error will occur. 
    sFilters = "(&(objectCategory=person)(objectClass=user)(sAMAccountName=" & sUserName & "))"
    
    'Attributes are the object attributes names you want to have available in your result set.
    'List as many as you wish, but separate them with commas, and beware of multi-valued attributes.
    sAttributes = "sAMAccountName,distinguishedName"
    
    'Scope will either be Base, OneLevel or Subtree.  The Base scope will search only the container
    'specified; OneLevel will search the container specified and one level beneath it; Subtree will
    'cause a recursive search through all subcontainers under the one specified.
    sScope = "Subtree"
    
    sSearchUsingLdapSyntax = sBase & ";" & sFilters &  ";" & sAttributes &  ";" & sScope
    


    
    '****** SQL Syntax ******    
    'You can use either the LDAP syntax above or the SQL syntax below, your choice.  But using and
    'learning the SQL syntax is better for leveraging your SQL skills with databases, WMI and other tools.
    'The LDAP syntax is preferred if you use LDP.EXE or if you're already conversant with LDAP itself.
    
    sSearchUsingSqlSyntax = "SELECT sAMAccountName,distinguishedName "&_ 
                            "FROM 'GC://" & sOuDomainPath & "' "&_
                            "WHERE objectCategory='person' AND objectClass='user' AND sAMAccountName='" & sUserName & "'"
    
    

    
    Set oConnection = CreateObject("ADODB.Connection")
    oConnection.ConnectionString = "Provider=ADsDSOObject;"
    oConnection.Open
    
    Set oCommand = CreateObject("ADODB.Command")
    oCommand.ActiveConnection = oConnection
    oCommand.CommandType = &H0001   'adCmdTxt    
    oCommand.CommandTimeout = 30
    oCommand.CommandText = sSearchUsingSqlSyntax      'or you can use sSearchUsingLdapSyntax here. 
    
    Set oRecordSet = CreateObject("ADODB.Recordset")
    oRecordSet.CursorLocation = 2   'adUseServer
    oRecordSet.CursorType = 0   'adOpenForwardOnly
    oRecordSet.LockType = 1   'adLockReadOnly
    oRecordSet.Open oCommand    
        
    
    If oRecordSet.RecordCount >= 1 Then
        UserAlreadyExists = True    
    '    Do Until oRecordset.EOF
    '        Wscript.Echo oRecordset.Fields("sAMAccountName") & " is " & oRecordset.Fields("distinguishedName")
    '        oRecordset.MoveNext
    '    Loop
    Else
        UserAlreadyExists = False
    End If

    
    If oRecordSet.State  = adStateOpen Then oRecordSet.Close
    If oConnection.State = adStateOpen Then oConnection.Close
    Set oRecordSet = Nothing
    Set oCommand = Nothing 
    Set oConnection = Nothing
End Function

'END OF SCRIPT********************************************************************************


'The following lines are just to demonstrate the function.
 If UserAlreadyExists("dc=usa,dc=sans,dc=org","Guest") Then 
    WScript.Echo "Exists!"
 Else
    WScript.Echo "Does NOT exist!"
 End If
 
 
 
 
