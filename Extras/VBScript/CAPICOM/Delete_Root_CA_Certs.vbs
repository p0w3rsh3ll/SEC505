'*****************************************************
' Script Name: Delete_Root_CA_Certs.vbs
'     Version: 2.0
'      Author: Jason Fossen, Enclave Consulting LLC
'Last Updated: 20.Feb.2004
'     Purpose: Deletes root CA certificates from the computer's Trusted Root CA Store.
'              Once deleted, the computer will no longer trust the root CA unless
'              it is added to user's own personal root CA store.
'       Notes: This function requires that CAPICOM.DLL version 2.0+ be registered on the
'              the machine with "regsvr32.exe capicom.dll".  The DLL can be
'              downloaded for free from Microsoft if not present on machine:
'              http://msdn.microsoft.com/library/en-us/security/security/capicom_versions.asp?frame=true
'       Usage: Edit script to add the key for the root CA cert(s) you want deleted,
'              if it's not on the lsit, then distribute the script with Group Policy And
'              make it a shutdown or startup script.
'       Notes: Special thanks to Aaron Hardwick (Hydrogenics Corp) for the CA names in the comments below.
'	    Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'              This script is provided "AS IS" without warranty or guarantees.
'*****************************************************
On Error Resume Next

'The following is a list of most of the root CA hash numbers.
'Comment out any lines for the certs you do *NOT* want to delete.
'UNcommented lines are for CA certs you *DO* want to delete.

sCertKeys = ""  
sCertKeys = sCertKeys & "4EF2E6670AC9B5091FE06BE0E5483EAAD6BA32D9:"   'Belgacom E-Trust Primary CA
'sCertKeys = sCertKeys & "0048F8D37B153F6EA2798C323EF4F318A5624A9E:"  'Certisign Autoridade Certificadora AC1S
'sCertKeys = sCertKeys & "00EA522C8A9C06AA3ECCE0B4FA6CDC21D92E8099:"  'Japan Certification Services, Inc. SecureSign RootCA2
'sCertKeys = sCertKeys & "0483ED3399AC3608058722EDBC5E4600E3BEF9D7:"  'UTN - USERFirst-Hardware
'sCertKeys = sCertKeys & "049811056AFE9FD0F5BE01685AACE6A5D1C4454C:"  'VeriSign Class 1 Primary CA
'sCertKeys = sCertKeys & "0B77BEBBCB7AA24705DECC0FBD6A02FC7ABD9B52:"  'VeriSign Class 4 Primary CA
'sCertKeys = sCertKeys & "1331F48A5DA8E01DAACA1BB0C17044ACFEF755BB:"  'Swisskey Root CA
'sCertKeys = sCertKeys & "18F7C1FCC3090203FD5BAA2F861A754976C8DD25:"  'VeriSign Time Stamping CA
'sCertKeys = sCertKeys & "1F55E8839BAC30728BE7108EDE7B0BB0D3298224:"  'Saunalahden Serveri CA
'sCertKeys = sCertKeys & "209900B63D955728140CD13622D8C687A4EB0085:"  'Thawte Personal Freemail CA
'sCertKeys = sCertKeys & "216B2A29E62A00CE820146D8244141B92511B279:"  'CertPlus Class 3P Primary CA
'sCertKeys = sCertKeys & "23E594945195F2414803B4D564D2A3A3F5D88B8C:"  'Thawte Server CA
'sCertKeys = sCertKeys & "245C97DF7514E7CF2DF8BE72AE957B9E04741E85:"  'Microsoft Timestamp Root
'sCertKeys = sCertKeys & "24A40A1F573643A67F0A4B0749F6A22BF28ABB6B:"  'VeriSign Commercial Software Publishers CA (the one used to issue the fraudulent software publisher's certs (Q293817)) Caution: Very many legitimate publishers' certs are subordinate to this cert.
'sCertKeys = sCertKeys & "24BA6D6C8A5B5837A48DB5FAE919EA675C94D217:"  'IPS SERVIDORES
'sCertKeys = sCertKeys & "273EE12457FDC4F90C55E82B56167F62F532E547:"  'VeriSign Class 1 Primary CA
'sCertKeys = sCertKeys & "284F55C41A1A7A3F8328D4C262FB376ED6096F24:"  'Certiposte Serveur
'sCertKeys = sCertKeys & "2F173F7DE99667AFA57AF80AA2D1B12FAC830338:"  'GlobalSign Root CA
'sCertKeys = sCertKeys & "317A2AD07F2B335EF5A1C34E4B57E8B7D8F1FCA6:"  'ValiCert Class 2 Policy Validation Authority
'sCertKeys = sCertKeys & "36863563FD5128C7BEA6F005CFE9B43668086CCE:"  'Thawte Personal Premium CA
'sCertKeys = sCertKeys & "394FF6850B06BE52E51856CC10E180E882B385CC:"  'Equifax Secure eBusiness CA-2
'sCertKeys = sCertKeys & "3F85F2BB4A62B0B58BE1614ABB0D4631B4BEF8BA:"  'VeriSign Class 4 Primary CA
'sCertKeys = sCertKeys & "4072BA31FEC351438480F62E6CB95508461EAB2F:"  'First Data Digital Certificates Inc. Certification Authority
'sCertKeys = sCertKeys & "40E78C1D523D1CD9954FAC1A1AB3BD3CBAA15BFC:"  'Thawte Personal Basic CA
'sCertKeys = sCertKeys & "43DDB1FFF3B49B73831407F6BC8B975023D07C50:"  'FESTE, Public Notary Certs
'sCertKeys = sCertKeys & "43F9B110D5BAFD48225231B0D0082B372FEF9A54:"  'Fabrica Nacional de Moneda y Timbre
'sCertKeys = sCertKeys & "4463C531D7CCC1006794612BB656D3BF8257846F:"  'VeriSign/RSA Secure Server CA
'sCertKeys = sCertKeys & "46B00C8EDD3E66CCA6F1207E1F9E6F5549CA77E5:"  'NOT INSTALLED
'sCertKeys = sCertKeys & "47AFB915CDA26D82467B97FA42914468726138DD:"  'CW HKT SecureNet CA Class B
'sCertKeys = sCertKeys & "4B421F7515F6AE8A6ECEF97F6982A400A4D9224E:"  'Societa Interbancaria per l'Automazione SIA Secure Client CA
'sCertKeys = sCertKeys & "4BA7B9DDD68788E12FF852E1A024204BF286A8F6:"  'CW HKT SecureNet CA Root
'sCertKeys = sCertKeys & "4C95A9902ABE0777CED18D6ACCC3372D2748381E:"  'Saunalahden Serveri CA 
'sCertKeys = sCertKeys & "4EFCED9C6BDD0C985CA3C7D253063C5BE6FC620C:"  'Certisign Autoridade Certificadora AC2
'sCertKeys = sCertKeys & "4F65566336DB6598581D584A596C87934D5F2AB4:"  'VeriSign Class 3 Primary CA
'sCertKeys = sCertKeys & "54F9C163759F19045121A319F64C2D0555B7E073:"  'Certisign Autoridade Certificadora AC4
'sCertKeys = sCertKeys & "58119F0E128287EA50FDD987456F4F78DCFAD6D4:"  'UTN - DATACorp SGC
'sCertKeys = sCertKeys & "5B4E0EC28EBD8292A51782241281AD9FEEDD4E4C:"  'EUnet International Root CA
'sCertKeys = sCertKeys & "5D989CDB159611365165641B560FDBEA2AC23EF1:"  'UTN - USERFirst-Network Applications
'sCertKeys = sCertKeys & "5E5A168867BFFF00987D0B1DC2AB466C4264F956:"  'Societa Interbancaria per l'Automazione SIA Secure Server CA
'sCertKeys = sCertKeys & "5E997CA5945AAB75FFD14804A974BF2AE1DFE7E1:"  'SecureNet CA Class A
'sCertKeys = sCertKeys & "627F8D7827656399D27D7F9044C9FEB3F33EFA9A:"  'Thawte Premium Server CA
'sCertKeys = sCertKeys & "6372C49DA9FFF051B8B5C7D4E5AAE30384024B9C:"  'KeyMail PTT Post Root CA
'sCertKeys = sCertKeys & "6782AAE0EDEEE21A5839D3C0CD14680A4F60142A:"  'VeriSign Class 2 Public Primary CA
'sCertKeys = sCertKeys & "67EB337B684CEB0EC2B0760AB488278CDD9597DD:"  'DST RootCA X2
'sCertKeys = sCertKeys & "687EC17E0602E3CD3F7DFBD7E28D57A0199A3F44:"  'SecureNet CA SGC Root
'sCertKeys = sCertKeys & "688B6EB807E8EDA5C7B17C4393D0795F0FAE155F:"  'VeriSign Commercial Software Publishers CA (expired - not used to create fraudulent certs)
'sCertKeys = sCertKeys & "68ED18B309CD5291C0D3357C1D1141BF883866B1:"  'Xcert EZ by DST
'sCertKeys = sCertKeys & "69BD8CF49CD300FB592E1793CA556AF3ECAA35FB:"  'ValiCert Class 3 Policy Validation Authority
'sCertKeys = sCertKeys & "6A174570A916FBE84453EED3D070A1D8DA442829:"  'CertPlus Class 1 Primary CA
'sCertKeys = sCertKeys & "720FC15DDC27D456D098FABF3CDD78D31EF5A8DA:"  'TC TrustCenter Class 1 C
'sCertKeys = sCertKeys & "74207441729CDD92EC7931D823108DC28192E2BB:"  'CertPlus Class 2 Primary CA
'sCertKeys = sCertKeys & "742C3192E607E424EB4549542BE1BBC53E6174E2:"  'VeriSign Class 3 Public Primary CA
'sCertKeys = sCertKeys & "7639C71847E151B5C7EA01C758FBF12ABA298F7A:"  'DST (ANX Network) CA
'sCertKeys = sCertKeys & "78E9DD0650624DB9CB36B50767F209B843BE15B3:"  'VeriSign Class 1 Primary CA
'sCertKeys = sCertKeys & "7A74410FB0CD5C972A364B71BF031D88A6510E9E:"  'DST (ABA.ECOM) CA
'sCertKeys = sCertKeys & "7AC5FFF8DCBC5583176877073BF751735E9BD358:"  'SecureNet CA Class B
'sCertKeys = sCertKeys & "7CA04FD8064C1CAA32A37AA94375038E8DF8DDC0:"  'SecureNet CA Root
'sCertKeys = sCertKeys & "7E784A101C8265CC2DE1F16D47B440CAD90A1945:"  'Equifax Secure Global eBusiness CA-1
'sCertKeys = sCertKeys & "7F88CD7223F3C813818C994614A89C99FA3B5247:"  'Microsoft Authenticode(tm) Root
'sCertKeys = sCertKeys & "81968B3AEF1CDC70F5FA3269C292A3635BD123D3:"  'DSTCA E1
'sCertKeys = sCertKeys & "838E30F77FDD14AA385ED145009C0E2236494FAA:"  'TC TrustCenter Class 2 CA
'sCertKeys = sCertKeys & "85371CA6E550143DCE2803471BDE3A09E8F8770F:"  'VeriSign Class 3 Primary CA
'sCertKeys = sCertKeys & "85A408C09C193E5D51587DCDD61330FD8CDE37BF:"  'Deutsche Telekom Root CA 2
'sCertKeys = sCertKeys & "879F4BEE05DF98583BE360D633E70D3FFE9871AF:"  'NetLock Uzleti (Class B) Tanusitvanykiado
'sCertKeys = sCertKeys & "8EB03FC3CF7BB292866268B751223DB5103405CB:"  'Japan Certification Services, Inc. SecureSign RootCA3
'sCertKeys = sCertKeys & "9078C5A28F9A4325C2A7C73813CDFE13C20F934E:"  'SERVICIOS DE CERTIFICACION - A.N.C.
'sCertKeys = sCertKeys & "90AEA26985FF14804C434952ECE9608477AF556F:"  'VeriSign Class 1 Public Primary CA
'sCertKeys = sCertKeys & "90DEDE9E4C4E9F6FD88617579DD391BC65A68964:"  'GTE CyberTrust Root
'sCertKeys = sCertKeys & "96974CD6B663A7184526B1D648AD815CF51E801A:"  'VeriSign Individual Software Publishers CA
'sCertKeys = sCertKeys & "97817950D81C9670CC34D809CF794431367EF474:"  'GTE CyberTrust Global Root
'sCertKeys = sCertKeys & "97E2E99636A547554F838FBA38B82E74F89A830A:"  'VeriSign Class 3 Primary CA
'sCertKeys = sCertKeys & "99A69BE61AFE886B4D2B82007CB854FC317E1539:"  'Entrust.net Secure Server Certification Authority
'sCertKeys = sCertKeys & "9BACF3B664EAC5A17BED08437C72E4ACDA12F7E7:"  'CW HKT SecureNet CA Class A
'sCertKeys = sCertKeys & "9E6CEB179185A29EC6060CA53E1974AF94AF59D4:"  'Deutsche Telekom Root CA 1
'sCertKeys = sCertKeys & "9FC796E8F8524F863AE1496D381242105F1B78F5:"  'TC TrustCenter Class 3 CA
'sCertKeys = sCertKeys & "A399F76F0CBF4C9DA55E4AC24E8960984B2905B6:"  'TC TrustCenter Time Stamping CA
'sCertKeys = sCertKeys & "A3E31E20B2E46A328520472D0CDE9523E7260C6D:"  'DST (Baltimore EZ) CA
'sCertKeys = sCertKeys & "A43489159A520F0D93D032CCAF37E7FE20A8B419:"  'Microsoft Root Authority
'sCertKeys = sCertKeys & "A5EC73D48C34FCBEF1005AEB85843524BBFAB727:"  'VeriSign Class 2 Primary CA
'sCertKeys = sCertKeys & "AB48F333DB04ABB9C072DA5B0CC1D057F0369B46:"  'DSTCA E2
'sCertKeys = sCertKeys & "ACED5F6553FD25CE015F1F7A483B6A749F6178C6:"  'NetLock Kozjegyzoi (Class A) Tanusitvanykiado
'sCertKeys = sCertKeys & "B172B1A56D95F91FE50287E14D37EA6A4463768A:"  'UTN - USERFirst-Client Authentication and Email
'sCertKeys = sCertKeys & "B19DD096DCD4E3E0FD676885505A672C438D4E9C:"  'VeriSign Individual Software Publishers CA
'sCertKeys = sCertKeys & "B3EAC44776C9C81CEAF29D95B6CCA0081B67EC9D:"  'VeriSign Class 2 Primary CA
'sCertKeys = sCertKeys & "B5D303BF8682E152919D83F184ED05F1DCE5370C:"  'ViaCode Certification Authority
'sCertKeys = sCertKeys & "B6AF5BE5F878A00114C3D7FEF8C775C34CCD17B6:"  'Autoridad Certificadora de la Asociacion Nacional del Notariado
'sCertKeys = sCertKeys & "B72FFF92D2CE43DE0A8D4C548C503726A81E2B93:"  'DST RootCA X1
'sCertKeys = sCertKeys & "BC9219DDC98E14BF1A781F6E280B04C27F902712:"  'DST-Entrust GTI CA
'sCertKeys = sCertKeys & "BE36A4562FB2EE05DBB3D32323ADF445084ED656:"  'Thawte Timestamping CA
'sCertKeys = sCertKeys & "CABB51672400588E6419F1D40878D0403AA20264:"  'Japan Certification Services, Inc. SecureSign RootCA1
'sCertKeys = sCertKeys & "CFDEFE102FDA05BBE4C78D2E4423589005B2571D:"  'DST (National Retail Federation) RootCA
'sCertKeys = sCertKeys & "CFF360F524CB20F1FEAD89006F7F586A285B2D5B:"  'VeriSign Class 2 Primary CA
'sCertKeys = sCertKeys & "CFF810FB2C4FFC0156BFE1E1FABCB418C68D31C5:"  'Certisign Autoridade Certificadora AC3S
'sCertKeys = sCertKeys & "D23209AD23D314232174E40D7F9D62139786633A:"  'Equifax Secure Certificate Authority
'sCertKeys = sCertKeys & "D29F6C98BEFC6D986521543EE8BE56CEBC288CF3:"  'TC TrustCenter Class 4 CA
'sCertKeys = sCertKeys & "D2EDF88B41B6FE01461D6E2834EC7C8F6C77721E:"  'CertPlus Class 3 Primary CA
'sCertKeys = sCertKeys & "DA40188B9189A3EDEEAEDA97FE2F9DF5B7D18A41:"  'Equifax Secure eBusiness CA-1
'sCertKeys = sCertKeys & "DBAC3C7AA4254DA1AA5CAAD68468CB88EEDDEEA8:"  'GTE CyberTrust Root
'sCertKeys = sCertKeys & "E12DFB4B41D7D9C32B30514BAC1D81D8385E2D46:"  'UTN - USERFirst-Object
'sCertKeys = sCertKeys & "E392512F0ACFF505DFF6DE067F7537E165EA574B:"  'NetLock Expressz (Class C) Tanusitvanykiado
'sCertKeys = sCertKeys & "E4554333CA390E128B8BF81D90B70F4002D1D6E9:"  'FESTE, Verified Certs
'sCertKeys = sCertKeys & "E5DF743CB601C49B9843DCAB8CE86A81109FE48E:"  'ValiCert Class 1 Policy Validation Authority
'sCertKeys = sCertKeys & "EBBC0E2D020CA69B222C2BFFD203CB8BF5A82766:"  'Certiposte Editeur
'sCertKeys = sCertKeys & "EC0C3716EA9EDFADD35DFBD55608E60A05D3CBF3:"  'DST (United Parcel Service) RootCA
'sCertKeys = sCertKeys & "EF2DACCBEABB682D32CE4ABD6CB90025236C07BC:"  'Autoridad Certificadora del Colegio Nacional de Correduria Publica Mexicana, A.C.
'sCertKeys = sCertKeys & "F44095C238AC73FC4F77BF8F98DF70F8F091BC52:"  'CertPlus Class 3TS Primary CA
'sCertKeys = sCertKeys & "F88015D3F98479E1DA553D24FD42BA3F43886AEF:"  'CW HKT SecureNet CA SGC Root
sCertKeys = sCertKeys & "TheEnd" 'Don't comment this line out.



'This is where you should check that the CAPICOM.DLL has been registered.
Err.Clear
Set oCapicomStore = CreateObject("CAPICOM.Store")
Set oCapicomStore = Nothing
If Err.Number <> 0 Then
    MsgBox "You have not registered the CAPICOM.DLL on this machine with REGSVR32.EXE. Quitting."
    WScript.Quit
    'Or try to register the DLL somehow, like map a drive letter to a share and
    'do it, or after you've copied it to the System32 folder, try something like:
        'Set oWshShell = WScript.CreateObject("WScript.Shell")
        'oWshShell.Run "%SystemRoot%\system32\regsvr32.exe capicom.dll /s"
End If



            
aCAkeys = Split(sCertKeys,":") 'Creates an array from the string, delimited by colons.
For Each sKeyHash In aCAkeys
    If Not sKeyHash="TheEnd" Then 
        bFlag = RemoveCertificate("LM","Root",sKeyHash) 
	End If
Next



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







'END OF SCRIPT ***************************************
