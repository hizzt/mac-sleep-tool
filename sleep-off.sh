#!/bin/bash
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCK_FILE="${TOOL_DIR}/locked"

sudo pmset -a disablesleep 0
rm -f "$LOCK_FILE"
osascript -e 'display notification "已恢复睡眠" with title "防睡眠开关"'
