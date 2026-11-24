#!/bin/sh
# Builds tuneless, copies it to ~/.local/bin and registers it as a LaunchAgent.
# Safe to run again to update: it replaces the binary and restarts the service.
set -eu

LABEL="io.github.nacholaciar.tuneless"
BIN_DIR="${TUNELESS_BIN_DIR:-$HOME/.local/bin}"
BIN="$BIN_DIR/tuneless"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

cd "$(dirname "$0")/.."

swift build -c release
mkdir -p "$BIN_DIR" "$(dirname "$PLIST")"

# Stop the previous version before replacing the binary.
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
install -m 755 .build/release/tuneless "$BIN"

sed "s|<string>__BIN__</string>|<string>$BIN</string>|" "LaunchAgent/$LABEL.plist" > "$PLIST"
plutil -lint "$PLIST" >/dev/null

launchctl bootstrap "$DOMAIN" "$PLIST"
echo "tuneless $("$BIN" --version) installed at $BIN and running ($DOMAIN/$LABEL)."
