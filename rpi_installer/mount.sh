#!/usr/bin/env bash

set -e

. rpi_installer/common.sh

MOUNT_ROOT="/media/${USER}/"
MOUNT_POINT_ROOTFS="$MOUNT_ROOT/rootfs"
MOUNT_POINT_BOOT="$MOUNT_ROOT/boot"


umount_all() {
  echo "- Unmounting existing partitions (if any) ..."
  sudo umount "$MOUNT_POINT_BOOT" "$MOUNT_POINT_ROOTFS" || true
  sudo rmdir "$MOUNT_POINT_BOOT" "$MOUNT_POINT_ROOTFS" || true
}

mount_all() {
  local device="$1"
  echo "- Mounting $device ..."

  sudo mkdir -p "$MOUNT_POINT_BOOT" "$MOUNT_POINT_ROOTFS"
  sudo mount "${device}1" "$MOUNT_POINT_BOOT"
  sudo mount "${device}2" "$MOUNT_POINT_ROOTFS"
}

mount_finish() {
  echo "- Finished. Tear down...."
  sync
  sleep 3  # Somehow we need this to avoid the device busy issue.
  umount_all
  sync
  sync
}
