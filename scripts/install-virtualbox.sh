#!/bin/bash

# Virtualbox ususally have dependency proble. So 'set -xe' is not used here
set -x

# NOTE: All the file location are based on project root directory


# Environment 
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

echo "${green}This script can only install virtualbox in x64 system${normal}"

VBOX_VERSION=$(grep virtualbox apps | awk -F "=" '{print $2}')
VBOX_MAJOR_VERSION=$(echo $VBOX_VERSION  | rev | cut -d"." -f2- | rev)
OS_DISTRIBUTION=$(lsb_release -i | cut -f2)
OS_CODENAME=$(lsb_release -c | cut -f2)
VBOX_BINARY_FILENAME=$(curl -ss https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/ |  grep ${OS_CODENAME} | grep amd64  | awk '{split($0,file,"\""); print file[2]}')
VBOX_DOWNLOAD_URL=https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/${VBOX_BINARY_FILENAME}
VBOX_EXTENSION_PACK=Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}.vbox-extpack
EXTENSTION_PACK_DOWNLOAD_URL=https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/${VBOX_EXTENSION_PACK}


install_virtualbox()
{
    if [ -f temp_download/${VBOX_BINARY_FILENAME} ] ; then 
        echo "Using already downloaded ${VBOX_BINARY_FILENAME} file"
    else
    	echo "${bold}Downloading virtualbox-${VBOX_VERSION} ... ${normal}"
        VBOX_BIANARY_EXIST=$(curl -sfI ${VBOX_DOWNLOAD_URL} | grep '200' ) 
  	if [  "${VBOX_BIANARY_EXIST}"  ]; then
	    wget ${VBOX_DOWNLOAD_URL} -O temp_download/${VBOX_BINARY_FILENAME} 
	else
	    echo "${bold}${red}Error: Cannot find a valid file ${VBOX_BINARY_FILENAME} in ${VBOX_DOWNLOAD_URL} ${normal}"
	    echo "${bold}${red}virtualbox-${VBOX_VERSION} is not installed ${normal}"
	    exit 1
	fi
    fi
    echo "${bold}Installing virtualbox-${VBOX_VERSION} ${normal}"
    sudo dpkg -i  temp_download/${VBOX_BINARY_FILENAME} || true
    sudo apt install -f -y > /dev/null 2>&1
}


if [ -x "$(command -v VBoxManage)" ]; then 
    INSTALLED_VERSION=$(VBoxManage --version | awk -F "r" '{print $1}' )
    INSTALLED_MAJOR_VERSION=$(echo ${INSTALLED_VERSION}  | rev | cut -d"." -f2- | rev)
    if [ ${INSTALLED_VERSION} == ${VBOX_VERSION} ]; then 
       	echo  "${bold}virtualbox-${INSTALLED_VERSION} is already installed${normal}"
	exit 0
    else 
        sudo dpkg --purge virtualbox-${INSTALLED_MAJOR_VERSION}
	install_virtualbox
    fi

else
    install_virtualbox
fi


# EXTENSION PACK
################

if [ -f temp_download/${VBOX_EXTENSION_PACK} ] ; then
    echo "Using already downloaded ${VBOX_EXTENSION_PACK} file"
else
    echo "Downloading ${VBOX_EXTENSION_PACK} ..."
    wget ${EXTENSTION_PACK_DOWNLOAD_URL} -O temp_download/${VBOX_EXTENSION_PACK} > /dev/null 2>&1
fi

echo "${green}Installing virtualbox extension pack ..${normal}"
yes | sudo VBoxManage extpack install --replace  temp_download/${VBOX_EXTENSION_PACK} > /dev/null 2>&1


# Bash Completion
##################
VBOX_BASH_COMPLETION_FILE_URL=https://raw.githubusercontent.com/gryf/vboxmanage-bash-completion/master/VBoxManage
VBOX_BASH_COMPLETION_EXIST=$(curl -sfI ${VBOX_BASH_COMPLETION_FILE_URL} | grep '200' ) 
if [  "${VBOX_BASH_COMPLETION_EXIST}"  ]; then 
    sudo wget ${VBOX_BASH_COMPLETION_FILE_URL} -O  /etc/bash_completion.d/VBoxManage > /dev/null 2>&1	

fi 

exit 0  


# Extra commands
# VBoxManage list extpacks
# sudo VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"
