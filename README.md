# ⭕ Claude Voice Notifier (Windows 11 64bit Edition)

## 发布信息

- Published by:       @barry.dong
- Release Version:    1.0.6
- Released Date:      2026-06-01
- Release Notes:      Windows 11 64bit version

## 介绍

Claude Voice Notifier 是一个 Windows 系统托盘应用，当 Claude Code 弹出确认对话框或会话完成时，播放提示音提醒用户，减少用户盯着屏幕查看 Claude Code 运行情况的时间，通过声音通知，可实时提醒用户确认问题，了解当前会话完成情况。

主要特色和功能：

- 🔔 当 Claude Code 弹出确认对话框或需要用户输入时，播放提示音提醒用户。
- 🔔 当 Claude Code 当前对话完成时，也会播放提示音。
- 🎵 提示音可以自定义，支持 `.wav` / `.mp3` 格式。同时，可配置声音文件、播放次数、播放间隔。
- ⚙️ 轻量级运行，无需额外运行时，安装简单。
- ✅ 推荐使用 VS Code + Claude Code 插件 + Claude Voice Notifier 托盘组合模式运行。
- 🖥️ 适用于Windows 11 x64 系统。

## 功能

- 🔔 在 Claude Code 需要用户确认时、会话完成时播放提示音
- 🎵 支持多种声音文件（`.wav` / `.mp3`）
- 🖥️ 系统托盘应用，最小化到托盘运行
- ⚡ FileSystemWatcher 事件驱动信号监听（非轮询）
- 🪝 通过 Claude Code Hooks 自动触发提示音
- 🎨 墨黑色/白色双主题托盘菜单

## 安装

### 1. 通过 npm 安装

```bash
npm install -g claude-voice-notifier
```

### 2. 通过 GitHub Release 安装

- 打开 GitHub Releases 页面：
  <https://github.com/barrydong/claude-voice-notifier/releases>
- 下载最新版本的 EXE 安装程序
- 通过EXE安装程序安装，然后直接运行安装程序
- 注意配置目录在%USERPROFILE%\.claude-voice-notifier中，非安装目录下的相关目录和文件。
- 通过%USERPROFILE%\.claude-voice-notifier目录下的config.ini配置基本参数，推荐使用托盘菜单配置
- 通过%USERPROFILE%\.claude-voice-notifier\media目录下可自定义声音文件

**前置要求**：Windows 11（x64），无需额外运行时。

### 3. 上传 GitHub Release

- 在仓库页面中选择 `Releases` → `Draft a new release`
- 填写版本号（例如 `v1.0.6`）、标题和说明
- 附加 `dist/claude-voice-notifier-windows-x64-v1.0.6.zip`，以及可选的安装程序
- 发布后，用户即可从上述 Release 页面下载

## 使用方法

### 快速开始

1. 安装后，可以：

   A. 双击 `bin\ClaudeVoiceNotifier.exe`

   B. 命令行查询版本信息：

   ```bash
   claude-voice-notifier --version 或者 claude-voice-notifier -v
   ```

   C. 命令行直接启动：

   ```bash
   claude-voice-notifier
   ```

   启动成功：会弹出加载动画窗口，3 秒后自动消失，托盘图标右下角显示"已启动"气泡。

2. 右键点击托盘图标可以：
   - 启动/停止监控
   - 分别配置"对话框提醒"和"当前会话完成提醒"
   - 分别测试声音、选择提示音、设置播放次数和播放间隔
   - 安装/卸载 Hooks
   - 显示日志
   - 退出程序

### 首次使用：安装 Hooks

右键点击托盘图标，选择 "Hooks 配置" -> "安装 Hooks"，然后重启 VSCode 或运行 `/hooks` 重新加载配置。

## 可用声音

声音文件位于 `media/` 目录。当前内置声音：

| 文件 | 描述 |
| ------ | ------ |
| `asterisk.wav` | 星号提示音（默认） |
| `notify.wav` | 通知音 |
| `ding.wav` | 叮声 |
| `exclamation.wav` | 警告音 |
| `alert.wav` | 提醒音 |

### 添加自定义声音

1. 将 `.wav` 或 `.mp3` 文件放入 `media/` 目录
2. 重启托盘应用
3. 右键托盘图标 → 对话框提醒 / 当前会话完成提醒 → 声音选择 → 选择新声音

## 工作原理

```text
Claude Code Hook 触发 (AskUserQuestion / PermissionRequest / PreToolUse)
    ↓
trigger-sound.js 写入信号到 attention.signal
    ↓
C# FileSystemWatcher 检测信号变化（事件驱动，非轮询）
    ↓
播放"对话框提醒"配置的声音
```

```text
Claude Code Stop Hook 触发
    ↓
trigger-sound.js 写入 session-complete 信号
    ↓
C# FileSystemWatcher 检测信号变化
    ↓
播放"当前会话完成提醒"配置的声音
```

**信号文件位置**: `~/.claude-voice-notifier/attention.signal`

信号文件内容为 JSON，例如：`{"type":"dialog","timestamp":...}` 或 `{"type":"session-complete","timestamp":...}`。

## 配置

编辑 `config.ini` 自定义配置：

```ini
[General]
DefaultSound=asterisk.wav
DialogSound=asterisk.wav
SessionCompleteSound=exclamation.wav

[Media]
MediaDir=.\media
Extensions=.wav,.mp3

[Monitor]
CooldownMs=2000
EnableLogMonitor=false
EnableProcessLog=false

[DialogPlayback]
DialogPlayCount=1
DialogPlayInterval=600

[SessionCompletePlayback]
SessionCompletePlayCount=1
SessionCompletePlayInterval=600
```

| 配置项 | 说明 |
| -------- | ---- |
| `DefaultSound` | 默认声音文件 |
| `DialogSound` | 对话框提醒声音文件 |
| `SessionCompleteSound` | 当前会话完成提醒声音文件 |
| `MediaDir` | 声音文件目录 |
| `Extensions` | 支持的声音文件扩展名 |
| `CooldownMs` | 信号检测冷却时间 |
| `DialogPlayCount` | 对话框提醒播放次数（1-6） |
| `DialogPlayInterval` | 对话框提醒播放间隔（ms） |
| `SessionCompletePlayCount` | 会话完成提醒播放次数（1-6） |
| `SessionCompletePlayInterval` | 会话完成提醒播放间隔（ms） |

## 技术架构

| 层级 | 组件 | 描述 |
| ------ | ------ | ------ |
| UI | `TrayApplication` / `TrayMenuBuilder` / `DarkMenuRenderer` | 系统托盘 + 预构建菜单 + 深色主题 |
| 服务 | `SignalMonitor` / `SoundPlaybackService` / `HooksService` | FileSystemWatcher 事件驱动 + 后台播放 + JSON 操作 |
| 配置 | `ConfigService` / `IniFileHelper` | INI 读写 + 热重载 |
| 启动 | `SplashWindow` / `App.xaml.cs` | WPF 毛玻璃加载动画 + 单例检测 |

## 许可证

MIT

---

## 作者

CC & CB & Barry

## 联系作者

- 邮箱：<barrydong2026@163.com>

---

## What is Claude Voice Notifier?

Claude Voice Notifier is a Windows system tray application that plays alert sounds when Claude Code pops up a confirmation dialog or when a conversation completes, reducing the need to stare at the screen while waiting for Claude Code.  Audio notifications provide real-time alerts so you can confirm issues and stay informed of session status.

Key features and highlights:

- 🔔 Plays an alert sound when Claude Code needs user input or confirmation.
- 🔔 Plays an alert sound when a Claude Code conversation completes.
- 🎵 Customizable sounds, supporting `.wav` / `.mp3` formats. Sound files, play count, and play interval are all configurable.
- ⚙️ Lightweight, no extra runtime required, easy installation.
- ✅ Designed for use with VS Code + Claude Code extension + Claude Voice Notifier tray combination.
- 🖥️ Built for Windows 11 x64.

## Features

- 🔔 Plays sounds when Claude Code needs user confirmation or session completes
- 🎵 Supports multiple sound files (`.wav` / `.mp3`)
- 🖥️ System tray application, minimize to tray
- ⚡ FileSystemWatcher event-driven signal detection (non-polling)
- 🪝 Auto-triggers via Claude Code Hooks
- 🎨 Dark / Light dual-theme tray menu

## Installation

```bash
npm install -g claude-voice-notifier
```

**Prerequisites**: Windows 10+ (x64), no extra runtime required.

## Usage

### Quick Start

1. After installation, you can:

   A. Double-click `bin\ClaudeVoiceNotifier.exe`

   B. Check version from command line:

   ```bash
   claude-voice-notifier --version  or  claude-voice-notifier -v
   ```

   C. Launch from command line:

   ```bash
   claude-voice-notifier
   ```

   On successful launch: a splash animation window appears, auto-dismisses after 3 seconds, and a "Started" bubble shows above the tray icon.

2. Right-click the tray icon to:
   - Start / Stop monitoring
   - Configure "Dialog Alert" and "Session Complete Alert" separately
   - Test sounds, select alert sounds, set play count and play interval
   - Install / Uninstall Hooks
   - Show logs
   - Exit

### First Use: Install Hooks

Right-click the tray icon, choose "Hooks Config" → "Install Hooks", then restart VSCode or run `/hooks` to reload config.

## Available Sounds

Sound files are in the `media/` directory. Built-in sounds:

| File | Description |
| ------ | ------ |
| `asterisk.wav` | Asterisk alert (default) |
| `notify.wav` | Notification sound |
| `ding.wav` | Ding sound |
| `exclamation.wav` | Warning sound |
| `alert.wav` | Alert sound |

### Adding Custom Sounds

1. Place `.wav` or `.mp3` files in the `media/` directory
2. Restart the tray app
3. Right-click tray icon → Dialog Alert / Session Complete Alert → Sound Selection → Choose new sound

## How It Works

```text
Claude Code Hook triggered (AskUserQuestion / PermissionRequest / PreToolUse)
    ↓
trigger-sound.js writes signal to attention.signal
    ↓
C# FileSystemWatcher detects signal change (event-driven, non-polling)
    ↓
Plays the sound configured for "Dialog Alert"
```

```text
Claude Code Stop Hook triggered
    ↓
trigger-sound.js writes session-complete signal
    ↓
C# FileSystemWatcher detects signal change
    ↓
Plays the sound configured for "Session Complete Alert"
```

**Signal file location**: `~/.claude-voice-notifier/attention.signal`

Signal file content is JSON, e.g.: `{"type":"dialog","timestamp":...}` or `{"type":"session-complete","timestamp":...}`.

## Configuration

Edit `config.ini` to customize settings:

```ini
[General]
DefaultSound=asterisk.wav
DialogSound=asterisk.wav
SessionCompleteSound=exclamation.wav

[Media]
MediaDir=.\media
Extensions=.wav,.mp3

[Monitor]
CooldownMs=2000
EnableLogMonitor=false
EnableProcessLog=false

[DialogPlayback]
DialogPlayCount=1
DialogPlayInterval=600

[SessionCompletePlayback]
SessionCompletePlayCount=1
SessionCompletePlayInterval=600

[Appearance]
MenuTheme=dark
Language=zh-CN
```

| Setting | Description |
| -------- | ---- |
| `DefaultSound` | Default sound file |
| `DialogSound` | Dialog alert sound file |
| `SessionCompleteSound` | Session complete alert sound file |
| `MediaDir` | Sound file directory |
| `Extensions` | Supported sound extensions, comma-separated |
| `CooldownMs` | Signal detection cooldown time |
| `DialogPlayCount` | Dialog alert play count (1-6) |
| `DialogPlayInterval` | Dialog alert play interval (ms) |
| `SessionCompletePlayCount` | Session complete alert play count (1-6) |
| `SessionCompletePlayInterval` | Session complete alert play interval (ms) |
| `MenuTheme` | Menu theme: `dark` or `light` |
| `Language` | Language: `zh-CN` or `en-US` |

## Technical Architecture

| Layer | Component | Description |
| ------ | ------ | ------ |
| UI | `TrayApplication` / `TrayMenuBuilder` / `DarkMenuRenderer` | System tray + pre-built menu + dark theme |
| Services | `SignalMonitor` / `SoundPlaybackService` / `HooksService` | FileSystemWatcher event-driven + background playback + JSON operations |
| Config | `ConfigService` / `IniFileHelper` | INI read/write + hot reload |
| Startup | `SplashWindow` / `App.xaml.cs` | WPF glass-morphism splash animation + singleton detection |

## License

MIT

---

## Author

CC & CB & Barry

## Contact

- Email: <barrydong2026@163.com>
