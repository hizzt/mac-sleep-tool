#!/bin/bash

# 防睡眠自动切换工具
# 插电源 → 禁用睡眠 | 拔电源 → 1小时后启用睡眠
# 用法: ./sleep-toggle.sh install   启用
#       ./sleep-toggle.sh uninstall 关闭
#       ./sleep-toggle.sh status    查看状态

LABEL="com.user.sleep-toggle"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
SCRIPT_DIR="$HOME/.sleep-toggle"
SCRIPT_PATH="${SCRIPT_DIR}/sleep-toggle.sh"
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCK_FILE="${TOOL_DIR}/locked"
SUDOERS_LINE="$(whoami) ALL=(root) NOPASSWD: /usr/bin/pmset"

notify() {
    osascript -e "display notification \"$1\" with title \"防睡眠开关\""
}

check_sudoers() {
    sudo grep -qF "pmset-nopasswd" /etc/sudoers.d/pmset-nopasswd 2>/dev/null
}

add_sudoers() {
    if check_sudoers; then
        echo "[OK] sudoers 免密已配置"
        return
    fi
    echo "[需要] 配置 pmset sudo 免密，将弹出密码框..."
    echo "$SUDOERS_LINE" | sudo tee /etc/sudoers.d/pmset-nopasswd > /dev/null
    sudo chmod 440 /etc/sudoers.d/pmset-nopasswd
    if check_sudoers; then
        echo "[OK] sudoers 免密配置成功"
    else
        echo "[FAIL] sudoers 配置失败，请手动运行: sudo visudo"
        exit 1
    fi
}

remove_sudoers() {
    if [ -f /etc/sudoers.d/pmset-nopasswd ]; then
        echo "[需要] 移除 sudoers 免密配置..."
        sudo rm /etc/sudoers.d/pmset-nopasswd
        echo "[OK] 已移除"
    else
        echo "[OK] sudoers 免密未配置，无需移除"
    fi
}

write_script() {
    mkdir -p "$SCRIPT_DIR"
    cat > "$SCRIPT_PATH" << INNER
#!/bin/bash
LOCK_FILE="${LOCK_FILE}"

SCRIPT_NAME="\$(basename "\$0")"
for pid in \$(pgrep -f "\$SCRIPT_NAME" || true); do
    if [ -n "\$pid" ] && [ "\$pid" != "\$\$" ]; then
        kill "\$pid" 2>/dev/null || true
    fi
done

on_battery=\$(pmset -g ps | grep -c "Battery Power")

if [ "\$on_battery" -eq 1 ]; then
    sleep 3600
    on_battery_still=\$(pmset -g ps | grep -c "Battery Power")
    if [ "\$on_battery_still" -eq 1 ]; then
        if [ -f "\$LOCK_FILE" ] && grep -q "type=manual" "\$LOCK_FILE"; then
            osascript -e 'display notification "拔电1小时，但手动锁存在，保持禁用睡眠" with title "防睡眠开关"'
        else
            sudo pmset -a disablesleep 0
            rm -f "\$LOCK_FILE"
            osascript -e 'display notification "已恢复睡眠" with title "防睡眠开关"'
        fi
    fi
else
    sudo pmset -a disablesleep 1
    echo "type=auto" > "\$LOCK_FILE"
    echo "time=\$(date '+%Y-%m-%d %H:%M:%S')" >> "\$LOCK_FILE"
    echo "reason=插电自动禁用" >> "\$LOCK_FILE"
    osascript -e 'display notification "已禁用睡眠" with title "防睡眠开关"'
fi
INNER
    chmod +x "$SCRIPT_PATH"
}

write_plist() {
    cat > "$PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>WatchPaths</key>
    <array>
        <string>/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist</string>
    </array>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${SCRIPT_PATH}</string>
    </array>
</dict>
</plist>
EOF
}

do_install() {
    if launchctl list | grep -q "$LABEL"; then
        echo "[OK] 自动切换已在运行中，无需重复安装"
        notify "自动切换已运行"
        return
    fi
    echo "=== 安装防睡眠自动切换 ==="
    add_sudoers
    write_script
    write_plist
    launchctl load "$PLIST" 2>/dev/null
    notify "防睡眠自动切换已启用"
    echo "[OK] 已启用！插电源自动禁用睡眠，拔电源1小时后自动启用睡眠"
}

do_uninstall() {
    echo "=== 卸载防睡眠自动切换 ==="
    if launchctl list | grep -q "$LABEL"; then
        launchctl unload "$PLIST" 2>/dev/null
        echo "[OK] 已停止监听"
    fi
    [ -f "$PLIST" ] && rm "$PLIST" && echo "[OK] 已删除 plist"
    [ -f "$SCRIPT_PATH" ] && rm "$SCRIPT_PATH" && echo "[OK] 已删除脚本"
    [ -d "$SCRIPT_DIR" ] && rmdir "$SCRIPT_DIR" 2>/dev/null
    remove_sudoers
    sudo pmset -a disablesleep 0
    rm -f "$LOCK_FILE"
    notify "防睡眠自动切换已关闭"
    echo "[OK] 已恢复默认睡眠设置"
    echo "[OK] 卸载完成"
}

do_status() {
    if launchctl list | grep -q "$LABEL"; then
        echo "状态: 已启用 (运行中)"
    else
        echo "状态: 未启用"
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
                reason)     echo "  原因:   $val" ;;
            esac
        done
    else
        echo "锁文件:   不存在"
    fi
}

case "${1}" in
    install)   do_install ;;
    uninstall) do_uninstall ;;
    status)    do_status ;;
    *)
        echo "用法: $0 {install|uninstall|status}"
        echo ""
        echo "  install   - 启用自动切换"
        echo "  uninstall - 关闭并清理"
        echo "  status    - 查看当前状态"
        exit 1
        ;;
esac
