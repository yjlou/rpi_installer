#!/usr/bin/env bash

set -e

. rpi_installer/common.sh

. "$DOWNLOADS_DIR"/shflags

COLOR_RED="\e[41;30m"
COLOR_GREEN="\e[42;30m"
COLOR_BLUE="\e[44;30m"
COLOR_YELLOW="\e[43;30m"
COLOR_WHITE="\e[0;37m"
COLOR_NO="\e[0m"

msg_debug() {
  local msg="$1"
  printf "${COLOR_NO}[ ${COLOR_BLUE}DEBUG${COLOR_NO} ]${COLOR_WHITE} $msg\n${COLOR_NO}"
}

msg_pass() {
  local msg="$1"
  printf "${COLOR_NO}[ ${COLOR_GREEN}PASS${COLOR_NO} ]${COLOR_WHITE} $msg\n${COLOR_NO}"
}

msg_warn() {
  local msg="$1"
  printf "${COLOR_NO}[ ${COLOR_YELLOW}WARN${COLOR_NO} ]${COLOR_WHITE} $msg\n${COLOR_NO}"
}

msg_fail() {
  local msg="$1"
  printf "${COLOR_NO}[ ${COLOR_RED}FAIL${COLOR_NO} ]${COLOR_WHITE} $msg\n${COLOR_NO}"
}

# Used to parse the script arguments. Please pass in the arguments.
#
#   parse_args "$@"
#
parse_args() {
  # Common arguments. This will be applied to all scripts. Add wisely.
  #
  DEFINE_boolean 'do_nothing' false "Parse syntax only. Do nothing." 'n'
  DEFINE_boolean 'force' false "Force to run program anyway." 'f'

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

is_running_on_arm() {
  if uname --machine | grep arm > /dev/null; then
    return true
  else
    return false
  fi
}

exit_if_running_on_rpi() {
  if is_running_on_arm; then
    echo "- Running on Raspberry Pi [$(uname -a)]."
    exit 56
  fi
}

exit_if_not_running_on_rpi() {
  if is_running_on_arm; then
    msg_pass "- Running on Raspberry Pi [$(uname -a)]."
  else
    msg_warn "- NOT running on Raspberry Pi. Instead, [$(uname -a)]."
    if [ ${FLAGS_force} -eq ${FLAGS_TRUE} ]; then
      msg_pass "  However, you are using -f to force continue."
      echo
    else
      msg_fail "  Stopped. Or you can use --force if you know what you are doing."
      exit 56
    fi
  fi
}

# Only append $lines when the $pattern is not found in the $file.
#
# Example:
#   append_if_not_existing /tmp/haha HAHA "$(printf '\n# HAHA\nB\nC')"
#
append_if_not_existing() {
  local filename="$1"
  local pattern="$2"
  local lines="$3"

  if ! grep -q "$pattern" "$filename"; then
    echo "$lines" >> "$filename"
  fi
}

sanity_check() {
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
}

dd_image() {
  local img_file="$1"
  local device="$2"

  echo "- Write the Raspberry Pi image into SD card [$device] ..."
  sudo dd if="$img_file" of="$device" bs=1M status=progress
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
install_rpi_installer() {
  local TARGET="$RPI_INSTALLER_DIR_TARGET"

  sudo mkdir -p "$TARGET"
  sudo cp -r "$RPI_INSTALLER_DIR" "$TARGET"
}

append_to_rc_local() {
  local cmds="$@"

  # Remot the last of file, which is "exit 0"
  sudo sed -i '$d' "$RC_LOCAL_FILE"

  echo "$@" | sudo tee -a "$RC_LOCAL_FILE"

  # Move back the "exit 0" line.
  echo "exit 0" | sudo tee -a "$RC_LOCAL_FILE"
}

hints_at_end() {
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
