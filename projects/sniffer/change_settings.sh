#!/usr/bin/env bash
#
# This file contains the user's settings. Modified by user_settings.sh.
#
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"/../../  # to the root of the rpi_installer

. rpi_installer/common.sh
. "$RPI_INSTALLER_DIR"/utils.sh
. "$RPI_INSTALLER_DIR"/host_utils.sh
. projects/sniffer/vars.sh


SETTINGS_TEMPLATE="$PROJECT_DIR/settings.sh.template"
SETTINGS_TEMPORARY="$GENERATED_DIR/$PROJECT_NAME/settings.sh.temporary"

mkdir -p "$GENERATED_DIR/$PROJECT_NAME/"

change_settigs_main() {
  FLAGS_HELP="USAGE: $0 [flags]"
  parse_args "$@"
  eval set -- "${FLAGS_ARGV}"

  # Copy the template to the output file.
  cp -f "$SETTINGS_TEMPLATE" "$SETTINGS_TEMPORARY"

  # WLAN
  echo "- WLAN"
  ask_and_replace "What's the WLAN SSID                              ? " "WLAN0_SSID"
  ask_and_replace "What's the WLAN password  (empty for open network)? " "WLAN0_PASSWORD"
  ask_and_replace "What's the WLAN IP address/mask   (empty for DHCP)? " "WLAN0_IPV4_ADDR"
  ask_and_replace "What's the WLAN IP gateway        (empty for DHCP)? " "WLAN0_IPV4_GW"

  # Ethernet
  echo "- Ethernet"
  ask_and_replace "What's the Ethernet IP address/mask  (empty for DHCP)? " "ETH0_IPV4_ADDR"
  ask_and_replace "What's the Ethernet IP gateway       (empty for DHCP)? " "ETH0_IPV4_GW"

  # Timezone
  echo "- Timezone"
  local def_tz="$(timedatectl |grep "Time zone" | awk '{ print $3}')"
  ask_and_replace "What's the timezone? Hints: 'timedatectl list-timezones' (empty to use local) " "TIMEZONE" "$def_tz"

  # Prompt the user that the file has been saved.
  echo '------------------------------------------------'
  mv -f "$SETTINGS_TEMPORARY" "$SETTINGS_SH"
  msg_pass "Saved in '$SETTINGS_SH'."
  echo '------------------------------------------------'
  cat "$SETTINGS_SH"
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || change_settigs_main "$@"
