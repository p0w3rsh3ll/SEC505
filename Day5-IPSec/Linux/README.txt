Windows IPsec and Linux IPsec can interoperate.  This folder contains a sample 
configuration file (swanctl.conf) for the strongSwan IPsec solution for Linux:

    https://www.strongswan.org


## Install strongSwan on Debian/Ubuntu/Mint: 
sudo apt install -y strongswan strongswan-swanctl
sudo systemctl enable strongswan
sudo systemctl start strongswan


## Remove any existing custom conf files:
sudo rm -v /etc/swanctl/conf.d/*.conf


## Copy in your own custom conf file(s):
sudo cp myfile.conf /etc/swanctl/conf.d 


## Restart the strongSwan service:
sudo systemctl restart strongswan


## In a script, sleep for a second (otherwise, you'll get errors):
sleep 1 


## Reload the config file:
sudo swanctl --load-all 


## Ping the Windows machine and confirm success:
sudo swanctl --list-sas 




#################################
#        NOTES & TODO
#################################
Confirm that the remote_ts and local_ts traffic selectors must include a [protocol] or else Windows will reject the quick mode SA.  

See https://wiki.strongswan.org/projects/strongswan/wiki/Swanctlconf and all the special IKEv1 notes.

Jason, need to create more examples for IKEv2, cert auth, multiple selectors, etc.


