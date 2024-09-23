#!/usr/bin/env bash
#
#  Running on the host. Support installing multiple projects at once.
#
#

set -e

. rpi_installer/common.sh
. "$RPI_INSTALLER_DIR"/utils.sh
. "$RPI_INSTALLER_DIR"/host_utils.sh

# to trick host_sanity_check()
export SETTINGS_SH="LICENSE"
# for host_install_rpi_installer()
export TARGET_PROG_DIR="/root/rpi_installer/"
export RPI_INSTALLER_DIR_TARGET="$MOUNT_POINT_ROOTFS/$TARGET_PROG_DIR"


FLAGS_HELP="USAGE: $0 [flags] /dev/sdcard image_file [projects ...]"
parse_args "$@"
eval set -- "${FLAGS_ARGV}"

dev_sdcard="$1"; shift
image_file="$1"; shift

echo
echo "- Run 'host_pre()' to install to [$dev_sdcard] from [$image_file] ..."
echo
host_pre "$dev_sdcard" "$image_file"

# first check if the directory exists
for project in "$@"; do
  if [ -d "projects/$project" ]; then
    host_sh="projects/$project/host.sh"
    if [[ -x "$host_sh" ]]; then
      continue  # good
    else
      echo "[$host_sh] is not a directory"
      exit 1
    fi
  else
    echo "[$project] is not a directory"
    exit 1
  fi
done

for project in "$@"; do
  host_sh="projects/$project/host.sh"
  echo
  echo "- Run [$host_sh] ..."
  echo
  "$host_sh" --project_only "$dev_sdcard" "$image_file"
done

echo
echo "- Run 'host_post()' ..."
echo
host_post "$dev_sdcard" "$image_file"
