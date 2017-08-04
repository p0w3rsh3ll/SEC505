<#############################################################################
.DESCRIPTION

This script demonstrates how to construct more complex IPsec policies from
within PowerShell.  There are more possible IPsec settings that may be 
specified using PowerShell than can be created (or even seen) in the 
graphical Windows Firewall snap-in tool or in a Group Policy Object.

This script only shows rules which use IKEv2 for key management.
See the Add-Custom-IKEv1-Rule.ps1 script for examples of IKEv1 and AuthIP.

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

Now, in IKEv2 there are no "Phases", and there is no "Main Mode" or "Quick Mode",
but understandably Microsoft wants to use a single set of PoSh cmdlets to manage
all IPsec rules, and there are at least rough analogies between the negotiation
phases of IKEv1 and the exchanges of IKEv2.  With that said, here are some terms:

"P1" stands for Phase 1, which is the first phase of IPsec negotiations.

"MM" stands for Main Mode, which is the mode of Phase 1 negotiations in IKEv1.

(Note: Windows does not use Aggressive Mode in P1 or otherwise.)

"P2" stands for Phase 2, which is the second phase of IPsec negotiations.

"QM" stands for Quick Mode, which the mode of Phase 2 negotiations in IKEv1.

During IKEv1 negotiations, Phase 1 (in Main Mode) comes first, then Phase 2
(in Quick Mode) comes second.  There are corresponding MM rules and QM rules
in Windows which are created with PowerShell or the Windows Firewall (WF)
graphical snap-in.  In IKEv2, Phase 1 mostly corresponds to the IKE_SA_INIT
exchange and the first part of the IKE_AUTH exchange, then Phase 2 is
kind of like the last part of the IKE_AUTH exchange when the first Child SA
is created.  In any case, proposals created with the following cmdlets are
used for all IKEv1, AuthIP and IKEv2 negotiations, even if the terminology 
of the tools doesn't always match the RFCs.  

Importantly, MM rules created in PowerShell will NOT be visible in the 
Windows Firewall snap-in!  They can only be seen and managed in PowerShell.

Each MM or QM rule is a combination of various proposal sets, such as:

    MMRule1 = AuthSet2 + MMSet3
    MMRule2 = AuthSet1 + MMSet1

    QMRule1 = QMSet2
    QMRule2 = AuthSet1 + QMSet2

When a MM or QM rule does not specify a particular set for some part of
the negotiation process, then the machine-wide defaults are used instead.
Some defaults are hard-coded into the OS (you'll have to RTFM), others
can be managed using the Window Firewall snap-in (IPSec Settings tab),
and most can be managed in PowerShell.  

P2 QM negotiations might negotiate either Transport Mode or Tunnel Mode.
In Windows, Transport Mode is the default.  Tunnel Mode must be explicitly 
enabled in a QM rule.  

Certain types of IPsec objects can be defined as the default for the entire
machine.  These are used when a rule does not specify every option.  In
general, it is best to define what is the default in every case for the
sake of troubleshooting, even if you do not intend to rely on any defaults.

Some cmdlets and IPsec objects in PowerShell are irrelevant to IKEv2, such
as the New-NetIPsecPhase2AuthSet cmdlet and P2 authentication in general,
which is a feature of AuthIP.  What about extensible EAP authentication for
IKEv2?  No examples of that in this script.  This script does not assume
you are using RRAS, NPS (RADIUS), DirectAccess, EAP, PEAP, or anything
other than IKEv2's built-in PSK or certificate authentication.  

.NOTES
This script is used in the "Securing Windows and PowerShell Automation" 
course (course SEC505) at the SANS Institute: https://sans.org/sec505

Created: 20.Jun.2017
Updated:  5.Jul.2017
 Author: Enclave Consulting LLC, Jason Fossen, SEC505 course author. 
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
#
# Scrub All IPsec Settings Clean:  
# WARNING! THIS WILL DELETE EVERY IPSEC RULE AND PROPOSAL!
#
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

    # The IKEEXT service implements both AuthIP and IKEv2:
    Restart-Service -Name IKEEXT
}

# Uncomment this line to do THE PURGE:
# Purge-AllIPsecSettings



##############################################################################
# Auth Proposal Library:
#
#   An AuthProposal is one offer of authentication settings.
#   AuthProposals are added only to Phase1AuthSets with IKEv2 and IKEv1, or to 
#   both Phase1AuthSets and Phase2AuthSets with Microsoft AuthIP.
##############################################################################

# Names of PKI CAs for cert auth (edit to match your own CA):
$CA1 = "DC=local, DC=testing, CN=Testing-CA"
$CA2 = "DC=local, DC=testing, CN=InterMM-CA"
$CA3 = "DC=LOCAL, DC=teSTing, CN=TESting-ca" #BEWARE: This is case sensitive!

# Any pre-shared key strings:
$PSK1 = 'SomeSekritPreSharedKey'
$PSK2 = 'Ander3Cekritt#PsSchlu$$l'

# Without EAP help, there is no user auth in IKEv2 like there is with Microsoft AuthIP, so don't try to
# use commands like "New-NetIPsecAuthProposal -USER" when creating auth proposals, use "-MACHINE":
$MachineCertAuthProposal = New-NetIPsecAuthProposal -Machine -Cert -Authority $CA1 -AuthorityType Root
$MachinePsk1AuthProposal = New-NetIPsecAuthProposal -Machine -PreSharedKey $PSK1



##############################################################################
# Phase 1 Auth Set Library:
#
#   A Phase1AuthSet is a set of one or more AuthProposals.
#
#   IKEv2 machine auth can only be 1) a certificate xor 2) a pre-shared key,  
#   never both, and not neither.  IKEv2 cannot use Kerberos or NTLM without 
#   EAP help, which is not covered here.  Don't use New-NetIPsecPhase2AuthSet,
#   since there is no such thing as "Phase 2 Auth" in IKEv2 without EAP help.
#
#   In general, try to only have one Phase1AuthSet defined.  If you create
#   multiple Phase1AuthSets in a script, choose which one you want to be the
#   machine-wide default, create that one last, and use the -Default switch
#   with the command to create it.  All other Phase1AuthSets created should be
#   created using the -Name parameter.  Remember, too, that the first thing 
#   this script did at the top was to purge all IPsec objects.  
##############################################################################

# First one, using -Name:
$P1MachinePSK1 = New-NetIPsecPhase1AuthSet -Name "P1MachinePSK1" -DisplayName "P1MachinePSK1" -Proposal $MachinePsk1AuthProposal #Use only one for IKEv2

# Last one, using -Default and not using -Name:
$P1MachineCertOnly = New-NetIPsecPhase1AuthSet -Default -DisplayName "P1MachineCertOnly" -Proposal $MachineCertAuthProposal #Use only one for IKEv2

# The name of the default Phase1AuthSet must be '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE3}', which
# you can confirm now by running Get-NetIPsecPhase1AuthSet.



##############################################################################
# MM Crypto Proposal Library:
#
#   A MMCryptoProposal is one IKEv1 Main Mode offer or, in this script, one 
#   IKEv2 offer for the initial IKE_SA_INIT exchange.
#
#   An MMCryptoProposal can only be added to a MMCryptoSet.
#
#   Not every option is legal.  The following are illegal in MMCryptoSets: 
#   AESGCM256, AESGMAC256, AESGMAC192
##############################################################################

$MmAes256Sha384Dh24 = New-NetIPsecMainModeCryptoProposal -Encryption AES256 -Hash SHA384 -KeyExchang DH24 
$MmAes128Sha256Dh19 = New-NetIPsecMainModeCryptoProposal -Encryption AES128 -Hash SHA256 -KeyExchang DH19
$MmAes192Sha256Dh20 = New-NetIPsecMainModeCryptoProposal -Encryption AES192 -Hash SHA256 -KeyExchange DH20



##############################################################################
# MM Crypto Set Library:
#
#   A MMCryptoSet is a collection of MM Crypto Proposals.
#   MM Crypto Proposals can only be added to MMRules, not IPsecRules.
#
#   BEWARE: Simply creating a MMCryptoSet, even if not used in any rules, will
#   change the customized MM offers when you go to WF > IPsec Settings > 
#   Customize (IPsec defaults) > Customize (Main Mode).  If you attempt to
#   change customized MM settings in the GUI again, there is no warning when
#   you attempt to save changes in the GUI, but they aren't actually saved. 
#   In general, try to only have one MMCryptoSet defined.  If you create
#   multiple MMCryptoSets in a script, choose which one you want to be the
#   machine-wide default, create that one last, and use the -Default switch
#   with the command to create it.  All other MMCyrptoSets created should be
#   created using the -Name parameter.  Remember, too, that the first thing 
#   this script did at the top was to purge all IPsec objects.  
##############################################################################

# First one, and using the -Name parameter:
$MmCryptoSetAllowDH = New-NetIPsecMainModeCryptoSet -Name 'MMCryptoSetAllowDH' -DisplayName 'MMCryptoSetAllowDH' -ForceDiffieHellman $False -Proposal $MmAes128Sha256Dh19

# Second one, and using the -Name parameter:
$MmCryptoSet192ForceDH = New-NetIPsecMainModeCryptoSet -Name 'MmCryptoSet192ForceDH' -DisplayName 'MmCryptoSet192ForceDH' -ForceDiffieHellman $True -Proposal $MmAes192Sha256Dh20

# Last one, and using the -Default switch instead of the -Name parameter:
$MmCryptoSetForceDH = New-NetIPsecMainModeCryptoSet -Default -DisplayName 'MMCryptoSetForceDH' -ForceDiffieHellman $True  -Proposal @($MmAes256Sha384Dh24,$MmAes128Sha256Dh19) 

# The name of the default MMCryptSet must be '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE1}', which
# can be confirmed if you now run Get-NetIPsecMainModeCryptoSet.



##############################################################################
# QM Crypto Proposal Library:
#
#   A QMCryptoProposal is one Quick Mode offer for IKEv1, or the offer used
#   to create Child SAs in IKEv2 with IKE_AUTH and CREATE_CHILD_SA.
#  
#   A QMCryptoProposal can only be added to a QMCryptoSet.
##############################################################################

$QmAesGcm256AesGmac256 = New-NetIPsecQuickModeCryptoProposal -Encryption AESGCM256 -ESPHash AESGMAC256 -Encapsulation ESP   
$QmAes128Sha256        = New-NetIPsecQuickModeCryptoProposal -Encryption AES128    -ESPHash SHA256     -Encapsulation ESP   
$QmEspPlaintext        = New-NetIPsecQuickModeCryptoProposal -Encapsulation ESP -Encryption None



##############################################################################
#QM Crypto Set Library:
#
#   A QMCryptoSet is a collection of Quick Mode Crypto Proposals.
#   A QMCryptoSet can only be added to an IPsecRule, not a MMRule.
#
#   In general, try to only have one QMCryptoSet defined.  If you create
#   multiple QMCryptoSets in a script, choose which one you want to be the
#   machine-wide default, create that one last, and use the -Default switch
#   with the command to create it.  All other QMCryptoSets created should be
#   created using the -Name parameter.  Remember, too, that the first thing 
#   this script did at the top was to purge all IPsec objects.  
##############################################################################

#First one, using -Name:
$QmCryptoSetEspNone = New-NetIPsecQuickModeCryptoSet -Name 'QmCryptoSetEspNone' -DisplayName 'QmCryptoSetEspNone' -Proposal $QmEspPlaintext

#Second one, using -Name:
$QmCryptoSetPfsNone = New-NetIPsecQuickModeCryptoSet -Name 'QmCryptoSetPfsNone' -DisplayName 'QmCryptoSetPfsNone' -PerfectForwardSecrecyGroup None -Proposal $QmAes128Sha256

#Last one, using -Default and no -Name:
$QmCryptoSetPfsDh24 = New-NetIPsecQuickModeCryptoSet -Default -DisplayName 'QmCryptoSetPfsDh24' -PerfectForwardSecrecyGroup DH24 -Proposal @($QmAesGcm256AesGmac256,$QmAes128Sha256)  


# The default QMCryptoSet must have a name of '{E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE2}', which
# can be confirmed if you now run Get-NetIPsecQuickModeCryptoSet.



##############################################################################
# Optionally, assemble your Phase 1 MMRules from the above libraries:
#
#   These rules will NOT be visible in the Windows Firewall snap-in!
#
#   When a MMCryptoSet or Phase1AuthSet is not specified, the machine defaults
#   as defined above in this script will be used. You do not have to create an
#   MMRule at all, you can just rely on the machine default; in fact, using
#   the default is the easiet and most comprehensible option, but you may
#   need different IKE_SA_INIT proposals for different selections of peers.
#
#   Notice that you can select remote peers by IP address, interface profile
#   type (Domain, Public, Private) and even *local* OS version (-Platform).
##############################################################################

$MmRule1 = New-NetIPsecMainModeRule -Name 'MMRule1' -DisplayName 'MMRule1' -LocalAddress Any -RemoteAddress '192.168.199.0/24' -MainModeCryptoSet $MmCryptoSetAllowDH.Name -Phase1AuthSet $P1MachineCertOnly.Name 

$MmRule2 = New-NetIPsecMainModeRule -Name 'MMRule2' -DisplayName 'MMRule2' -Profile Public -LocalAddress Any -RemoteAddress Any -MainModeCryptoSet $MmCryptoSetForceDH.Name -Phase1AuthSet $P1MachinePSK1.Name

$MmRule3 = New-NetIPsecMainModeRule -Name 'MMRule3' -DisplayName 'MMRule3' -Profile Domain -LocalAddress Any -RemoteAddress @('192.168.199.0/24','10.7.0.0/16') #Use machine-wide defaults for MMCryptoSet and Phase1AuthSet.



##############################################################################
# 
# Mandatorily, assemble your Phase 2 IPsecRules from the above libraries:
#
#   These will be visible as 'Connection Security Rules' in the FW snap-in;
#   however, not every option can be seen or edited in the WF snap-in.  To 
#   see any new rules in the snap-in, right-click and refresh.  
#
#   Strictly speaking, there is no "Phase 2" or "Quick Mode" in IKEv2, so
#   these are the rules used by the IKE_AUTH and CREATE_CHILD_CA exchanges
#   to create Child SAs, also known as "IPsec SAs."  Nonetheless, these
#   Child SAs will be seen when you run Get-NetIPsecQuickModeSA, and the
#   IKE SAs will be seen when you run Get-NetIPsecMainModeSA.
##############################################################################

# You can specify everything explicity:
$IPsec2 = New-NetIPsecRule -IPsecRuleName 'IPsec2' -DisplayName 'IPsec2' -KeyModule IKEv2 -Phase1AuthSet $P1MachineCertOnly.Name -InboundSecurity Require -OutboundSecurity Require -Profile Domain -LocalAddress Any -Protocol TCP -LocalPort Any -RemoteAddress @('192.168.1.0/24','10.0.0.0/8') -RemotePort 5985 -InterfaceType Any 

# Or use the defaults:
$IPsec4 = New-NetIPsecRule -IPsecRuleName 'IPsec4' -DisplayName 'IPsec4' -KeyModule IKEv2   

# Use the default Phase1AuthSet:
$IPsec5 = New-NetIPsecRule -IPsecRuleName 'IPsec5' -DisplayName 'IPsec5' -KeyModule IKEv2 -InboundSecurity Require -OutboundSecurity Require -Protocol TCP -LocalPort Any -RemotePort 5985 -LocalAddress Any -RemoteAddress Any 

# Applies to all IP addresses, protocols and ports:
$IPsec8 = New-NetIPsecRule -IPsecRuleName 'IPsec8' -DisplayName 'IPsec8' -KeyModule IKEv2 -Phase1AuthSet $P1MachineCertOnly.Name -InboundSecurity Require -OutboundSecurity Require  

# Use a pre-shared key (event ID 4650 in the Security log confirms PSK):
$IPsec10 = New-NetIPsecRule -IPsecRuleName 'IPsec10' -DisplayName 'IPsec10' -KeyModule IKEv2 -Phase1AuthSet $P1MachinePSK1.Name -InboundSecurity Require -OutboundSecurity Require -Protocol TCP -LocalPort Any -RemotePort 5985 -LocalAddress Any -RemoteAddress Any 

# Specify a QMCryptoSet explicity for Child SAs:
$IPsec14 = New-NetIPsecRule -IPsecRuleName 'IPsec14' -DisplayName 'IPsec14' -KeyModule IKEv2 -Phase1AuthSet $P1MachineCertOnly.Name -QuickModeCryptoSet $QmCryptoSetPfsDh24.Name -InboundSecurity Require -OutboundSecurity Require -Protocol TCP -LocalPort Any -RemotePort 5985 -LocalAddress Any -RemoteAddress Any 



##############################################################################
#
# Optional Clean Up
#
##############################################################################

# Delete the IPsecRules created above:
Get-NetIPsecRule -DisplayName 'IPsec*' | Remove-NetIPsecRule

# Uncomment this line to do THE PURGE:
# Purge-AllIPsecSettings




##############################################################################
#
# What about IKEv2 in tunnel mode?  This is currently blocked in PoSh, with
# the exception of creating VPN connectoids which use IKEv2.  NETSH.EXE can 
# be used to manage RRAS as an IKEv2 gateway.
#
# Hence, the following code will NOT work to create an IKEv2 tunnel:
##############################################################################

$IPsec3Tunnel = @{
    IPsecRuleName = 'IPsec3'
    DisplayName = 'IPsec3'
    KeyModule = 'IKEv2' #IKEv1 and AuthIP work fine, IKEv2 throws "choice of key modules is invalid"
    Mode = 'Tunnel' 
    LocalAddress =         '192.168.1.0/24'     #Local LAN network ID for routing
    LocalTunnelEndpoint =  '192.168.1.204'      #My public IP as a gateway
    RemoteAddress =        '204.51.94.0/24'     #Remote LAN network ID for routing
    RemoteTunnelEndpoint = '204.51.94.202'      #Remote gateway's public IP
    InboundSecurity =  'Require' 
    OutboundSecurity = 'Require' 
    Phase1AuthSet = ($P1MachineCertOnly.Name)
}

$IPsec3 = New-NetIPsecRule @IPsec3Tunnel   #Not working, throws "The choice of key modules is invalid"...???  

Remove-NetIPsecRule -DisplayName 'IPsec3'





<#############################################################################
MISC NOTES:

* When creating an IKEv2 rule, you might not get an error in PoSh, the rule might become 
visible in the WF snap-in, but the Security log can show an error that the 
rule was not applied (Category: MPSSVC Rule-Level Policy Change, ID: 4958).
Or, there might be no error in the Security log at and the rule will simply
not be applied at all, e.g., if Kerberos is specified for the IKEv2 rule.  

* When you run this command, $ThisCaString is case-sensitive:

    New-NetIPsecAuthProposal -Machine -Cert -Authority $ThisCaString

The connection will fail if $ThisCaString does not exactly match the Subject field
in the CA's own cert.  However, these two CA Subject strings are treated as
identical, they both work:

    "DC=local, DC=testing, CN=Testing-CA"
    "DC=local,DC=testing,CN=Testing-CA"

* When creating an AuthProposalSet, it must either be just PSK or just cert.  It 
cannot be both cert and PSK.  It cannot be Kerberos, NTLM or any other auth method.
Using anything other than just PSK or just cert will not show any errors in PoSh
or in the Security event log, does not block the selected traffic, does not 
trigger any IKE negotiations, it just does nothing (other than creating a visible
ConSecRule in the WF snap-in, a rule which does nothing).


* Do not use the -Phase2AuthSet parameter.  This will not show any errors in PoSh
or in the Security event log, does not block the selected traffic, does not 
trigger any IKE negotiations, it just does nothing (other than creating a visible
ConSecRule in the WF snap-in, a rule which does nothing).  There is no need then
to run New-NetIPsecPhase2AuthSet or "New-NetIPsecAuthProposal -User".

* In a script to manage IKEv2 rules, purge everything first, only create one
MainModeCryptoSet and use the -Default switch when you do so.  

* Whenever you create a new IPsec item, it creates an additional item 
even if an item with the same DisplayName already exists.  Said another way, you 
can have multiple IPsec items with the same DisplayName, but not the same Name.
Hence, IPsec config scripts usually should first purge all existing IPsec objects
before creating new ones, then use the -Name parameter to help duplicates. If
you try to create a duplicate IPsec object with the same name as an existing
object, you will get a "Catastrophic failure" error.  

* Just because intellisense shows an argument for a parameter does not mean
that that argument is always legal or will resulting in a functioning policy.

* Windows IKEv2 does not support IKEv2 fragmentation. Large UDP packets 
containing certificates will often be fragmented at the IP layer, then dropped 
by routers or firewalls configured to drop IP fragments. 

* For Azure IKEv2 connections at least, Microsoft recommends a TCP MSS of 1350.

#############################################################################>
