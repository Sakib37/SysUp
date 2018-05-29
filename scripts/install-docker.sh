#!/bin/bash

set -xe

# NOTE: All the file location are based on project root directory


# Environment 
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

echo "${green}This script can only install docker in x64 system${normal}"

DOCKER_VERSION=$(grep docker apps | awk -F "=" '{print $2}')
OS_DISTRIBUTION=$(lsb_release -i | cut -f2 |  awk '{print tolower($0)}' )
#OS_CODENAME=$(lsb_release -c | cut -f2)
# Docker still not available for Ubuntu 18.04. So using the binary for xenial
OS_CODENAME=artful
DOCKER_BINARY_FILENAME=$(curl -ss https://download.docker.com/linux/${OS_DISTRIBUTION}/dists/${OS_CODENAME}/pool/stable/amd64/ | grep "${DOCKER_VERSION}" | awk '{split($0,file,"\""); print file[2]}')
DOCKER_DOWNLOAD_URL=https://download.docker.com/linux/${OS_DISTRIBUTION}/dists/${OS_CODENAME}/pool/stable/amd64/${DOCKER_BINARY_FILENAME}


install_docker()
{
    if [ -f temp_download/${DOCKER_BINARY_FILENAME} ] ; then
        echo "Using already downloaded ${DOCKER_BINARY_FILENAME} file"
    else
        echo "${bold}Downloading docker-${DOCKER_VERSION} ... ${normal}"
        DOCKER_BIANARY_EXIST=$(curl -sfI ${DOCKER_DOWNLOAD_URL} | grep '200' )
        if [  "${DOCKER_BIANARY_EXIST}"  ]; then
            wget ${DOCKER_DOWNLOAD_URL} -O temp_download/${DOCKER_BINARY_FILENAME}
        else
            echo "${bold}${red}Error: Cannot find a valid file ${DOCKER_BINARY_FILENAME} in ${DOCKER_DOWNLOAD_URL} ${normal}"
            echo "${bold}${red}docker-${DOCKER_VERSION} is not installed ${normal}"
            exit 1
        fi
    fi
    echo "${bold}Installing docker-${DOCKER_VERSION} ${normal}"
    sudo dpkg -i  temp_download/${DOCKER_BINARY_FILENAME} 
}



if [ -x "$(command -v docker)" ]; then
    INSTALLED_VERSION=$(docker version --format '{{.Server.Version}}' | sed -r 's/-/~/' )
    if [ ${INSTALLED_VERSION} == ${DOCKER_VERSION} ]; then
        echo  "${bold}docker ${INSTALLED_VERSION} is already installed${normal}"
	exit 0
    else
	sudo apt-get remove docker docker-engine docker.io docker-ce  -y > /dev/null 2>&1
	sudo dpkg --purge docker-ce  || true
        install_docker
    fi

else
    install_docker
fi

# Docker post installation steps
sudo groupadd docker || true
sudo usermod -aG docker $USER || true
sleep 2
newgrp docker || true


# Bash Completion
##################
echo "${bold}Setting up docker bash completion${normal}"
sudo curl -L https://raw.githubusercontent.com/docker/compose/1.21.2/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

exit 0