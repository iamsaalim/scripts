#!/usr/bin/env bash

# Copyright (C) 2019 Saalim Quadri <danascape@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

# Arguements check
if [ -z ${1} ] || [ -z ${2} ] || [ -z ${3} ] || [ -z ${4} ]; then
	echo -e "Usage: bash rom.sh <rom-name> <device-name> <variant> <package-name>"
	exit 1
fi

# Store variables
BOT_API_TOKEN=""
CHAT_ID=""
DEVICE="$2"
PACKAGE_NAME="$4"
ROM="$1"
ROM_DIR="$PWD" # By default
VARIANT="$3"

# Check envsetup
if [ -f $ROM_DIR/build/envsetup.sh ]; then
	echo "Starting build"
	source build/envsetup.sh
else
	echo "Either rom path is wrong or rom isnt synced"
	exit 1
fi

# Lunch
lunch $ROM_$DEVICE-$VARIANT | grep TARGET_PRODUCT

# Start the build
make $PACKAGE_NAME -j$(nproc --all) |& tee buildlogs.txt

# Check if build is done
if [ -f $ROM_DIR/out/target/product/$DEVICE/*.zip ]; then
	ZIP=$(echo $ROM_DIR/out/target/product/$DEVICE/*$ROM*.zip)
	echo "\n Build Complete"
	echo $ZIP
	exit 1
else
	echo "Build failed, Uploading logs"
	curl -F chat_id="${CHAT_ID}" \
		-F document=@"buildlogs.txt" \
		https://api.telegram.org/bot${BOT_API_TOKEN}/sendDocument >/dev/null 2>&1
	exit 1
fi
