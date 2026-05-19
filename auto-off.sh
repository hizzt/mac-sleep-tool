#!/bin/bash
LABEL="com.user.sleep-toggle"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
SCRIPT_DIR="$HOME/.sleep-toggle"
SCRIPT_PATH="${SCRIPT_DIR}/sleep-toggle.sh"
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCK_FILE="${TOOL_DIR}/locked"

if launchctl list | grep -q "$LABEL"; then
    launchctl unload "$PLIST" 2>/dev/null
fi
[ -f "$PLIST" ] && rm "$PLIST"
[ -f "$SCRIPT_PATH" ] && rm "$SCRIPT_PATH"
[ -d "$SCRIPT_DIR" ] && rmdir "$SCRIPT_DIR" 2>/dev/null
sudo pmset -a disablesleep 0
rm -f "$LOCK_FILE"
osascript -e 'display notification "防睡眠自动切换已关闭" with title "防睡眠开关"'
echo "[OK] 已关闭并清理"
