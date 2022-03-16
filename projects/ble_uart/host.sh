#!/usr/bin/env bash
#
#  Running on the host. You must provide a Raspian OS image path and a SD device path.
#
#  

set -e

. rpi_installer/common.sh
. projects/ble_uart/vars.sh
. "$RPI_INSTALLER_DIR"/mount.sh
. "$RPI_INSTALLER_DIR"/ssh.sh
. "$RPI_INSTALLER_DIR"/utils.sh
. "$(dirname "$0")"/change_settings.sh
. "$SETTINGS_SH"  || true

main() {
  local img_file="$1"
  local device="$2"

  sanity_check "$device"

  echo "- Downloading BLE UART code ..."
  if [ -d "$BLE_UART_DIR_HOST" ]; then
    msg_pass "Directory [$BLE_UART_DIR_HOST] exists."
  else
    git clone git@github.com:yjlou/ble_uart.git "$BLE_UART_DIR_HOST"
  fi

  echo "- Unmounting existing partitions (if any) ..."
  umount_all

  dd_image "$img_file" "$device"
  
  ###########################################################################
  #
  #  Let's do some real works now !!!!!
  #
  ###########################################################################

  # Copy RPi installer code.
  install_rpi_installer
  sudo cp "$PROJECT_DIR"/vars.sh "$RPI_INSTALLER_DIR_TARGET"
  sudo mkdir -p "$RPI_INSTALLER_DIR_TARGET/$GENERATED_DIR"
  sudo cp "$SETTINGS_SH" "$RPI_INSTALLER_DIR_TARGET/$GENERATED_DIR"

  # Copy BLE UART code
  local TARGET_PROGRAM_DIR="${MOUNT_ROOT}/rootfs/${BLE_UART_DIR_TARGET}"
  echo "- Copying all scripts into $TARGET_PROGRAM_DIR ..."
  sudo mkdir -p "$TARGET_PROGRAM_DIR"
  sudo cp -v -rf -L "$BLE_UART_DIR_HOST"/* "$TARGET_PROGRAM_DIR"

  # Copy ssh credential for the host to login.
  copy_ssh_credential

  # Copy .bashrc and .tmux files
  sudo cp conf/.bashrc conf/.tmux.conf "${MOUNT_ROOT}/rootfs/root/"

  # Set boot/config.txt
  local BOOT_CONFIG_FILE="${MOUNT_ROOT}/boot/config.txt"
  echo "hdmi_force_hotplug=1" | sudo tee -a "$BOOT_CONFIG_FILE"

  # rc.local
  #
  # TODO: rewrite with tmux
  echo "- Install run once program into '$RC_LOCAL_FILE' ..."
  sudo mkdir -p "$RPI_INSTALLER_DIR_TARGET"
  sudo cp -r "$PROJECT_DIR/only_once.sh" "$RPI_INSTALLER_DIR_TARGET"
  append_to_rc_local "/root/$RPI_INSTALLER_DIR/rpi_installer/run_once.sh /root/$RPI_INSTALLER_DIR/only_once.sh >> /var/log/setup.log 2>&1"

  # TODO: tmux.sh
  echo "- Install programs into '$RC_LOCAL_FILE' ..."
  append_to_rc_local "cd $BLE_UART_DIR_TARGET"
  append_to_rc_local "tmux new-session -d -s ble_uart -n daemon"
  append_to_rc_local "tmux send-keys -t ble_uart:daemon './ble_uart.py -l' Enter"
  append_to_rc_local "tmux new-window -t ble_uart -n help"
  append_to_rc_local "tmux send-keys -t ble_uart:help './ble_uart.py --help' Enter"

  # Tear down ...
  mount_finish

  msg_pass "Done"

  hints_at_end
}

FLAGS_HELP="USAGE: $0 [flags] image_file /dev/sdcard"
parse_args "$@"
eval set -- "${FLAGS_ARGV}"
main "$@"
