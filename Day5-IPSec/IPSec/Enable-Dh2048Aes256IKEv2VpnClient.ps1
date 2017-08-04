<#############################################################################
.SYNOPSIS
Enable Diffie-Hellman 2048 and AES 256 for IKEv2 VPN clients.

.DESCRIPTION
Some versions of Windows use relatively weak encryption for IKEv2 VPNs by 
default.  See Microsoft's technical paper entitled "Microsoft Windows 8, 
Microsoft Windows Server 2012, Microsoft Windows RT Common Criteria 
Supplemental Admin Guidance for IPsec VPN Clients", which was last seen at:

http://download.microsoft.com/download/A/9/F/A9FD7E2D-023B-4925-A62F-58A7F1A6BD47/Microsoft%20Windows%208%20Windows%20Server%202012%20Supplemental%20Admin%20Guidance%20IPsec%20VPN%20Client.docx

#############################################################################>


REG.EXE ADD HKLM\SYSTEM\CurrentControlSet\Services\RasMan\Parameters /v NegotiateDH2048_AES256 /t REG_DWORD /d 0x2 /f


