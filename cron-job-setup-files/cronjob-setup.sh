#	Update Apt-cache
sudo apt-get update

# install needed packages
sudo apt install python3 cron cron-apt crontab python3-crontab -y

# enable system services
sudo systemctl enable cron
sudo systemctl start cron

# Echo the command below into the file /etc/crontab
echo 'MAILTO="alert@tyates.one"
0 */6 * * * root apt-get update && apt install upgrade -y && apt-get -y -d full-upgrade && apt-get autoremove -y' | sudo tee -a /etc/crontab
