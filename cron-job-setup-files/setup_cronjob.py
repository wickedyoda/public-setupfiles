#!/usr/bin/env python3

import subprocess

#!/usr/bin/env python3

import subprocess

# Check if Python 3 is installed
try:
    subprocess.run(["python3", "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
except subprocess.CalledProcessError:
    print("Python 3 is not installed. Installing Python 3...")
    subprocess.run(["sudo", "apt", "update"])
    subprocess.run(["sudo", "apt", "install", "python3", "-y"])

# Rest of the script as before
# ...

# Update package lists and install cron
subprocess.run(["sudo", "apt", "update"])
subprocess.run(["sudo", "apt", "install", "cron", "-y"])

# Enable and start the cron service
subprocess.run(["sudo", "systemctl", "enable", "cron"])
subprocess.run(["sudo", "systemctl", "start", "cron"])

# Stop the cron service to make changes
subprocess.run(["sudo", "systemctl", "stop", "cron"])

# Define the cron job command
cron_job_command = (
    'MAILTO="alerts@tyates.one"\n'
    '0 */6 * * * root apt-get update && apt-get -y -d full-upgrade && apt-get autoremove -y && sudo apt-get clean -y && sudo apt-get purge -y'
)

# Write the cron job to a file
with open("/etc/cron.d/auto_updates", "w") as cron_file:
    cron_file.write(cron_job_command)

# Restart the cron service to apply the new cron job
subprocess.run(["sudo", "systemctl", "start", "cron"])
