function Set-NetFirewallRuleGroupName 
{
	###############################################################
	#.SYNOPSIS
	#  Change the name of the Group for a Windows Firewall rule.
	#
	#.DESCRIPTION
	#  Windows Firewall rules have a Group property which cannot
	#  be set using the Windows Firewall MMC.EXE snap-in.  This
	#  function can change the Group property on existing rules.
	#  In the Windows Firewall snap-in, new Group names can be
	#  used to filter rules (right-click > Filter By Group).
	#  Firewall rules are stored in the registry as REG_SZ values.
	#  The Group property of a firewall rule is encoded in the  
	#  EmbedCtxt portion of those strings in the registry.
	#
	#.PARAMETER DisplayName
	#  The name of the rule as displayed in the Windows Firewall.
	#  Firewall rule objects may be piped into this function.
	#
	#.PARAMETER GroupName
	#  The new firewall group name.
	#
	#.EXAMPLE
	#  Get-NetFirewallRule -DisplayName '*Cortana*' | Set-NetFirewallRuleGroupName -GroupName "Cortana Blocker"
	#
	#.EXAMPLE
	#  Set-NetFirewallRuleGroupName -DisplayName "MyRule" -GroupName "My New Group"
	#
	#.NOTES
	#  Legal: Public domain, no rights reserved, provided "AS IS" without warranties.
	#  Author: Jason Fossen, Enclave Consulting LLC (https://www.sans.org/sec505)
	#  Last Updated: 23.Sep.2016
	###############################################################

    [CmdletBinding()] Param 
    ( 
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)] [String] $DisplayName, 
        [Parameter(Mandatory=$true,Position=1)] [String] $GroupName 
    )

    BEGIN { $rule = $null; $iGiven = 0; $iModified = 0 } 

    PROCESS
    {
        if ($VerbosePreference){ Write-Verbose "Getting firewall rule $i : $DisplayName" } 
        $rule = Get-NetFirewallRule -DisplayName $DisplayName -ErrorAction SilentlyContinue 
    
        if ($rule -eq $null)
        {
            Write-Error -Message "Rule not found with display name: $DisplayName" 
        }
        else
        { 
            if ($VerbosePreference){ Write-Verbose ("Setting Group='" + $GroupName + "' on rule $i : $DisplayName") } 
            $rule.Group = $GroupName
            $rule | Set-NetFirewallRule
            if ($?){ $iModified++ }
        }

        $iGiven++
    }

    END 
    { 
        if ($VerbosePreference)
        { 
            Write-Verbose "Count of firewall rules given: $iGiven"
            Write-Verbose "Count of firewall rules successfully modified: $iModified"
        } 

        $rule = $null
    } 
}



