# Nudge 安装脚本（Windows 10/11，x64）。用法（PowerShell）：irm https://nudge.yxamz.com/win | iex
# 下载源：阿里云 OSS 优先（国内秒开），GitHub Releases 备用。
# 做的事：下载最新版 → 去掉"来自网络"标记 → 静默安装到当前用户目录 → 注册开机自启 → 启动。
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$repo = 'yuxinz77/nudge-ai'
$oss = 'https://nudge-ai.oss-cn-shenzhen.aliyuncs.com'
function Retry($what, [scriptblock]$do) {
  for ($i = 1; $i -le 4; $i++) {
    try { return & $do } catch {
      if ($i -eq 4) { throw "$what 失败：$($_.Exception.Message)`n连不上 GitHub。请先打开代理（系统代理）再重新运行这条命令。" }
      Write-Host "  $what 第 $i 次没成功，3 秒后重试…"; Start-Sleep 3
    }
  }
}
Write-Host '查询最新版本…'
$json = $null
try { $json = Invoke-RestMethod "$oss/latest.json" -UseBasicParsing -TimeoutSec 20 } catch { Write-Host '  OSS 没连上，改用 GitHub…' }
if (-not $json) { $json = Retry '查询版本' { Invoke-RestMethod "https://github.com/$repo/releases/latest/download/latest.json" -UseBasicParsing } }
$url = $json.platforms.'windows-x86_64'.url
$ver = $json.version
if (-not $url) { throw '没找到 Windows 安装包，稍后再试。' }
$tmp = Join-Path $env:TEMP 'Nudge-setup.exe'
Write-Host "下载 Nudge v$ver…"
Retry '下载' { Invoke-WebRequest $url -OutFile $tmp -UseBasicParsing }
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
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Nudge' -Value ('"' + $exe.FullName + '" --autostart')
Start-Process $exe.FullName

Write-Host ''
Write-Host "装好了：Nudge v$ver 已在任务栏托盘（字母 n）。"
Write-Host '一个免费的 AI 习惯纠偏小工具，帮你防降智、省 Token。'
Write-Host '它平时不露面；你在 Claude Code 或 Codex 里发一句话，它就出来。'
Write-Host "卸载：irm https://nudge.yxamz.com/uninstall-win | iex"
