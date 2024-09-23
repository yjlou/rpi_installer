#!/usr/bin/env bash
#
#  Host-specific helper functions.
#

set -e

. rpi_installer/common.sh
. rpi_installer/ssh.sh

. "$DOWNLOADS_DIR"/shflags

BOOT_CONFIG_FILE="${MOUNT_ROOT}/boot/config.txt"

# Used to parse the script arguments. Please pass in the arguments.
#
#   parse_args "$@"
#
parse_args() {
  # Common arguments. This will be applied to all scripts. Add wisely.
  #
  DEFINE_boolean 'do_nothing' false "Parse syntax only. Do nothing." 'n'
  DEFINE_boolean 'force' false "Force to run program anyway." 'f'
  DEFINE_boolean 'project_only' false "Execute the project-specific code only." 'p'

  # parse the command-line
  FLAGS "$@" || exit $?
  eval set -- "${FLAGS_ARGV}"

  if [ ${FLAGS_help} -eq ${FLAGS_TRUE} ]; then
    flags_help
    exit 1
  fi

  if [ ${FLAGS_do_nothing} -eq ${FLAGS_TRUE} ]; then
    msg_pass ""
    msg_pass "Done."
    msg_pass ""
    exit
  fi
}

host_sanity_check() {
  local device="$1"

  # Prompt user if user config file is not generated yet.
  if [ ! -f "$SETTINGS_SH" ]; then
    msg_fail "'$SETTINGS_SH' is not found. Please run $PROJECT_DIR/change_settings.sh to generate it."
    exit 2
  fi

  # Require the SD card device.
  if [ -z "$device" ]; then
    msg_fail "Please provide the device (ex /dev/sdz) of the SD card."
    echo
    flags_help
    exit 1
  fi

  # Warn the user.
  msg_warn "This will destroy the $device. Please confirm before we move on!"
  if [ ${FLAGS_force} -ne ${FLAGS_TRUE} ]; then
    read -r -p "Are you sure? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            exit 1
            ;;
    esac
  fi

  # Ask for sudo grant now. So that we don't ask the user again.
  sudo echo -n
  # Then keep the sudo working until the program terminates.
  keep_sudo
}

host_dd_image() {
  local img_file="$1"
  local device="$2"

  echo "- Write the Raspberry Pi image into SD card [$device] ..."
  sudo dd if="$img_file" of="$device" bs=1M status=progress
  sleep 3
  echo "- Re-detect the partition ..."
  sudo partprobe "$device"  # re-detect the partition table.
  sleep 3
  echo "- Mounting SD card ..."
  mount_all "$device"
}

# Install the RPi installer itself to /root/
#
# Assume the rootfs has mounted.
#
host_install_rpi_installer() {
  local TARGET="$RPI_INSTALLER_DIR_TARGET"

  sudo mkdir -p "$TARGET"
  sudo cp -r "$RPI_INSTALLER_DIR" "$TARGET"
  sudo cp -r "$DOWNLOADS_DIR"/shflags* "$TARGET"
}

host_copy_conf() {
  sudo cp conf/.bashrc conf/.tmux.conf "${MOUNT_ROOT}/rootfs/root/"
}

host_set_config_file() {
  echo "hdmi_force_hotplug=1" | sudo tee -a "$BOOT_CONFIG_FILE"
  echo "dtparam=spi=on" | sudo tee -a "$BOOT_CONFIG_FILE"
  echo "enable_uart=1" | sudo tee -a "$BOOT_CONFIG_FILE"
}

host_append_to_rc_local() {
  local cmds="$@"

  # Remot the last of file, which is "exit 0"
  sudo sed -i '$d' "$RC_LOCAL_FILE"

  echo "$@" | sudo tee -a "$RC_LOCAL_FILE"

  # Move back the "exit 0" line.
  echo "exit 0" | sudo tee -a "$RC_LOCAL_FILE"
}

host_install_target_once() {
  echo "- Install run once program into '$RC_LOCAL_FILE' ..."
  sudo mkdir -p "$RPI_INSTALLER_DIR_TARGET"
  sudo cp -r "$PROJECT_DIR/target_once.sh" "$RPI_INSTALLER_DIR_TARGET/target_once.sh-$PROJECT_NAME"
  host_append_to_rc_local "/root/$RPI_INSTALLER_DIR/rpi_installer/run_once.sh /root/$RPI_INSTALLER_DIR/target_once.sh-* >> /var/log/setup.log 2>&1"
}

host_pre() {
  local device="$1"
  local img_file="$2"

  host_sanity_check "$device"

  umount_all

  host_dd_image "$img_file" "$device"

  host_install_rpi_installer
  copy_ssh_credential
  host_set_config_file
}

host_copy_vars_and_settings() {
  local target_gen_dir="$RPI_INSTALLER_DIR_TARGET/$GENERATED_DIR/$PROJECT_NAME/"
  sudo mkdir -p "$target_gen_dir"
  sudo cp "$PROJECT_DIR"/vars.sh "$target_gen_dir"
  sudo cp "$SETTINGS_SH" "$target_gen_dir"
}

host_hints_at_end() {
  echo "--------------------------------------------------------------------------"
  echo "+ Insert the SD card into the Raspberry Pi board."
  echo "+ Connect an Ethernet conenction to the Internet."
  echo "+ Power up the board, and wait for about 30 mins."
  echo "+ The board will be automatically shut down after successful installation."
  echo "+ If not, please log in and check the '/var/log/setup.log' file."
  echo "--------------------------------------------------------------------------"
  if [ ! -z "$ETH0_IPV4_ADDR" ]; then
    echo "After installation, ssh to root@${ETH0_IPV4_ADDR%/*}"
    echo "--------------------------------------------------------------------------"
  fi
}

host_post() {
  mount_finish
  msg_pass "Done"
  host_hints_at_end
}
