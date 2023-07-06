import subprocess

# Run 'sudo apt update'
subprocess.run(['sudo', 'apt', 'update'])

# Run 'sudo apt install cron cron-apt -y'
subprocess.run(['sudo', 'apt', 'install', 'cron', 'cron-apt', '-y'])

# Run 'sudo systemctl enable cron'
subprocess.run(['sudo', 'systemctl', 'enable', 'cron'])

# Run 'sudo systemctl stop cron'
subprocess.run(['sudo', 'systemctl', 'stop', 'cron'])

# Append the cron job to /etc/crontab
cron_job = 'echo "MAILTO=\"alerts@tyates.one\"\n0 */6 * * * root apt-get update && apt-get -y -d full-upgrade && apt-get autoremove -y && sudo apt-get clean -y && sudo apt-get purge -y" >> /etc/crontab'
subprocess.run(cron_job, shell=True)

# Run 'sudo systemctl start cron'
subprocess.run(['sudo', 'systemctl', 'start', 'cron'])
