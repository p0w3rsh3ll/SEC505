###############################################################################
#
#"[+] Disabling Windows Defender..."
#
###############################################################################

$wd = $null 
$wd = Get-Command -Name 'Set-MpPreference' -ErrorAction SilentlyContinue

if ($wd)
{ 
    Set-MpPreference -DisableRealtimeMonitoring $True -Force
    Set-MpPreference -DisableBehaviorMonitoring $True -Force
    Set-MpPreference -ExclusionPath @('C:\SANS','C:\Temp','D:\') -Force 
    Set-MpPreference -ScanScheduleDay Never -Force
    Set-MpPreference -RemediationScheduleDay Never -Force
} 

