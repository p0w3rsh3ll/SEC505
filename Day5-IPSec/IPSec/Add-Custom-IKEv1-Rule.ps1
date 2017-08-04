<#############################################################################
.DESCRIPTION

This script demonstrates how to construct more complex IPsec policies from
within PowerShell.  There are more possible IPsec settings that may be 
specified using PowerShell than can be created (or even seen) in the 
graphical Windows Firewall snap-in tool or in a Group Policy Object.

This script only shows rules which use IKEv1 or AuthIP for key management.
See the Add-Custom-IKEv2-Rule.ps1 script for examples of IKEv2 IPsec rules.

A "proposal" is a combination of particular IPsec settings for a particular
phase of the IPsec negotiation process, such as the cipher, key size, and 
hashing algo used during Phase 1 (P1) Main Mode (MM) negotiations.

A "set" is a collection of one or more "proposals."  There are different types
of sets for different types of proposals for the two phases of the IPsec
negotiation process.

A "library" is a just a list of sets of proposals defined in this script, so
that we may choose a set from our own custom library when creating rules.
The concept of a "library" has no meaning to Windows or Microsoft IPsec, but
you will likely create your own such library to maintain consistency, enforce 
version control, and simplify IPsec management.  

    Library of Authentication Sets:
        AuthSet1:
            AuthProposal1
            AuthProposal2
            AuthProposal3
        AuthSet2:
            AuthProposal1
            AuthProposal2

    Library of Main Mode Crypto Sets:
        MMSet1:
            MMProposal1
            MMProposal2
        MMSet2:
            MMProposal1
        MMSet3:
            MMProposal1
            MMProposal2
            MMProposal3

    Library of Quick Mode Crypto Sets:
        QMSet1:
            QMProposal1
        QMSet2:
            QMProposal1
            QMProposal2


"P1" stands for Phase 1, which is the first phase of IPsec negotiations.

"MM" stands for Main Mode, which is the mode of Phase 1 negotiations.

(Note: Windows does not use Aggressive Mode in P1 or otherwise.)

"P2" stands for Phase 2, which is the second phase of IPsec negotiations.

"QM" stands for Quick Mode, which the mode of Phase 2 negotiations.

During IPsec negotiations, Phase 1 (in Main Mode) comes first, then Phase 2
(in Quick Mode) comes second.  There are corresponding MM rules and QM rules
in Windows which are created with PowerShell or the Windows Firewall (WF)
graphical snap-in.  

Importantly, MM rules created in PowerShell will NOT be visible in the 
Windows Firewall snap-in!  They can only be seen and managed in PowerShell.

Each MM or QM rule is a combination of various proposal sets, such as:

    MMRule1 = AuthSet2 + MMSet3
    MMRule2 = AuthSet1 + MMSet1

    QMRule1 = QMSet2
    QMRule2 = AuthSet1 + QMSet2

When a MM or QM rule does not specify a particular set for some part of
the negotiation process, then the machine-wide defaults are used instead.
Some defaults are hard-coded into the OS (you'll have to RTFM) and others
can be managed using the Window Firewall snap-in (IPSec Settings tab),
and most can be managed in PowerShell. 

P2 QM negotiations might negotiate either Transport Mode or Tunnel Mode.
In Windows, Transport Mode is the default.  Tunnel Mode must be explicitly 
enabled in a QM rule.  

When there is at least one MM rule and at least one QM rule, using either
default settings or explicitly-defined proposal sets, then IPsec becomes
operational on the computer, i.e., you can start sniffing IPsec packets.

.NOTES
Created: 20.Jun.2017
Updated: 24.Jun.2017
 Author: Enclave Consulting LLC, Jason Fossen (https://sans.org/sec505)
  Legal: Public domain, provided "AS IS" without any warranties.
#############################################################################>




##############################################################################
# View Main Mode Rules (MMRules) and IPsec Connection Rules (IPsecRules)
#
#   There are only two types of rules: MMRules and IPsecRules.
##############################################################################

# View your current MMRules:
Get-NetIPsecMainModeRule | Select *
Get-NetIPsecMainModeRule | Select DisplayName,Enabled 

# View your current IPsecRules:
Get-NetIPsecRule | Select * 
Get-NetIPsecRule | Select DisplayName,Enabled 



##############################################################################
# Scrub All IPsec Settings Clean: WARNING! THIS WILL PURGE ALL IPSEC RULES!
##############################################################################


function Purge-AllIPsecSettings
{
    # Remove MMRules and IPsecRules first:
    Get-NetIPsecMainModeRule | Remove-NetIPsecMainModeRule
    Get-NetIPsecRule | Remove-NetIPsecRule

    # Remove the CryptoSets and AuthSets used in the rules:
    Get-NetIPsecMainModeCryptoSet  | Remove-NetIPsecMainModeCryptoSet 
    Get-NetIPsecQuickModeCryptoSet | Remove-NetIPsecQuickModeCryptoSet
    Get-NetIPsecPhase1AuthSet | Remove-NetIPsecPhase1AuthSet
    Get-NetIPsecPhase2AuthSet | Remove-NetIPsecPhase2AuthSet
}


## Uncomment the next line to do THE PURGE...
#  Purge-AllIPsecSettings



##############################################################################
# Auth Proposal Library:
#
#   An AuthProposal is one offer of authentication settings.
#   AuthProposals can be added to either Phase1AuthSets or Phase2AuthSets.
##############################################################################

# Names of PKI CAs for cert auth (edit to match your own CA):
$CA1 = "DC=local, DC=testing, CN=Testing-CA"
$CA2 = "DC=local, DC=testing, CN=InterMM-CA"

# Any pre-shared key strings:
$PSK1 = 'SomeSekritPreSharedKey'
$PSK2 = 'Ander3Cekritt#PsSchlu$$l'

# Machine Auth (First):
$MachineCertAuthProposal = New-NetIPsecAuthProposal -Machine -Cert -Authority $CA1 -AuthorityType Root
$MachinePsk1AuthProposal = New-NetIPsecAuthProposal -Machine -PreSharedKey $PSK1
$MachineKerbAuthProposal = New-NetIPsecAuthProposal -Machine -Kerberos

# User Auth (Second):
$UserCertAuthProposal    = New-NetIPsecAuthProposal -User -Cert -Authority $CA1 -AuthorityType Root
$UserKerbAuthProposal    = New-NetIPsecAuthProposal -User -Kerberos 



##############################################################################
# Auth Set Library:
#
#   An AuthSet is a set of AuthProposals.
#   Phase1AuthSets can be used for both MMRules and IPsecRules.
#   Phase2AuthSets can be used only for IPsecRules.
##############################################################################

#Phase1AuthSets (MMRules or IPsecRules):
$P1MachineCertOnly = New-NetIPsecPhase1AuthSet –DisplayName "P1MachineCertOnly" -Proposal $MachineCertAuthProposal
$P1MachineKerbOnly = New-NetIPsecPhase1AuthSet –DisplayName "P1MachineKerbOnly" -Proposal $MachineKerbAuthProposal
$P1MachinePSK1     = New-NetIPsecPhase1AuthSet –DisplayName "P1MachinePSK1"     -Proposal $MachinePsk1AuthProposal

#Phase2AuthSets (IPsecRules only):
$P2UserCertOnly    = New-NetIPsecPhase2AuthSet -DisplayName "P2UserCertOnly" -Proposal $UserCertAuthProposal
$P2UserKerbOnly    = New-NetIPsecPhase2AuthSet -DisplayName "P2UserKerbOnly" -Proposal $UserKerbAuthProposal



##############################################################################
# MM Crypto Proposal Library:
#
#   A MMCryptoProposal is one Main Mode offer. 
#   Can only be added to a MMCryptoSet.
#   Just because intellisense shows an argument for a parameter does not mean
#   that that argument is always legal.
##############################################################################

$MmAes256Sha384Dh24 = New-NetIPsecMainModeCryptoProposal -Encryption AES256 -Hash SHA384 -KeyExchang DH24
$MmAes128Sha256Dh19 = New-NetIPsecMainModeCryptoProposal -Encryption AES128 -Hash SHA256 -KeyExchang DH19



##############################################################################
# MM Crypto Set Library:
#
#   A MMCryptoSet is a collection of MM Crypto Proposals.
#   Can only be added to a MMRule, not IPsecRules.
#   BEWARE: Simply creating MMCryptoSets, even if not used in any rules, will
#   change the customized MM offers when you go to WF > IPsec Settings > 
#   Customize (IPsec defaults) > Customize (Main Mode).  If you attempt to
#   change customized MM settings in the GUI again, there is no warning when
#   you attempt to save changes in the GUI, but they weren't actually saved. 
#   Only create one MMCryptoSet because the *last* created MMCryptoSet
#   becomes the *only* MMCryptoSet seen in the WF snap-in! CRAZY!!!
#   See the -Default switch in the help for New-NetIPsecMainModeCryptoSet.
##############################################################################

$MmCryptoSetAllowDH = New-NetIPsecMainModeCryptoSet -DisplayName 'MMCryptoSetAllowDH' -ForceDiffieHellman $False -Proposal $MmAes128Sha256Dh19
#The one above will not appear in the WF, only the next one!
$MmCryptoSetForceDH = New-NetIPsecMainModeCryptoSet -DisplayName 'MMCryptoSetForceDH' -ForceDiffieHellman $True  -Proposal @($MmAes256Sha384Dh24,$MmAes128Sha256Dh19) 



##############################################################################
# QM Crypto Proposal Library:
#
#   A QMCryptoProposal is one Quick Mode offer. 
#   Can only be added to a QMCryptoSet.
##############################################################################

$QmAesGcm256AesGmac256 = New-NetIPsecQuickModeCryptoProposal -Encryption AESGCM256 -ESPHash AESGMAC256 -Encapsulation ESP   
$QmAes128Sha256        = New-NetIPsecQuickModeCryptoProposal -Encryption AES128    -ESPHash SHA256     -Encapsulation ESP   
$QmEspPlaintext        = New-NetIPsecQuickModeCryptoProposal -Encapsulation ESP -Encryption None



##############################################################################
# QM Crypto Set Library:
#
#   A QMCryptoSet is a collection of Quick Mode Crypto Proposals.
#   Can only be added to an IPsecRule, not MMRules.
##############################################################################

$QmCryptoSetPfsDh24 = New-NetIPsecQuickModeCryptoSet -DisplayName 'QmCryptoSetPfsDh24' -PerfectForwardSecrecyGroup DH24 -Proposal @($QmAesGcm256AesGmac256,$QmAes128Sha256)  
$QmCryptoSetPfsNone = New-NetIPsecQuickModeCryptoSet -DisplayName 'QmCryptoSetPfsNone' -PerfectForwardSecrecyGroup None -Proposal $QmAes128Sha256
$QmCryptoSetEspNone = New-NetIPsecQuickModeCryptoSet -DisplayName 'QmCryptoSetEspNone' -Proposal $QmEspPlaintext



##############################################################################
# Assemble your Phase 1 MMRules from the above libraries:
#
#   IMPORTANT: These rules will NOT be visible in the Windows Firewall snap-in!
#
#   When a MMCryptoSet or Phase1AuthSet is not specified, the global defaults
#   as seen in the Windows Firewall snap-in will be used (IPsec Settings tab).
##############################################################################

$MmRule1 = New-NetIPsecMainModeRule -DisplayName 'MMRule1' -LocalAddress Any -RemoteAddress '192.168.1.0/24' -MainModeCryptoSet $MmCryptoSetAllowDH.Name -Phase1AuthSet $P1MachineCertOnly.Name 

$MmRule2 = New-NetIPsecMainModeRule -DisplayName 'MMRule2' -Profile Public -LocalAddress Any -RemoteAddress Any -MainModeCryptoSet $MmCryptoSetForceDH.Name -Phase1AuthSet $P1MachinePSK1.Name

$MmRule3 = New-NetIPsecMainModeRule -DisplayName 'MMRule3' -Profile Domain -LocalAddress Any -RemoteAddress @('192.168.1.0/24','10.7.0.0/16') #Use machine-wide defaults for MMCryptoSet and Phase1AuthSet in WF snap-in.



##############################################################################
# Assemble your Phase 2 Quick Mode IPsecRules from the above libraries:
#
#   These will be visible as 'Connection Security Rules' in the FW snap-in;
#   however, not every option can be seen or edited in the WF snap-in, it
#   depends on the options used when the rule is created.  To see any new
#   rules in the WF snap-in, right-click and refresh.  
##############################################################################

$IPsec1 = New-NetIPsecRule -DisplayName "IPsec1" -InboundSecurity Require -OutboundSecurity Require -Phase1AuthSet $P1MachineKerbOnly.Name -Phase2AuthSet $P2UserCertOnly.Name -QuickModeCryptoSet $QmCryptoSetPfsDh24.Name

$IPsec2 = New-NetIPsecRule -DisplayName "IPsec2" -InboundSecurity Require -OutboundSecurity Request -InterfaceType Wireless  

$IPsec3 = New-NetIPsecRule -DisplayName "IPsec3" -InboundSecurity Require -OutboundSecurity Require -Profile Domain -Protocol TCP -LocalPort Any -RemotePort 5985 -LocalAddress Any -RemoteAddress @('192.168.1.0/24','10.0.0.0/8') -InterfaceType Any -Phase1AuthSet $P1MachineCertOnly.Name 


$IPsec4Tunnel = @{
    DisplayName = 'IPsec4'
    Mode = 'Tunnel' 
    LocalAddress =         '192.168.1.0/24'     #Local LAN network ID for routing
    LocalTunnelEndpoint =  '204.51.94.202'      #My public IP as a gateway
    RemoteAddress =        '10.4.0.0/16'        #Remote LAN network ID for routing
    RemoteTunnelEndpoint = '61.177.137.130'     #Remote gateway's public IP
    InboundSecurity = 'Require' 
    OutboundSecurity = 'Require' 
    EncryptedTunnelBypass = $True               #Don't double-encrypt
    QuickModeCryptoSet = ($QmCryptoSetPfsDh24.Name)
    Phase1AuthSet = ($P1MachineCertOnly.Name)
    KeyModule = 'IKEv1'
}

$IPsec4 = New-NetIPsecRule @IPsec4Tunnel




##############################################################################
#
# Optional Clean Up
#
##############################################################################

# Delete the IPsecRules created above:
Get-NetIPsecRule -DisplayName 'IPsec*' | Remove-NetIPsecRule

# Uncomment this line to do THE PURGE:
# Purge-AllIPsecSettings




<#############################################################################
MISC NOTES:

* When you run this command, $ThisCaString is case-sensitive:

    New-NetIPsecAuthProposal -Machine -Cert -Authority $ThisCaString

The connection will fail if $ThisCaString does not exactly match the Subject field
in the CA's own cert.  However, these two CA Subject strings are treated as
identical, they both work:

    "DC=local, DC=testing, CN=Testing-CA"
    "DC=local,DC=testing,CN=Testing-CA"

* In a script to manage IPsec rules, purge everything first, only create one
MainModeCryptoSet and use the -Default switch when you do so.  This makes
troubleshooting easier.

* Whenever you create a new IPsec item, it creates an additional item 
even if an item with the same DisplayName already exists.  Said another way, you 
can have multiple IPsec items with the same DisplayName, but not the same Name.
Hence, IPsec config scripts usually should first purge all existing IPsec objects
before creating new ones, then use the -Name parameter to help duplicates. If
you try to create a duplicate IPsec object with the same name as an existing
object, you will get a "Catastrophic failure" error.  

* Just because intellisense shows an argument for a parameter does not mean
that that argument is always legal or will resulting in a functioning policy.

#############################################################################>
