#############################################################################
#.SYNOPSIS
# Get process creation events, EventID 4688 from the Security log.
#.NOTES
# To audit process creation events:
#     auditpol.exe /set /Subcategory:"Process Creation" /success:enable /failure:enable
# By default, command-line arguments are not logged, to enable:
#     Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit' -Name 'ProcessCreationIncludeCmdLine_Enabled' -Value 0x1
#############################################################################


Param ($ComputerName = $env:COMPUTERNAME, $MaxEvents = 10)

$Output = '' | Select-Object MachineName,TimeCreated,Account,Command

Get-WinEvent -ComputerName $ComputerName -LogName Security `
-FilterXPath '*[System[(EventID=4688)]]' -MaxEvents $MaxEvents |
ForEach `
{ 
    $Output.MachineName = $_.MachineName.ToLower() 
    $Output.TimeCreated = $_.TimeCreated
    $Output.Account = ($_.Properties[2].Value + "\" + $_.Properties[1].Value)
    $Output.Command = $_.Properties[8].Value
    $Output 
}


