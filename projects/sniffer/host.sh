#!/usr/bin/env bash
#
#  Running on the host. You must provide a Raspian OS image path and a SD device path.
#
#  

set -e

. rpi_installer/common.sh
. projects/sniffer/vars.sh
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
