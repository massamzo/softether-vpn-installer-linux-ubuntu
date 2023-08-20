#! /usr/bin/bash

INSTALLATION_PATH="vpn_install"

#UNINSTALLING EVERYTHING

#updating firewall
sudo ufw delete allow 80,443,992,1194,5555/tcp
sudo ufw delete allow 80,443,992,1194,5555/udp
sudo ufw delete allow 1194,51612,53400,56452,40085/udp

#update firewall
ufw reload

#stopping the service
cd $INSTALLATION_PATH
cd vpnserver

sudo ./vpnserver stop


#deleting the folder 
cd ..
cd ..

sudo rm -r $INSTALLATION_PATH

echo -e "---------- SUCCESSFULLY DELETED -----------"
