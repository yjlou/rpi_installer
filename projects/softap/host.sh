#!/usr/bin/env bash
#
#  Running on the host. You must provide a Raspian OS image path and a SD device path.
#
#
set -e

. rpi_installer/common.sh
. projects/softap/vars.sh
. "$RPI_INSTALLER_DIR"/mount.sh
. "$RPI_INSTALLER_DIR"/ssh.sh
. "$RPI_INSTALLER_DIR"/utils.sh
. "$RPI_INSTALLER_DIR"/host_utils.sh
. "$(dirname "$0")"/change_settings.sh
. "$SETTINGS_SH"  || true

host_project() {
  # These helpers need project-specific settings.
  host_copy_vars_and_settings
  host_install_target_once

  # Define your project specific code below.
  host_copy_conf

  # Copy soft AP specific configuration files to /etc.
  sudo cp -r "$PROJECT_DIR/conf" "${MOUNT_ROOT}/rootfs/root/$RPI_INSTALLER_DIR/"

  # special handle for WLAN DHCP addresses
  local WLAN0_AP_IPV4_START=$(awk -F"." '{print $1"."$2"."$3".100"}'<<<$WLAN0_AP_IPV4_GW)
  local WLAN0_AP_IPV4_END=$(awk -F"." '{print $1"."$2"."$3".199"}'<<<$WLAN0_AP_IPV4_GW)
  # replace the variables in files.
  for var in WLAN0_AP_BAND WLAN0_AP_CHANNEL WLAN0_AP_SSID WLAN0_AP_PASSWORD \
             WLAN0_AP_IPV4_GW WLAN0_AP_IPV4_START WLAN0_AP_IPV4_END \
             ETH0_IPV4_ADDR ETH0_IPV4_GW ETH0_IPV4_DNS \
             TIMEZONE; do
    local value="$(eval echo $(echo "\$$var"))"
    echo "- Replacing $var --> $value ..."
    sudo find "${MOUNT_ROOT}/rootfs/root/$RPI_INSTALLER_DIR/conf" -type f |  \
        xargs sudo sed -i "s#$var#$value#"
  done

  host_append_to_rc_local "iperf3 -s -D"
  host_append_to_rc_local "iptables-restore < /etc/iptables.ipv4.nat || true"
}


FLAGS_HELP="USAGE: $0 [flags] /dev/sdcard image_file"
parse_args "$@"
eval set -- "${FLAGS_ARGV}"

if [ ${FLAGS_project_only} -eq ${FLAGS_TRUE} ]; then
  host_project "$@"
else
  host_pre "$@"
  host_project "$@"
  host_post "$@"
fi
