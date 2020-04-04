<#
.SYNOPSIS
Lists of potentially suspicious keywords in PowerShell logs.

.NOTES
Every typo or error in these lists is mine, everything good
or useful here comes from Sean Metcalf's 2015 article on
detecting PowerShell abuse.  His blog articles and company 
are highly recommended: 

       Blog: https://adsecurity.org
    Company: https://trimarcsecurity.com
    Twitter: @PyroTek3

If a keyword is pointless, in the wrong list, or causes too
many false positives, please assume it was probably not in
Sean's original list but was added later by me.

The $AllKeyWords array is created at the end of the script.
#>

#Region Constants
$ConstantKeywords = @'
IMAGE_NT_OPTIONAL_HDR64_MAGIC
LSA_UNICODE_STRING
PAGE_EXECUTE_READ
SE_PRIVILEGE_ENABLED
SECURITY_DELEGATION
TOKEN_ADJUST_PRIVILEGES
TOKEN_ALL_ACCESS
TOKEN_ASSIGN_PRIMARY
TOKEN_DUPLICATE
TOKEN_ELEVATION
TOKEN_IMPERSONATE
TOKEN_INFORMATION_CLASS
TOKEN_PRIVILEGES
TOKEN_QUERY
'@ -Split "`n" | ForEach { $_.Trim() } | Where { $_.Length -gt 0 } 
#EndRegion


#Region Assemblies
$AssemblyKeywords = @'
AdjustTokenPrivileges
Advapi32.dll
GetDelegateForFunctionPointer
Groups.User.Properties.cpassword
KerberosRequestorSecurityToken
kernel32.dll
Management.Automation.RuntimeException
Metasploit
Microsoft.Win32.UnsafeNativeMethods
MiniDumpWriteDump
msvcrt.dll
Net.Sockets.SocketFlags
ntdll.dll
ReadProcessMemory.Invoke
Reflection.Assembly
Runtime.InteropServices
ScheduledTasks.Task.Properties.cpassword
secur32.dll
System.Management.Automation.WindowsErrorReporting
System.MulticastDelegate
System.Reflection.AssemblyNam
System.Reflection.AssemblyName
System.Reflection.CallingConventions
System.Reflection.Emit.AssemblyBuilderAccess
System.Reflection.Emit.AssemblyBuilderAccess 
System.Runtime.InteropServices
System.Runtime.InteropServices.MarshalAsAttribute
System.Security.Cryptography
System.Security.Cryptography.AesCryptoServiceProvider
user32.dll
'@ -Split "`n" | ForEach { $_.Trim() } | Where { $_.Length -gt 0 } 
#EndRegion


#Region Modules
$ModuleKeywords = @'
Code Execution
Collection
Credentials
Exfiltration
Exploitation
Lateral Movement
Management
Persistence
Privilege Escalation
Recon
Situational Awareness
Trollsploit
'@ -Split "`n" | ForEach { $_.Trim() } | Where { $_.Length -gt 0 } 
#EndRegion


#Region Commands
$CommandKeywords = @'
Add-Exfiltration
Add-ObjectACL
Add-Persistence
Add-RegBackdoor
Add-ScrnSaveBackdoor
Check-VM
Copy-VSS
Do-Exfiltration
Enabled-DuplicateToken
Exploit-Jboss
Find-Fruit
Find-GPOLocation
Find-TrustedDocuments
Get-ApplicationHost
Get-ChromeDump
Get-ClipboardContents
Get-ComputerDetails
Get-FoxDump
Get-GPPPassword
Get-GPPPassword.ps1
Get-IndexedItem
Get-Information
Get-Keystrokes
Get-Keystrokes.ps1
Get-LSASecret
Get-MapDomainTrust
Get-NetDomainTrust
Get-NetForest
Get-NetForestDomain
Get-NetForestTrust
Get-NetGPOGroup
Get-NetGroup
Get-NetGroupMember
Get-NetLocalGroup
Get-NetOU
Get-NetSession
Get-NetUser
Get-ObjectACL
Get-PassHashes
Get-RegAlwaysInstallElevated
Get-RegAutoLogon
Get-RickAstley
Get-Screenshot
Get-SecurityPackages
Get-ServiceFilePermission
Get-ServicePermission
Get-ServiceUnquoted
Get-SiteListPassword
Get-SPN
Get-System
Get-SystemDNSServer
Get-TimedScreenshot.ps1
Get-UnattendedInstallFile
Get-Unconstrained
Get-VaultCredential
Get-VaultCredential.ps1
Get-VulnAutoRun
Get-VulnSchTask
Get-WebConfig
Gupt-Backdoor
HTTP-Login
Install-ServiceBinary
Install-SSP
Invoke-ACLScanner
Invoke-ADSBackdoor
Invoke-ARPScan
Invoke-BackdoorLNK
Invoke-BypassUAC
Invoke-CredentialInjection.ps1
Invoke-DCSync
Invoke-DllInjection
Invoke-DllInjection.ps1
Invoke-DowngradeAccount
Invoke-EgressCheck
Invoke-Inveigh
Invoke-InveighRelay
Invoke-Mimikatz
Invoke-Mimikatz.ps1
Invoke-NetRipper
Invoke-NinjaCopy
Invoke-NinjaCopy.ps1
Invoke-Paranoia
Invoke-PortScan
Invoke-PoshRatHttp
Invoke-PostExfil
Invoke-PowerDump
Invoke-PowerShellTCP
Invoke-PowerShellWMI
Invoke-PsExec
Invoke-PSInject
Invoke-PsUaCme
Invoke-ReflectivePEInjection
Invoke-ReflectivePEInjection.ps1
Invoke-ReverseDNSLookup
Invoke-RunAs
Invoke-ServiceAbuse
Invoke-ShellCode
Invoke-Shellcode.ps1
Invoke-SMBScanner
Invoke-SSHCommand
Invoke-Tater
Invoke-ThunderStruck
Invoke-TokenManipulation
Invoke-TokenManipulation.ps1
Invoke-UserHunter
Invoke-VoiceTroll
Invoke-WinEnum
Invoke-WmiCommand.ps1
Invoke-WScriptBypassUAC
MailRaider
New-HoneyHash
Out-Minidump
Out-Minidump.ps1
Port-Scan
PowerBreach
PowerUp
PowerView
Remove-Update
Set-MacAttribute
Set-Wallpaper
Show-TargetScreen
Start-CaptureServer
VolumeShadowCopyTools.ps1
'@ -Split "`n" | ForEach { $_.Trim() } | Where { $_.Length -gt 0 } 
#EndRegion



# The lists can be easily combined if necessary (slow performance on large arrays):
$AllKeyWords = $ConstantKeywords += $AssemblyKeywords += $ModuleKeywords += $CommandKeywords 



<# 
# Help weed out potential false positive triggers:
$BuiltInCommands = Get-Command -CommandType All | Select-Object -ExpandProperty Name
foreach ($cmd in $AllKeyWords){ if ($BuiltInCommands -contains $cmd){ $cmd } } 

#>


