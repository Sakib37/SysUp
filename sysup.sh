#!/bin/bash

# Developer:  Mohammad Badruzzaman < shakib37@ymail.com>
# Date     :  16.05.2018

echo "
		||==========================================||
		||   _____                 _    _   _____   ||
		||  / ____|               | |  | | |  __ \  ||
		|| | (___    _   _   ___  | |  | | | |__) | ||
		||  \___ \  | | | | / __| | |  | | |  ___/  ||
		||  ____) | | |_| | \__ \ | |__| | | |      ||
		|| |_____/   \__, | |___/  \____/  |_|      ||
		||            __/ |                         ||
		||           |___/                          ||
		||==========================================||
"
# Environment 
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)


DISTRIBUTION_NAME=$(lsb_release -i | awk '{print $3}')
DISTRIBUTION_CODENAME=$(lsb_release -c | awk '{print $2}')
DISTRIBUTION_VERSION=$(lsb_release -r | awk '{print $2}')

echo "Detected installed OS:  ${bold}${DISTRIBUTION_NAME} ${DISTRIBUTION_VERSION} ${DISTRIBUTION_CODENAME}${normal}"

$(pwd)/scripts/general-packages.sh

echo -e "\n#########################################\n"
echo "${bold}${green}Installing following softwares:"
grep -v '^#' apps
${normal}
echo -e "\n#########################################\n"
for app in $(grep -v '^#' apps | awk -F "=" '{print $1}')
do
	if [  -f  $(pwd)/scripts/install-${app}.sh  ] ; then 
		echo -e "\n${bold}Setting up ${app} ${normal}"
		$(pwd)/scripts/install-${app}.sh
	else 
		echo -e "\n${bold}${red}Error: No installation script found for ${app} in $(pwd)/scripts ${normal}"
		echo "Skipping ${app} installation"
	fi
done
