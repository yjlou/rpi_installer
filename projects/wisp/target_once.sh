#!/usr/bin/env bash
#
# This script assumes only running once.
#
set -e
cd "$(dirname "$0")"
. rpi_installer/common.sh
. "$GENERATED_DIR"/wisp/vars.sh
. "$SETTINGS_SH"
. rpi_installer/target_setup.sh
. shflags

target_setup_pre_project_packages() {
  apt install -y xxd curl python3 python3-pip \
    dnsmasq
}


FLAGS_HELP="USAGE: $0 [flags]"
target_setup_parse_args "$@"
eval set -- "${FLAGS_ARGV}"

if [ ${FLAGS_project_only} -eq ${FLAGS_TRUE} ]; then
  target_setup_pre_project_packages
else
  target_setup_post_ssh_enable  # turn on the SSH for debug.
  target_setup_pre_time_is_synced
  target_setup_pre_locale_and_keyboard
  target_setup_pre_common_packages
  target_setup_pre_project_packages
  target_setup_post_networks
  target_setup_dhcp_server
  target_setup_nat "wlan0"  # The interface to the Internet.
  target_setup_post_ssh_enable
  target_setup_post_shutdown
fi