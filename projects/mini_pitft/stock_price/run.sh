#!/bin/bash
#
# Run with 'pi' permission.
#

cd "$(dirname "$0")"/..  # Change to source root directory
. rpi_installer/common.sh
. "$GENERATED_DIR"/mini_pitft/vars.sh
. "$SETTINGS_SH"


export TTY=/dev/tty0
export FMP_KEY

#
# main()
#
while true; do
  sudo -E sh -c "/root/rpi_installer/stock_price/show.py KO > $TTY"
  sleep 60
done
