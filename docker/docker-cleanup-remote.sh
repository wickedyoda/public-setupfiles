#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINE_FILE="${1:-$SCRIPT_DIR/machines.txt}"
LOG_FILE="$SCRIPT_DIR/docker_cleanup_$(date +%Y%m%d_%H%M%S).log"

if [[ ! -f "$MACHINE_FILE" ]]; then
    echo "Machine list file not found: $MACHINE_FILE"
    echo "Create it with one hostname or IP per line."
    exit 1
fi

if ! command -v sshpass >/dev/null 2>&1; then
    echo "sshpass is required but not installed."
    echo "Install it and run the script again."
    exit 1
fi

read -r -p "SSH username (same account for all machines): " SSH_USER
if [[ -z "$SSH_USER" ]]; then
    echo "Username cannot be empty."
    exit 1
fi

read -r -s -p "SSH password: " SSH_PASS
echo
if [[ -z "$SSH_PASS" ]]; then
    echo "Password cannot be empty."
    exit 1
fi

trap 'unset SSH_PASS' EXIT

echo "This will remove unused Docker containers, images, volumes, and networks on all listed hosts."
read -r -p "Continue? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo "Docker cleanup run started: $(date)" | tee "$LOG_FILE"
echo "Machine file: $MACHINE_FILE" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

SUCCESS_COUNT=0
FAIL_COUNT=0

while IFS= read -r RAW_LINE || [[ -n "$RAW_LINE" ]]; do
    HOST="$(printf '%s' "$RAW_LINE" | sed 's/#.*$//' | xargs)"

    if [[ -z "$HOST" ]]; then
        continue
    fi

    echo "========== $HOST ==========" | tee -a "$LOG_FILE"

    if sshpass -p "$SSH_PASS" ssh \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=12 \
        "$SSH_USER@$HOST" 'bash -s' >>"$LOG_FILE" 2>&1 <<'REMOTE_CLEANUP'
set -e

docker container prune -f
docker image prune -a -f
docker volume prune -f
docker network prune -f
REMOTE_CLEANUP
    then
        echo "SUCCESS: $HOST" | tee -a "$LOG_FILE"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "FAILED: $HOST" | tee -a "$LOG_FILE"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    echo | tee -a "$LOG_FILE"
done < "$MACHINE_FILE"

echo "Run complete: $(date)" | tee -a "$LOG_FILE"
echo "Successful hosts: $SUCCESS_COUNT" | tee -a "$LOG_FILE"
echo "Failed hosts: $FAIL_COUNT" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE"
