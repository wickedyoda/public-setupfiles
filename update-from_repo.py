#!/bin/bash

# run apt update to make sure the system has the latest repo files
import subprocess

subprocess.run(["sudo", "apt", "update", "-y"])

# Check if git is installedd
try:
    subprocess.run(["git", "--version"], check=True)
except subprocess.CalledProcessError:
    # Install git
    subprocess.run(["sudo", "apt-get", "install", "git", "-y"])

# Specify the remote repository URLL
remote_repo = "https://github.com/wickedyoda/public-setupfiles.git"

# Specify the local file path
local_file = "./pubic-setupfiles"


# Check if the local file path exists and is not empty
import os

if os.path.isdir(local_file) and os.listdir(local_file):
    # Delete the existing directory
    subprocess.run(["sudo", "rm", "-rf", local_file])

# Clone the remote repository to the local file pathh
subprocess.run(["git", "clone", remote_repo, local_file])


# Make all files executable and public ownership
subprocess.run(["sudo", "chmod", "777", "-R", local_file])

