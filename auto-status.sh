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
    echo "锁文件:   存在"
    cat "$LOCK_FILE" | while IFS='=' read -r key val; do
        case "$key" in
            type)       echo "  类型:   $val" ;;
            time)       echo "  时间:   $val" ;;
            duration)   echo "  时长:   $val" ;;
            recover_at) echo "  恢复于: $val" ;;
        esac
    done
else
    echo "锁文件:   不存在"
fi