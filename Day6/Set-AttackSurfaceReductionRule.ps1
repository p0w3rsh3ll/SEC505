<#
.SYNOPSIS
 Set an action for all Attack Surface Reduction (ASR) rules.

.NOTES
 ASR rules are dangerous to enable because of false positives, see:
 https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/overview-attack-surface-reduction

 In the Windows Defender operations log, look for these event ID numbers:
    5007 	Settings are changed
    1121 	Rule blocked something
    1122 	Rule triggered in audit mode, nothing blocked
#> 



# The ASR rules in Windows 10 v1909:

$RulesASR = @{
'7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c' = 'Block Adobe Reader from creating child processes'
'D4F940AB-401B-4EFC-AADC-AD5F3C50688A' = 'Block all Office applications from creating child processes'
'9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2' = 'Block credential stealing from the Windows local security authority subsystem (lsass.exe)'
'BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550' = 'Block executable content from email client and webmail'
'01443614-cd74-433a-b99e-2ecdc07bfc25' = 'Block executable files from running unless they meet a prevalence, age, or trusted list criteria'
'5BEB7EFE-FD9A-4556-801D-275E5FFC04CC' = 'Block execution of potentially obfuscated scripts'
'D3E037E1-3EB8-44C8-A917-57927947596D' = 'Block JavaScript or VBScript from launching downloaded executable content'
'3B576869-A4EC-4529-8536-B80A7769E899' = 'Block Office applications from creating executable content'
'75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84' = 'Block Office applications from injecting code into other processes'
'26190899-1602-49e8-8b27-eb1d0a1ce869' = 'Block Office communication applications from creating child processes'
'e6db77e5-3df2-4cf1-b95a-636979351e5b' = 'Block persistence through WMI event subscription'
'd1e49aac-8f56-4280-b9ba-993a6d77406c' = 'Block process creations originating from PSExec and WMI commands'
'b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4' = 'Block untrusted and unsigned processes that run from USB'
'92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B' = 'Block Win32 API calls from Office macro'
'c1db55ab-c21a-4637-bb3f-a12568109d35' = 'Use advanced protection against ransomware'
}


###################################################
#
#  WARNING! DO NOT SET $ACTION TO 'Enabled' 
#  UNLESS YOU HAVE CREATED A SNAPSHOT OR
#  CHECKPOINT OF YOUR VIRTUAL MACHINE FIRST!
#
###################################################


# Choose your desired setting for all of the above rules.
# Options: AuditMode, Enabled, Disabled
$Action = 'AuditMode'   



# Need to create an array of your chosen $Action that is exactly
# the same size as $RulesASR:
[String[]] $ActionArray = @()
1..$($RulesASR.Count) | ForEach { $ActionArray += $Action } 



# Sanity check:
if ($RulesASR.Count -ne $ActionArray.Count)
{ throw "These two arrays must be the same size" }



# With one command, all existing ASR rules, if any, are overwritten with an
# array of the rules you wish to have ($RulesASR.Keys) matched with a same-sized
# array with the desired $Action for each of these rules:

Set-MpPreference -AttackSurfaceReductionRules_Ids $RulesASR.Keys -AttackSurfaceReductionRules_Actions $ActionArray 


# Set-MpPreference overwrites the existing rules. To only add a rule, 
# use Add-MpPreference instead. 

