#!/bin/bash

defaultPath="opt/massam/service/"
foldername="softetherVpn_Installation"
user="orangepi"
DEB_NAME="softetherVpn"
deb_info_file="control"
description="This service is used to install and uninstall softetherVpn on the device"
version="1"

function copyFiles {

    search="*"
    for file in $search
    do
       
        if [[ "$file" == *"."* ]] && [[ "$file" != "make_deb.sh" ]];
        then 
            #copy file to the path
            sudo cp "$file" "$DEB_NAME/$defaultPath$foldername"

        fi
    done

}

function myLocation {
    location="$(pwd)"
    echo -e "Directory: $location"
}

#creation of a folder
mkdir $DEB_NAME && cd $DEB_NAME
myLocation

#creation of DEBIAN folder
mkdir "DEBIAN" && cd DEBIAN
myLocation

echo "Package: $DEB_NAME" >> $deb_info_file
echo "Version: $version" >> $deb_info_file
echo "Maintainer: $user" >> $deb_info_file
echo "Architecture: all" >> $deb_info_file
echo "Description: $description" >> $deb_info_file


cd ..
myLocation
#creation of the defaultPath

mkdir -p "$defaultPath$foldername"

# sudo chown -R $user:$user "$defaultPath$foldername"

cd ..
myLocation

copyFiles


#build the deb package
sleep 1
sudo dpkg --build "$DEB_NAME"
sudo rm -r "$DEB_NAME"

echo "DEB CREATED SUCCESSFULLY"

echo "$DEB_NAME.deb"
