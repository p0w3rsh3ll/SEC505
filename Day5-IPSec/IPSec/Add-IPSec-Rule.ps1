###################################################
# This script demonstrates how to create an IPsec # 
# rule on Server 2012, Windows 8 and later.  This #
# will use IKEv1 because of the pre-shared key.   #
###################################################


#Create an authentication proposal using a pre-shared key:

$AuthProposal = New-NetIPsecAuthProposal -Machine -PreSharedKey "ThePreSharedKey" 



#Add the above authentication proposal to a named set:

$AuthProposalSet = New-NetIPsecPhase1AuthSet -DisplayName "Auth-Proposal-Set" -Proposal $AuthProposal 



#Create the IPsec rule using the above proposal set:

$ArgSet = @{
    DisplayName = 'Testing-IPSec-PowerShell'
    Phase1AuthSet = $AuthProposalSet.Name 
    InboundSecurity = 'Require'
    OutboundSecurity = 'Request'
    Protocol = 'TCP'
    LocalAddress = 'Any'
    LocalPort = 'Any'
    RemoteAddress = '10.0.0.0/8'
    RemotePort = @('3389','135','139','445','21','20','23') 
    Profile = 'Any'
    InterfaceType = 'Any'
    Enabled = 'True'
}

New-NetIPsecRule @ArgSet


# Prevent the script from running any further:
return



# To display information about the IPsec rule:
Get-NetIPsecRule -DisplayName "Testing-IPSec-PowerShell"



# To delete the IPsec rule:
Remove-NetIPsecRule -DisplayName "Testing-IPSec-PowerShell"


