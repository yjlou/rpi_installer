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

  # DHCP server
  sudo systemctl stop dnsmasq  || true
  cp conf/dnsmasq.conf /etc/dnsmasq.conf
  sudo systemctl start dnsmasq

  # routing and iptables
  sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  iptables-save > /etc/iptables.ipv4.nat  # will be loaded in /etc/rc.local
}


main() {
  target_setup_pre_time_is_synced
  target_setup_pre_locale_and_keyboard
  target_setup_pre_common_packages
  target_setup_pre_project_packages
  target_setup_post_networks
  target_setup_post_ap_settings
  target_setup_post_ssh_enable
  target_setup_post_shutdown
  echo  "Setup is complete. The system is shutting itself down."
}

main "$@"
