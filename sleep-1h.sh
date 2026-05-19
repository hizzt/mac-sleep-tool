#!/bin/bash
set -euo pipefail
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCK_FILE="${TOOL_DIR}/locked"
seconds=${1:-3600}
minutes=$((seconds / 60))

# 清理之前残留的 sleep-1h.sh 后台进程
SCRIPT_NAME="$(basename "$0")"
for pid in $(pgrep -f "$SCRIPT_NAME" || true); do
    if [ -n "$pid" ] && [ "$pid" != "$$" ]; then
        kill "$pid" 2>/dev/null || true
    fi
done

sudo pmset -a disablesleep 1
echo "type=timer" > "$LOCK_FILE"
echo "time=$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOCK_FILE"
echo "duration=${minutes}分钟" >> "$LOCK_FILE"
echo "recover_at=$(date -v+${minutes}M '+%Y-%m-%d %H:%M:%S')" >> "$LOCK_FILE"
osascript -e "display notification \"已禁用睡眠，${minutes}分钟后自动恢复\" with title \"防睡眠开关\""
sleep "$seconds"

# 定时恢复：检查是否有手动锁，有锁则跳过恢复
if [ -f "$LOCK_FILE" ] && grep -q "type=manual" "$LOCK_FILE"; then
    osascript -e 'display notification "定时到期，但手动锁存在，保持禁用睡眠" with title "防睡眠开关"'
else
    sudo pmset -a disablesleep 0
    osascript -e 'display notification "已恢复睡眠" with title "防睡眠开关"'
fi