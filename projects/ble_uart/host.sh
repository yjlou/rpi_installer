#!/usr/bin/env bash
#
#  Running on the host. You must provide a Raspian OS image path and a SD device path.
#

set -e

. rpi_installer/common.sh
. projects/ble_uart/vars.sh
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

  echo "- Downloading BLE UART code ..."
  if [ -d "$BLE_UART_DIR_HOST" ]; then
    msg_pass "Directory [$BLE_UART_DIR_HOST] exists."
  else
    git clone git@github.com:yjlou/ble_uart.git "$BLE_UART_DIR_HOST"
  fi

  # Copy BLE UART code
  local TARGET_PROGRAM_DIR="${MOUNT_ROOT}/rootfs/${BLE_UART_DIR_TARGET}"
  echo "- Copying all scripts into $TARGET_PROGRAM_DIR ..."
  sudo mkdir -p "$TARGET_PROGRAM_DIR"
  sudo cp -v -rf -L "$BLE_UART_DIR_HOST"/* "$TARGET_PROGRAM_DIR"

  # TODO: use tmux.sh
  # TODO: move to projects/ble_uart/everytime.sh
  echo "- Install programs into '$RC_LOCAL_FILE' ..."
  host_append_to_rc_local "cd $BLE_UART_DIR_TARGET"
  host_append_to_rc_local "tmux new-session -d -s ble_uart -n daemon"
  host_append_to_rc_local "tmux send-keys -t ble_uart:daemon './ble_uart.py -l' Enter"
  host_append_to_rc_local "tmux new-window -t ble_uart -n help"
  host_append_to_rc_local "tmux send-keys -t ble_uart:help './ble_uart.py --help' Enter"

  mount_finish
  msg_pass "Done"
  host_hints_at_end
}

FLAGS_HELP="USAGE: $0 [flags] image_file /dev/sdcard"
parse_args "$@"
eval set -- "${FLAGS_ARGV}"
main "$@"
