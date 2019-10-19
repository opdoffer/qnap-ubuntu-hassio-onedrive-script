# Bash Script to finish the configuration for HASSIO on QNAP running Ubuntu including custom dockercontainers
I created this script to easily to finish the installation and recovery of my HASSIO setup on a QNAP TS251+ running ubuntu 18.04 (not QTS).
You can use the whole or parts of this script for your own benefit because it is mostly generic in its setup.
But a good understanding of ubuntu, qnap, docker hassio and onedrive is needed. I cannot be held responsible for any result.

My goal and setup is: 
- QNAP TS251 running Ubuntu 18.04 native
- Docker for my custom dockercontainers with webservers and traefik als a reverse proxy, secured and seperated
- Docker-container configs synced with onedrive (selective folders) for backup and easy adjustments of config/website design
- NICS loadbalanced
- HASSIO installed directly on Ubuntu
- HASSIO able to access and use a Conbee 2 zigbee usb stick and an Aeotec Zwave USB stick.

Please note that I'm not very experienced in scripting. If you have any feedback or suggestions (especially in the security parts of the intallation procedure) let me know.
All this is a result of solutions and script out there. So shout out to:
- Inspiration for Ubuntu directly on QNAP. Check: [bricked qnap with ubuntu](https://www.reddit.com/r/homelab/comments/95ld5d/bricked_qnap_ts251_ubuntu_nas_with_desktop/);
- Home Assistant is an open source Domotica system with a large community. Check: [Home Assistant](https://homeAssistant.io);
- [Onedrive on linux](https://www.maketecheasier.com/sync-onedrive-linux/);
- [HASSIO on Ubuntu](https://gist.github.com/frenck/32b4f74919ca6b95b30c66f85976ec58) Github: frenck/hassio_ubuntu_install_commands.sh

**WARNING!!!**
**This script is tested on my own setup, but use this is at your own risk. DATA will be lost on QNAP. Please adjust it to your own needs!!**
**In case you want to be absloutely sure about the outcome, use manual installation steps following the links mentioned before.**

## Step1. Prepare the QNAP (you can skip this if you have Ubuntu up and running already or don't own a QNAP):
- Create a Ubuntu live USB (This procedure is tested with ubuntu 18.04);
- Connect a keyboard and HDMI screen to the QNAP TS251+;
- Boot the QNAP and press DEL repeatedly when QNAP splash screen starts;
- Change the boot order to local harddrive, and shutdown QNAP
- Insert Ubuntu live USB and press F7 during QNAP splash screen repeatedly until temporary bootmenu appears
- Choose to boot from Live usb
- Follow instructions to install ubuntu on local harddisk of the QNAP WARNING!!!: all data will be lost!!!!
- After reboot QNAP will start Ubuntu. Proceed to next step.

## Step 2. Onedrive for container-config backups
I Use onedrive to backup my container-configs. So I can easily recover and or adjust my websites by editing html files using onedrive. In my setup I have a folder with 
all container-config located in the root of Onedrive: /container-configs.

In that folder I also host the docker-compose.yml. I use the following routine (since I'm not completely relying on Onedrive sync to execute well).
- Intial recovery/resync using "onedrive for linux" to selective download docker-container-configs. Folder will be located at ~/Onedrive/container-configs-current
- copying those to a different local folder ~/container-configs
- regurarly backing it uo using crontab to ~/Onedrive/container-configs-backup

Prequisite: In case you want to use the Onedrive feature too:
- make sure you have a folder in you Onedrive root named: /container-configs-current and /container-configs-backup
- in the folder "/container-configs-current" copy you current container config folders and prepare a docker-compose file that matches the folder structure (for volumes) with "~/container-configs" (without quotes).

In case you want different folder structures, please make adjustments in the variabels of the script: "onedrivefoldercurrent" and "onedrivefolderbackup".


## Step 3. Installation of Docker, HASSIO and Onedrive
The following script can install docker followed by HASSIO and/or including install Onedrive for linux. I use Onedrive to backup my config of the dockercontainers and recreate the dockers with docker-compose automatically.
So the script has couple of options:
1. Clean install of docker and HASSIO"
2. Install of docker, HASIO and recovery of HASSIO config"
3. Install of docker, HASIO and recovery of HASSIO config from Onedrive and custom containers"
4. Loadbalance nics (bond0 interface will be created, testen on QNAP TS251)"

Prerequisites for option 3 is explained in more detail step 2.

Enter the following command to download it:
```
git clone https://github.com/opdoffer/qnap-ubuntu-hassio-onedrive-script.git
```
Start the script:
```
sudo ./qnap-ubuntu-hassio-onedrive-script/qnap-ubuntu-hassio-onedrive-script.sh
```

## TODO list
- create docker-compose example for traefik and 2 webservers
- security enhancements

##Related
[Home Assistant](https://homeAssistant.io).
[OpenZwave](https://github.com/OpenZWave).
[Onedrive on linux](https://www.maketecheasier.com/sync-onedrive-linux/);
[HASSIO on Ubuntu](https://gist.github.com/frenck/32b4f74919ca6b95b30c66f85976ec58) Github: frenck/hassio_ubuntu_install_commands.sh
[bricked qnap with ubuntu](https://www.reddit.com/r/homelab/comments/95ld5d/bricked_qnap_ts251_ubuntu_nas_with_desktop/)
