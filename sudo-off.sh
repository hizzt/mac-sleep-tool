#!/bin/bash
if [ -f /etc/sudoers.d/pmset-nopasswd ]; then
    sudo rm /etc/sudoers.d/pmset-nopasswd
    echo "[OK] pmset 免密已关闭"
else
    echo "[OK] 免密未启用，无需操作"
fi
