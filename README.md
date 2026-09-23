# Nudge — AI habit coach for Claude Code & Codex. Know when to stop.

一个免费的 AI 习惯纠偏小工具，帮你省 Token。它只做一件事：知道什么时候该停。

**Nudge 只看本机的 token 用量记录，对话内容一个字不读、不存，全程离线。**（自动更新只访问下载服务器取新版本）

## 安装

macOS（Apple 芯片），终端里一条命令：

```sh
curl -fsSL https://nudge-ai.oss-cn-shenzhen.aliyuncs.com/mac | sh
```

Windows 10/11（x64），PowerShell 里一条命令：

```powershell
irm https://nudge-ai.oss-cn-shenzhen.aliyuncs.com/win | iex
```

装完它不会立刻出现。你在 Claude Code 或 Codex 里发一句话，它才从屏幕边缘滑出来；15 分钟没动静就自己收起。有新版本会在你不用它的时候静默更新。

也可以在 [Releases](https://github.com/yuxinz77/nudge-ai/releases/latest) 直接下载安装包（Mac 首次打开需要在「系统设置 → 隐私与安全性」里点「仍要打开」）。

## 灯的含义

- 🟢 绿灯：可以继续工作
- 🟡 黄灯：掌握会话任务节奏，提前存记忆，开新会话
- 🔴 红灯：上下文快爆了，自动压缩容易降智，快收尾
- 🔴 红灯（Codex 过计费线）：token 额度正在按多倍率计算，及时止损省钱

## 卸载

```sh
curl -fsSL https://nudge-ai.oss-cn-shenzhen.aliyuncs.com/uninstall-mac | sh   # macOS
```
```powershell
irm https://nudge-ai.oss-cn-shenzhen.aliyuncs.com/uninstall-win | iex          # Windows
```

## 隐私

读取的文件：`~/.claude/projects` 与 `~/.codex/sessions` 下的会话日志。读取的字段：只有 token 数字（输入、输出、缓存、模型名、窗口大小）和压缩标记。不读取、不保存内容；不联网、不收集任何统计。本地只保留一份配置和一份日志：`~/.config/nudge-ai/`，删掉即清空。

---

© 2026 Nudge · 免费使用，保留所有权利。本仓库只发布安装包，不含源码。
