'**********************************************************************
' Script Name: Get_Clipboard_Text.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC ( www.ISAscripts.org )
'Last Updated: 27.May.2006
'     Purpose: Demos how to retrieve text in the clipboard.
'       Notes: Requires IE 5.0 or later.  If something other than plain
'              text is in the clipboard, e.g., a graphics object, then
'              the function returns "<Clipboard-Data-Not-Text>".
'       Legal: Public Domain.  Modify and redistribute freely.  
'              No rights reserved.  SCRIPT PROVIDED "AS IS" WITHOUT 
'              WARRANTIES OR GUARANTEES OF ANY KIND.  USE AT YOUR OWN 
'              RISK AND ONLY ON NETWORKS WITH PRIOR WRITTEN PERMISSION.
'**********************************************************************


Function GetClipboardText()
    Dim oHtmlFile : Set oHtmlFile = CreateObject("htmlfile")
    GetClipboardText = oHtmlFile.ParentWindow.ClipboardData.GetData("Text")
    Set oHtmlFile = Nothing
    If VarType(GetClipboardText) <> 8 Then GetClipboardText = "<Clipboard-Data-Not-Text>"  
End Function




'Copy some text to the clipboard and then run this script...
MsgBox GetClipboardText()


