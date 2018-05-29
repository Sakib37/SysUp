#!/bin/bash

set -xe 

# This script install notes app in debian/ubuntu
# Source: www.get-notes.com/linux-download-debian-ubuntu/

# Downloading notes is a bit tricky and it does not work always
# So downloaded it already in the temp_download directory

# Environment 
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)
if [ -x "$(command -v VBoxManage)" ]; then
    echo  "${bold}Notes is already installed${normal}"
    exit 0
else
    echo "${bold}${green}Installing Notes app ${normal}"
    sudo dpkg -i temp_download/notes_1.0.0_amd64-zesty.deb || true
    sudo apt install -f -y
fi
