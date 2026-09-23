#!/bin/sh
# Nudge 安装脚本（macOS，Apple 芯片）。用法：curl -fsSL https://raw.githubusercontent.com/yuxinz77/nudge-ai/main/install.sh | sh
# 做的事：下载最新版 → 放进 /Applications → 去掉隔离标记（不弹"无法验证开发者"）→ 注册开机自启 → 启动。
set -e
REPO="yuxinz77/nudge-ai"
LABEL="ai.nudge.desktop"
case "$(uname -s)-$(uname -m)" in Darwin-arm64) ;; Darwin-*) echo "目前只提供 Apple 芯片版（M1 及以后）。"; exit 1 ;; *) echo "这是 macOS 安装脚本。"; exit 1 ;; esac

echo "查询最新版本…"
JSON=$(curl -fsSL "https://github.com/$REPO/releases/latest/download/latest.json")
URL=$(printf '%s' "$JSON" | tr -d '\n' | grep -oE '"darwin-aarch64"[^}]*' | grep -oE 'https://[^"]+' | head -1)
VER=$(printf '%s' "$JSON" | tr -d '\n' | grep -oE '"version" *: *"[^"]+"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
[ -n "$URL" ] || { echo "没找到 Mac 安装包，稍后再试。"; exit 1; }

TMP=$(mktemp -d)
echo "下载 Nudge v$VER…"
curl -fL --progress-bar "$URL" -o "$TMP/nudge.tar.gz"

DEST=/Applications
[ -w "$DEST" ] || { DEST="$HOME/Applications"; mkdir -p "$DEST"; }
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
pkill -x nudge-ai 2>/dev/null || true
rm -rf "$DEST/Nudge.app"
tar -xzf "$TMP/nudge.tar.gz" -C "$DEST"
xattr -dr com.apple.quarantine "$DEST/Nudge.app" 2>/dev/null || true
rm -rf "$TMP"

PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>$DEST/Nudge.app/Contents/MacOS/nudge-ai</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><false/>
  <key>ProcessType</key><string>Interactive</string>
</dict></plist>
PL
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo
echo "装好了：Nudge v$VER 已在菜单栏（右上角的字母 n）。"
echo "它平时不露面；你在 Claude Code 或 Codex 里发一句话，它就出来。以后有新版会自己静默更新。"
echo "卸载：curl -fsSL https://raw.githubusercontent.com/$REPO/main/uninstall.sh | sh"
