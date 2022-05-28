#!/usr/bin/env bash
#
# This file provides the common functions for setup.
#
# We can split the setup procedure into 2 stages:
#
#   1. 'pre_setup' stage: In this stage, the program requires to access the Internet and download
#                         the necessary packages.
#
#   2. 'post_setup' stage: In this stage, the system will be shaped to the real production
#                          configuration. For example, setting up the WiFi SSID and Etherner
#                          settings.
#
#   After the 2 stages are done, the system will shutdown to indicate the setup is done.
#

set -e
cd "$(dirname "$0")"
. rpi_installer/nmcli.sh

# Sanity checks
if [ -z "$PROJECT_VARS_IMPORTED" ]; then
  echo
  echo "The 'PROJECT_VARS_IMPORTED' variable was not defined. Please fix the program. Maybe '. \$GENERATED_DIR/PROJECT/vars.sh'?"
  echo
  exit 1
fi
if [ -z "$PROJECT_SETTINGS_IMPORTED" ]; then
  echo
  echo "The 'PROJECT_SETTINGS_IMPORTED' variable was not defined. Please fix the program. Maybe '. \$SETTINGS_SH?"
  echo
  exit 1
fi

target_setup_pre_time_is_synced() {
  echo "- Sleep 10 secs to let the device have time to sync up ..."
  sleep 15
}

target_setup_pre_locale_and_keyboard() {
  echo "- Setting up the locale and keyboard ..."
  wget -O - https://gist.githubusercontent.com/adoyle/71803222aff301da9662/raw/e40f2a447e0ae333801e6fddf5e6bdb7430c289d/raspi-init.sh | bash
  timedatectl set-timezone "$TIMEZONE"
}

target_setup_pre_common_packages() {
  apt update -y
  apt install -y tmux
}

target_setup_post_networks() {
  # Configure the network interfaces (this must be the last one since nmcli can change the network
  # settings and fail to connect network again.
  nmcli_setup
  nmcli_ethernet_conn eth0 "$ETH0_IPV4_ADDR" "$ETH0_IPV4_GW"
  nmcli_wifi_conn wlan0 "$WLAN0_IPV4_ADDR" "$WLAN0_IPV4_GW" "$WLAN0_SSID" "$WLAN0_PASSWORD"
}

target_setup_post_ssh_enable() {
  # Enable ssh
  sudo systemctl enable ssh
  sudo systemctl start ssh
}

target_setup_post_shutdown() {
  # Schedule a shutdown to inform the user everything is done.
  (sleep 10; shutdown -h now) &
}
