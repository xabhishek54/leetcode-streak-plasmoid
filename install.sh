#!/bin/bash
set -e

PACKAGE_DIR="./package"
WIDGET_ID="com.custom.leetcode-streak"

echo "Installing LeetCode Streak Plasmoid for Plasma 6..."

# Clear Plasma QML cache to prevent stale compiled QML (.qmlc) execution
rm -rf ~/.cache/plasmashell/qmlcache/* ~/.cache/plasma* 2>/dev/null || true

if kpackagetool6 --type Plasma/Applet --list | grep -q "$WIDGET_ID"; then
    echo "Upgrading existing plasmoid..."
    kpackagetool6 --type Plasma/Applet --upgrade "$PACKAGE_DIR"
else
    echo "Installing new plasmoid..."
    kpackagetool6 --type Plasma/Applet --install "$PACKAGE_DIR"
fi

echo "Installation complete!"
echo "Restarting plasmashell to load updated QML..."
plasmashell --replace >/dev/null 2>&1 &

echo "Done! You can now add 'LeetCode Streak' to your desktop or test it with:"
echo "  plasmawindowed com.custom.leetcode-streak"
