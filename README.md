# ⭕ Claude Voice Notifier (Windows 11 64bit Edition)

## 发布信息

- Published by:       @barry.dong
- Release Version:    1.0.12
- Released Date:      2026-06-05
- Release History:

    1. v1.0.6: Published Windows 11 64bit version
    2. v1.0.12: Solved npm and EXE installation's compatible issue for hooks status display

## 特别说明(Special Notes)

- For English Version, please refer to the section as below after the Chinese section.

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

### 2. 通过 GitHub Release 安装 (推荐)

- 打开 GitHub Releases 页面：
  <https://github.com/dyxdong/claude-voice-notifier/releases>
- 下载最新版本的 EXE 安装程序（`claude-voice-notifier-windows-x64-vX.X.X.exe`）。
- 双击运行安装程序。安装过程中可自定义安装目录，安装程序会自动将软件路径添加到系统环境变量（PATH）中。
- **首次运行**：安装完成后启动程序，会自动在 `%USERPROFILE%\.claude-voice-notifier` 下生成初始配置文件和媒体目录。
- **重要提示**：用户的配置文件和自定义声音均存放在 `%USERPROFILE%\.claude-voice-notifier` 目录中，**而非软件安装目录**。这样即使重装或升级软件，您的配置也不会丢失。
- 您可以通过修改 `%USERPROFILE%\.claude-voice-notifier\config.ini` 来配置基本参数，但更推荐直接使用系统托盘菜单进行可视化配置。
- 将自定义声音文件（`.wav` 或 `.mp3`）放入 `%USERPROFILE%\.claude-voice-notifier\media` 目录即可在托盘菜单中选用。

**前置要求**：Windows 11（x64），无需安装任何额外运行时。

### 3. 卸载

- **EXE 安装**：通过 Windows 设置 -> 应用 -> 卸载，或运行安装目录下的 `unins000.exe`。卸载程序会自动清理安装目录（包括隐藏文件）、系统环境变量及注册表项。
- **npm 安装**：运行 `npm uninstall -g claude-voice-notifier`。

## 使用方法

### 快速开始

1. 启动程序：

   - **方式一**：在开始菜单找到 "Claude Voice Notifier" 快捷方式运行。
   - **方式二**：打开命令行（CMD 或 PowerShell），直接输入（得益于自动配置的环境变量）：

     ```bash
     claude-voice-notifier
     ```

   - **方式三**：双击安装目录下的 `bin\ClaudeVoiceNotifier.exe`。
   - **查看版本**：

     ```bash
     claude-voice-notifier --version  # 或 -v
     ```

   启动成功后：会弹出加载动画窗口，3 秒后自动消失，系统托盘图标右下角会显示"已启动"气泡提示。

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

CC & CB & CD & Barry

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

### 1. Install via npm

```bash
npm install -g claude-voice-notifier
```

### 2. Install via GitHub Release (Recommended)

- Go to the GitHub Releases page:
  <https://github.com/dyxdong/claude-voice-notifier/releases>
- Download the latest EXE installer (`claude-voice-notifier-windows-x64-vX.X.X.exe`).
- Run the installer. You can choose a custom installation directory, and the installer will automatically add the application path to your system environment variables (PATH).
- **First Run**: After installation, launch the application. It will automatically generate the initial configuration and media directories at `%USERPROFILE%\.claude-voice-notifier`.
- **Important Note**: User configuration files and custom sounds are stored in `%USERPROFILE%\.claude-voice-notifier`, **NOT** in the installation directory. This ensures your settings are preserved across upgrades or reinstallations.
- You can configure basic parameters by editing `%USERPROFILE%\.claude-voice-notifier\config.ini`, though using the system tray menu is highly recommended.
- Place your custom sound files (`.wav` or `.mp3`) in the `%USERPROFILE%\.claude-voice-notifier\media` directory to select them from the tray menu.

**Prerequisites**: Windows 11 (x64), no extra runtime required.

### 3. Uninstallation

- **EXE Installation**: Go to Windows Settings -> Apps -> Uninstall, or run `unins000.exe` in the installation directory. The uninstaller will automatically clean up the installation directory (including hidden files), system environment variables, and registry entries.
- **npm Installation**: Run `npm uninstall -g claude-voice-notifier`.

## Usage

### Quick Start

1. Launch the application:

   - **Method A**: Find and run the "Claude Voice Notifier" shortcut from the Start Menu.
   - **Method B**: Open a command prompt (CMD or PowerShell) and type (thanks to the auto-configured environment variables):

     ```bash
     claude-voice-notifier
     ```

   - **Method C**: Double-click `bin\ClaudeVoiceNotifier.exe` in the installation directory.
   - **Check version**:

     ```bash
     claude-voice-notifier --version  # or -v
     ```

   On successful launch: a splash animation window appears, auto-dismisses after 3 seconds, and a "Started" bubble shows above the system tray icon.

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

CC & CB & CD & Barry

## Contact

- Email: <barrydong2026@163.com>
