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
. shflags

target_setup_pre_project_packages() {
  # Install necessary packges
  apt update -y
  apt install -y xxd curl tmux python3 python3-pip
  pip3 install -r /root/ble_uart/requirements.txt

  # Download necessary files
  # TODO: cd /root/ble_uart/; ./envsetup.sh
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
  target_setup_post_ssh_enable
  target_setup_post_shutdown
fi