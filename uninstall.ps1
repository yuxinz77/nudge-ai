# Nudge 卸载脚本（Windows）。用法：irm https://raw.githubusercontent.com/yuxinz77/nudge-ai/main/uninstall.ps1 | iex
$ErrorActionPreference = 'SilentlyContinue'
Get-Process nudge-ai | Stop-Process -Force
Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Nudge'
$reg = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Nudge'
$un = $null
if ($reg -and $reg.UninstallString) { $un = $reg.UninstallString.Trim('"') }
if (-not $un) { $un = Join-Path $env:LOCALAPPDATA 'Nudge\uninstall.exe' }
if (Test-Path $un) { Start-Process $un -ArgumentList '/S' -Wait }
Remove-Item -Recurse -Force (Join-Path $env:USERPROFILE '.config\nudge-ai')
Write-Host 'Nudge 已卸载：程序、开机自启、配置和日志都清掉了。'
