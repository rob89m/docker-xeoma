#!/bin/bash

set -e

DEFAULT_CONFIG_FILE=/files/xeoma.conf.default
CONFIG_FILE=/config/xeoma.conf
MAC_FILE=/config/macs.txt

#-----------------------------------------------------------------------------------------------------------------------

function ts {
  echo [`date '+%b %d %X'`]
}

#-----------------------------------------------------------------------------------------------------------------------

# Handle the config file
if [ ! -f "$CONFIG_FILE" ]
then
  echo "$(ts) Creating config file $CONFIG_FILE. Please set the password and rerun this container."
  cp "$DEFAULT_CONFIG_FILE" "$CONFIG_FILE"
  chmod a+w "$CONFIG_FILE"
  exit 1
fi

# Deal with \r caused by editing in windows
tr -d '\r' < "$CONFIG_FILE" > /tmp/xeoma.conf

source /tmp/xeoma.conf

if [[ "$PASSWORD" == "YOUR_PASSWORD" ]]; then
  echo "$(ts) Config file still has the default password. Please change the password and rerun this container."
  exit 1
fi

#-----------------------------------------------------------------------------------------------------------------------

# Save some information about the interface that talks to the internet, in case we need it later.

# Have to parse /proc/net/route because there is no "ip" to do this: iface=$(ip route show default | awk '/default/ {print $5}')
iface=$(grep -E '^\S+\s+00000000' /proc/net/route | awk '{print $1}')
mac_address=$(cat /sys/class/net/$iface/address)
echo "$(ts) $iface $mac_address" >> "$MAC_FILE"

#-----------------------------------------------------------------------------------------------------------------------

ln -s /config /usr/local/Xeoma
rm -f /config/XeomaArchive
ln -s /archive /config/XeomaArchive