sudo apt install -y nmap \
    wordlist \
    ettercap-common \
    ettercap-graphical \
    arp-scan \
    wfuzz \
    wireshark \
    airgeddon \
    aircrack-ng \
    airgraph-ng \
    traceroute \
    wifite wpscan \
    whois \
    wifiphisher \
    kismet \
    netdiscover \
    bettercap \
    burpsuite  \
    tcpdump \
    fern-wifi-cracker \
    bettercap-ui \
    wifi-honey \
    gparted \
    gvm \
    openvas \
    git

git clone https://github.com/LionSec/katoolin.git && cp katoolin/katoolin.py /usr/bin/katoolin
chmod +x  /usr/bin/katoolin
# sudo katoolin

