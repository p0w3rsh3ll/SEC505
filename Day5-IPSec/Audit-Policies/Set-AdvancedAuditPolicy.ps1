<################################################################################
.SYNOPSIS
  Overwrites current advanced audit policies with policies in this script.

.DESCRIPTION
  Microsoft periodically updates and publishes a spreadsheet of recommended
  audit policies for various operating systems.  Subscribe to the RSS feed here:

      http://blogs.technet.com/b/secguide/rss.aspx
  
  Or search Microsoft's web site for "Microsoft Security Compliance Toolkit"
  for the latest download URL.  

  This script sets the audit policies as recommended for Windows 10 and 
  Windows Server 2016, but feel free to edit the $AuditPolicyList variable
  to change the advanced audit policies which are applied.  The script can be
  run on older systems too.  The script is just a wrapper for auditpol.exe.    

  WARNING: This script disables all audit policies first, then only enables
  the audit policies defined in this script.  This script does not append to
  the existing policies, it overwrites all existing audit policies.

.PARAMETER DisableAllAuditPolicies
  Disables all audit policies and exits.  No audit policies will be enabled.
  Current audit policies are not backed up.  Run "auditpol.exe /backup /?"
  to see how to export the current audit policies to a CSV file.  

.PARAMETER ShowCurrentPolicies
  Displays current advanced audit policies only.  Nothing is changed.

.PARAMETER ShowCommands
  Displays auditpol.exe commands as they are being run.

.NOTES
    Legal: Public domain, no rights reserved, provided "AS IS" without warranties.
   Course: SANS SEC505: Securing Windows and PowerShell Automation
 SANS URL: https://www.sans.org/sec505
   Author: Jason Fossen, Enclave Consulting LLC
  Created: 16.Jul.2017
  Updated: 18.Jul.2017 
################################################################################>

Param ( [Switch] $DisableAllAuditPolicies, [Switch] $ShowCurrentPolicies, [Switch] $ShowCommands ) 


# Add "Success" and/or "Failure" after the colon for each audit subcategory,
# or leave blank to disable all auditing for that subcategory.  Do not delete
# or add any lines, there must be exactly 59 policies in the list.  Space
# characters do not matter, except inside the name of the policy on the left.
# Do not add comment markers (#) anywhere inside the $AuditPolicyList.
#
# To see your current audit policies, run this command:
#     auditpol.exe /get /category:*


$AuditPolicyList = @'
Credential Validation                  : Success Failure
Kerberos Authentication Service        : 
Kerberos Service Ticket Operations     : 
Other Account Logon Events             : 
Application Group Management           : 
Computer Account Management            : Success
Distribution Group Management          : 
Other Account Management Events        : Success Failure
Security Group Management              : Success Failure
User Account Management                : Success Failure
DPAPI Activity                         : 
Plug and Play Events                   : Success
Process Creation                       : Success
Process Termination                    : 
RPC Events                             : 
Token Right Adjusted                   : 
Detailed Directory Service Replication : 
Directory Service Access               : Success Failure
Directory Service Changes              : Success Failure
Directory Service Replication          : 
Account Lockout                        : Success Failure
Group Membership                       : Success
IPSec Extended Mode                    : 
IPSec Main Mode                        : 
IPSec Quick Mode                       : 
Logoff                                 : Success
Logon                                  : Success Failure
Network Policy Server                  : 
Other Logon/Logoff Events              : 
Special Logon                          : Success
User / Device Claims                   : 
Application Generated                  : 
Central Access Policy Staging          : 
Certification Services                 : 
Detailed File Share                    : 
File Share                             : 
File System                            : 
Filtering Platform Connection          : 
Filtering Platform Packet Drop         : 
Handle Manipulation                    : 
Kernel Object                          : 
Other Object Access Events             : 
Registry                               : 
Removable Storage                      : Success Failure
SAM                                    : 
Policy Change                          : Success Failure
Authentication Policy Change           : Success
Authorization Policy Change            : Success
Filtering Platform Policy Change       : 
MPSSVC Rule-Level Policy Change        : 
Other Policy Change Events             : 
Non Sensitive Privilege Use            : 
Other Privilege Use Events             : 
Sensitive Privilege Use                : Success Failure
IPSec Driver                           : Success Failure
Other System Events                    : Success Failure
Security State Change                  : Success
Security System Extension              : Success Failure
System Integrity                       : Success Failure
'@



# Sanity check: Path to auditpol.exe:
$AuditPolExePath = Resolve-Path -Path "$env:WinDir\System32\auditpol.exe" | Select -ExpandProperty Path
if (-not $? -or $AuditPolExePath.Length -lt 8){ Write-Error -Message "Cannot Find AUDITPOL.EXE" ; Return } 


# Display current policies and quit?
if ($ShowCurrentPolicies)
{ 
    auditpol.exe /get /category:* | Select-String -Pattern 'Success|Failure|No Auditing' | Foreach { $_.Line.Trim() } 
    Return
} 


# Disable all existing audit policies and maybe quit:
if ($ShowCommands){ "$AuditPolExePath /clear /y" } 
Start-Process -FilePath $AuditPolExePath -ArgumentList '/clear /y' -NoNewWindow
if ($DisableAllAuditPolicies){ Return } 


# Parse audit policy list into an array:
$AuditPolicyList = $AuditPolicyList -split "`n"


# Sanity check: must have 59 policies:
# Has the number of advanced audit policies changed from 59?
# auditpol.exe /get /category:* | Select-String -Pattern 'Success|Failure|No Auditing' | Measure-Object
if ($AuditPolicyList.Count -ne 59)
{ Write-Error -Message "Wrong Count of Audit Policies: Must Be 59" ; Return }


# Sanity check: every line has a colon: 
$AuditPolicyList | ForEach { if ($_ -notlike '*:*'){ Write-Error -Message "Missing Colon: $_" ; Return } } 


# Apply audit policy array:
ForEach ($Policy in $AuditPolicyList)
{
    # $PolicyPart[0] is the name of the policy
    # $PolicyPart[1] is Success and/or Failure
    $PolicyPart = $Policy -split ':'

    # Neither Success nor Failure? Continue to next:
    if ($PolicyPart[1].Trim().Length -eq 0){ Continue }  

    # Construct arguments to auditpol.exe:
    $EndingArgs = ''
    if ($PolicyPart[1] -like '*Success*'){ $EndingArgs =  '/success:enable ' }
    if ($PolicyPart[1] -like '*Failure*'){ $EndingArgs += '/failure:enable'  } 
    $EndingArgs = '/set /subcategory:"' + $PolicyPart[0].Trim() + '" ' + $EndingArgs

    # Run auditpol.exe with the arguments:
    if ($ShowCommands){ "$AuditPolExePath $EndingArgs" } 
    Start-Process -FilePath $AuditPolExePath -ArgumentList $EndingArgs -NoNewWindow
}



# FIN