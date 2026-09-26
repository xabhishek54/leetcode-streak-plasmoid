#!/bin/bash
set -e

WIDGET_ID="com.custom.leetcode-streak"

echo "Uninstalling LeetCode Streak Plasmoid..."

if kpackagetool6 --type Plasma/Applet --list | grep -q "$WIDGET_ID"; then
    kpackagetool6 --type Plasma/Applet --remove "$WIDGET_ID"
    echo "Uninstalled $WIDGET_ID successfully."
else
    echo "Plasmoid $WIDGET_ID is not currently installed."
fi
