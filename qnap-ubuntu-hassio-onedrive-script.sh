#!/bin/bash
# Fresh install, backup or restore HASSIO on QNAPTS251 running Ubuntu
# Author: opdoffer
exec 1 2>&1 | tee ${~/qnap-ubuntu-hassio-onedrive-script.log}

## ----------------------------------
# Define custom variables
# ----------------------------------
onedrivefoldercurrent="container-configs-current" #Enter your most current docker container config folder, which you copied to OneDrive and want to recover from
onedrivefolderbackup="container-configs-backup" #Enter the path in OneDrive where backups of your contianer-configs will be synced
hassiobackupfolder="~/hassiobackupfolder"
ip_addresses="[192.168.5.3/24]" #Enter the ip adress and subnet to config you bonding nics in Ubuntu on the QNAP. Entering wrong will end up in an inaccessible server.
gateway4="192.168.5.1" #Enter the ip adress of your gateway to config you bonding nics in Ubuntu on the QNAP. 

## ----------------------------------
# Colors - do not change below
# ----------------------------------
RED='\033[0;31m \e[1m'
NC='\033[0m' # No Color
DATE=`date +%d-%m-%y-%H-%M`



# ----------------------------------------------
# Clean INSTALLATION of Docker and HASSIO
# ----------------------------------------------
inst_docker_hassio(){
			printf "\033c"
			echo -e "${RED}Really want to start install of docker and HASSIO?${NC}\n"
			read -p "Press [ENTER] to continue or CTRL-C to abort..."
            install_docker
            install_hassio
}

# -------------------------------------------------------------------------------------
# INSTALLATION of Docker and HASSIO and recovery of config from local backupfolder
# -------------------------------------------------------------------------------------
inst_docker_hassio_localbackupconfig(){
			printf "\033c"
			echo -e "${RED}Really want to start install of docker and HASSIO and recover HASSIO from local config folder?${NC}\n"
			read -p "Press [ENTER] to continue or CTRL-C to abort..."
            install_docker
            install_hassio
       		echo" "
       		echo" "
       		echo -e "${RED}Is the backup of HASSIO located in $hassiobackupfolder? (y/n)  ${NC}\n"
			read answer0
			if [ "$answer0" != "${answer0#[Yy]}" ] ;then
    			echo "You answered yes, assuming  the config of HASSIO is backed-up in $hassiobackupfolder"
    			cp -rv $hassiobackupfolder/* /usr/share/hassio/homeassistant
			else
   			 echo "You answered No, please enter full path of the backupfolder. Example: /home/yourname/hassiobackupfolder"
   			 read answer0a
   			 cp -rv $answer0a/* /usr/share/hassio/homeassistant ; 
			fi
			mkdir ~/hassiobackupfolder
			mkdir ~/hassiobackupfolder/$DATE
			echo "create an axtra backup, just for sure."
			cp -vr /usr/share/hassio/homeassistant/* ~/hassiobackupfolder/$DATE
			echo "Please reboot, it is necessary(!)"
			read -p "Press [ENTER] to continue or CTRL-C to abort..."
}
			
# -------------------------------------------------------------------------------------
# INSTALLATION of Docker and HASSIO and recovery of config from OneDrive backupfolder
# -------------------------------------------------------------------------------------			
inst_docker_hassio_onedrive_containers(){
			printf "\033c"
			echo -e "${RED}Really want to start install of docker and HASSIO and recover HASSIO from OneDrive folder?${NC}\n"
			read -p "Press [ENTER] to continue or CTRL-C to abort..."
			install_docker
			install_hassio
       		install_OneDrive
       		recover_HASSIO_from_Drive
       		echo "Please reboot, it is necessary(!)"
       		read -p "Press [ENTER] to continue or CTRL-C to abort..."
}	

# -------------------------------------------------------------------------------------
# INSTALLATION of OneDrive
# -------------------------------------------------------------------------------------	
install_OneDrive(){
			printf "\033c"
			echo -e "${RED}Really want to start install of OneDrive. Please skip this if you already install Onedrive on this system.${NC}\n"
			read -p "Press [ENTER] to continue or CTRL-C to abort..."
			apt -y install libcurl4-openssl-dev git
			apt -y install libsqlite3-dev
			echo -e "${RED}Are you running Ubuntu 18.04 or higher? (y/n)  ${NC}\n"
			read answer1
			if [ "$answer1" != "${answer1#[Yy]}" ] ;then
    			echo "You answered yes, assuming you have Ubuntu 18.04 or higher"
    			snap install --classic dmd && sudo snap install --classic dub
			else
   			 echo "You answered No, assuming you have an older system"
   			 wget http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list
			 apt-get -y update && sudo apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring
			 apt-get -y update && sudo apt-get install dmd-compiler dub
			fi
			git clone https://github.com/abraunegg/onedrive.git
			cd onedrive
			./configure
			make
			make install
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			echo "Next wil start OneDrive and it will prompt you to visit the URL to get authorization. Log in to your OneDrive account, and grant the app permission to access your account. Once this is done, you will be presented with a blank white page. Copy the URL and paste it into the Terminal at the prompt."
			read -p "Press [Enter] key to continue..."
			onedrive
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""read -p "Was there a successful login? Press [Enter] key to continue..."
			mkdir -p ~/.config/onedrive
			cp ~/onedrive/config ~/ .config/onedrive/config
			echo "$onedrivefoldercurrent" > ~/.config/onedrive/sync_list
			echo "$onedrivefolderbackup" >> ~/.config/onedrive/sync_list
			onedrive --display-config
			onedrive --synchronize
			systemctl --user enable onedrive
			systemctl --user start onedrive
			(crontab -u remco -l; echo "@reboot /bin/sh onedrive --monitor" ) | crontab -u $USER -
			read -p "Press [ENTER] to continue or CTRL-C to abort..."
}

# -------------------------------------------------------------------------------------
# Restore HASSIO config from OneDrive
# -------------------------------------------------------------------------------------	
recover_HASSIO_from_Drive(){
			echo -e "${RED}Do you want to restore HASS config v=from you OneDrive folder (y/n)  ${NC}\n"
			read answer5
			if [ "$answer5" != "${answer5#[Yy]}" ] ;then
    			echo "You answered yes, assuming  the config of HASSIO is backed-up in $hassiobackupfolder"
    			cp -rv $onedrivefoldercurrent/* /usr/share/hassio/homeassistant
			else
   			 echo "You answered No, please restore folder yourself or start with a clean config."
			fi
			mkdir ~/OneDrive/$onedrivefolderbackup
			mkdir ~/OneDrive/$onedrivefolderbackup/hassiobackupfolder
			mkdir ~/OneDrive/$onedrivefolderbackup/hassiobackupfolder/$DATE
			echo "Creating an extra backup, just for sure."
			cp -vr /usr/share/hassio/homeassistant/* ~/OneDrive/$onedrivefolderbackup/hassiobackupfolder/$DATE
			read -p "Press [ENTER] to continue or CTRL-C to abort..."
}

# -------------------------------------------------------------------------------------
# Docker install procedure
# -------------------------------------------------------------------------------------			
install_docker(){
            if [[ `systemctl|grep docker|wc -l` -lt 1 ]]; then
				echo -e "${RED}Looks like docker is not installed. Continuing...${NC}\n"
			apt-get -y update
            apt -y install docker
            apt -y install docker-compose
            else
    			echo -e "${RED}Docker seems to be installed already. Skipping docker installation.${NC}\n"
    		fi
    		read -p "Press [ENTER] to continue or CTRL-C to abort..."
}



# -------------------------------------------------------------------------------------
# HASSIO install procedure
# -------------------------------------------------------------------------------------			
install_hassio(){
            echo "Trying to install HASSIO, but first let's check if it is already installed..."
            if [[ `systemctl|grep hassio|wc -l` -lt 1 ]]; then
				echo -e "${RED}Looks like HASSIO is not installed. Continuing...${NC}\n"
			apt-get -y update
            apt-get -y install pkg-config
            apt-get -y install pkgconf      
            echo -e "${RED}Type EXIT en ENTER. I need to exit current user and enter root...sorry for that${NC}"
            sudo -i
			add-apt-repository universe
			apt-get -y update
			apt-get install -y apparmor-utils apt-transport-https avahi-daemon ca-certificates curl dbus jq network-manager socat software-properties-common
			curl -sL "https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh" | bash -s
       		echo" "
       		echo" "
    		else
    			echo -e "${RED}HASSIO seems to be installed already. Skipping HASSIO installation.${NC}\n"
    		fi
    		read -p "Press [ENTER] to continue or CTRL-C to abort..."
}
		
# -------------------------------------------------------------------------------------
# Bond nics tested on QNAP TS251
# -------------------------------------------------------------------------------------			
bond_nics(){			
			printf "\033c"
			echo -e "${RED}Do you want your NICS loadbalanced? (y/n) only tested on QNAPTS251. ${NC}\n"
			read answer2
			if [ "$answer2" != "${answer2#[Yy]}" ] ;then
    			apt -y install net-tools
    			echo "You answered yes, assuming you have a QNAP TS251"
    				    modprobe bonding
	    				echo "bonding" >> /etc/modulesdub
	    				echo "define network interface.The following is a creation of a yamlfile do not change the indents!"
			echo "network:
  version: 2
  ethernets:
    eports:
      match:
        name: enp*
      optional: true
  bonds:
    bond0:
      interfaces: [eports]
      addresses: $ip_addresses
      gateway4: $gateway4
      nameservers:
        addresses: [1.1.1.1, 1.0.0.1, 8.8.8.8, 8.8.4.4]
      parameters:
        mode: 802.3ad
        lacp-rate: fast
        mii-monitor-interval: 100" >/etc/netplan/01-network-manager-all.yaml
			netplan --debug apply
			echo "The following commands sets NIC in promiscuous mode enabled."
			ifconfig bonbd0 up
			ifconfig bond0 promisc
			else
			    echo "You answered no."
			fi
			read -p "Press [ENTER] to continue or CTRL-C to abort..."
}


# -------------------------------------------------------------------------------------
# Upgrade conbee 2 usbstick
# -------------------------------------------------------------------------------------			

upgrade_conbee2(){
			printf "\033c"
			echo -e "${RED}Do you want to upgrade Conbee 2 USBstick? (y/n) only tested on QNAPTS251. ${NC}\n"
			read answer4
			if [ "$answer4" != "${answer4#[Yy]}" ] ;then
		    	systemctl stop deconz
		    	wget https://www.dresden-elektronik.de/rpi/deconz-firmware/deCONZ_ConBeeII_0x26490700.bin.GCF
		    	GCFFlasher_internal -d /dev/ttyACM0 -f deCONZ_ConBeeII_0x26490700.bin.GCF
		    	systemctl start deconz
		    else
			    echo "You answered no."
			fi
			read -p "Press [ENTER] to continue or CTRL-C to abort..."
}


# ----------------------------------------------
# Update containers
# ----------------------------------------------
# under construction




# ----------------------------------------------
# Function to display menus
# ----------------------------------------------
show_menus() {
	clear
	echo -e "This scripts is build and tested on a ${RED}QNAP TS251+ ${NC}\n with Ubuntu 18.04 installed"
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo " 1. Clean install of docker and HASSIO"
	echo " 2. Install of docker, HASIO and recovery of HASSIO config"
	echo " 3. Install of docker, HASIO and recovery of HASSIO config from onedrive"
	echo " 4. Loadbalance nics (bond0 interface will be created, testen on QNAP TS251)"
	echo " 5. Upgrade Conbee 2 USB  stick"
	echo " 6. Update containers (working on)"
	echo " 7. Quit"
}
# read input from the keyboard and take a action
read_options(){
	local choice
	read -p "Enter choice [ 1 - 16] " choice
	case $choice in
		1) inst_docker_hassio ;;
		2) inst_docker_hassio_localbackupconfig ;;
		3) inst_docker_hassio_onedrive_containers ;;
		4) bond_nics ;;
		5) upgrade_conbee2 ;;
		6) update_containers ;;
		7) exit 0;;
		*) echo -e "${RED}Error...${NC}" && sleep 2
	esac
}
# -----------------------------------

# -----------------------------------
# Main logic - infinite loop
# ------------------------------------
while true
do
	show_menus
	read_options
done








