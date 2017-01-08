

$cred = get-credential		 # Dialog box appears... 
get-wmiobject -query "SELECT * FROM Win32_BIOS" -computer server3 -credential $cred



# Show the so-called secure string password in plaintext:

$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.password)
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

