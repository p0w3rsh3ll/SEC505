<################################################################################
.SYNOPSIS
  Change the Group property on Windows Firewall rules.

.DESCRIPTION
  Windows Firewall rules have a Group property which cannot be set using the 
  Windows Firewall MMC.EXE snap-in.  This function can change the Group property
  on existing rules.  In the Windows Firewall snap-in, new Group names can be
  used to filter rules (right-click > Filter By Group).  Firewall rules are 
  stored in the registry as REG_SZ values.  The Group property of a firewall 
  rule is encoded in the EmbedCtxt portion of those strings in the registry.
  Function returns the affected firewall rules or throws an error.  

.PARAMETER DisplayName
  The name of the rule as displayed in the Windows Firewall.
  One or more wildcards may be used in the name.
  Firewall rule objects may be piped into this function.

.PARAMETER GroupName
  The new firewall rule group name.

.EXAMPLE
  Get-NetFirewallRule -DisplayName 'MSN News' | 
  Set-NetFirewallRuleGroupName -GroupName "PorkSpam"

.EXAMPLE
  $Rules = Set-NetFirewallRuleGroupName -DisplayName "MSN*" -GroupName "HamSpam"
  $Rules.Count

.NOTES
  Legal: Public domain, no rights reserved, provided "AS IS" without warranties.
  Author: Jason Fossen, Enclave Consulting LLC (https://www.sans.org/sec505)
  Created: 23.Sep.2016
  Updated: 7.Jun.2017
################################################################################>
function Set-NetFirewallRuleGroupName 
{
    [CmdletBinding()] Param 
    ( 
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)] [String] $DisplayName, 
        [Parameter(Mandatory=$true)] [String] $GroupName 
    )

    BEGIN { $rules = @() } 

    PROCESS
    {
        $rules = @( Get-NetFirewallRule -DisplayName $DisplayName -ErrorAction SilentlyContinue ) 

        if ($VerbosePreference){ Write-Verbose ("Count of $DisplayName rules = " + $rules.Count) } 

        if ($rules.Count -eq 0)
        {
            Write-Error -Message "Rule(s) not found with display name: $DisplayName" 
        }
        else
        { 
            foreach ($rule in $rules)
            {
                if ($VerbosePreference){ Write-Verbose ("Setting group on rule ID = " + $rule.ID) } 
                $rule.Group = $GroupName
                $rule | Set-NetFirewallRule -PassThru 
            }
        }
    }
} 





