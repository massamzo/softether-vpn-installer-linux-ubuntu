#! /usr/bin/bash
INSTALLATION_PATH="vpn_install"
INSTALLATION_LINK="https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.41-9782-beta/softether-vpnserver-v4.41-9782-beta-2022.11.17-linux-arm64-64bit.tar.gz"
IP="127.0.0.1:"
PORT="5555"
PASSWORD="massam123"
MAIN_USER="massamlocal"
MAIN_PSWD="massam123"
HUB="DEFAULT"
OPENVPN_FOLDER="openVpnFiles"
OPENVPN_FILE_TAR=openVpnConfiguration


askInformation () {


    read -p "PORT ($PORT) : " porta
    len=${#porta}
    if [ $len -gt 1 ]; then
        PORT=$porta

    fi

    read -p "PRIVILEGE PSWD ($PASSWORD) : " pswd
    len=${#psw}
    if [ $len -gt 1 ]; then
        PASSWORD=$pswd

    fi

    read -p "MAIN USER ($MAIN_USER) : " user
    len=${#user}
    if [ $len -gt 1 ]; then
        MAIN_USER=$user

    fi

    read -p "MAIN PASSWORD ($MAIN_PSWD) : " pswdo
    len=${#pswdo}
    if [ $len -gt 1 ]; then
        MAIN_PSWD=$pswdo
    fi

    read -p "HUB ($HUB) : " hub
    len=${#hub}
    if [ $len -gt 1 ]; then
        HUB=$hub
    fi
    
}


print_information(){

    echo -e "------------------- DETAILS -----------"

    echo "PORT : $PORT"
    echo "PRIVILEGE PSWD : $PASSWORD"
    echo "MAIN USER : $MAIN_USER"
    echo "MAIN PSWD : $MAIN_PSWD"
    echo "HUB : $HUB"
}

install_make () {

    sudo apt-get install build-essential gnupg2 gcc make -y

    #installing packages
    sudo apt install gcc binutils gzip libreadline-dev libssl-dev libncurses5-dev libncursesw5-dev libpthread-stubs0-dev


}

open_ports () {

    sudo ufw allow 80,443,992,1194,5555/tcp
    sudo ufw allow 80,443,992,1194,5555/udp
    sudo ufw allow 1194,51612,53400,56452,40085/udp

    #update firewall
    ufw reload

}

#check if the folder where to install the vpn exists


read -p "cpu type (arm 64 (1) or intel 64 (2)) DEFAULT (1): " cpu

if [ $cpu == 2 ];
then
    
    INSTALLATION_LINK="https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.39-9772-beta/softether-vpnserver-v4.39-9772-beta-2022.04.26-linux-x64-64bit.tar.gz"
fi

echo $INSTALLATION_LINK


if ! test -d ./$INSTALLATION_PATH ; #if doesn't exists
then
    mkdir $INSTALLATION_PATH

else
    cd $INSTALLATION_PATH  #if the folder exists it creates another inside it
fi


echo -e ""
print_information
echo -e ""
read -p "use default values (y/n) : " choice
if [ "$choice" == "n" ]; then

   askInformation
fi

echo -e ""
print_information


#install the softethervpn package
sleep 1
cd $INSTALLATION_PATH

pwd 

wget $INSTALLATION_LINK

#get the name of the package (splitting string)

IFS="/" # delimiter
read -ra parts <<< $INSTALLATION_LINK

fileToExtract="${parts[-1]}"

echo -e " -------------- extracting ----------------"
#extract the package
tar -xvzf $fileToExtract
pwd

rm $fileToExtract

cd vpnserver


echo -e "--------- installing dependencies -----------"
#insatlling make packages / dependencies
install_make

#build the package
make main



echo -e "--------------- opening ports ------------"
#open Ports
open_ports

#start the server

sudo ./vpnserver start
sudo ./vpnserver stop

echo -e " VPN SERVER STARTED "
current_path=$(pwd)

echo -e "----------- CREATING SERVICE -------"
percorsocorrente="$(pwd)"
userlocal="$(whoami)"
#entering the servcie folder

cd /etc/systemd/system

servicePath="softether-vpnserver.service"
#creating a service that needs to  be run on boot
sudo echo "[Unit]" > $servicePath #creates the file

#appending into the file
sudo echo -e >> $servicePath
sudo echo "Description=SoftEther VPN server" >> $servicePath
sudo echo -e >> $servicePath
sudo echo "After=network-online.target" >> $servicePath
sudo echo -e >> $servicePath
sudo echo "After=dbus.service" >> $servicePath

sudo echo -e >> $servicePath
sudo echo "[Service]" >> $servicePath

sudo echo -e >> $servicePath
sudo echo "Type=forking" >> $servicePath
sudo echo -e >> $servicePath
sudo echo "ExecStart=$percorsocorrente/vpnserver start" >> $servicePath
sudo echo -e >> $servicePath
sudo echo "ExecReload=/bin/kill -HUP $'MAINPID'" >> $servicePath

# sudo echo -e >> $servicePath
# sudo echo "User=$userlocal" >> $servicePath

sudo echo -e >> $servicePath
sudo echo "[Install]" >> $servicePath
sudo echo -e >> $servicePath
sudo echo "WantedBy=multi-user.target" >> $servicePath

sleep 1
echo -e "----------- starting the service ------------"

sudo systemctl daemon-reload
sudo systemctl start softether-vpnserver.service
sudo systemctl enable softether-vpnserver.service



cd "$current_path"

echo "current path : $current_path"

echo -e "running the cli... "

#run the cli 

localhost="$IP$PORT"

(
    echo 1
    sleep 1
    echo $localhost
    sleep 1
    echo
    sleep 1
    echo ServerPasswordSet
    sleep 1
    echo $PASSWORD
    sleep 1
    echo $PASSWORD
    sleep 1
    echo hub $HUB
    sleep 1
    echo UserCreate $MAIN_USER
    sleep 1
    echo
    echo
    echo
    sleep 1
    echo UserPasswordSet $MAIN_USER
    sleep 1
    echo $MAIN_PSWD
    sleep 1
    echo $MAIN_PSWD
    sleep 1
    echo BridgeDeviceList
    sleep 1
    read -p "network device : " NTDEVICE
    sleep 2
    echo BridgeCreate
    sleep 1
    echo $HUB
    sleep 1
    echo $NTDEVICE
    sleep 1
    echo OpenVpnMakeConfig
    sleep 1
    echo $OPENVPN_FILE_TAR

)| sudo ./vpncmd



# moving the files into another folder

cd ..
mkdir $OPENVPN_FOLDER
cd vpnserver

openFolder="$OPENVPN_FILE_TAR.zip"

#move into folder
sudo mv $openFolder ../$OPENVPN_FOLDER

#extraxt
cd ../$OPENVPN_FOLDER
sudo unzip $openFolder
sudo rm $openFolder

pwd

cd ..
cd vpnserver


echo -e "----- SUCCESSFULLY INSTALLED --------"
