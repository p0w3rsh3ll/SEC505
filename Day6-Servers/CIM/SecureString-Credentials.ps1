

$cred = Get-Credential		 # Dialog box appears... 

$s = New-CimSession -Credential $cred -ComputerName server3.testing.local 

Get-CimInstance -Query "Select * From Win32_BIOS" -CimSession $s

Get-CimClass -ClassName "Win32_Process" -CimSession $s





# Show the so-called secure string password in plaintext:

$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.password)
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)


# The username can be displayed, but the password cannot:
$cred.username 
$cred.password 

# Unless you have PoSh 3.0+:
$cred.GetNetworkCredential().Password



