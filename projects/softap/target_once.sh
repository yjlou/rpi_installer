#!/usr/bin/env bash
#
# This script assumes only running once.
#
set -e
cd "$(dirname "$0")"
. rpi_installer/common.sh
. "$GENERATED_DIR"/softap/vars.sh
. "$SETTINGS_SH"
. rpi_installer/target_setup.sh

target_setup_pre_project_packages() {
  apt install -y xxd curl python3 python3-pip \
      hostapd dnsmasq \
      iperf3
}

target_setup_post_ap_settings() {
  # https://thepi.io/how-to-use-your-raspberry-pi-as-a-wireless-access-point/

  # hostapd
  sudo systemctl stop hostapd  || true
  cp conf/hostapd.conf /etc/hostapd/hostapd.conf
  cat conf/interfaces >> /etc/network/interfaces
  sudo systemctl unmask hostapd
  sudo systemctl enable hostapd
  sudo systemctl start hostapd
}


main() {
  target_setup_pre_time_is_synced
  target_setup_pre_locale_and_keyboard
  target_setup_pre_common_packages
  target_setup_pre_project_packages
  target_setup_post_networks
  target_setup_post_ap_settings
  target_setup_dhcp_server
  target_setup_nat "eth0"
  target_setup_post_ssh_enable
  target_setup_post_shutdown
  echo  "Setup is complete. The system is shutting itself down."
}

main "$@"
