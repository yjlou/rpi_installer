#!/usr/bin/env bash
#
# This script assumes only running once.
#
set -e
cd "$(dirname "$0")"
. rpi_installer/common.sh
. "$GENERATED_DIR"/dummy/vars.sh
. "$SETTINGS_SH"
. rpi_installer/target_setup.sh

target_setup_pre_project_packages() {
  apt install -y xxd curl python3 python3-pip
}

main() {
  target_setup_pre_time_is_synced
  target_setup_pre_locale_and_keyboard
  target_setup_pre_common_packages
  target_setup_pre_project_packages
  target_setup_post_networks
  target_setup_post_ssh_enable
  target_setup_post_shutdown
  echo  "Setup is complete. The system is shutting itself down."
}

main "$@"
