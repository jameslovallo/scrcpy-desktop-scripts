#!/bin/bash

# Get Resolution
resolution=$(python3 -c '
import os, xml.etree.ElementTree as ET
path = os.path.expanduser("~/.config/monitors.xml")
m = ET.parse(path).find("configuration[1]/logicalmonitor[primary=\"yes\"]/monitor/mode")
print(m.find("width").text + "x" + m.find("height").text)
')

# Function to clean up the virtual display when the script is terminated
cleanup() {
    echo "Cleaning up..."
    echo "Removing the virtual display..."
    adb shell settings put global overlay_display_devices none
    echo "Virtual display removed."
    exit 0
}

# Trap to call cleanup function when the script is closed
trap cleanup EXIT

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "Error: adb is not installed or not in PATH. Please install Android Debug Bridge."
    exit 1
fi

# Check if device is connected
if ! adb devices | grep -q device$; then
    echo "Error: No Android device connected. Please connect a device and try again."
    exit 1
fi

# Function to get the list of display IDs
get_display_ids() {
    adb shell dumpsys display | grep "mDisplayId=" | awk '{print $1}' | cut -d= -f2 | sort -u
}

# Get initial display IDs
initial_displays=$(get_display_ids)

# Create a virtual display on the Android device
echo "Creating a virtual display..."
adb shell settings put global overlay_display_devices $resolution/240

# Wait for the new display to be recognized
sleep 2

# Get new display IDs
new_displays=$(get_display_ids)

# Find the new display ID
secondary_display_id=$(comm -13 <(echo "$initial_displays") <(echo "$new_displays") | tr -d '[:space:]')

if [ -z "$secondary_display_id" ]; then
    echo "Failed to detect the new display ID."
    cleanup
    exit 1
else
    echo "Detected secondary display ID: $secondary_display_id"
fi

# Check if scrcpy is available
if ! command -v scrcpy &> /dev/null; then
    echo "Error: scrcpy is not installed or not in PATH. Please install scrcpy."
    cleanup
    exit 1
fi

# Start scrcpy with the provided options and detected display ID
echo "Starting scrcpy on the virtual display..."
cd ~/AppImages
./scrcpy.appimage -b 24M --turn-screen-off -M -K --max-fps=60 -f --display-id "$secondary_display_id"

# The cleanup function will be called automatically when the script exits
