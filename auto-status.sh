#!/bin/bash
LABEL="com.user.sleep-toggle"
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCK_FILE="${TOOL_DIR}/locked"

if launchctl list | grep -q "$LABEL"; then
    echo "自动切换: 已启用 (运行中)"
else
    echo "自动切换: 未启用"
fi
echo ""
echo "当前电源: $(pmset -g ps | head -1)"
echo "防睡眠:   $(pmset -g | grep disablesleep)"
if [ -f "$LOCK_FILE" ]; then
    echo "手动锁:   存在（手动禁止休眠中，自动恢复不会生效）"
else
    echo "手动锁:   不存在"
fi