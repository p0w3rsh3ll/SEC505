<#
.SYNOPSIS
    Creates a new TPM virtual smart card.

.DESCRIPTION
    Windows 8.0 and later can use a TPM chip to implement a virtual smart card.
    TPM must be version 1.2, 2.0, or later. Up to 30 certificates may be stored on
    one TPM.  A maximum of 10 smart cards may be connected to a single computer,
    whether physical or virtual; though there will be a performance penalty with 
    more than four cards. Script is just a wrapper for the built-in tpmvscmgr.exe.  

.PARAMETER UserPIN
    The user's smart card PIN.  Must be at least four characters long. The
    default is 1234.

.PARAMETER AdminPIN
    The user PIN unlock key (PUK) in case the user PIN is forgotten or in case
    the smart card is locked due to failed PIN attempts.  The AdminPIN (or PUK)
    must be at least eight characters long.  The default is 12345678.

.PARAMETER MinLengthUserPIN
    Minimum acceptable length of the UserPIN.  Must be at least 4 characters.
    The default is 4.

.PARAMETER MaxLengthUserPIN
    Maximum acceptable length of the UserPIN.  Cannot be longer than 127 
    characters.  The default is 127.

.PARAMETER CloseWindow
    By default, the new PowerShell.exe window opened by the script to run the
    tpmvscmgr.exe tool will remain open after the TPM virtual smart card is created.
    Use the -CloseWindow switch to automatically close this PowerShell window.

.NOTES
    The user PIN can be any standard printable ASCII character, not just numbers.
    When creating the virtual smart card, it is not unusual for the process to 
    require 40 to 90 seconds.  

    To see a C# and JavaScript sample applications to manage TPM smart cards:
    https://code.msdn.microsoft.com/windowsapps/Smart-card-sample-c7d342e0
    This would be preferable to these horked-up functions...  :-\  

    TODO: add admin key option, not just PUK; add remote computer option.

    Author: Enclave Consulting LLC, Jason Fossen (http://sans.org/sec505)
    Legal: Public domain, no rights reserved, provided "AS IS" without warranty.
    Version: 1.0
    Updated: 18.May.2017
#>
function New-TpmVirtualSmartCard 
{
    [CmdletBinding()]
    Param
    (
      [ValidateLength(4,127)][String] $UserPIN = '1234', 
      [ValidateLength(8,127)][String] $AdminPIN = '12345678', 
      [ValidateRange(4,127)] [Int] $MinLengthUserPIN = 4, 
      [ValidateRange(4,127)] [Int] $MaxLengthUserPIN = 127, 
      [Switch] $CloseWindow
    )


    # Confirm that tpmvscmgr.exe is present:
    if (-not (Test-Path -Path $env:WinDir\System32\tpmvscmgr.exe))
    { Write-Error -Message 'ERROR: Cannot find tpmvscmgr.exe' ; return }


    # Load .NET classes needed to send keystrokes to tpmvscmgr.exe:
    [void] [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    if (-not $?){ Write-Error -Message 'ERROR: Could not load Microsoft.VisualBasic' ; return } 
    
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') 
    if (-not $?){ Write-Error -Message 'ERROR: Could not load System.Windows.Forms' ; return } 


    # Construct the commands to be run in powershell.exe and convert to base64 string:    
    $tickytitle = 'TPM Virtual Smart Card ' + (Get-Date).Ticks 
    [String[]] $cmds = '$Host.UI.RawUI.WindowTitle = "' + $tickytitle + '"'
    $cmds += "$env:WinDir\System32\tpmvscmgr.exe create /name 'VirtualSmartCard' /pin prompt /puk prompt /adminkey random /pinpolicy minlen " + $MinLengthUserPIN + " maxlen " + $MaxLengthUserPIN + " /generate" 
    $bytes = [System.Text.Encoding]::Unicode.GetBytes(($cmds -join ' ; '))
    $encodedCommand = [Convert]::ToBase64String($bytes)


    # Launch a separate powershell.exe window and send commands:
    if ($CloseWindow){ $ArgList = '-nologo -noprofile -windowstyle normal -encodedcommand ' + $encodedCommand } 
    else { $ArgList = '-nologo -noexit -noprofile -windowstyle normal -encodedcommand ' + $encodedCommand }
    Start-Process -FilePath 'powershell.exe' -ArgumentList $ArgList


    # Wait for the new powershell process to be ready, but don't wait too long:
    $i = 20
    do 
    { 
        $posh = $null
        Start-Sleep -Milliseconds 100 
        $posh = Get-Process -Name powershell | where { $_.MainWindowTitle -eq $tickytitle } 
        $i-- 
    }
    while ( ($i -gt 0) -and ($posh -ne $null) )

    
    # Confirm that we just didn't time out while waiting:
    if ($i -eq 0)
    { Write-Error -Message 'ERROR: Could not launch a new powershell window' ; return } 


    # Send keystrokes to the new powershell windows to enter PIN and PUK:
    Start-Sleep -Milliseconds 500
    [Microsoft.VisualBasic.Interaction]::AppActivate($tickytitle)  
    [System.Windows.Forms.SendKeys]::SendWait([String]($UserPIN + "{ENTER}")) #First PIN
    Start-Sleep -Milliseconds 200
    [Microsoft.VisualBasic.Interaction]::AppActivate($tickytitle)  
    [System.Windows.Forms.SendKeys]::SendWait([String]($UserPIN + "{ENTER}")) #Confirm PIN
    Start-Sleep -Milliseconds 200
    [Microsoft.VisualBasic.Interaction]::AppActivate($tickytitle)  
    [System.Windows.Forms.SendKeys]::SendWait([String]($AdminPIN + "{ENTER}")) #First PUK
    Start-Sleep -Milliseconds 200
    [Microsoft.VisualBasic.Interaction]::AppActivate($tickytitle)  
    [System.Windows.Forms.SendKeys]::SendWait([String]($AdminPIN + "{ENTER}")) #Confirm PUK

}




<#
.SYNOPSIS
  Lists the ID strings of all TPM virtual smart cards.

.NOTES
  The Remove-TpmVirtualSmartCard function takes these ID
  strings as arguments.  These virtual smart cards can
  also be seen in Device Manager. 
#>
function Get-TpmVirtualSmartCardID
{
    $regPath = 'HKLM:\system\CurrentControlSet\Control\DeviceClasses\{50dd5230-ba8a-11d1-bf5d-0000f805f530}'

    if (-not (Test-Path -Path $regPath)){ return } 

    dir -Path $regPath | ForEach `
    {
        $name = ($_.pschildname -split '{')[0]
        $name = $name -replace '##\?#',''
        $name = $name.Substring(0, $($name.length - 1))
        $name = $name.Replace('#','\')
        $name
    }
}






<#
.SYNOPSIS
  Removes one or all TPM virtual smart cards.

.PARAMETER ID
  The ID string of the virtual smart card.  The default value
  is 'ROOT\SMARTCARDREADER\0000', which is the default first card.

.PARAMETER RemoveAll
  Removes all TPM virtual smart cards.

.NOTES
  The -RemoveAll switch uses and requires the Get-TpmVirtualSmartCardID function.
  There is no prompting to confirm the deletion.  Deleting a virtual smart card
  also permanently deletes all the certificates and keys in that card.
#>
function Remove-TpmVirtualSmartCard ( $ID = 'ROOT\SMARTCARDREADER\0000', [Switch] $RemoveAll )
{
    if (-not (Test-Path -Path "$env:WinDir\System32\tpmvscmgr.exe"))
    { Write-Error -Message 'ERROR: Cannot find tpmvscmgr.exe' ; return } 

    if ($RemoveAll)
    { Get-TpmVirtualSmartCardID | Foreach { tpmvscmgr.exe destroy /instance $_ } }
    else
    { tpmvscmgr.exe destroy /instance $ID } 
}


