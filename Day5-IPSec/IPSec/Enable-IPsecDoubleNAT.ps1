<#############################################################################
.SYNOPSIS
Enable IPsec for double-NAT scenarios.

.DESCRIPTION
Windows Vista, Server 2008 and later operating systems by default cannot
establish IPsec connections when two or more routers, firewalls or wireless
access points in between the IPsec peers are using Network Address
Translation (NAT).  For example, when a laptop behind a hotel NAT attempts
to open an IPsec VPN to a gateway behind a firewall that also performs NAT.
This is true even when the NAT-T extension to IPsec is enabled.

See KB926179 for more information about the double-NAT scenarios and the
following registry value for NAT-T.

When the AssumeUDPEncapsulationContextOnSendRule registry value is set to 0x2
on both the IPsec peers, however, the double-NATing is tolerated and the
IPsec connection succeeds.  There is a small security disadvantage for this.

#############################################################################>


REG.EXE ADD HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f

