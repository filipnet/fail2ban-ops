#!/bin/bash
# Script to remove an IP address (IPv4/IPv6) or DNS-resolved IPs from a Fail2Ban jail.

# ANSI color codes
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# Check for correct input parameters
if [ $# -ne 2 ]; then
  echo "Usage: $0 <IP/Hostname> <Jail-Name>"
  exit 1
fi

TARGET=$1       # IPv4, IPv6, or DNS name
JAIL_NAME=$2    # Jail name from which the IP(s) should be unbanned

# Function to unban an IP address
unban_ip() {
  local IP=$1
  echo "Attempting to unban IP: $IP from Jail: $JAIL_NAME"

  # Run fail2ban-client and capture its return status
  fail2ban-client set "$JAIL_NAME" unbanip "$IP"
  STATUS=$?

  if [ $STATUS -eq 0 ]; then
    # IP was not found in the jail
    echo -e "${RED}Not found:${RESET} IP $IP in Jail $JAIL_NAME"
  elif [ $STATUS -eq 1 ]; then
    # IP successfully removed
    echo -e "${GREEN}Success:${RESET} IP $IP has been removed from Jail $JAIL_NAME"
  else
    # Other errors
    echo -e "${RED}Error:${RESET} Failed to remove IP $IP from Jail $JAIL_NAME"
  fi
}

# Resolve DNS name to IPv4 and IPv6 addresses if necessary
if [[ $TARGET =~ ^[a-zA-Z0-9.-]+$ ]]; then
  echo "Resolving DNS name: $TARGET"

  # Resolve IPv4 addresses
  IPV4_ADDRESSES=$(getent ahosts "$TARGET" | awk '$2 == "STREAM" {print $1}' | grep -E '^[0-9.]+$' | sort -u)
  # Resolve IPv6 addresses
  IPV6_ADDRESSES=$(getent ahosts "$TARGET" | awk '$2 == "STREAM" {print $1}' | grep -E '^[0-9a-fA-F:]+$' | sort -u)

  if [ -z "$IPV4_ADDRESSES" ] && [ -z "$IPV6_ADDRESSES" ]; then
    echo -e "${RED}Error:${RESET} Could not resolve any IP addresses for $TARGET"
    exit 2
  fi

  # Unban all resolved IPv4 addresses
  for IP in $IPV4_ADDRESSES; do
    unban_ip "$IP"
  done

  # Unban all resolved IPv6 addresses
  for IP in $IPV6_ADDRESSES; do
    unban_ip "$IP"
  done
else
  # Direct IP input (IPv4 or IPv6)
  unban_ip "$TARGET"
fi

exit 0
