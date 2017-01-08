'*************************************************************************************
' Script Name: Taste_Of_XML.vbs
'     Version: 1.0.1
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 14.Dec.2006
'     Purpose: To work through a sampling of code chunks for manipulating XML.
'       Notes: For a nice on-line XML reference with VBScript/JScript samples, see 
'              http://www.devguru.com/Technologies/xmldom/quickref/xmldom_intro.html 
'       Notes: See also the XMLHTTP.VBS script for related HTTP functions.  
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*************************************************************************************

Set oXMLDOM = WScript.CreateObject("Microsoft.XMLDOM")
oXMLDOM.Async = False     'False means any loaded XML doc must be completely parsed before continuing further.

'
' If you already have an XML string, or an XML file, or a URL to an XML file
' that you'd like to use, you don't have to create your XML document in the 
' script from scratch.  
'
'     oXMLDOM.LoadXml("<root><node><property>Green</property></node></root>")
'     oXMLDOM.Load("c:\philosophers.xml")
'     oXMLDOM.Load("http://www.devguru.com/Features/tutorials/XML/devguru_staff_list.xml")
' 
'
' But let's programmatically create the following XML document from scratch:
'
'            <philosophers>
'                  <thinker><name>Aristotle</name> <home>Stagira</home></thinker>
'                  <thinker><name>Plato</name> <home>Athens</home></thinker>
'            </philosophers>
'

Dim oPhilosophers, oThinker, oName, oHome   'These global variables must be declared first (see functions).

bFlag = CreateAndAppendEmptyElement(oXMLDOM, oPhilosophers, "philosophers")

bFlag = CreateAndAppendEmptyElement(oPhilosophers, oThinker, "thinker")
bFlag = CreateAndAppendElementWithText(oThinker, oName, "name", "Aristotle")
bFlag = CreateAndAppendElementWithText(oThinker, oHome, "home", "Stagira")

bFlag = CreateAndAppendEmptyElement(oPhilosophers, oThinker, "thinker")
bFlag = CreateAndAppendElementWithText(oThinker, oName, "name", "Plato")
bFlag = CreateAndAppendElementWithText(oThinker, oHome, "home", "Athens")


'
' Now that we have an XML document, we'll get a collection of all <thinker> elements
' and cycle through them in some different ways to see how to extract data.
'

Set cNodeList = oXMLDOM.GetElementsByTagName("thinker")

For Each oNode In cNodeList
    WScript.Echo(oNode.ChildNodes(0).Text & " was born in " & oNode.ChildNodes(1).Text) 
Next


For Each oNode In cNodeList
    Set oName = oNode.SelectSingleNode("name")
    Set oHome = oNode.SelectSingleNode("home")
    WScript.Echo oHome.Text & " was the birthplace of " & oName.Text
Next


Set oRootElement = oXMLDOM.DocumentElement                  ' .DocumentElement gets the root node of the doc.
For i = 0 To (oRootElement.ChildNodes.Length - 1)
    Set oChild = oRootElement.ChildNodes(i)
    Set oName = oChild.SelectSingleNode("name")
    Set oHome = oChild.SelectSingleNode("home")
    WScript.Echo oName.Text & " was born in " & oHome.Text    
Next


'
' Saving your XML to a text file is easy.
' 

oXMLDOM.Save("c:\philosophers.xml")


'
' And retrieving the XML data from the doc is easy too.
'

WScript.Echo oXMLDOM.Xml    'Returns XML of entire doc.
WScript.Echo oXMLDOM.Text   'Returns text of doc with XML tags stripped away.




' *******************************************************************************
' ******** Functions And Procedures *********************************************
' *******************************************************************************


'
' The element to which you are appending must already exist.  This is the first argument.
' You must declare a global variable to pass in as second argument.  This is the new element.
' The name of the element is the third argument, e.g., "pizza" becomes "<pizza></pizza>".
'
Function CreateAndAppendEmptyElement(ByRef oNodeToAppendTo, ByRef oNewElement, sNewElementName)
    Set oXMLDOM = WScript.CreateObject("Microsoft.XMLDOM")
    Set oNewElement  = oXMLDOM.CreateElement(sNewElementName)
    oNodeToAppendTo.AppendChild(oNewElement)
    If Err.Number = 0 Then CreateAndAppendEmptyElement = True Else CreateAndAppendEmptyElement = False
End Function



'
' The element to which you are appending must already exist.  This is the first argument.
' You must declare a global variable to pass in as second argument.  This is the new element.
' The name of the element is the third argument, e.g., "pizza" becomes "<pizza></pizza>".
' The contents of the new element is the fourth argument, e.g., "<pizza>Pepperoni</pizza>".
'
Function CreateAndAppendElementWithText(ByRef oNodeToAppendTo, ByRef oNewElement, sNewElementName, sText)
    Set oXMLDOM = WScript.CreateObject("Microsoft.XMLDOM")
    Set oNewElement  = oXMLDOM.CreateElement(sNewElementName)
    Set oTextNode = oXMLDOM.CreateTextNode(sText)
    oNewElement.AppendChild(oTextNode)
    oNodeToAppendTo.AppendChild(oNewElement)
    If Err.Number = 0 Then CreateAndAppendElementWithText = True Else CreateAndAppendElementWithText = False
End Function



