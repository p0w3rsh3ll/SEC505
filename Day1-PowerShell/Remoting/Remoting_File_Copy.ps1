# PowerShell 5.0 and later supports the copying of files through
# the remoting channel itself, which means no additional ports
# must be opened between source and destination machines other
# than the already-open remoting port(s).


# Create a session to a remote host with PoSh 5.0+:

$session = New-PSSession -ComputerName dc.testing.local

 

# Upload a file to the remote host (-ToSession):

copy -Path C:\LocalFolder\file.txt -Destination C:\RemoteFolder\file.txt -ToSession $session



# Download a file from the remote host (-FromSession):

copy -Path C:\RemoteFolder\file.txt -Destination C:\LocalFolder\file.txt -FromSession $session



# Caveats:
# You cannot remote into two hosts (A and B) and copy files between them (A <-> B) using your two sessions.



# PowerShell Direct
# If you have Windows 10, Server 2016 or later on 1) a system running Hyper-V as
# a host and also 2) in a VM guest running on that host, then all of the above
# remoting commands can be used from Host -> Guest VM using the Hyper-V VMBus.
# This means that the VM guest does not have to be accessible over the network
# and does not require any TCP/UDP ports to be opened.  The VMBus is a communications
# shared memory buffer implemented by the Hyper-V hypervisor, it does not use
# the protocol stack on either the host server or the guest VM.  Again, both host
# and guest must be Windows 10, Server 2016 or later, PowerShell must be running
# elevated, and you must be a member of the Administrators group in the guest VM.


