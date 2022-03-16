#!/usr/bin/env bash
#
# Run once before using this tool.
#

set -e

. rpi_installer/common.sh

# Create working folders
mkdir -p "$GENERATED_DIR" "$DOWNLOADS_DIR"

echo
echo "You might be asked for password for sudo."
echo
sudo apt install wget

echo "Downloading shflags ..."
rm -f "$DOWNLOADS_DIR"/shflags*
wget https://raw.githubusercontent.com/kward/shflags/master/shflags -O "$DOWNLOADS_DIR"/shflags

. rpi_installer/utils.sh

msg_pass
