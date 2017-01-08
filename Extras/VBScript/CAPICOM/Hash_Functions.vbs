'*****************************************************
' Script Name: Hash_Functions.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 6/24/02
'     Purpose: Demonstrates how to use CAPICOM to hash data.  
'       Notes: You must register CAPICOM.DLL version 2.0+ before use.  Obtain the
'              CAPICOM.DLL file from: http://msdn.microsoft.com/library/default.asp?url=/library/en-us/security/security/capicom_versions.asp?frame=true
'              This website is also where the CAPICOM documentation can be found.
'       Notes: Windows represents data in Unicode by default in order to support
'              international languages, hence, when data is hashed, it is Unicode
'              data that is hashed, not ANSI data.  To get the hashes of
'              data on Windows to match the hashes of the "same" data on other
'              platforms, you will likely need to convert the text to ASNI first.
'              You should use the HashRawData() and HashUnicodeTextFile() functions
'              unless you need interoperability with other tools/platforms that convert 
'              to ANSI automatically or use ANSI natively.  The Unicode-oriented
'              functions are MUCH faster because they omit the ANSI-translation.
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              CAPICOM.DLL is owned by Microsoft, but it is redistributable.
'*****************************************************
Option Explicit

WScript.Echo HashUnicodeData("HiThere!") 
WScript.Echo HashUnicodeData(ConvertUnicodeToANSI("HiThere!")) 
WScript.Echo HashANSIData("HiThere!") 
WScript.Echo HashUnicodeTextFile(WScript.ScriptFullName)
WScript.Echo HashANSITextFile(WScript.ScriptFullName)


'*****************************************************
' Functions.
'*****************************************************

Function HashUnicodeData(sData)
     Const CAPICOM_HASH_ALGORITHM_SHA1 = 0
     Const CAPICOM_HASH_ALGORITHM_MD5  = 3
     Dim oCAPI
     Set oCAPI = CreateObject("CAPICOM.HashedData")
     oCAPI.Algorithm = CAPICOM_HASH_ALGORITHM_MD5
     oCAPI.Hash sData
     HashUnicodeData = oCAPI.Value
     sData = ""
     Set oCAPI = Nothing   
End Function



Function HashANSIData(sData)
     Const CAPICOM_HASH_ALGORITHM_SHA1 = 0
     Const CAPICOM_HASH_ALGORITHM_MD5  = 3
     Dim oCAPI,sOutput,iCounter,sCharacter

     Set oCAPI = CreateObject("CAPICOM.HashedData")
     oCAPI.Algorithm = CAPICOM_HASH_ALGORITHM_MD5

     sOutput = ""
     For iCounter = 1 To Len(sData)
          sCharacter = Mid(sData, iCounter, 1)
          sOutput = sOutput & ChrB(AscB(sCharacter))  'Slowwwwwly...converts text to ANSI.
     Next
     sData = ""
	
    oCAPI.Hash sOutput
    HashANSIData = oCAPI.Value
    sOutput = ""
    Set oCAPI = Nothing   
End Function



Function HashUnicodeTextFile(sFile)   
     Const CAPICOM_HASH_ALGORITHM_SHA1 = 0
     Const CAPICOM_HASH_ALGORITHM_MD5  = 3
     Dim oCAPI,oFileSystem,oFile,sData
     Set oCAPI = CreateObject("CAPICOM.HashedData")
     Set oFileSystem = CreateObject("Scripting.FileSystemObject")
    
     Const ForReading = 1
     Set oFile = oFileSystem.OpenTextFile(sFile,ForReading)  
     sData = oFile.ReadAll
     oFile.Close
    
     oCAPI.Algorithm = CAPICOM_HASH_ALGORITHM_MD5
     oCAPI.Hash sData
     HashUnicodeTextFile = oCAPI.Value
	
     sData = ""
     Set oCAPI = Nothing   
     Set oFile = Nothing
     Set oFileSystem = Nothing   
End Function



Function HashANSITextFile(sFile)   
     Const CAPICOM_HASH_ALGORITHM_SHA1 = 0
     Const CAPICOM_HASH_ALGORITHM_MD5  = 3
     Dim oCAPI,oFileSystem,oFile,sData,sOutput,sCharacter,iCounter,sLength
	
     Set oCAPI = CreateObject("CAPICOM.HashedData")
     Set oFileSystem = CreateObject("Scripting.FileSystemObject")
    
     Const ForReading = 1
     Set oFile = oFileSystem.OpenTextFile(sFile,ForReading)  
     sData = oFile.ReadAll
     oFile.Close
    
     sOutput = ""
     sLength = Len(sData)
     For iCounter = 1 To sLength
          sCharacter = Mid(sData, iCounter, 1)
          sOutput = sOutput & ChrB(AscB(sCharacter))  'Slowwwwwly...converts text to ANSI.
     Next
     sData = ""
    
     oCAPI.Algorithm = CAPICOM_HASH_ALGORITHM_MD5
     oCAPI.Hash sOutput
     HashANSITextFile = oCAPI.Value

     sOutput = ""
     Set oCAPI = Nothing   
     Set oFile = Nothing
     Set oFileSystem = Nothing   
End Function



Function ConvertUnicodeToANSI(sInput)
     Dim iCounter,sCharacter,sLength
     sLength = Len(sInput)
     For iCounter = 1 To sLength
          sCharacter = Mid(sInput, iCounter, 1)
          ConvertUnicodeToANSI = ConvertUnicodeToANSI & ChrB(AscB(sCharacter))  'Slowwwwwly...converts text to ANSI.
     Next
End Function



'END OF SCRIPT****************************************
