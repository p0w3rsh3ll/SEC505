# This script demos how to configure a Windows computer
# as a wireless access point with netsh.exe.  Microsoft
# calls such an access point a "hosted network."  


# Stop the current hosted network, if started.
netsh.exe wlan stop hostednetwork

# Create the hosted network, SSID and pre-shared key.
netsh.exe wlan set hostednetwork mode=allow ssid="FBI Surveillance Van" key=TheSekritPreSharedWirelessKey

# Start the hosted network.
netsh.exe wlan start hostednetwork

# Show current settings.
start-sleep -seconds 3
netsh.exe wlan show hostednetwork

read-host "Hit any key to stop..."
# Stop the current hosted network.
netsh.exe wlan stop hostednetwork



# Notes:
# Requires Windows 7, Server 2008-R2, or later.
# Requires local Administrators membership.
# Sets network profile type to "Private" on the interface.
# 'FBI' stands for Food & Beverage Institute of Norway.




