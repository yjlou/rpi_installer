#!/usr/bin/env bash
#
#  Running on the host. You must provide a Raspian OS image path and a SD device path.
#
#

set -e

. rpi_installer/common.sh
. projects/dummy/vars.sh
. "$RPI_INSTALLER_DIR"/mount.sh
. "$RPI_INSTALLER_DIR"/ssh.sh
. "$RPI_INSTALLER_DIR"/utils.sh
. "$RPI_INSTALLER_DIR"/host_utils.sh
. "$(dirname "$0")"/change_settings.sh
. "$SETTINGS_SH"  || true

main() {
  local img_file="$1"
  local device="$2"

  host_sanity_check "$device"

  umount_all

  host_dd_image "$img_file" "$device"

  host_install_rpi_installer
  host_copy_vars_and_settings
  copy_ssh_credential

  host_copy_conf
  host_set_config_file
  host_install_target_once

  mount_finish
  msg_pass "Done"
  host_hints_at_end
}

FLAGS_HELP="USAGE: $0 [flags] image_file /dev/sdcard"
parse_args "$@"
eval set -- "${FLAGS_ARGV}"
main "$@"
