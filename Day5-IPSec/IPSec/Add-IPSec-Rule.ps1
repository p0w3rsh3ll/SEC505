###########################################################################
#.DESCRIPTION
# This script demonstrates how to create an IPsec rule using a pre-shared 
# key.  Script requires Windows Server 2012, Windows 8 or later OS.  
# This script is run as part of a lab on the IPsec day of SEC505. 
###########################################################################


# Create an authentication proposal using a pre-shared key:

$AuthProposal = New-NetIPsecAuthProposal -Machine -PreSharedKey "ThePreSharedKey" 



# Add the above authentication proposal to a set of proposals:

$AuthProposalSet = New-NetIPsecPhase1AuthSet -DisplayName "Auth-Proposal-Set" -Proposal $AuthProposal 



# Create a hashtable of parameters and arguments to use in the next command:

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



# Create an IPsec rule using the above hashtable of arguments:

New-NetIPsecRule @ArgSet





## To display information about the above IPsec rule:
#Get-NetIPsecRule -DisplayName "Testing-IPSec-PowerShell"


## To delete the above IPsec rule:
#Remove-NetIPsecRule -DisplayName "Testing-IPSec-PowerShell"


