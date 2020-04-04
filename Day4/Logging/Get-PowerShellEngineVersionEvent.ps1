############################################################################
#.SYNOPSIS
# Get Windows PowerShell launch events with engine version.
#
#.DESCRIPTION
# Windows PowerShell 2.0 should no longer be used for security reasons.
# The event log named "Windows PowerShell" records event ID 400 as new
# instances are created, and these events include the version of the
# PowerShell "engine" DLL loaded for that instance.  This script outputs
# these events with the EngineVersion extracted as a property.  This
# can be used to query what version(s) of Windows PowerShell are being
# used.
############################################################################

Param ($ComputerName = "$env:ComputerName", $MaxEvents = 1000)


Get-WinEvent -LogName 'Windows PowerShell' -FilterXPath '*[System[(EventID=400)]]' -MaxEvents $MaxEvents -ComputerName $ComputerName |
ForEach `
{ 
    $Output = '' | Select-Object MachineName,TimeCreated,EngineVersion

    $Output.MachineName = $_.MachineName
    $Output.TimeCreated = $_.TimeCreated
    $Match = Select-String -InputObject $_.Message -Pattern 'EngineVersion=([0-9\.]+)' 

    $Output.EngineVersion = $Match.Matches[0].Value.Replace('EngineVersion=','')
    $Output #| Where { $_.EngineVersion -notlike '5.1.*' } 
}

