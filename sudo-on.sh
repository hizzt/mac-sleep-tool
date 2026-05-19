#!/bin/bash
SUDOERS_LINE="${SUDO_USER:-$(whoami)} ALL=(root) NOPASSWD: /usr/bin/pmset"

if sudo grep -qF "pmset-nopasswd" /etc/sudoers.d/pmset-nopasswd 2>/dev/null; then
    echo "[OK] 免密已启用，无需重复配置"
else
    echo "$SUDOERS_LINE" | sudo tee /etc/sudoers.d/pmset-nopasswd > /dev/null
    sudo chmod 440 /etc/sudoers.d/pmset-nopasswd
    echo "[OK] pmset 免密已启用"
fi
