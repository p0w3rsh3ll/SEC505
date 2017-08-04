<#############################################################################
.SYNOPSIS
Enable DH Group 14 and AES 256 for IKEv2 VPN Win8 clients.

.DESCRIPTION
Some versions of Windows use relatively weak encryption for IKEv2 VPNs by 
default.  See Microsoft's technical paper entitled "Microsoft Windows 8, 
Microsoft Windows Server 2012, Microsoft Windows RT Common Criteria 
Supplemental Admin Guidance for IPsec VPN Clients", which was last seen at:

http://download.microsoft.com/download/A/9/F/A9FD7E2D-023B-4925-A62F-58A7F1A6BD47/Microsoft%20Windows%208%20Windows%20Server%202012%20Supplemental%20Admin%20Guidance%20IPsec%20VPN%20Client.docx

For IKEv2 on Windows 8:
    MM: DH14 AES256 SHA256
    QM: AES256-SHA1(HMAC)
    
For L2TP and IKEv1 on Windows 8:
    MM: DH14-SHA1-AES128
    QM: AES128-SHA1

For Windows 10 and later, however, see Set-VpnConnectionIPsecConfiguration.
On Windows 10 and later, use PowerShell, don't mess with this registry value.
#############################################################################>


REG.EXE ADD HKLM\SYSTEM\CurrentControlSet\Services\RasMan\Parameters /v NegotiateDH2048_AES256 /t REG_DWORD /d 0x2 /f


