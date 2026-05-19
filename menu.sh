#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCK_FILE="${SCRIPT_DIR}/locked"

echo "========================================="
echo "         防睡眠工具集"
echo "========================================="
echo ""
echo "  1) 禁止休眠（加锁，不会被自动恢复）"
echo "  2) 恢复休眠（解锁）"
echo "  3) 禁止休眠1小时（不加锁，到时自动恢复）"
echo "  4) 禁止休眠2小时（不加锁，到时自动恢复）"
echo "  5) 取消定时休眠"
echo "  6) 启用电源自动切换"
echo "  7) 关闭电源自动切换"
echo "  8) 查看状态"
echo "  9) 启用 pmset 免密"
echo "  s) 关闭 pmset 免密"
echo "  c) 查看电源管理设置 (custom)"
echo "  g) 查看电源管理设置 (全部)"
echo "  0) 退出"
echo ""
echo "========================================="

read -p "请选择 [0-9,s,c,g]: " choice

close_tab() {
    osascript -e 'tell application "Terminal" to quit' >/dev/null 2>&1 &
}

case "$choice" in
    1) "${SCRIPT_DIR}/sleep-on.sh" ;;
    2) "${SCRIPT_DIR}/sleep-off.sh" ;;
    3)
        nohup "${SCRIPT_DIR}/sleep-1h.sh" 3600 > /dev/null 2>&1 &
        echo "[OK] 已在后台启动：1小时后自动恢复睡眠"
        close_tab
        exit 0
        ;;
    4)
        nohup "${SCRIPT_DIR}/sleep-1h.sh" 7200 > /dev/null 2>&1 &
        echo "[OK] 已在后台启动：2小时后自动恢复睡眠"
        close_tab
        exit 0
        ;;
    5)
        pkill -f "sleep-1h.sh" 2>/dev/null || true
        sudo pmset -a disablesleep 0
        rm -f "$LOCK_FILE"
        osascript -e 'display notification "已取消定时休眠，恢复睡眠" with title "防睡眠开关"'
        echo "[OK] 已取消定时休眠"
        ;;
    6) "${SCRIPT_DIR}/auto-on.sh" ;;
    7) "${SCRIPT_DIR}/auto-off.sh" ;;
    8) "${SCRIPT_DIR}/auto-status.sh" ;;
    9) "${SCRIPT_DIR}/sudo-on.sh" ;;
    s|S) "${SCRIPT_DIR}/sudo-off.sh" ;;
    c|C) pmset -g custom; echo ""; read -p "按回车键退出..."; close_tab; exit 0 ;;
    g|G) pmset -g; echo ""; read -p "按回车键退出..."; close_tab; exit 0 ;;
    0) echo "再见！"; exit 0 ;;
    *) echo "无效选择"; exit 1 ;;
esac

close_tab
