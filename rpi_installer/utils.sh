#!/usr/bin/env bash
#
# Platform-independent helpers.  Used in both host and target.
#

set -e

. rpi_installer/common.sh

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

# Ask a question, get answer from the user, then replace the setting file.
ask_and_replace() {
  local question="$1"
  local variable="$2"
  local default="$3"
  local answer=""

  read -r -p "$question" answer
  [ -z "$answer" ] && answer="$default"
  sed -i "s~^$variable=.*$~$variable='$answer'~g" "$SETTINGS_TEMPORARY"
}

# Once sudo authentication is successful, keep this script authenticated until the program stops.
# Credits: https://serverfault.com/questions/266039/temporarily-increasing-sudos-timeout-for-the-duration-of-an-install-script
keep_sudo() {
  trap "exit" INT TERM
  trap "kill 0" EXIT
  sudo -v || exit $?
  sleep 1
  while true; do
      sleep 56
      sudo -nv
  done 2>/dev/null &
}
