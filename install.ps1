# Nudge 安装脚本（Windows 10/11，x64）。用法（PowerShell）：irm https://raw.githubusercontent.com/yuxinz77/nudge-ai/main/install.ps1 | iex
# 做的事：下载最新版 → 去掉"来自网络"标记 → 静默安装到当前用户目录 → 注册开机自启 → 启动。
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$repo = 'yuxinz77/nudge-ai'
Write-Host '查询最新版本…'
$json = Invoke-RestMethod "https://github.com/$repo/releases/latest/download/latest.json"
$url = $json.platforms.'windows-x86_64'.url
$ver = $json.version
if (-not $url) { throw '没找到 Windows 安装包，稍后再试。' }
$tmp = Join-Path $env:TEMP 'Nudge-setup.exe'
Write-Host "下载 Nudge v$ver…"
Invoke-WebRequest $url -OutFile $tmp -UseBasicParsing
Unblock-File $tmp
Get-Process nudge-ai -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process $tmp -ArgumentList '/S' -Wait
Remove-Item $tmp -ErrorAction SilentlyContinue

$dir = $null
$reg = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Nudge' -ErrorAction SilentlyContinue
if ($reg -and $reg.InstallLocation) { $dir = $reg.InstallLocation }
if (-not $dir -or -not (Test-Path $dir)) { $dir = Join-Path $env:LOCALAPPDATA 'Nudge' }
$exe = Get-ChildItem $dir -Filter '*.exe' | Where-Object Name -ne 'uninstall.exe' | Select-Object -First 1
if (-not $exe) { throw "安装完成但没找到程序文件（$dir）。" }
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Nudge' -Value ('"' + $exe.FullName + '"')
Start-Process $exe.FullName

Write-Host ''
Write-Host "装好了：Nudge v$ver 已在任务栏托盘（字母 n）。"
Write-Host '它平时不露面；你在 Claude Code 或 Codex 里发一句话，它就出来。以后有新版会自己静默更新。'
Write-Host "卸载：irm https://raw.githubusercontent.com/$repo/main/uninstall.ps1 | iex"
