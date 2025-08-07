#!/bin/bash

SERVICE="nginx"
LOG_DIR="/var/log/${SERVICE}_logs"
LOG_FILE="${LOG_DIR}/${SERVICE}.log"

mkdir -p "$LOG_DIR"

DATE=$(date '+%d/%m/%Y %H:%M:%S')

if systemctl is-active "$SERVICE"; then
    echo "[$DATE]: O serviço $SERVICE está ativo!" >> "$LOG_FILE"
else
    echo "[$DATE]: O serviço $SERVICE está desativado." >> "$LOG_FILE"
    ./discord_alert.sh
fi
