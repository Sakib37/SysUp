#!/bin/bash

set -x

# NOTE: All the file location are based on project root directory


# Environment 
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)


INTELLIJ_VERSION=$(grep intellijIdea apps | awk -F "=" '{print $2}')
INTELLIJ_BINARY_FILENAME=ideaIU-${INTELLIJ_VERSION}.tar.gz
INTELLIJ_DOWNLAOD_URL=https://download.jetbrains.com/idea/${INTELLIJ_BINARY_FILENAME}
INTELLIJ_INSTALLATION_DIRECTORY=/opt/Intellij


if [[ -d ${INTELLIJ_INSTALLATION_DIRECTORY}  ||  -d ${HOME}/.IntelliJIdea ]]; then
    echo -e "${bold}${green}It seems IntellijIdea is already installed. \nIn order to reninstall, Please remove following directories before running this script again \n${red}${INTELLIJ_INSTALLATION_DIRECTORY} \n${HOME}/.IntelliJIdea ${normal} "
    exit 0
fi

sudo mkdir -p ${INTELLIJ_INSTALLATION_DIRECTORY}

if [ -f temp_download/${INTELLIJ_BINARY_FILENAME} ] ; then
    echo "${bold}Using already downloaded ${INTELLIJ_BINARY_FILENAME} file${normal}"
else
    echo "${bold}Downloading intellijIdea-${INTELLIJ_VERSION} ... ${normal}"
    INTELLIJ_BIANARY_EXIST=$(curl -sfI ${INTELLIJ_DOWNLOAD_URL} | grep '200' )
    if [  "${INTELLIJ_BIANARY_EXIST}"  ]; then
        wget ${INTELLIJ_DOWNLOAD_URL} -O temp_download/${INTELLIJ_BINARY_FILENAME}
    else
        echo "${bold}${red}Error: Cannot find a valid file ${INTELLIJ_BINARY_FILENAME} in ${INTELLIJ_DOWNLOAD_URL} ${normal}"
        echo "${bold}${red}IntellijIdea ${INTELLIJ_VERSION} is not installed ${normal}"
        exit 1
    fi
fi

sudo tar -xvf temp_download/${INTELLIJ_BINARY_FILENAME} -C /opt/Intellij --strip-components=1 > /dev/null 2>&1
/opt/Intellij/bin/idea.sh
echo "Successfully installed IntellijIdea"
exit 0

# To uninstall Intellij
#echo "${red}Uninstalling IntellijIdea ${normal}"
#sudo rm -r /opt/Intellij  \
#	~/.IntelliJIdea   \
#	$HOME/.local/share/applications/jetbrains-idea-ce*  \
#	/usr/share/applications/jetbrains-idea.desktop \
#        .java/.userPrefs/jetbrains/idea
