﻿MAILTO="alert@tyates.one" 
0  */6 * * *  root apt-get update && apt install upgrade -y && apt-get -y -d full-upgrade && apt-get autoremove -y

#* */4 * * * /home/pi/Desktop/sync.sh
#		sudo apt-get update
#		sudo apt-get upgrade -y


#https://crontab-generator.org/
#apt-get install cron-apt -y
#https://www.techrepublic.com/article/automatically-update-your-ubuntu-system-with-cron-apt/
#https://www.linuxfordevices.com/tutorials/linux/automatic-updates-cronjob


#[minute] [hour] [day_of_month] [month] [day_of_week] [user] [command_to_run]

#0 0 * * 0 root (apt-get update && apt-get -y -d upgrade)

sudo apt install cron cron-apt -y
sudo systemctl enable cron
sudo nano /etc/crontab

#MAILTO="alerts@tyates.one"
#0 */6 * * * root apt-get update && apt-get -y -d full-upgrade && apt-get autoremove -y

#sudo apt-get update && sudo apt-get full-upgrade -y && sudo apt autoremove -y
