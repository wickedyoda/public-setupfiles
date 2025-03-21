# Observium-Agent
This is an install script for both the Enterprise and Community Editions which will setup the Observium Agent with the provided configuration. Note that this script currently only works for Debian/Ubuntu and Redhat based systems.

### Installation
To run the script from GitHub create file in your current directory named agent.conf.sh with executable permissions.

`sudo wget https://raw.githubusercontent.com/tkrause/Observium-Agent/master/agent.conf.sh`

Now download and run the setup script

`sudo wget https://raw.githubusercontent.com/tkrause/Observium-Agent/master/observium-agent-install.sh`

Note: You will need to edit agent.conf.sh to fit your configuration.

`sudo chmod +x agent.conf.sh observium-agent-install.sh`

Run the installer

`sudo ./observium-agent-install.sh`

### Agent Conf Options
`$SYSCONTACT` This option should be set to an email address in the format `Person Name <email@example.com>`.

`$SYSLOCATION` For best results, set to a street address or geolocation that can be found on Google Maps.

`$SNMP_COMMUNITY` Set to the SNMP Community you would like to use to access this system from Observium.

`$OBSERVIUM_HOST` Set to the IP Address or Hostname of your Observium Server. This will be used to limit connection to be only from this host.

`$MODULES` (optional, array) Set to a space delimited list of modules you would like to install. These are simply the file names from `observium/scripts/agent-local/`. Excluding this option from the config will result in no extra modules being installed. A list is provided in agent.conf.sh however you can retrieve an updated list by running `ls -l /opt/observium/scripts/agent-local/ | tr -s ' ' | cut -d ' ' -f9` on your Observium Server

`$SVN_USER` (optional) Set to the username provided by Observium when you purchased your Enterprise License. Excluding this option from the config will result in using the Community Edition. 

`$SVN_PASS` (optional) Set to the password provided by Observium when you purchased your Enterprise License. Excluding this from the config will result in using the Community Edition. 

### FAQ
1. I'm prompted "Attention! Your password for authentication realm:" what do I do?

You can safely say "no" to allow it to encrypt your SVN password for future use.