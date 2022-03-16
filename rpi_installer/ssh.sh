#!/usr/bin/env bash
#
#  SSH related functions
#
set -e

. rpi_installer/common.sh
. "$RPI_INSTALLER_DIR"/mount.sh


# Copy ssh credential for the host to login.
#
copy_ssh_credential() {
  echo "- Copy ssh credential ..."
  local SSH_ROOT="${MOUNT_ROOT}/rootfs/root/.ssh/"
  sudo mkdir -p "$SSH_ROOT"
  # For user to login this device.
  cat ~/.ssh/id_rsa.pub | sudo tee -a "$SSH_ROOT"/authorized_keys
}
