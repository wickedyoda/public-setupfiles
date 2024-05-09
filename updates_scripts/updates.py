#!/usr/bin/env python3

import subprocess


# Run 'sudo apt update'
subprocess.run(['sudo', 'apt', 'update'])

# Run 'sudo apt upgrade -y'
subprocess.run(['sudo', 'apt', 'upgrade', '-y'])

# Run 'sudo apt full-upgrade -y'
subprocess.run(['sudo', 'apt', 'full-upgrade', '-y'])

# Run 'sudo apt dist-upgrade -y'
subprocess.run(['sudo', 'apt', 'dist-upgrade', '-y'])

# Run 'sudo apt autoremove -y'
subprocess.run(['sudo', 'apt', 'autoremove', '-y'])

# Run 'sudo apt clean -y'
subprocess.run(['sudo', 'apt', 'clean', '-y'])

# Run 'sudo apt purge -y'
subprocess.run(['sudo', 'apt', 'purge', '-y'])
