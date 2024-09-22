#!/usr/bin/env bash
#
# This script assumes only running once.
#
set -e
cd "$(dirname "$0")"
. rpi_installer/common.sh
. "$GENERATED_DIR"/sniffer/vars.sh
. "$SETTINGS_SH"
. rpi_installer/target_setup.sh
. shflags

target_setup_pre_project_packages() {
  apt install -y xxd curl tmux python3 python3-pip git \
                 build-essential tcpdump autotools-dev wget libncurses-dev libssl-dev libffi-dev dkms \
                 raspberrypi-kernel-headers
}

target_setup_install_rtl8812au() {
  # Check out and build the WiFi dongle driver
  #
  # See details in https://github.com/aircrack-ng/rtl8812au#for-raspberry-rpi
  #
  cd "$TARGET_PROG_DIR"
  git clone https://github.com/aircrack-ng/rtl8812au.git
  cd rtl8812au

  # A known working version is 37e27f91 (v5.6.4.2) with 2022-04-04-raspios-buster-armhf-lite.img
  # ( https://downloads.raspberrypi.org/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2022-04-07/2022-04-04-raspios-buster-armhf-lite.img.xz )
  git checkout 37e27f91

  sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
  sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/g' Makefile
  make dkms_install
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
  target_setup_install_rtl8812au
  target_setup_post_shutdown
fi