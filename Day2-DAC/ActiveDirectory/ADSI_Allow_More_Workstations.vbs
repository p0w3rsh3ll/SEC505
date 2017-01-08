'***********************************************************************************
' Script Name: ADSI_Allow_More_Workstations.vbs
'     Version: 1.0
'      Author: Anonymous (probably Jason)
'Last Updated: 5/28/02
'     Purpose: Increase the number of workstations a regular user is permitted
'              to join to the domain from 10 to the number you specify.
'       Notes: See Q251335 for more information.
'    Keywords: ADSI, Add workstations to domain, computer accounts, ms-DS-MachineAccountQuota
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'***********************************************************************************
On Error Resume Next

Set oRootDSE = GetObject("LDAP://RootDSE")
sDefaultNamingContext = oRootDSE.Get("defaultNamingContext")
Call CatchAnyErrorsAndQuit("Problem getting domain name from RootDSE.")

Set oAD = GetObject("LDAP://" & sDefaultNamingContext)
Call CatchAnyErrorsAndQuit("Problem connecting to domain controller.")

iOldMax = oAD.Get("ms-DS-MachineAccountQuota")
Call CatchAnyErrorsAndQuit("Problem reading value from domain controller.")

iMax = InputBox("Enter the number of workstations which any regular user should be " & _
                "permitted to join to the domain.  You currently allow " & iOldMax & "." & vbCrLf & _
                "(Min. = 0.  Max. = 2,000,000,000)", sDefaultNamingContext)

If (iMax = "") Then 
	MsgBox("No changes made.  Action cancelled by user.")
	Set oAD = Nothing
	Set oRootDSE = Nothing
	WScript.Quit
End If

iMax = Abs(CLng(Replace(iMax,",","")))

oAD.Put "ms-DS-MachineAccountQuota", iMax
oAD.SetInfo
Call CatchAnyErrorsAndQuit("Problem writing change to Active Directory.")

oAD.GetInfo
iNewMax = oAD.Get("ms-DS-MachineAccountQuota")

MsgBox "Quota has been successfully changed to " & iNewMax & ".",vbOkOnly,sDefaultNamingContext




'***********************************************************************************
' Helper Procedures and Functions.
'***********************************************************************************
Sub CatchAnyErrorsAndQuit(msg)
	If Err.Number <> 0 Then
		sOutput = vbCrLf
		sOutput = sOutput &  "ERROR:             " & msg & vbCrLf 
		sOutput = sOutput &  "Error Number:      " & Err.Number & vbCrlf
		sOutput = sOutput &  "Error Description: " & Err.Description & vbCrLf
		sOutput = sOutput &  "Error Source:      " & Err.Source & vbCrLf 
		sOutput = sOutput &  "Script Name:       " & WScript.ScriptName & vbCrLf 
		sOutput = sOutput &  vbCrLf
		
        WScript.Echo sOutput
		WScript.Quit Err.Number
	End If 
End Sub 

'END OF SCRIPT *********************************************************************
