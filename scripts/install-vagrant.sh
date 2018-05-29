#!/bin/bash

set -xe 

# NOTE: All the file location are based on project root directory

# Environment
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)


VAGRANT_VERSION=$(grep vagrant apps | awk -F "=" '{print $2}')
DOWNLOAD_URL=https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb
BINARY_FILENAME=$(basename ${DOWNLOAD_URL} )


if [ -x "$(command -v vagrant)" ]; then
	echo 'Vagrant is already installed' >&2
	echo 'Skipping vagrant installation' 
	exit 0

else
	if [ -f temp_download/${BINARY_FILENAME} ] ; then 
		echo "Using already downloaded ${BINARY_FILENAME} file"
	else
		echo "${bold}Downloading ${BINARY_FILENAME} ...${normal}"
		wget ${DOWNLOAD_URL} -O temp_download/${BINARY_FILENAME} > /dev/null 2>&1
	fi
	
	echo "Installing vagrant ..."
	sudo dpkg -i temp_download/${BINARY_FILENAME}  > /dev/null 2>&1
	
	until vagrant version | grep ${VAGRANT_VERSION} 
	do
		echo "Waiting for vagrant installation to be completed .."
		sleep 2
	done
	
	echo "Successfully installed Vagrant ${VAGRANT_VERSION}"
fi


# Bash Completion
##################
echo "${green}Setting up vagrant bash completion${normal}"
VAGRANT_BASH_COMPLETION_FILE_URL=https://raw.githubusercontent.com/hashicorp/vagrant/master/contrib/bash/completion.sh
VAGRANT_BASH_COMPLETION_EXIST=$(curl -sfI ${VAGRANT_BASH_COMPLETION_FILE_URL} | grep '200')
if [ "${VAGRANT_BASH_COMPLETION_EXIST}" ]; then
    sudo wget ${VAGRANT_BASH_COMPLETION_FILE_URL} -O  /etc/bash_completion.d/VBoxManage > /dev/null 2>&1

fi


exit 0
