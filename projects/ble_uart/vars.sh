#!/usr/bin/env bash

set -e

. rpi_installer/common.sh
. rpi_installer/mount.sh

PROJECT_NAME="ble_uart"
PROJECT_DIR="projects/$PROJECT_NAME"

RPI_INSTALLER_DIR_TARGET="$MOUNT_POINT_ROOTFS/root/rpi_installer/"

BLE_UART_DIR_HOST="$DOWNLOADS_DIR/$PROJECT_NAME/ble_uart/"
BLE_UART_DIR_TARGET="/root/ble_uart/"

SETTINGS_SH="$GENERATED_DIR/settings.sh"

