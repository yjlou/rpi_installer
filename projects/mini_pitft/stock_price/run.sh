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

show() {
  local symbol="$1"

  sudo -E sh -c "/root/rpi_installer/stock_price/show.py $symbol > $TTY"
  sleep 5
}

#
# main()
#
set -e
while true; do
  show KO
  show NVDA
  show TSLA
  show PLTR
done
