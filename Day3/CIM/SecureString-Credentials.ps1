

$cred = Get-Credential		 # Dialog box appears... 

$s = New-CimSession -Credential $cred -ComputerName server3.testing.local 

Get-CimInstance -Query "Select * From Win32_BIOS" -CimSession $s

Get-CimClass -ClassName "Win32_Process" -CimSession $s





# The username can be displayed, but the password cannot:
$cred.username 
$cred.password 


# Show the password in plaintext on PoSh 1.0/2.0:
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.password)
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)


# Show the password in plaintext on PoSh 3.0+:
$cred.GetNetworkCredential().Password



