#############################################################################
#.SYNOPSIS
# Decrypts protected event log messages with Unprotect-CmsMessage.
#
#.NOTES
# When piping encrypted event log messages through Unprotect-CmsMessage, 
# only the plaintext of the body of the message is returned, not the
# entire original message object with all of its properties, hence, a
# wrapper script like this is necessary to retain those other properties.
# The performance of Add-Member and Unprotect-CmsMessage is not good.
#############################################################################

[CmdletBinding()]
Param (
       [String] $ComputerName = $env:COMPUTERNAME, 
       [String] $LogName = 'Microsoft-Windows-PowerShell/Operational', 
       [Int] $EventID = 4104,
       [Int] $MaxEvents = 10
      )


$XPath = '*[System[(EventID=' + $EventID + ')]]'

Get-WinEvent -ComputerName $ComputerName -LogName $LogName -FilterXPath $XPath -MaxEvents $MaxEvents |
ForEach { 
    if ($_.Message.IndexOf('-----BEGIN CMS-----') -ne -1)
    { 
        Write-Verbose ("Encrypted: " + $_.RecordID)
        Add-Member -PassThru -InputObject $_ -NotePropertyName 'Plaintext' -NotePropertyValue $($_.Message | Unprotect-CmsMessage -IncludeContext) 
    }
    else
    {
        Write-Verbose ("Plaintext: " + $_.RecordID)
        $_
    }
}

