#!/bin/bash

set -xe

# NOTE: All the file location are based on project root directory


# Environment
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

JAVA_VERSION=$(grep java apps | awk -F "=" '{print $2}')


echo "${green}This script can only install Oracle JAVA ${normal}"

sudo -E -s -- << EOF
cat > /etc/default/java <<EOL
export JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-oracle
export PATH=${PATH}:/usr/lib/jvm/java-${JAVA_VERSION}-oracle/bin
EOL

# add a line which sources /etc/default/etcd in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/java' /etc/environment || echo '. /etc/default/java' >> /etc/environment

# source the enviroment variables in the current shell
source /etc/environment


# Add the Orcale java repository
if [ -f /etc/apt/sources.list.d/webupd8team*.list   ]; then
    echo "${green}Oracle java repository is already added to repository list ${normal}"
else
    echo "${green}Adding Oracle JAVA repository  ${normal}"
    yes |  sudo add-apt-repository ppa:webupd8team/java
fi

sudo apt update

export DEBIAN_FRONTEND=noninteractive

# Accept Java License agreement using debconf-set-selections
cat <<EOL | debconf-set-selections
oracle-java8-installer shared/accepted-oracle-license-v1-1 boolean true
EOL

dpkg-reconfigure -f noninteractive oracle-java8-installer || true

EOF

install_java()
{
    echo "${green} Installing oracle-java${JAVA_VERSION} ${normal}"
    yes | sudo apt-get install oracle-java${JAVA_VERSION}-installer
}



if [ -x "$(command -v java)" ]; then
    echo  "${bold}${green}java is already installed"
    $(java -version ) ${normal}
    echo "${red} Skipping Java installation as already present ${normal}"
	exit 0
else
	install_java
fi


# In case of dpkg query error run:
#sudo rm /var/lib/dpkg/info/oracle-java8-installer.postinst -f
#sudo dpkg --configure oracle-java8-installer
#sudo dpkg-reconfigure oracle-java8-installer