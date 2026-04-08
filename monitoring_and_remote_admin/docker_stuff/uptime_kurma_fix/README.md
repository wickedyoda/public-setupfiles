# uptime_kurma_fix

## Overview
Utility script for enabling the Docker remote API so Uptime Kuma can check Docker status.

## Contents
- `uptime_docker-fix.sh`

## Usage
Run the script as root on the target host and optionally restrict access with the `--allow-ip` flag.

## Notes
The script modifies the Docker systemd override and can expose the Docker API over TCP, so firewall controls matter.
