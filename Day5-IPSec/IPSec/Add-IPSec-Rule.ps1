###################################################
# This script demonstrates how to create an IPSec # 
# rule on Server 2012, Windows 8 and later.       #
###################################################


#Create an authentication proposal using a pre-shared key:
$AuthProposal = New-NetIPsecAuthProposal -Machine –PreSharedKey "ThePreSharedKey" 



#Add the above authentication proposal to a named set:
$AuthProposalSet = New-NetIPsecPhase1AuthSet –DisplayName "Auth-Proposal-Set" -Proposal $AuthProposal 



#Create the IPSec rule using the above proposal set:
New-NetIPsecRule -DisplayName "Testing-IPSec-PowerShell" `
-Phase1AuthSet $AuthProposalSet.Name `
-InboundSecurity Require `
-OutboundSecurity Request `
-Protocol TCP `
-LocalAddress Any `
-LocalPort Any `
-RemoteAddress 10.146.208.0/24 `
-RemotePort 3389,135,139,445,21,20,23 `
-Profile Any `
-InterfaceType Any `
-Enabled True 



# Prevent the script from running any further:
return



# To display information about the IPSec rule:
Get-NetIPsecRule -DisplayName "Testing-IPSec-PowerShell"



# To delete the IPSec rule:
Remove-NetIPsecRule -DisplayName "Testing-IPSec-PowerShell"


