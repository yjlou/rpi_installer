#!/usr/bin/env bash
#
# This script assumes only running once.
#
set -e
cd "$(dirname "$0")"
. rpi_installer/common.sh
. "$GENERATED_DIR"/ble_uart/vars.sh
. "$SETTINGS_SH"
. rpi_installer/nmcli.sh
. rpi_installer/target_setup.sh

target_setup_pre_time_is_synced

echo "- Setting up the locale and keyboard ..."
wget -O - https://gist.githubusercontent.com/adoyle/71803222aff301da9662/raw/e40f2a447e0ae333801e6fddf5e6bdb7430c289d/raspi-init.sh | bash
timedatectl set-timezone "$TIMEZONE"

# Install necessary packges
apt update -y
apt install -y xxd curl tmux python3 python3-pip
pip3 install -r /root/ble_uart/requirements.txt

# Download necessary files
# TODO: cd /root/ble_uart/; ./envsetup.sh

# Configure the network interfaces (this must be the last one since nmcli can change the network
# settings and fail to connect network again.
nmcli_setup
nmcli_ethernet_conn eth0 "$ETH0_IPV4_ADDR" "$ETH0_IPV4_GW"
nmcli_wifi_conn wlan0 "$WLAN0_IPV4_ADDR" "$WLAN0_IPV4_GW" "$WLAN0_SSID" "$WLAN0_PASSWORD"

# Enable ssh
sudo systemctl enable ssh
sudo systemctl start ssh

# Schedule a shutdown to inform the user everything is done.
(sleep 10; shutdown -h now) &
