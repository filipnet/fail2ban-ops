#!/bin/bash
# Script to analyze and display blocked IP statistics from the firewall log based on Fail2Ban activity.

# Configurable log file (default is /var/log/firewalld.log)
LOG_FILE="/var/log/firewalld.log"

# Configurable threshold for the block count (default is 200)
THRESHOLD=200

# Check if the log file exists
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: Log file $LOG_FILE does not exist."
    exit 1
fi

# Firewalld zone where Fail2Ban adds blocked IPs
ZONE="public"

echo "Checking blocked IP addresses in Firewalld zone '$ZONE' via logs:"

# Print table header
printf "\n%-20s %-20s\n" "Blocking Counter" "IP Address"
printf "%-40s\n" "-----------------------------------------"

# Use a single pass of awk to extract, count, and filter the IPs efficiently, then sort and format the output
awk -v threshold="$THRESHOLD" '
    /filter_IN_public_REJECT/ {
        if (match($0, /SRC=[0-9a-fA-F:.]+/)) {
            ip = substr($0, RSTART+4, RLENGTH-4)  # Extract IP after "SRC="
            ip_count[ip]++
        }
    }
    END {
        for (ip in ip_count) {
            if (ip_count[ip] >= threshold) {
                printf "%-20d %-20s\n", ip_count[ip], ip
            }
        }
    }
' "$LOG_FILE" | sort -nr
