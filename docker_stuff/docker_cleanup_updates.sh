#!/bin/bash

set -euo pipefail

echo "=================================================="
echo " WickedYoda System Update & Docker Cleanup"
echo " Started: $(date)"
echo "=================================================="

#
# Step 1 - Update local setup scripts from GitHub
#
echo
echo "==> Updating setup scripts from GitHub..."
curl -fsSL https://raw.githubusercontent.com/wickedyoda/public-setupfiles/refs/heads/main/update-from_repo.sh | sudo bash

#
# Step 2 - Run the update script
#
echo
echo "==> Running system update..."
sudo ./public-setupfiles/updates_scripts/updates.sh

#
# Step 3 - Remove unused Docker images
#
echo
echo "==> Pruning unused Docker images..."
docker image prune -af

#
# Step 4 - Remove unused Docker networks
#
echo
echo "==> Pruning unused Docker networks..."
docker network prune -f

#
# Step 5 - Remove stopped containers
#
echo
echo "==> Pruning stopped Docker containers..."
docker container prune -f

#
# Step 6 - Remove unused build cache
#
echo
echo "==> Pruning Docker build cache..."
docker builder prune -af

echo
echo "=================================================="
echo " Update and cleanup completed successfully!"
echo " Finished: $(date)"
echo "=================================================="