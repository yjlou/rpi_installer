#!/usr/bin/env bash

set -e

. rpi_installer/common.sh

NMCLI="sudo nmcli"

nmcli_restart() {
  sudo systemctl stop dhcpcd.service  || true
  sudo systemctl disable dhcpcd.service  || true
  sudo service network-manager restart  || true  # for old version of raspberry images
  sudo service NetworkManager restart  || true  # for new version of raspberry images
  sleep 10  # This takes some time to acquire the interfaces.
}

nmcli_setup() {
  apt install -y "network-manager"

  nmcli_restart
  if ! systemctl is-active --quiet NetworkManager.service; then
    systemctl start NetworkManager.service
    systemctl enable NetworkManager.service
  fi
  nmcli_restart
}

nmcli_ethernet_dhcp() {
  local ifname="$1"

  $NMCLI con delete "$ifname" || true
  $NMCLI con add type ethernet con-name "$ifname" ifname "$ifname"
  $NMCLI con modify "$ifname" connection.autoconnect yes
  $NMCLI con modify id "$ifname" 802-3-ethernet.mac-address ""
  $NMCLI con modify "$ifname" ipv4.method auto
}

nmcli_ethernet_static() {
  local ifname="$1"
  local address="$2"
  local gateway="$3"

  $NMCLI con delete "$ifname" || true
  $NMCLI con add type ethernet con-name "$ifname" ifname "$ifname"
  $NMCLI con modify "$ifname" connection.autoconnect yes
  $NMCLI con modify id "$ifname" 802-3-ethernet.mac-address ""
  $NMCLI con modify "$ifname" ipv4.addresses "$address"
  $NMCLI con modify "$ifname" ipv4.gateway "$gateway"
  $NMCLI con modify "$ifname" ipv4.method manual
  $NMCLI con modify "$ifname" ipv4.dns "8.8.8.8"
  $NMCLI con modify "$ifname" ipv4.route-metric 1000
  $NMCLI con up "$ifname"
}

nmcli_ethernet_conn() {
  local ifname="$1"
  local address="$2"
  local gateway="$3"

  if [ -z "$address" ]; then
    nmcli_ethernet_dhcp "${ifname}"
  else
    nmcli_ethernet_static "${ifname}" "$address" "$gateway"
  fi
}

nmcli_wifi_dhcp() {
  local ifname="$1"
  local ssid="$2"
  local password="$3"
  [ -z "$password" ] || password="password $password"

  $NMCLI con delete "$ssid" || true
  $NMCLI dev wifi connect "$ssid" $password ifname "$ifname"
  $NMCLI con modify "$ssid" connection.autoconnect yes
  $NMCLI con modify id "$ssid" 802-11-wireless.mac-address ""
  $NMCLI con modify "$ssid" ipv4.method auto
}

nmcli_wifi_static() {
  local ifname="$1"
  local address="$2"
  local gateway="$3"
  local ssid="$4"
  local password="$5"
  [ -z "$password" ] || password="password $password"

  $NMCLI con delete "$ssid" || true
  $NMCLI dev wifi connect "$ssid" $password ifname "$ifname"
  $NMCLI con modify "$ssid" connection.autoconnect yes
  $NMCLI con modify id "$ssid" 802-11-wireless.mac-address ""
  $NMCLI con modify "$ssid" ipv4.addresses "$address"
  $NMCLI con modify "$ssid" ipv4.gateway "$gateway"
  $NMCLI con modify "$ssid" ipv4.method manual
  $NMCLI con modify "$ssid" ipv4.dns "8.8.8.8"
  $NMCLI con up "$ssid"
}

nmcli_wifi_conn() {
  local ifname="$1"
  local address="$2"
  local gateway="$3"
  local ssid="$4"
  local password="$5"

  if [ -z "$ssid" ]; then
    return
  fi

  if [ -z "$address" ]; then
    nmcli_wifi_dhcp "${ifname}" "$ssid" "$password"
  else
    nmcli_wifi_static "${ifname}" "$address" "$gateway" "$ssid" "$password"
  fi
}
