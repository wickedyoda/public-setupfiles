sudo apt update
sudo apt full-upgrade -y
sudo apt install cron cron-apt -y
sudo systemctl enable cron
sudo systemctl stop cron

echo "MAILTO="alerts@tyates.one"
0 */6 * * * root apt-get update && apt-get -y -d full-upgrade && apt-get autoremove -y" >> /etc/crontab

sudo systemctl start cron
