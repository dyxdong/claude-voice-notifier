@echo off
if /i "%~1"=="--version" goto :version
if /i "%~1"=="-v" goto :version
if /i "%~1"=="--help" goto :help
if /i "%~1"=="-h" goto :help
start "" "%~dp0ClaudeVoiceNotifier.exe"
goto :eof

:version
echo claude-voice-notifier v1.0.6
goto :eof

:help
echo Claude Voice Notifier - Desktop voice notifier for Claude Code
echo.
echo Usage:
echo   claude-voice-notifier          Launch the tray application
echo   claude-voice-notifier --version Show version
echo   claude-voice-notifier -v       Show version
echo   claude-voice-notifier --help   Show this help
echo   claude-voice-notifier -h       Show this help
goto :eof
