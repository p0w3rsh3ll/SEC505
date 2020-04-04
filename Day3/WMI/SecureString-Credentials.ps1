

$cred = get-credential		 # Dialog box appears... 
get-wmiobject -query "SELECT * FROM Win32_BIOS" -computer server3 -credential $cred



# Show the so-called secure string password in plaintext:

$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.password)
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

# The username can be displayed, but the password cannot:
$cred.username 
$cred.password 


# Unless you have PoSh 3.0+:
$cred.GetNetworkCredential().Password


