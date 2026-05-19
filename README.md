# 防睡眠工具集

一套 macOS 防睡眠管理脚本，支持手动开关、定时恢复、电源自动切换、sudo 免密管理、交互菜单。

## 前置条件

- macOS 13+ (Ventura)
- 首次使用需运行 `sudo-on.sh`（或菜单选项 9）启用免密，否则其他脚本需要手动输入密码

## 安装

```bash
git clone https://github.com/hizzt/mac-sleep-tool.git
cd mac-sleep-tool
chmod +x *.sh
```

> **路径说明：** 所有脚本使用相对路径互相引用，锁文件 `locked` 也存放在脚本同目录下。你可以将项目克隆到任意路径，脚本均可正常工作。

---

## 快速开始

```bash
# 1. 启用免密（首次使用必须）
./sudo-on.sh

# 2a. 手动模式：直接开关
./sleep-on.sh    # 禁止休眠（加锁，不会被自动恢复）
./sleep-off.sh   # 恢复休眠（解锁）

# 2b. 定时模式：自动恢复
./sleep-1h.sh       # 1小时后自动恢复（不加锁）
./sleep-1h.sh 7200  # 2小时后自动恢复

# 2c. 自动模式：根据电源自动切换
./auto-on.sh     # 启用自动切换
./auto-status.sh # 查看状态（含锁状态）
./auto-off.sh    # 关闭自动切换

# 3. 或者直接用菜单
./menu.sh
```

---

## 使用方式

### 方式一：交互菜单（推荐）

```bash
./menu.sh
```

```
=========================================
         防睡眠工具集
=========================================

  1) 禁止休眠（加锁，不会被自动恢复）
  2) 恢复休眠（解锁）
  3) 禁止休眠1小时（不加锁，到时自动恢复）
  4) 禁止休眠2小时（不加锁，到时自动恢复）
  5) 取消定时休眠
  6) 启用电源自动切换
  7) 关闭电源自动切换
  8) 查看状态
  9) 启用 pmset 免密
  s) 关闭 pmset 免密
  c) 查看电源管理设置 (custom)
  g) 查看电源管理设置 (全部)
  0) 退出

=========================================
请选择 [0-9,s,c,g]:
```

**终端关闭行为：**

| 选项 | 执行后 |
|------|--------|
| 1-2, 5-9 | 自动关闭终端 |
| 3-4 | 后台启动定时任务，立即关闭终端 |
| c, g | 显示结果，按回车后关闭终端 |
| 0 | 不关闭终端 |

#### 通过 macOS 自动操作启动

项目自带两个 Automator 快速操作，双击即可导入使用。

**导入方式：**

1. 双击 `mac休眠工具.app` 或 `mac休眠工具-运行1小时.app`
2. 系统弹出提示，点击「打开」
3. 导入后可在「系统设置 → 隐私与安全性 → 辅助功能」中授权

**修改路径（必须）：**

导入后，自动操作中的脚本路径默认为 `/usr/local/bin/sleep`，你需要改为你的实际路径：

1. 打开「自动操作」App
2. 菜单栏 → 文件 → 打开最近使用 → 选择对应的自动操作
3. 找到 `SCRIPT_DIR="/usr/local/bin/sleep"` 这一行
4. 将路径改为你的实际路径，例如 `SCRIPT_DIR="/Users/你的用户名/sleep"`
5. 保存（Cmd+S）

**两个自动操作说明：**

| 文件 | 功能 | 用途 |
|------|------|------|
| `mac休眠工具.app` | 打开交互菜单 | 弹出终端显示菜单，选择操作后自动关闭 |
| `mac休眠工具-运行1小时.app` | 后台禁止休眠1小时 | 无需交互，直接后台运行，1小时后自动恢复 |

**添加到工具栏：**

1. 系统设置 → 控制中心 → 菜单栏
2. 或将 .app 拖到 Dock 栏快速启动

### 方式二：直接运行单个脚本

```bash
# 免密管理
./sudo-on.sh        # 启用 pmset 免密
./sudo-off.sh       # 关闭 pmset 免密

# 手动开关
./sleep-on.sh       # 禁止休眠（加锁）
./sleep-off.sh      # 恢复休眠（解锁）

# 定时禁止休眠
./sleep-1h.sh          # 默认1小时后恢复（不加锁）
./sleep-1h.sh 1800     # 30分钟后恢复
./sleep-1h.sh 7200     # 2小时后恢复

# 取消定时休眠
pkill -f sleep-1h.sh
sudo pmset -a disablesleep 0

# 电源自动切换
./auto-on.sh        # 启用自动切换
./auto-off.sh       # 关闭自动切换
./auto-status.sh    # 查看状态

# 整合脚本
./sleep-toggle.sh install    # 启用自动切换
./sleep-toggle.sh uninstall  # 关闭自动切换
./sleep-toggle.sh status     # 查看状态
```

### 方式三：整合脚本

`sleep-toggle.sh` 是 install/uninstall/status 三合一版本，功能与拆分脚本完全一致：

```bash
./sleep-toggle.sh install    # 等同于 auto-on.sh
./sleep-toggle.sh uninstall  # 等同于 auto-off.sh
./sleep-toggle.sh status     # 等同于 auto-status.sh
```

---

## 锁机制说明

各脚本之间通过锁文件 `locked`（位于脚本同目录下）协调，避免冲突：

| 操作 | 锁文件 | 效果 |
|------|--------|------|
| `sleep-on.sh`（手动禁止） | 创建锁 | 自动切换/定时到期后**不会**恢复睡眠 |
| `sleep-off.sh`（手动恢复） | 删除锁 | 正常恢复睡眠 |
| `sleep-1h.sh`（定时禁止） | 不创建锁 | 到时间后正常恢复睡眠 |
| 自动切换（拔电1小时后） | 检查锁 | 有锁则跳过恢复，无锁则正常恢复 |
| 菜单选项5（取消定时） | 删除锁 | 同时取消定时并恢复睡眠 |

**典型场景：**

- 手动禁止休眠 → 开了自动切换 → 拔电1小时后不会恢复（锁存在）
- 定时1小时禁止 → 期间手动恢复 → 锁被清除，定时到期也不会重复禁止
- 定时1小时禁止 → 到期后正常恢复（无锁）

---

## 注意事项

- 手动禁止休眠（`sleep-on.sh`）会加锁，自动切换和定时恢复不会覆盖手动操作
- 定时禁止休眠（`sleep-1h.sh`）不加锁，到时间后正常恢复
- 恢复休眠（`sleep-off.sh`）会同时解锁，确保后续自动切换正常工作
- 取消定时休眠（菜单选项5）会同时杀掉定时进程、恢复睡眠、删除锁文件
- 关闭自动切换（`auto-off.sh`）会恢复默认睡眠设置并删除锁文件
- 免密配置仅对 `pmset` 命令生效，不影响其他 sudo 操作
- 定时休眠（选项 3/4）在后台运行，关闭终端不影响倒计时
- 重复启动定时休眠会自动取消上一个定时任务

---

## 文件结构

```
sleep/
├── menu.sh                          # 交互菜单（推荐入口）
├── sleep-on.sh                      # 禁止休眠（加锁）
├── sleep-off.sh                     # 恢复休眠（解锁）
├── sleep-1h.sh                      # 定时禁止休眠（不加锁，支持自定义秒数，默认1小时）
├── auto-on.sh                       # 启用电源自动切换
├── auto-off.sh                      # 关闭电源自动切换
├── auto-status.sh                   # 查看自动切换状态
├── sudo-on.sh                       # 启用 pmset 免密
├── sudo-off.sh                      # 关闭 pmset 免密
├── sleep-toggle.sh                  # 整合脚本（install/uninstall/status）
├── mac休眠工具.app                  # Automator 快速操作：打开菜单
├── mac休眠工具-运行1小时.app        # Automator 快速操作：禁止休眠1小时
├── locked                           # 手动锁文件（由脚本自动创建/删除，无需手动操作）
└── README.md
```

---

## 实现原理

### 免密管理

- 启用时，将 `用户名 ALL=(root) NOPASSWD: /usr/bin/pmset` 写入 `/etc/sudoers.d/pmset-nopasswd`，并设置权限 440
- 关闭时，删除 `/etc/sudoers.d/pmset-nopasswd`
- 仅对 `pmset` 命令免密，不影响其他 sudo 命令的安全性
- 首次运行需要输入密码（用于写入 sudoers 文件）
- 重复运行不会重复写入

### 手动开关

- `sleep-on.sh` 执行 `sudo pmset -a disablesleep 1` 禁止休眠，并创建锁文件 `locked`
- `sleep-off.sh` 执行 `sudo pmset -a disablesleep 0` 恢复休眠，并删除锁文件
- `-a` 参数表示对所有电源源（battery、ac、ups）生效
- 锁文件确保手动禁止后，自动切换和定时恢复不会意外恢复睡眠
- 执行后通过 `osascript` 发送系统通知

### 定时禁止休眠

1. 启动前先通过 `pgrep` 查找并杀掉旧的 `sleep-1h.sh` 进程，避免多个定时任务并存
2. 执行 `sudo pmset -a disablesleep 1` 禁止休眠（不创建锁文件）
3. 发送系统通知，显示分钟数（如「60分钟后自动恢复」）
4. `sleep` 等待指定秒数
5. 等待结束后检查锁文件：
   - 无锁 → 恢复睡眠，发送通知
   - 有锁 → 跳过恢复，通知「手动锁存在，保持禁用睡眠」

### 电源自动切换

1. **launchd 监听机制**：`auto-on.sh` 在 `~/Library/LaunchAgents/` 创建 plist 配置，利用 launchd 的 `WatchPaths` 功能监听 `/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist` 文件变化。macOS 在电源状态改变时会更新此文件，从而触发脚本执行。

2. **核心脚本**：写入 `~/.sleep-toggle/sleep-toggle.sh`，每次触发时：
   - 先杀掉旧的同类进程，避免重复执行
   - 通过 `pmset -g ps` 检测当前是电池还是充电器供电
   - 插电 → 立即执行 `pmset -a disablesleep 1`
   - 拔电 → `sleep 3600` 等待1小时，醒来后再次检测电源状态，仍用电池时检查锁文件：
     - 无锁 → 恢复睡眠
     - 有锁 → 跳过恢复

3. **防误操作**：1小时等待期间如果重新插电，脚本醒来后检测到已插电，不会恢复睡眠

4. **重复安装保护**：`auto-on.sh` 检测到已在运行时会跳过，不会重复 load

5. **关闭清理**：`auto-off.sh` 卸载 launchd 服务、删除 plist 和核心脚本、恢复默认睡眠设置、删除锁文件

### 电源管理查看

- `pmset -g custom`：按电源源分类显示设置（电池/充电器/UPS 各自的配置）
- `pmset -g`：显示当前生效的全部电源管理设置