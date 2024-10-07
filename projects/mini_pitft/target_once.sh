#!/usr/bin/env bash
#
# This script assumes only running once.
#
set -e
cd "$(dirname "$0")"
. rpi_installer/common.sh
. "$GENERATED_DIR"/mini_pitft/vars.sh
. "$SETTINGS_SH"
. rpi_installer/target_setup.sh
. shflags

target_setup_project_packages() {
  apt install -y xxd curl python3 python3-pip git

  # Install venv
  apt install python3-venv
  cd ~
  python -m venv env --system-site-packages

  # Enter venv mode
  source env/bin/activate

  # install and downaload PyTFT tools.
  pip3 install --upgrade adafruit-python-shell click 
  if [ ! -d "Raspberry-Pi-Installer-Scripts" ]; then
    git clone https://github.com/adafruit/Raspberry-Pi-Installer-Scripts.git
  fi
  cd Raspberry-Pi-Installer-Scripts
  sudo -E env PATH=$PATH python3 adafruit-pitft.py --display=st7789_240x240 --rotation=0 --install-type=console --reboot=no

  # Exit venv
  deactivate
}


FLAGS_HELP="USAGE: $0 [flags]"
target_setup_parse_args "$@"
eval set -- "${FLAGS_ARGV}"

if [ ${FLAGS_project_only} -eq ${FLAGS_TRUE} ]; then
  target_setup_project_packages
else
  target_setup_post_ssh_enable  # turn on the SSH for debug.
  target_setup_pre_time_is_synced
  target_setup_pre_locale_and_keyboard
  target_setup_pre_common_packages
  target_setup_disable_creating_account
  target_setup_project_packages
  target_setup_post_networks
  target_setup_post_ssh_enable
  target_setup_post_shutdown
fi
