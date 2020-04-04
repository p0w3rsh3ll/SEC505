###########################################################################
#.SYNOPSIS
#   Create an IPsec rule using a pre-shared key for several TCP ports.
#
#.NOTES
#   This script purges all other IPsec rules and settings first!
#   See Custom-IKEv1-Rule-Details.ps1 for more examples.
#   This script requires Windows Server 2012, Windows 8, or later.
#   Last Updated: 30.Dec.2019 by JF@Enclave.  
###########################################################################


# Choose your long, random, pre-shared key:

$MyPreSharedKey = 'P@ssword'



#######################################
#     START WITH A CLEAN SLATE 
#######################################
# Scrub the slate clean of all existing IPsec rules and settings so that
# we will get exactly what we want and have nothing else lingering behind
# to cause problems.  When troubleshooting, purge all existing rules and
# settings, then add your rules back again.  

function Remove-AllIPsecRulesAndSettings
{
    # Remove all default IPsec settings (error expected if an item does not exist):
    Remove-NetIPsecMainModeCryptoSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE1}' -ErrorAction SilentlyContinue
    Remove-NetIPsecQuickModeCryptoSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE2}' -ErrorAction SilentlyContinue
    Remove-NetIPsecPhase1AuthSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE3}' -ErrorAction SilentlyContinue
    Remove-NetIPsecPhase2AuthSet -Name '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE4}' -ErrorAction SilentlyContinue

    # Remove MMRules and IPsecRules first:
    Get-NetIPsecMainModeRule | Remove-NetIPsecMainModeRule
    Get-NetIPsecRule | Remove-NetIPsecRule

    # Then remove the CryptoSets and AuthSets used in the rules:
    Get-NetIPsecMainModeCryptoSet  | Remove-NetIPsecMainModeCryptoSet 
    Get-NetIPsecQuickModeCryptoSet | Remove-NetIPsecQuickModeCryptoSet
    Get-NetIPsecPhase1AuthSet | Remove-NetIPsecPhase1AuthSet
    Get-NetIPsecPhase2AuthSet | Remove-NetIPsecPhase2AuthSet

    # Restart IPsec IKE service (optional):
    Restart-Service -Name IKEEXT -Force 
}

# Run the function to purge everything:
Remove-AllIPsecRulesAndSettings




#######################################
#     COMPUTER AUTHENTICATION
#######################################
# You must offer a list of authentication proposals to the other computer, 
# even if you only have one proposal in that list.  So, create a computer 
# authentication proposal and add it to a new list of proposals to send to 
# the other computer.  Notice the -Default switch: this makes it the global 
# default for any rules that do not specify other computer authentication 
# methods.  Try to use the defaults when creating new rules to simplify. 

$AuthProposal = New-NetIPsecAuthProposal -Machine -PreSharedKey $MyPreSharedKey

New-NetIPsecPhase1AuthSet -Default -DisplayName "MyList" -Proposal $AuthProposal | Out-Null




#######################################
#     NEW CONNECTION SECURITY RULE 
#######################################
# Create a hashtable of arguments to use for splatting.  We are going to
# require IPsec for *inbound* connections to several of our listening TCP
# ports on the local computer, but only request IPsec when connecting
# *outbound* to these ports on other machines.  This rule will only apply
# to computers whose IP addresses begin with 10.*.*.* (10.0.0.0/255.0.0.0).
# We will use only default authentication and crypto settings.


$NewRuleSplat = @{
    DisplayName = 'Dangerous TCP Ports'
    InboundSecurity = 'Require'
    OutboundSecurity = 'Request'
    Protocol = 'TCP'
    LocalAddress = 'Any'
    LocalPort = 'Any'
    RemoteAddress = '10.0.0.0/8'
    RemotePort = @('3389','139','445','21') 
    Profile = 'Any'
    InterfaceType = 'Any'
    Enabled = 'True'
}


# Create a new IPsec rule with the above hashtable:

New-NetIPsecRule @NewRuleSplat



# That's it!
#
# Now, in the Windows Firewall snap-in in your MMC.EXE console, 
# right-click 'Connection Security Rules' and select Refresh
# to see the new IPsec rule just created.
