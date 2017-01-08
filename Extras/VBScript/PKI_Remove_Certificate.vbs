'************************************************************************************
' Script Name: PKI_Remove_Certificate.vbs
'     Version: 2.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 20.Feb.2004
'     Purpose: Deletes a digital certificate by its SHA1 hash value.
'       Usage: Function takes three arguments: physical location of certificate,
'              the container its in, and the SHA1 hash of the certificate.   
'     Returns: True if successful and no errors, False if any error occurs.
'              Also returns True if the certificate is not found at all!
'       Notes: This function requires that CAPICOM.DLL version 2.0+ be registered on the
'              the machine with "regsvr32.exe capicom.dll".  The DLL can be
'              downloaded for free from Microsoft if not present on machine:
'              http://msdn.microsoft.com/library/en-us/security/security/capicom_versions.asp?frame=true
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              Script provided "AS IS" without warranties or guarantees of any kind.
'************************************************************************************



Function RemoveCertificate(sStoreLocation, sContainerName, sSha1Hash)
    On Error Resume Next
    
    'These are the storage locations possible for certificates.
    Const CAPICOM_MEMORY_STORE                = 0
    Const CAPICOM_LOCAL_MACHINE_STORE         = 1
    Const CAPICOM_CURRENT_USER_STORE          = 2
    Const CAPICOM_ACTIVE_DIRECTORY_USER_STORE = 3
    Const CAPICOM_SMART_CARD_USER_STORE       = 4
    
    'These are the possible open methods when opening a storage location.
    Const CAPICOM_STORE_OPEN_READ_ONLY        = 0
    Const CAPICOM_STORE_OPEN_READ_WRITE       = 1
    Const CAPICOM_STORE_OPEN_MAXIMUM_ALLOWED  = 2
    Const CAPICOM_STORE_OPEN_EXISTING_ONLY    = 128
    Const CAPICOM_STORE_OPEN_INCLUDE_ARCHIVED = 256

    'These are the possible storage container names.
    Const MY = "My"
    Const CA = "CA"
    Const ROOT = "Root"
    Const ADDRESSBOOK = "AddressBook"
    
    'These are the different possible ways of finding a certificate, but this function only uses SHA1 hashes.
    Const CAPICOM_CERTIFICATE_FIND_SHA1_HASH          = 0
    Const CAPICOM_CERTIFICATE_FIND_SUBJECT_NAME       = 1
    Const CAPICOM_CERTIFICATE_FIND_ISSUER_NAME        = 2
    Const CAPICOM_CERTIFICATE_FIND_ROOT_NAME          = 3
    Const CAPICOM_CERTIFICATE_FIND_TEMPLATE_NAME      = 4
    Const CAPICOM_CERTIFICATE_FIND_EXTENSION          = 5
    Const CAPICOM_CERTIFICATE_FIND_EXTENDED_PROPERTY  = 6
    Const CAPICOM_CERTIFICATE_FIND_APPLICATION_POLICY = 7
    Const CAPICOM_CERTIFICATE_FIND_CERTIFICATE_POLICY = 8
    Const CAPICOM_CERTIFICATE_FIND_TIME_VALID         = 9
    Const CAPICOM_CERTIFICATE_FIND_TIME_NOT_YET_VALID = 10
    Const CAPICOM_CERTIFICATE_FIND_TIME_EXPIRED       = 11
    Const CAPICOM_CERTIFICATE_FIND_KEY_USAGE          = 12    
    
    Select Case UCase(sStoreLocation)
        Case "MEMORY","MEM","FILE"  'FILE?
            sStoreLocation = CAPICOM_MEMORY_STORE
        Case "LM","LOCALMACHINE","LOCAL MACHINE","LOCAL_MACHINE","COMPUTER"
            sStoreLocation = CAPICOM_LOCAL_MACHINE_STORE
        Case "CU","CURRENT","CURRENT USER","CURRENT_USER"
            sStoreLocation = CAPICOM_CURRENT_USER_STORE
        Case "AD","ACTIVEDIRECTORY","ACTIVE DIRECTORY","ACTIVE_DIRECTORY"
            sStoreLocation = CAPICOM_ACTIVE_DIRECTORY_USER_STORE
        Case "SC","SMARTCARD","SMART CARD","SMART_CARD"
            sStoreLocation = CAPICOM_SMART_CARD_USER_STORE
        Case Else
            sStoreLocation = CAPICOM_CURRENT_USER_STORE
    End Select

    Select Case UCase(sContainerName)
        Case "MY","MINE","PERSONAL"
            sContainerName = MY
        Case "CA"
            sContainerName = CA
        Case "ROOT","TRUSTEDROOT","TRUSTED ROOT","TRUSTED_ROOT"
            sContainerName = ROOT
        Case "ADDRESSBOOK","ADDRESS","ADDRESS BOOK","ADDRESS_BOOK"
            sContainerName = ADDRESSBOOK
        Case Else
            sContainerName = MY
    End Select

    Set oCapicomStore = CreateObject("CAPICOM.Store")
    oCapicomStore.Open sStoreLocation, sContainerName, CAPICOM_STORE_OPEN_MAXIMUM_ALLOWED OR CAPICOM_STORE_OPEN_EXISTING_ONLY
    Set cCertificates = oCapicomStore.Certificates.Find(CAPICOM_CERTIFICATE_FIND_SHA1_HASH, sSha1Hash)
    
    For Each oCert In cCertificates
        'oCert.PrivateKey.Delete  'CAREFUL!!! This will delete the private key of the selected certificates!!!
        oCapicomStore.Remove oCert
    Next
    
    If Err.Number = 0 Then RemoveCertificate = True Else RemoveCertificate = False
 
    Set cCertificates = Nothing
    Set oCapicomStore = Nothing
End Function





