###########################################################################
#.SYNOPSIS
#   Create an IPsec rule with Kerberos authentication.
#
#.NOTES
#   This script purges all other IPsec rules and settings first!
#   This script requires Windows Server 2012, Windows 8, or later.
#   See Custom-IKEv1-Rule-Details.ps1 for more examples.
#   Last Updated: 30.Dec.2019 by JF@Enclave.  
###########################################################################



#######################################
#     START WITH A CLEAN SLATE 
#######################################
# Scrub the slate clean of all existing IPsec rules and settings: 

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

    # Then remove the CryptoSets and AuthSets used in these rules:
    Get-NetIPsecMainModeCryptoSet  | Remove-NetIPsecMainModeCryptoSet 
    Get-NetIPsecQuickModeCryptoSet | Remove-NetIPsecQuickModeCryptoSet
    Get-NetIPsecPhase1AuthSet | Remove-NetIPsecPhase1AuthSet
    Get-NetIPsecPhase2AuthSet | Remove-NetIPsecPhase2AuthSet

    # Restart IPsec IKE service (optional):
    Restart-Service -Name IKEEXT -Force 
}


# Run the above function to purge everything:
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

$ComputerKerberos = New-NetIPsecAuthProposal -Machine -Kerberos


New-NetIPsecPhase1AuthSet -Default -DisplayName "MyComputerList" `
  -Proposal $ComputerKerberos | Out-Null



#######################################
#     USER AUTHENTICATION 
#######################################
# Optionally, you can propose user authentication too with a list of user
# authentication proposals, even if that list will only have one offer.  
# Here, we will create one user authentication proposal and add it to a new 
# list of such offers.  Notice the -Default switch: this makes it the global 
# default for any rules that do not specify other user authentication methods.  
# Try to use the defaults to simplify.

$UserKerberos = New-NetIPsecAuthProposal -User -Kerberos 


New-NetIPsecPhase2AuthSet -Default -DisplayName "MyUserList" `
  -Proposal $UserKerberos | Out-Null




#######################################
#     MAIN MODE (PHASE 1) 
#######################################
# Assume that we want only 256-bit AES, SHA-256 and Diffie-Hellman Group 14 
# for security.  Create this proposal for main mode (phase 1) negotiations, 
# then add it to a list of such proposals, even though it will be a list of 
# only one offer.  Notice the -Default switch again: this makes this main mode 
# proposal the default for all rules which do not specify different main mode 
# settings.  Try to use the defaults.

$MainModeCrypto = New-NetIPsecMainModeCryptoProposal `
                    -Encryption AES256 -Hash SHA256 -KeyExchang DH14


New-NetIPsecMainModeCryptoSet -Default -DisplayName 'MyMainModeList' `
  -ForceDiffieHellman $True -Proposal $MainModeCrypto | Out-Null 



#######################################
#     QUICK MODE (PHASE 2) 
#######################################
# Assume we want only 256-bit AES and SHA-256 for ESP encryption of packets.
# Create this proposal for quick mode (phase 2) negotiations, then add it to 
# a list of such proposals, even though it will be a list of only one offer.  
# Notice the -Default switch again: this makes this quick mode proposal the 
# default for all rules which do not specify different quick mode settings.  
# Try to use the defaults.

$QuickModeCrypto = New-NetIPsecQuickModeCryptoProposal `
  -Encryption AESGCM256 -ESPHash AESGMAC256 -Encapsulation ESP


New-NetIPsecQuickModeCryptoSet -Default -DisplayName 'MyQuickModeList' `
  -PerfectForwardSecrecyGroup DH14 -Proposal $QuickModeCrypto | Out-Null



#######################################
#     NEW CONNECTION SECURITY RULE 
#######################################
# Create a hashtable of arguments to use for splatting.  We are going to
# require IPsec for *inbound* connections to several of our listening TCP
# ports on the local computer, but only request IPsec when connecting
# *outbound* to these ports on other machines.  This rule will only apply
# to computers whose IP addresses begin with 10.*.*.* (10.0.0.0/255.0.0.0).
# Notice that we do not have to specify main mode proposals, quick mode
# proposals or authentication methods because we will use the defaults above.

$NewRuleSplat = @{
    DisplayName = 'Dangerous Ports Custom'
    InboundSecurity = 'Require'
    OutboundSecurity = 'Request'
    Protocol = 'TCP'
    LocalAddress = 'Any'
    LocalPort = @('3389','139','445','21') 
    RemoteAddress = '10.0.0.0/8'
    RemotePort = 'Any'
    Profile = 'Any'
    InterfaceType = 'Any'
    Enabled = 'True'
}


# Create a new IPsec rule with the above hashtable:

New-NetIPsecRule @NewRuleSplat 1>$null 



# That's it!
#
# Now, in the Windows Firewall snap-in in your MMC.EXE console, 
# right-click 'Connection Security Rules' and select Refresh
# to see the new IPsec rule just created.
