#!/bin/dash 

# This just speeds up strongSwan config testing; run with sudo.

if [ $# -ne 1 ];
then
    echo "Required argument missing, needs path to strongSwan config file, quitting..."
    exit 1
fi

rm -v /etc/swanctl/conf.d/*.conf

echo ''

cp -v $1 /etc/swanctl/conf.d 

echo ''

systemctl restart strongswan  

sleep 1

echo ''

swanctl --load-all 

echo ''

swanctl --list-conns

echo ''




