#!/bin/sh
# Stops tuneless and removes the binary and the LaunchAgent. Leaves the repository untouched.
set -eu

LABEL="io.github.nacholaciar.tuneless"
BIN="${TUNELESS_BIN_DIR:-$HOME/.local/bin}/tuneless"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
rm -f "$BIN" "$PLIST"
echo "tuneless uninstalled."
