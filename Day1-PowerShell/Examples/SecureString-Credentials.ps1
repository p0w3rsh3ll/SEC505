# Script demonstrates how to obtain the plaintext password
# from a "secure string" created for you on this machine.


# Dialog box appears, asking for the username and password:
$Creds = Get-Credential		  


# Do something useful with the creds:
$Sess = New-CimSession -ComputerName localhost -Credential $Creds
Get-CimInstance -Query "SELECT * FROM Win32_BIOS" -CimSession $Sess



# Show the so-called secure string password in plaintext:
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Creds.password)
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)


