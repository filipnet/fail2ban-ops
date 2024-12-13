#!/bin/bash
# Script to check the status of Fail2Ban jails and list banned IP addresses.

# Define color codes
GREEN="\033[0;32m"   # Green color
RED="\033[0;31m"     # Red color
RESET="\033[0m"      # Reset color

# Check if fail2ban is installed
if ! command -v fail2ban-client &> /dev/null; then
    echo "fail2ban is not installed."
    exit 1
fi

# Check firewall status
echo "Firewall Status:"
firewall-cmd --list-rich-rules
echo

# Retrieve all active jails
JAILS=$(fail2ban-client status | grep 'Jail list:' | sed 's/.*: *//;s/,/ /g')

# Convert jails into an array
JAIL_ARRAY=($JAILS)

if [ ${#JAIL_ARRAY[@]} -eq 0 ]; then
    echo "No active jails."
    exit 0
fi

# Check and output the status for each jail
for JAIL in "${JAIL_ARRAY[@]}"; do
    STATUS=$(fail2ban-client status "$JAIL")

    # Print the status of the jail
    echo "$STATUS"

    # Extract the Banned IP list (everything after "Banned IP list:")
    BANNED_LIST=$(echo "$STATUS" | grep -oP '(?<=Banned IP list:).*')

    # Check if BANNED_LIST is empty or contains only spaces
    if [[ -z "$BANNED_LIST" || "$BANNED_LIST" =~ ^[[:space:]]*$ ]]; then
        echo -e "${GREEN}No IP addresses have been banned in $JAIL.${RESET}"
    else
        echo -e "${RED}IP addresses have been banned in $JAIL.${RESET}"
    fi
    echo
done
