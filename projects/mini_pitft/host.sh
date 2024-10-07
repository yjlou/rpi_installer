#!/usr/bin/env bash
#
#  Running on the host. You must provide a Raspian OS image path and a SD device path.
#
#

set -e

. rpi_installer/common.sh
. projects/mini_pitft/vars.sh
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
  host_copy_conf

  # ----------------------------------------
  # Define your project specific code below.

  # Copy code
  local HOST_CODE_DIR="stock_price"
  local TARGET_CODE_DIR="${TARGET_PROG_DIR}/${HOST_CODE_DIR}"
  local TARGET_PROGRAM_DIR="${RPI_INSTALLER_DIR_TARGET}/${HOST_CODE_DIR}"

  echo "- Copying all scripts into $TARGET_PROGRAM_DIR ..."
  sudo mkdir -p "$TARGET_PROGRAM_DIR"
  sudo cp -v -rf -L "$PROJECT_DIR/$HOST_CODE_DIR"/* "$TARGET_PROGRAM_DIR"

  echo "- Install programs into '$RC_LOCAL_FILE' ..."
  host_append_to_rc_local "tmux new-session -d -s pitft -n daemon"
  host_append_to_rc_local "tmux send-keys -t pitft:daemon '$TARGET_CODE_DIR/run.sh' Enter"
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
