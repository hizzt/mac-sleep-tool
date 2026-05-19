#!/bin/bash
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCK_FILE="${TOOL_DIR}/locked"

sudo pmset -a disablesleep 1
touch "$LOCK_FILE"
osascript -e 'display notification "已禁用睡眠（已加锁）" with title "防睡眠开关"'
