# Peer Name Resolution Protocol (PNRP) is an alternative to DNS for
# name resolution on IPv6 networks.  PNRP is only for IPv6, not IPv4.
# PNRP is rarely used.  To disable PNRP, disable the two Windows
# services which implement it (below) and block UDP 3540 on IPv6.


Set-Service -Name PNRPAutoReg -StartupType Disabled -Status Stopped

Set-Service -Name PNRPsvc -StartupType Disabled -Status Stopped


# Simple Service Discovery Protocol (SSDP) and Universal Plug and
# Play (UPnP) are used in home and small offices to advertise and
# discover network services on devices, such as printers, media
# players and wireless access points with Internet connectivity.
# SSDP are UPnP are rarely used in enterprise environments.  To
# disable SSDP, block multicast UDP port 1900, and disable the
# SSDP Discovery service (SSDPSRV).  To disable UPnP, block TC
# 2869 and disable the UPnP Device Host service (upnphost).

Set-Service -Name SSDPSRV -StartupType Disabled -Status Stopped

Set-Service -Name upnphost -StartupType Disabled -Status Stopped






