<#
This code is for running PowerShell commands from within the
KeePass password manager app (www.keepass.info) by double-click
the URL column for a KeePass entry (or Ctrl-U).  The password
field from the KeePass entry will be encrypted with DPAPI and
passed into a new PowerShell.exe process as a command-line arg.

In KeePass, paste the following into the URL field of an entry:
    cmd://powershell.exe -noexit -command "{NOTES}"

The Title field in the KeePass entry should be the PowerShell
command or script you want to run.  If the command requires a
PSCredential, then pass in the $creds variable (see below).

Then paste the following code into the Notes field of that entry:
#>


$username = '{USERNAME}';

$cipherbytes = [System.Convert]::FromBase64String( '{PASSWORD_ENC}' );

[System.Reflection.Assembly]::LoadWithPartialName("System.Security") | Out-Null;

#This variable from KeePass source code (\KeePassLib\Utility\StrUtil.cs);
[byte[]] $m_pbOptEnt = @(0xA5,0x74,0x2E,0xEC);

$plainbytes = [System.Security.Cryptography.ProtectedData]::Unprotect($cipherbytes, $m_pbOptEnt, 0);

$password = [System.Text.Encoding]::UTF8.GetString( $plainbytes );

$secstring = ConvertTo-SecureString -asPlainText -Force -String $password;

$password = $null; $plainbytes = $null;

$creds = New-Object System.Management.Automation.PSCredential($username, $secstring); 

{TITLE}



