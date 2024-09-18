#!/usr/bin/env bash

set -e

. rpi_installer/common.sh
. rpi_installer/mount.sh

PROJECT_NAME="wisp"
PROJECT_DIR="projects/$PROJECT_NAME"

TARGET_PROG_DIR="/root/rpi_installer/"

RPI_INSTALLER_DIR_TARGET="$MOUNT_POINT_ROOTFS/$TARGET_PROG_DIR"

SETTINGS_SH="$GENERATED_DIR/$PROJECT_NAME/settings.sh"

PROJECT_VARS_IMPORTED="1"
