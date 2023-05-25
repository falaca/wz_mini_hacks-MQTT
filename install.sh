#!/bin/sh

# Run from your localhost
# This script will:
#   + ssh copy all the MQTT requirements to the Wyze Cam V3 (that already has wz_mini hacks installed)
#   + overwrite /configs/.user_config iCamera settings with all default settings
#   + overwrite web server init script with a fixed version

if [ -z "$1" ]; then
    echo "Usage: $0 <wyze cam v3 host address>"
    echo "Example: $ $0 10.0.0.172"
    echo "Ensure to update mosquitto.conf with MQTT broker connection details and desired status update interval."
    exit 1
fi
WYZECAMV3_HOST=$1

OPENSSH_VERSION=$(ssh -V 2>&1)
TARGET_VERSION="OpenSSH_8.8"
SCP_ARGS=""
# OpenSSH 8.8 onward uses SFTP protocol by default, which is unsupported on wz_mini_hacks
if printf '%s\n' "$TARGET_VERSION" "$OPENSSH_VERSION" | sort -V | head -n1 | grep -q "$TARGET_VERSION"; then
  SCP_ARGS="-O"
fi

echo "Uploading MQTT client to camera at ${WYZECAMV3_HOST}..."
ssh root@${WYZECAMV3_HOST} 'mkdir -p /media/mmc/mosquitto/bin; mkdir -p /media/mmc/mosquitto/lib; mkdir -p /media/mmc/mosquitto/installer'
scp ${SCP_ARGS} ./installer/* root@${WYZECAMV3_HOST}:/media/mmc/mosquitto/installer
scp ${SCP_ARGS} ./bin/* root@${WYZECAMV3_HOST}:/media/mmc/mosquitto/bin
scp ${SCP_ARGS} ./lib/* root@${WYZECAMV3_HOST}:/media/mmc/mosquitto/lib
scp ${SCP_ARGS} mosquitto.conf root@${WYZECAMV3_HOST}:/media/mmc/mosquitto

echo "Installing MQTT client on camera..."
ssh root@${WYZECAMV3_HOST} '/media/mmc/mosquitto/installer/setup.sh'
echo "Camera rebooting..."
echo "You should see MQTT messages published when camera restarts."
echo "Done"



