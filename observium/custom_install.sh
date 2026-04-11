#!/bin/bash
set -e

VERSION="0.3.1"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

function observiumfound {
    observium_found="no"
    if [ -d "/opt/observium" ]; then
        observium_found="yes"
        if [ -f "/opt/observium/config.php" ]; then
            observium_found="configured"
        fi
    fi
}

function agentinstall {
    if [ -d "/run/systemd/system" ] && [ -f "/opt/observium/scripts/systemd/observium_agent.socket" ]; then
        echo -e "${GREEN}Installing systemd unix-agent service...${NC}"
        cp /opt/observium/scripts/systemd/observium_agent.service /etc/systemd/system/observium_agent\@.service
        cp /opt/observium/scripts/systemd/observium_agent.socket /etc/systemd/system/observium_agent.socket
        systemctl daemon-reload
        systemctl enable observium_agent.socket
        systemctl start observium_agent.socket
        apt -qq install -y dmidecode
    else
        echo -e "${GREEN}Installing xinetd unix-agent service...${NC}"
        apt-get -qq install -y xinetd libwww-perl dmidecode
        cp /opt/observium/scripts/observium_agent_xinetd /etc/xinetd.d/observium_agent_xinetd
        service xinetd restart
    fi
    
    cp /opt/observium/scripts/observium_agent /usr/bin/observium_agent
    mkdir -p /usr/lib/observium_agent
    mkdir -p /usr/lib/observium_agent/scripts-available
    mkdir -p /usr/lib/observium_agent/scripts-enabled
    cp -r /opt/observium/scripts/agent-local/* /usr/lib/observium_agent/scripts-available
    chmod +x /usr/bin/observium_agent
    ln -sf /usr/lib/observium_agent/scripts-available/dmi /usr/lib/observium_agent/scripts-enabled
    ln -sf /usr/lib/observium_agent/scripts-available/dpkg /usr/lib/observium_agent/scripts-enabled
    
    if [ "$observ_ver" -lt "4" ]; then
        ln -sf /usr/lib/observium_agent/scripts-available/apache /usr/lib/observium_agent/scripts-enabled
        ln -sf /usr/lib/observium_agent/scripts-available/mysql /usr/lib/observium_agent/scripts-enabled
    fi


    echo "\$config['poller_modules']['unix-agent']                   = 1;" >> /opt/observium/config.php
    echo -e "${GREEN}DONE! UNIX-agent is installed and this server is now monitored by Observium${NC}"
}

function snmpdinstall {
    echo -e "${GREEN}Installing snmpd...${NC}"
    apt-get -qq install -y snmpd

    observiumfound
    if [ $observium_found = "no" ]; then
        # Observium not installed, download distro from site
        curl -s -o /usr/local/bin/distro https://www.observium.org/files/distro
        #wget -O /usr/local/bin/distro https://www.observium.org/files/distro
    else
        # locally installed observium, copy from scripts
        cp /opt/observium/scripts/distro /usr/local/bin/distro
    fi
    chmod +x /usr/local/bin/distro

    echo -e "${YELLOW}Reconfiguring local snmpd${NC}"
    if [ $observ_ver = 6 ] || [ $observium_found = "no" ]; then
        # remote poller hostname
        hostname="$(hostname -f)"
        # WARNING. Remote pollers have troubles with ip 127.0.1.1 (default in debian for hosts)
        echo "agentAddress udp:161" > /etc/snmp/snmpd.conf
    else
        # common install, probably better to use full hostname..
        hostname="localhost"
        echo "agentAddress  udp:127.0.0.1:161" > /etc/snmp/snmpd.conf
    fi
    snmpcommunity="yates-network"
    echo "rocommunity yates-network" >> /etc/snmp/snmpd.conf

    # Distro sctipt
    echo "# This line allows Observium to detect the host OS if the distro script is installed" >> /etc/snmp/snmpd.conf
    echo "extend .1.3.6.1.4.1.2021.7890.1 distro /usr/local/bin/distro" >> /etc/snmp/snmpd.conf

    # Vendor/hardware extending
    if [ -f "/sys/devices/virtual/dmi/id/product_name" ]; then
        echo "# This lines allows Observium to detect hardware, vendor and serial" >> /etc/snmp/snmpd.conf
        echo "extend .1.3.6.1.4.1.2021.7890.2 hardware /bin/cat /sys/devices/virtual/dmi/id/product_name" >> /etc/snmp/snmpd.conf
        echo "extend .1.3.6.1.4.1.2021.7890.3 vendor   /bin/cat /sys/devices/virtual/dmi/id/sys_vendor" >> /etc/snmp/snmpd.conf
        echo "#extend .1.3.6.1.4.1.2021.7890.4 serial   /bin/cat /sys/devices/virtual/dmi/id/product_serial" >> /etc/snmp/snmpd.conf
    elif [ -f "/proc/device-tree/model" ]; then
        # ARM/RPi specific hardware
        echo "# This lines allows Observium to detect hardware, vendor and serial" >> /etc/snmp/snmpd.conf
        echo "extend .1.3.6.1.4.1.2021.7890.2 hardware /bin/cat /proc/device-tree/model" >> /etc/snmp/snmpd.conf
        echo "#extend .1.3.6.1.4.1.2021.7890.4 serial   /bin/cat /proc/device-tree/serial" >> /etc/snmp/snmpd.conf
    fi

    # Accurate uptime
    echo "# This line allows Observium to collect an accurate uptime" >> /etc/snmp/snmpd.conf
    echo "extend uptime /bin/cat /proc/uptime" >> /etc/snmp/snmpd.conf

    echo "# This line enables Observium's ifAlias description injection" >> /etc/snmp/snmpd.conf
    echo "#pass_persist .1.3.6.1.2.1.31.1.1.1.18 /usr/local/bin/ifAlias_persist" >> /etc/snmp/snmpd.conf
  
    service snmpd restart
  
    if [ $observium_found = "no" ]; then
        # snmpd without observium install
        echo -e "${YELLOW}You can add host to Observium${NC}"
        echo -e "      SNMP hostname: ${BOLD}$hostname${NC}"
        echo -e " SNMP v2c community: ${BOLD}$snmpcommunity${NC}"
        echo -e "${GREEN}DONE! SNMPD is installed and this server can be monitored by Observium${NC}"
    else
        # observium install, auto add host to db
        echo -e "${YELLOW}Adding $hostname to Observium${NC}"
        /opt/observium/add_device.php $hostname $snmpcommunity
        echo -e "${GREEN}DONE! SNMPD is installed and this server is now monitored by Observium${NC}"
    fi
}

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR: You must be a root user${NC}" 2>&1
    exit 1
fi

ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')

if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    OS=Debian  # XXX or Ubuntu??
    VER=$(cat /etc/debian_version)
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [[ !$OS =~ ^(Ubuntu|Debian)$ ]]; then
    echo -e "${RED} [*] ERROR: This installscript does not support this distro, only Debian or Ubuntu supported. Use the manual guide at https://docs.observium.org/install_rhel7/ ${NC}"
    exit 1
fi

cat << "EOF"
  ___  _                         _
 / _ \| |__  ___  ___ _ ____   _(_)_   _ _ __ ___
| | | | '_ \/ __|/ _ \ '__\ \ / / | | | | '_ ` _ \
| |_| | |_) \__ \  __/ |   \ V /| | |_| | | | | | |
 \___/|_.__/|___/\___|_|    \_/ |_|\__,_|_| |_| |_|
EOF
echo -e ""
echo -e "${GREEN}Welcome to Observium installation script v${VERSION}"
echo -e ""
echo -e "Please select the version of Observium you would like to install${NC}"
echo -e ""
echo -e "1. Observium ${BOLD}Community Edition${NC}"
echo -e "2. Observium ${BOLD}Pro/Ent Edition ${GREEN}stable${NC} (requires account at https://www.observium.org/subs/)"
echo -e "3. Observium ${BOLD}Pro/Ent Edition ${YELLOW}rolling${NC} (requires account at https://www.observium.org/subs/)"
echo -e "4. Install the UNIX-Agent"
echo -e "5. Install the SNMPD (snmpd-config will be overwritten)"
echo -e "6. ${YELLOW}Remote poller${NC} for ${BOLD}Observium Pro/Ent Edition ${GREEN}stable${NC} (requires account at https://www.observium.org/subs/)"
echo -n "(1-6): "
read -n 1 observ_ver
echo -e ""
echo "you choose $observ_ver"
echo " "

# check already installed Observium
observiumfound
if [ $observ_ver = 4 ]; then
    if [ $observium_found = "no" ]; then
        echo -e "${YELLOW} Observium not installed. Install it before install UNIX-Agent${NC}"
    fi
    agentinstall
    exit 1
elif [ $observ_ver = 5 ]; then
    snmpdinstall
    exit 1
fi

if [ $observium_found = "yes" ]; then
    echo -e "${RED} Observium already installed.${NC}"
    echo -e " Please follow update procedure: https://docs.observium.org/#upgrading-observium"
    echo -e " or backup and remove /opt/observium directory for reinstall."
    exit 1
fi

if [ $observ_ver = 2 ] || [ $observ_ver = 3 ]; then
    echo -e "${BOLD} Your SVN username and password can be found after logging in at: https://www.observium.org/subs/${NC}"
    read -p "Please enter your SVN Username: " svn_user
    read -s -p "Please enter your SVN Password: " svn_password
    echo -e ""
    mysql_user="observium"
elif [ $observ_ver = 6 ]; then
    echo -e "${BOLD} Requested installing Remote poller for Observium Pro/Ent${NC}"
    echo -e ""
    
    echo -e "${YELLOW}Please enter your params...${NC}"
    echo -e "${BOLD} Your SVN username and password can be found after logging in at: https://www.observium.org/subs/${NC}"
    read -p "  SVN Username: " svn_user
    read -s -p "  SVN Password: " svn_password
    echo -e ""
    
    echo -e "${BOLD} Your MySQL server should be remotely accessed to DB 'observium' with this username and password${NC}"
    read -p "  MySQL Host:Port: " mysql_host
    read -p "  MySQL Username [observium]: " mysql_user
    mysql_user=${mysql_user:-observium}
    read -s -p "  MySQL Password: " mysql_password
    echo -e ""
    
    read -p "  RRDCacheD Host:Port: " rrdcahed_host
    echo -e ""
    
    hostname="$(hostname -f)"
    read -p "  Observium Poller Name [$hostname]: " observium_poller
    if [ -z "${observium_poller}" ]; then
        observium_poller=$hostname
    fi
    echo -e ""
elif [ $observ_ver = 1 ]; then
    echo -e "${BOLD} Requested installing Observium CE${NC}"
    echo -e ""
    mysql_user="observium"
else
    echo -e "${RED} [*] ERROR: Invalid option $observ_ver${NC}"
    exit 1
fi

if [ "$observ_ver" -lt "4" ]; then
    if [ -f /etc/apache2/sites-available/000-default.conf ] || [ -f /etc/apache2/sites-available/default ]; then
        echo -e "${YELLOW}WARNING: Apache default configuration was found. This script will overwrite that configuration, and your current settings will be lost.${NC}"
        echo "Continue?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes )
                    echo "Apache config will be overwritten..."
                    break
                    ;;
                No )
                    echo "Exiting..."
                    exit 1
                    ;;
            esac
        done
    fi

    # mysql server only for base install
    if $(dpkg --list mysql-server 2>/dev/null | egrep -q ^ii) || $(dpkg --list mariadb-server 2>/dev/null | egrep -q ^ii); then
        echo -e "${YELLOW}WARNING: A MySQL server is already installed. Do you know the root password for this server?${NC}"
        select yn in "Yes" "No"; do
            case $yn in
                Yes )
                    echo "Please enter the MySQL root password and press [ENTER]"
                    read -s mysql_root
                    break
                    ;;
                No )
                    echo "Exiting..."
                    exit 1
                    ;;
            esac
        done
    else
        echo -e "${GREEN} [*] No MySQL server was detected on this server. Installing MySQL...${NC}"
        echo "Choose a MySQL root password"
        read -s mysql_root
    fi
    
    echo "mysql-server mysql-server/root_password password $mysql_root" | debconf-set-selections
    echo "mysql-server mysql-server/root_password_again password $mysql_root" | debconf-set-selections
fi

echo -e "${GREEN} [*] Starting package installation; this may take up to 30 minutes${NC}"
if [ $OS = "Ubuntu" ] && [ $VER = "16.04" ]; then
    # Unsupported!
    echo -e "${GREEN} [*] We are on Ubuntu 16.04 LTS, installing packages...${NC}"
    apt-get -qq update
    apt-get -qq install -y php7.0-cli php7.0-mysql php7.0-gd php7.0-mcrypt php7.0-json php7.0-bcmath php7.0-mbstring php7.0-curl php-apcu php-pear snmp fping  mysql-client python-mysqldb rrdtool subversion whois mtr-tiny ipmitool
    phpenmod mcrypt
    if [ "$observ_ver" -lt "4" ]; then
        apt-get -qq install -y libapache2-mod-php7.0 graphviz imagemagick mysql-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
        a2enmod php7.0
    fi
elif [ $OS = "Ubuntu" ] && [ $VER = "17.04" ]; then
    # Unsupported!
    echo -e "${GREEN} [*] We are on Ubuntu 17.04, installing packages...${NC}"
    apt-get -qq update
    apt-get -qq install -y php7.0-cli php7.0-mysql php7.0-gd php7.0-mcrypt php7.0-json php7.0-bcmath php7.0-mbstring php7.0-curl php-apcu php-pear snmp fping mysql-client python-mysqldb rrdtool subversion whois mtr-tiny ipmitool
    phpenmod mcrypt
    if [ "$observ_ver" -lt "4" ]; then
        apt-get -qq install -y libapache2-mod-php7.0 graphviz imagemagick mysql-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
        a2enmod php7.0
    fi
elif [ $OS = "Ubuntu" ] && [ $VER = "17.10" ]; then
    # Unsupported!
    echo -e "${GREEN} [*] We are on Ubuntu 17.10, installing packages...${NC}"
    apt-get -qq update
    apt-get -qq install -y php7.1-cli php7.1-mysql php7.1-gd php7.1-mcrypt php7.1-json php7.1-bcmath php7.1-mbstring php7.1-opcache php7.1-curl php-apcu php-pear snmp fping mysql-client python-mysqldb rrdtool subversion whois mtr-tiny ipmitool libvirt-clients
    phpenmod mcrypt
    if [ "$observ_ver" -lt "4" ]; then
        apt-get -qq install -y libapache2-mod-php7.1 graphviz imagemagick mysql-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
        a2enmod php7.1
    fi
elif [ $OS = "Ubuntu" ] && [ $VER = "18.04" ]; then
    echo -e "${GREEN} [*] We are on Ubuntu 18.04 LTS, installing packages...${NC}"
    add-apt-repository universe -y
    add-apt-repository multiverse -y
    apt -qq update
    apt -q install -y php7.2-cli php7.2-mysql php7.2-gd php7.2-json php7.2-bcmath php7.2-mbstring php7.2-opcache php7.2-curl php-apcu php-pear snmp fping mysql-client python-mysqldb rrdtool subversion whois mtr-tiny ipmitool libvirt-clients
    #phpenmod mcrypt
    if [ "$observ_ver" -lt "4" ]; then
        apt -q install -y libapache2-mod-php7.2 graphviz imagemagick mysql-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
        a2enmod php7.2
    fi
elif [ $OS = "Ubuntu" ] && [ $VER = "20.04" ]; then
    echo -e "${GREEN} [*] We are on Ubuntu 20.04 LTS, installing packages...${NC}"
    add-apt-repository universe -y
    add-apt-repository multiverse -y
    apt -qq update
    apt -q install php7.4-cli php7.4-mysql php7.4-gd php7.4-json php7.4-bcmath php7.4-mbstring php7.4-opcache php7.4-curl php-apcu php-pear snmp fping mysql-client rrdtool subversion whois mtr-tiny ipmitool libvirt-clients python3-mysqldb python3-pymysql python-is-python3
    if [ "$observ_ver" -lt "4" ]; then
        apt -q install libapache2-mod-php7.4 graphviz imagemagick mysql-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
        a2enmod php7.4
    fi
elif [ $OS = "Ubuntu" ] && [ $VER = "21.04" ]; then
    echo -e "${GREEN} [*] We are on Ubuntu 21.04, installing packages...${NC}"
    echo -e "${YELLOW} [*] Please note that we generally recommend using the latest Ubuntu LTS release.${NC}"
    add-apt-repository universe -y
    add-apt-repository multiverse -y
    apt -qq update
    apt -q install php7.4-cli php7.4-mysql php7.4-gd php7.4-json php7.4-bcmath php7.4-mbstring php7.4-opcache php7.4-curl php-apcu php-pear snmp fping mysql-client rrdtool subversion whois mtr-tiny ipmitool libvirt-clients python3-mysqldb python3-pymysql python-is-python3
    if [ "$observ_ver" -lt "4" ]; then
        apt -q install libapache2-mod-php7.4 graphviz imagemagick mysql-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
        a2enmod php7.4
    fi
elif [ $OS = "Ubuntu" ] && [ $VER = "22.04" ]; then
    echo -e "${GREEN} [*] We are on Ubuntu 22.04, installing PHP 8.1 and other packages...${NC}"
    add-apt-repository universe -y
    add-apt-repository multiverse -y
    apt -qq update
    apt -q install php8.1-cli php8.1-mysql php8.1-gd php8.1-bcmath php8.1-mbstring php8.1-opcache php8.1-curl php-apcu php-pear snmp fping mysql-client rrdtool subversion whois mtr-tiny ipmitool libvirt-clients python3-mysqldb python3-pymysql python-is-python3
    if [ "$observ_ver" -lt "4" ]; then
        apt -q install libapache2-mod-php8.1 graphviz imagemagick mysql-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
        a2enmod php8.1
    fi
elif [ $OS = "Ubuntu" ] && [ $VER = "24.04" ]; then
    echo -e "${GREEN} [*] We are on Ubuntu 24.04, installing PHP 8.3 and other packages...${NC}"
    add-apt-repository universe -y
    add-apt-repository multiverse -y
    apt -qq update
    apt -q install php8.3-cli php8.3-mysql php8.3-gd php8.3-bcmath php8.3-mbstring php8.3-opcache php8.3-curl php-apcu php-pear snmp fping mysql-client rrdtool subversion whois mtr-tiny ipmitool libvirt-clients python3-mysqldb python3-pymysql python-is-python3
    if [ "$observ_ver" -lt "4" ]; then
        apt -q install libapache2-mod-php8.3 graphviz imagemagick mysql-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
        a2enmod php8.3
    fi
elif [ $OS = "Debian" ] && [[ $VER =~ ^8.* ]]; then
    echo -e "${GREEN} [*] We are on Debian 8.x, installing packages...${NC}"
    # Unsupported!
    apt-get -qq update
    apt-get -qq install -y php7.0-cli php7.0-mysql php7.0-gd php7.0-libsodium php7.0-mcrypt php7.0-json php7.0-bcmath php7.0-mbstring php7.0-opcache php7.0-apcu php7.0-curl php-pear snmp fping mysql-client python-mysqldb rrdtool subversion whois mtr-tiny ipmitool
    phpenmod mcrypt
    if [ "$observ_ver" -lt "4" ]; then
        apt-get -qq install -y libapache2-mod-php7.0 graphviz imagemagick mysql-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
        a2enmod php7.0
    fi
elif [ $OS = "Debian" ] && [[ $VER =~ ^9.* ]]; then
    # Unsupported!
    echo -e "${GREEN} [*] We are on Debian 9.x, installing packages...${NC}"
    apt-get -qq update
    apt-get -qq install -y php7.0-cli php7.0-mysql php7.0-gd php7.0-libsodium php7.0-mcrypt php7.0-json php7.0-bcmath php7.0-mbstring php7.0-opcache php7.0-apcu php7.0-curl php-pear snmp fping mariadb-client python-mysqldb rrdtool subversion whois mtr-tiny ipmitool
    phpenmod mcrypt
    if [ "$observ_ver" -lt "4" ]; then
        apt-get -qq install -y libapache2-mod-php7.0 graphviz imagemagick mariadb-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
        a2enmod php7.0
    fi
elif [ $OS = "Debian" ] && [[ $VER =~ ^10.* ]]; then
    echo -e "${GREEN} [*] We are on Debian 10.x, we will install PHP 7.3. Installing packages...${NC}"
    apt -qq update
    apt -qq install -y php7.3-cli php7.3-mysql php7.3-gd php7.3-json php7.3-bcmath php7.3-mbstring php7.3-opcache php7.3-apcu php7.3-curl php-pear snmp fping mariadb-client python-mysqldb rrdtool subversion whois mtr-tiny ipmitool libvirt-clients
    #phpenmod mcrypt
    if [ "$observ_ver" -lt "4" ]; then
        apt -qq install -y libapache2-mod-php7.3 graphviz imagemagick mariadb-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
    fi
elif [ $OS = "Debian" ] && [[ $VER =~ ^11.* ]]; then
    echo -e "${GREEN} [*] We are on Debian 11.x, we will install PHP 7.4. Installing packages...${NC}"
    apt -qq update
    apt -qq install -y php7.4-cli php7.4-mysql php7.4-gd php7.4-json php7.4-bcmath php7.4-mbstring php7.4-opcache php7.4-apcu php7.4-curl php-pear snmp fping mariadb-client python3-mysqldb rrdtool subversion whois mtr-tiny ipmitool libvirt-clients python-is-python3 python3-pymysql
    if [ "$observ_ver" -lt "4" ]; then
        apt -qq install -y libapache2-mod-php7.4 graphviz imagemagick mariadb-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
    fi
elif [ $OS = "Debian" ] && [[ $VER =~ ^12.* ]]; then
    echo -e "${GREEN} [*] We are on Debian 12.x, we will install PHP 8.2. Installing packages...${NC}"
    apt -qq update
    apt -qq install -y php8.2-cli php8.2-mysql php8.2-gd php8.2-bcmath php8.2-mbstring php8.2-opcache php8.2-apcu php8.2-curl php-json php-pear snmp fping mariadb-client python3-mysqldb python3-pymysql python-is-python3 rrdtool subversion whois mtr-tiny ipmitool libvirt-clients
    if [ "$observ_ver" -lt "4" ]; then
        apt -qq install -y libapache2-mod-php8.2 graphviz imagemagick mariadb-server apache2
        a2dismod mpm_event
        a2enmod mpm_prefork
    fi
else
   echo -e "${RED} [*] ERROR: This installscript does not support this distro, only Debian or Ubuntu supported. Use the manual guide at https://docs.observium.org/install_rhel7/ ${NC}"
   echo "OS:" $OS
   echo "Version:" $VER
   exit 1
fi

echo -e "${GREEN} [*] Creating Observium dir${NC}"
mkdir -p /opt/observium && cd /opt

if [ $observ_ver = 1 ]; then
   echo -e "${GREEN} [*] Downloading Observium CE and unpacking...${NC}"
   wget -r -nv https://www.observium.org/observium-community-latest.tar.gz -O /opt/observium-community-latest.tar.gz
   tar zxf observium-community-latest.tar.gz --checkpoint=.1000
   echo " "
elif [ $observ_ver = 2 ] || [ $observ_ver = 6 ]; then
   echo -e "${GREEN} [*] Checking out Observium Pro/Ent stable from SVN${NC}"
   #echo "Your SVN username and password is found after you login at: https://www.observium.org/subs/"
   #read -p "Please enter your SVN username: " svn_user
   svn co -q --username "$svn_user" --password "$svn_password" https://svn.observium.org/svn/observium/branches/stable observium
elif [ $observ_ver = 3 ]; then
   echo -e "${GREEN} [*] Checking out Observium Pro/Ent rolling from SVN${NC}"
   #echo "Your SVN username and password is found after you login at: https://www.observium.org/subs/"
   #read -p "Please enter your SVN username: " svn_user
   svn co -q --username "$svn_user" --password "$svn_password" https://svn.observium.org/svn/observium/trunk observium
fi

cd observium

if [ "$observ_ver" -lt "4" ]; then
    # initial mysql db user/password creation
    echo -e "${GREEN} [*] Creating database user for Observium with a random password...${NC}"
    mysql_password="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-15};echo;)"
    mysql -uroot -p"$mysql_root" -e "CREATE DATABASE observium DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci"

    if [[ $OS = "Ubuntu" ]] && ( [[ $VER = "20.04" ]] || [[ $VER = "21.04" ]] || [[ $VER = "22.04" ]] || [[ $VER = "24.04" ]] ); then
        #echo -e "${GREEN} [*] We are on Ubuntu 20.04 LTS, installing packages...${NC}"
        mysql -uroot -p"$mysql_root" -e "CREATE USER 'observium'@'localhost' IDENTIFIED BY '$mysql_password'"
        mysql -uroot -p"$mysql_root" -e "GRANT ALL ON observium.* TO 'observium'@'localhost'"
    else
        mysql -uroot -p"$mysql_root" -e "GRANT ALL PRIVILEGES ON observium.* TO 'observium'@'localhost' IDENTIFIED BY '$mysql_password'"
    fi
elif [ $observ_ver = 6 ]; then
    echo -e ""
    if mysql -u "$mysql_user" -p"$mysql_password" -h "$mysql_host" -D observium -e "SELECT VERSION();" > /dev/null 2>&1; then
        echo "Connection to database successful."
    else
        # still configure poller for manual config later
        echo "Failed to connect to database. Please check DB host/user/password and set correct in config.php"
    fi
fi

echo -e "${GREEN} [*] Creating Observium config-file...${NC}"
sed "s/'USERNAME'/'$mysql_user'/g" config.php.default > config.php
sed -i "s/'PASSWORD'/'$mysql_password'/g" config.php
if [ $observ_ver = 6 ]; then
    # extra configurations for remote poller
    sed -i "s/'localhost'/'$mysql_host'/g" config.php
    
    echo -e "" >> config.php
    echo -e "# Remote poller" >> config.php
    echo -e "\$config['rrdcached']      = '$rrdcahed_host';" >> config.php
    echo -e "# Force get poller_id by host id if name changed" >> config.php
    echo -e "\$config['poller_by_host'] = TRUE;" >> config.php
    echo -e "\$config['poller_name']    = '$observium_poller';" >> config.php

fi

echo -e "${GREEN} [*] Creating log and rrd-directories...${NC}"
id -u observium &>/dev/null || useradd -G www-data observium
mkdir -p logs
chown -R observium:observium logs
#this mode makes all files created inherit permissions of rrd/-folder
mkdir -p --mode=u+rwx,g+rs,o-w rrd
chown -R observium:www-data rrd
chmod -R g+w rrd

if [ "$observ_ver" -lt "4" ]; then
    # DB schema upgrade & apache config for common install
    ./discovery.php -u

    apachever="$(apache2ctl -v)"
    if [[ $apachever == *"Apache/2.4"* ]]; then
        echo -e "${GREEN} [*] Apache version is 2.4, creating config...${NC}"
        cat > /etc/apache2/sites-available/000-default.conf <<- EOM
  <VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /opt/observium/html
    <FilesMatch \.php$>
      SetHandler application/x-httpd-php
    </FilesMatch>
    <Directory />
            Options FollowSymLinks
            AllowOverride None
    </Directory>
    <Directory /opt/observium/html/>
            DirectoryIndex index.php
            Options Indexes FollowSymLinks MultiViews
            AllowOverride All
            Require all granted
    </Directory>
    ErrorLog  ${APACHE_LOG_DIR}/error.log
    LogLevel warn
    CustomLog  ${APACHE_LOG_DIR}/access.log combined
    ServerSignature On
  </VirtualHost>
EOM
        
        #echo "$APACHE24" > /etc/apache2/sites-available/000-default.conf
    elif [[ $apachever == *"Apache/2.2"* ]]; then
        echo -e "${GREEN} [*] Apache version is 2.2m creating config...${NC}"
        cat > /etc/apache2/sites-available/default <<- EOM
  <VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /opt/observium/html
    <FilesMatch \.php$>
      SetHandler application/x-httpd-php
    </FilesMatch>
    <Directory />
            Options FollowSymLinks
            AllowOverride None
    </Directory>
    <Directory /opt/observium/html/>
            DirectoryIndex index.php
            Options Indexes FollowSymLinks MultiViews
            AllowOverride All
            Order allow,deny
            allow from all
    </Directory>
    ErrorLog  ${APACHE_LOG_DIR}/error.log
    LogLevel warn
    CustomLog  ${APACHE_LOG_DIR}/access.log combined
    ServerSignature On
  </VirtualHost>
EOM
        
        #echo "$APACHE22" > /etc/apache2/sites-available/default
    else
        echo -e "${RED} [*] ERROR: Could not find right version of Apache${NC}"
        exit 1
    fi
    a2enmod rewrite
    apache2ctl restart
    
    echo -e "${GREEN} [*] Create first time Observium admin user..${NC}"
    read -p "Username: " observ_username
    read -s -p "Password: " observ_password
    ./adduser.php $observ_username $observ_password 10

    echo -e "${GREEN} [*] Creating Observium cronjob...${NC}"
cat > /etc/cron.d/observium <<- EOM
# Run a complete discovery of all devices once every 6 hours
33  */6   * * *   observium   /opt/observium/observium-wrapper discovery >> /dev/null 2>&1
# Run automated discovery of newly added devices every 5 minutes
*/5 *     * * *   observium   /opt/observium/observium-wrapper discovery --host new >> /dev/null 2>&1
# Run multithreaded poller wrapper every 5 minutes
*/5 *     * * *   observium   /opt/observium/observium-wrapper poller >> /dev/null 2>&1

# Run housekeeping script daily for syslog, eventlog and alert log
13 5      * * *   observium   /opt/observium/housekeeping.php -ysel >> /dev/null 2>&1
# Run housekeeping script daily for rrds, ports, orphaned entries in the database and performance data
47 4      * * *   observium   /opt/observium/housekeeping.php -yrptb >> /dev/null 2>&1
EOM

else
    # remote poller, housekeeping disabled
    echo -e "${GREEN} [*] Creating Observium cronjob...${NC}"
cat > /etc/cron.d/observium <<- EOM
# Run a complete discovery of all devices once every 6 hours
33  */6   * * *   observium   /opt/observium/observium-wrapper discovery >> /dev/null 2>&1
# Run automated discovery of newly added devices every 5 minutes
*/5 *     * * *   observium   /opt/observium/observium-wrapper discovery --host new >> /dev/null 2>&1
# Run multithreaded poller wrapper every 5 minutes
*/5 *     * * *   observium   /opt/observium/observium-wrapper poller >> /dev/null 2>&1

# Run housekeeping script daily for syslog, eventlog and alert log
#13 5      * * *   observium   /opt/observium/housekeeping.php -ysel >> /dev/null 2>&1
# Run housekeeping script daily for rrds, ports, orphaned entries in the database and performance data
#47 4      * * *   observium   /opt/observium/housekeeping.php -yrptb >> /dev/null 2>&1
EOM
    
fi

# Fixate fping on ARM before snmpinstall
# chmod u+s /usr/bin/fping

echo -en "${GREEN}Would you like to install/configure SNMP daemon and monitor this host with Observium? ${YELLOW}(your snmpd-config will be overwritten!)${NC} (${BOLD}Y${NC}/n): "
read -n 1 yn
echo
case $yn in
  No|no|N|n)
    echo "Skipping snmpd installation"
    ;;
  *)
    snmpdinstall
    ;;
esac

echo -en "${GREEN}Would you like to install the UNIX-agent on this host?${NC} (y/${BOLD}N${NC}): "
read -n 1 yn
echo
case $yn in
  Yes|YES|yes|Y|y)
    agentinstall
    ;;
  *)
    echo "Skipping unix-agent installation"
    ;;
esac

echo -e "${GREEN} [*] Installation complete! Open your web browser, log in to the web interface with the account you just created, and add your first device.${NC}"

# EOF