'*****************************************************
' Script Name: Inject_Root_CA_Cert.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 4/4/01
'     Purpose: This simple script demonstrates how the certificate of a root CA can be
'              injected into the registry and thereby make the computer trust the CA.
'       Usage: This is a proof-of-concept script only.  It merely injects the
'              Belgacom E-Trust Primary root CA certificate, which is already in
'              the trusted root CA store by default.  The corresponding
'              Delete_Root_CA.vbs script can delete it.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "as is" without implied warranty or guarantee.  Use
'              at your own risk and only on networks with prior written permission.
'*****************************************************

On Error Resume Next

'The following is the Belgacom E-Trust root CA certificate in exported .REG file format.

sCertText = "Windows Registry Editor Version 5.00" & vbCrLf & vbCrLf & _
"[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SystemCertificates\Root\Certificates\4EF2E6670AC9B5091FE06BE0E5483EAAD6BA32D9]" & vbCrLf & _
" ""Blob""=hex:04,00,00,00,01,00,00,00,10,00,00,00,03,42,87,d7,c1,16,7d,18,af,a4,\" & vbCrLf & _
"  70,3c,b8,31,2c,3e,03,00,00,00,01,00,00,00,14,00,00,00,4e,f2,e6,67,0a,c9,b5,\" & vbCrLf & _
"  09,1f,e0,6b,e0,e5,48,3e,aa,d6,ba,32,d9,14,00,00,00,01,00,00,00,14,00,00,00,\" & vbCrLf & _
"  55,e5,e7,94,62,b6,49,0d,c6,3c,bc,71,22,36,12,89,8b,68,49,3c,20,00,00,00,01,\" & vbCrLf & _
"  00,00,00,8d,02,00,00,30,82,02,89,30,82,01,f2,a0,03,02,01,02,02,04,37,87,67,\" & vbCrLf & _
"  ac,30,0d,06,09,2a,86,48,86,f7,0d,01,01,05,05,00,30,75,31,0b,30,09,06,03,55,\" & vbCrLf & _
"  04,06,13,02,62,65,31,11,30,0f,06,03,55,04,0a,13,08,42,65,6c,67,61,63,6f,6d,\" & vbCrLf & _
"  31,0c,30,0a,06,03,55,04,0b,13,03,4d,54,4d,31,24,30,22,06,03,55,04,03,13,1b,\" & vbCrLf & _
"  42,65,6c,67,61,63,6f,6d,20,45,2d,54,72,75,73,74,20,50,72,69,6d,61,72,79,20,\" & vbCrLf & _
"  43,41,31,1f,30,1d,06,0a,09,92,26,89,93,f2,2c,64,01,03,14,0f,69,6e,66,6f,40,\" & vbCrLf & _
"  65,2d,74,72,75,73,74,2e,62,65,30,1e,17,0d,39,38,31,31,30,34,31,33,30,34,33,\" & vbCrLf & _
"  39,5a,17,0d,31,30,30,31,32,31,31,33,30,34,33,39,5a,30,75,31,0b,30,09,06,03,\" & vbCrLf & _
"  55,04,06,13,02,62,65,31,11,30,0f,06,03,55,04,0a,13,08,42,65,6c,67,61,63,6f,\" & vbCrLf & _
"  6d,31,0c,30,0a,06,03,55,04,0b,13,03,4d,54,4d,31,24,30,22,06,03,55,04,03,13,\" & vbCrLf & _
"  1b,42,65,6c,67,61,63,6f,6d,20,45,2d,54,72,75,73,74,20,50,72,69,6d,61,72,79,\" & vbCrLf & _
"  20,43,41,31,1f,30,1d,06,0a,09,92,26,89,93,f2,2c,64,01,03,14,0f,69,6e,66,6f,\" & vbCrLf & _
"  40,65,2d,74,72,75,73,74,2e,62,65,30,81,9f,30,0d,06,09,2a,86,48,86,f7,0d,01,\" & vbCrLf & _
"  01,01,05,00,03,81,8d,00,30,81,89,02,81,81,00,aa,d9,b9,b3,d5,4f,6a,4d,c5,41,\" & vbCrLf & _
"  d0,7b,04,61,6a,8b,71,81,07,da,64,e3,58,6e,27,55,c2,ad,ce,17,b0,fc,fa,92,8d,\" & vbCrLf & _
"  08,f0,1c,72,ff,b2,c3,31,fe,e0,6a,87,97,4c,cc,43,57,a7,28,79,3a,b5,83,5d,a4,\" & vbCrLf & _
"  1d,6a,f1,6a,c5,3e,14,22,1d,59,06,6f,f0,a6,31,77,dc,b0,49,38,e6,cb,0c,0f,fe,\" & vbCrLf & _
"  aa,72,34,88,da,28,3a,21,5a,ee,74,2b,1b,a4,db,5b,13,16,b5,73,5f,c3,ae,8c,d2,\" & vbCrLf & _
"  c0,3e,3d,b0,cb,f0,ec,8b,86,0b,c2,c1,44,18,5a,63,a8,d5,02,03,01,00,01,a3,26,\" & vbCrLf & _
"  30,24,30,0f,06,03,55,1d,13,04,08,30,06,01,01,ff,02,01,01,30,11,06,09,60,86,\" & vbCrLf & _
"  48,01,86,f8,42,01,01,04,04,03,02,00,07,30,0d,06,09,2a,86,48,86,f7,0d,01,01,\" & vbCrLf & _
"  05,05,00,03,81,81,00,7a,b2,b1,a5,b1,7d,33,e9,c2,e1,1b,ce,d3,93,8c,7f,01,fd,\" & vbCrLf & _
"  1b,1d,5a,9a,ae,ab,07,51,2f,ed,89,ab,dd,50,42,bb,1f,ff,4a,b5,a4,9c,b1,61,29,\" & vbCrLf & _
"  0a,4c,ea,83,59,49,8d,af,86,69,d7,81,ac,47,aa,a4,71,6e,59,ef,ca,7c,6a,6e,54,\" & vbCrLf & _
"  8a,da,a8,92,c9,f5,66,b3,79,5f,d4,8b,01,9e,21,63,46,35,93,a5,c2,5f,22,62,03,\" & vbCrLf & _
"  70,1d,63,23,e8,6b,48,1d,23,10,27,d8,f6,df,47,a2,ba,ec,80,50,4a,6c,c4,70,a6,\" & vbCrLf & _
"  7a,e4,74,22,7f,f6,84,62,32,7f" & vbCrLf & vbCrLf



'Create a temporary file and write the certificate to the file.
Const OpenFileForWriting = 2
Set oFSO = CreateObject("Scripting.FileSystemObject")
sTempFile = oFSO.GetTempName
sTempPath = oFSO.GetSpecialFolder(2) 'Code 2 is for the TEMP folder.
sInjectFile = sTempPath & "\" & sTempFile

Set oTxtStreamOut = oFSO.OpenTextFile(sInjectFile, OpenFileForWriting, True)
oTxtStreamOut.Write sCertText
Set oTxtStreamOut = Nothing

'Run REGEDIT.EXE to import the REG file.  The data cannot be written directly because there's too much of it.
sCommand = "regedit.exe -s " & sInjectFile
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run sCommand, 0, True

'Clean up the temp file.
oFSO.DeleteFile sInjectFile



'END OF SCRIPT ***************************************
