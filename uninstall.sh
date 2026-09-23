#!/bin/sh
# Nudge 卸载脚本（macOS）。用法：curl -fsSL https://raw.githubusercontent.com/yuxinz77/nudge-ai/main/uninstall.sh | sh
LABEL="ai.nudge.desktop"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
pkill -x nudge-ai 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/$LABEL.plist"
rm -rf /Applications/Nudge.app "$HOME/Applications/Nudge.app" "$HOME/.config/nudge-ai"
echo "Nudge 已卸载：程序、开机自启、配置和日志都清掉了。"
