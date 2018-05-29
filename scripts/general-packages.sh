#!/bin/bash

echo "Updating the repositories ..."
sudo apt update > /dev/null 2>&1

sudo apt install -y vim \
		curl \
		git  \
		python3 \
	    gcc \
		make \
		perl \
		debconf-utils \ 
		libcanberra-gtk-module \
		software-properties-common
			
