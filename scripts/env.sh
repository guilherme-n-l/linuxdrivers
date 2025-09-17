#!/bin/bash

: "${SRC_DIR:=.}"

export SRC_DIR
export IMG_NAME="img.qcow2"
export SHARED_DIR="./shared"
export LINUX_DIR="linux"
export DRIVER_PATH="drivers/net/ethernet/realtek/r8169_rs" # Path inside linux dir. e.g.: `drivers/...`

full_driver_path="${LINUX_DIR%/}/${DRIVER_PATH#/}"
full_driver_path="${SRC_DIR}/${full_driver_path%#}"
full_driver_path="${full_driver_path%/}"
full_linux_path="${SRC_DIR}/${LINUX_DIR#/}"
