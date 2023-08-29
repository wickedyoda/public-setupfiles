Just a public directory of some simple scripts I use to setup my own clients and things. 

Since its public, I dont have need my new clients to login or worry about cridentials.

### Syncing this repo locally: 
```
git init
git remote add origin https://github.com/wickedyoda/public-setupfiles
git fetch
git checkout main
To remove "rm -rf .git"
```

### Setting up crontab to run updates automatically: 

```
sudo apt install cron cron-apt -y
sudo systemctl enable cron
sudo nano /etc/crontab

MAILTO="alerts@tyates.one"
`0 */6 * * * root apt-get update && apt-get -y -d full-upgrade && apt-get autoremove -y```