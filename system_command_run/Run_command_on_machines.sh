#!/bin/bash

MACHINE_FILE="machines.txt"
LOG_FILE="ssh_command_log.txt"

echo -n "Enter command to execute: "
read COMMAND

echo "Executing on all machines..."
echo "Execution Log - $(date)" > "$LOG_FILE"

while IFS=" " read -r HOST USER PASS; do
    echo "Running on $HOST..."
    if [[ -z "$PASS" ]]; then
        ssh "$USER@$HOST" "$COMMAND" >> "$LOG_FILE" 2>&1
    else
        sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no "$USER@$HOST" "$COMMAND" >> "$LOG_FILE" 2>&1
    fi
done < "$MACHINE_FILE"

echo "Execution complete. Logs saved in $LOG_FILE."