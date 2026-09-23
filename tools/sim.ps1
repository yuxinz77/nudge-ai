# Nudge 假会话工具包（Windows）。不用装 Claude Code / Codex：往两个监听目录写假的会话日志，逐步触发 Nudge 的每一种状态。
# 用法（PowerShell）：
#   irm https://raw.githubusercontent.com/yuxinz77/nudge-ai/main/tools/sim.ps1 -OutFile sim.ps1
#   powershell -ExecutionPolicy Bypass -File .\sim.ps1          # 每一步按回车再继续（推荐，边看浮窗边走）
#   powershell -ExecutionPolicy Bypass -File .\sim.ps1 -Auto    # 每步自动隔 3 秒
# 先装好并启动 Nudge 再跑。结束自动清理写入的假文件。日志：%USERPROFILE%\.config\nudge-ai\nudge.log
param([switch]$Auto)
$ErrorActionPreference = 'Stop'
$home_ = if ($env:HOME) { $env:HOME } else { $env:USERPROFILE }
$CL = Join-Path $home_ '.claude\projects\nudge-test'
$CX = Join-Path $home_ '.codex\sessions\2026\09\23'
New-Item -ItemType Directory -Force -Path $CL, $CX | Out-Null
$F1 = Join-Path $CL 'test-claude.jsonl'; $F2 = Join-Path $CL 'test-claude-heavy.jsonl'
$X1 = Join-Path $CX 'rollout-2026-09-23T11-00-00-nudgetest.jsonl'; $X2 = Join-Path $CX 'rollout-2026-09-23T11-30-00-nudgeprice.jsonl'
Remove-Item -Force -ErrorAction SilentlyContinue $F1, $F2, $X1, $X2
$utf8 = New-Object System.Text.UTF8Encoding($false)
function Append($file, $line) { [IO.File]::AppendAllText($file, $line + "`n", $utf8) }
function Step($name, $expect) {
  if ($Auto) { Start-Sleep -Seconds 3; Write-Host "[$name] $expect" }
  else { Read-Host "[$name] $expect  —— 看浮窗，回车继续" | Out-Null }
}
function CU($f, $t) { Append $f ('{"type":"user","message":{"role":"user","content":"' + $t + '"}}') }
function CA($f, $id, $model, $in, $cc, $cr, $out) { Append $f ('{"type":"assistant","message":{"id":"' + $id + '","model":"' + $model + '","usage":{"input_tokens":' + $in + ',"cache_creation_input_tokens":' + $cc + ',"cache_read_input_tokens":' + $cr + ',"output_tokens":' + $out + '}}}') }
function XM($f, $model) {
  Append $f '{"type":"session_meta","payload":{"cwd":"C:\\nudge-test","originator":"codex_work_desktop"}}'
  Append $f ('{"type":"turn_context","payload":{"model":"' + $model + '"}}')
  Append $f '{"type":"response_item","payload":{"type":"message","role":"user","content":[{"type":"input_text","text":"帮我看看这个"}]}}'
}
function XT($f, $in, $cached, $out, $win, $total) { Append $f ('{"type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":' + $in + ',"cached_input_tokens":' + $cached + ',"output_tokens":' + $out + '},"model_context_window":' + $win + ',"total_token_usage":{"total_tokens":' + $total + '}}}}') }
function XC($f, $n) { Append $f ('{"type":"compacted","payload":{"window_number":' + $n + '}}') }

Write-Host "写入目录：$CL 和 $CX"
Write-Host "Nudge 现在应该是隐身的（托盘只有一个 n）。"
Step '0' '确认 Nudge 隐身，准备写第一条'
Write-Host '== Claude 200k 模型（黄 8 万 / 红 12 万）'
CU $F1 '帮我看下这个'; Start-Sleep 1
CA $F1 m1 claude-sonnet-4-5 1000 20000 0 500;     Step 'c1' '首次露面：右下滑入，绿灯，约 11%'
CA $F1 m2 claude-sonnet-4-5 500 60000 21500 800;  Step 'c2' '黄灯 + 一句"把握节奏"提示'
CA $F1 m3 claude-sonnet-4-5 500 42000 82000 900;  Step 'c3' '红灯 + "再不存记忆就要被压缩"提示'
Append $F1 '{"type":"system","subtype":"compact_boundary"}'
CA $F1 m4 claude-sonnet-4-5 500 2000 27000 600;   Step 'c4' '压缩后回绿 + "细节已丢"提示'
CA $F1 m5 claude-sonnet-4-5 4000 55000 0 1000;    Step 'c5' '缓存冷（本轮计费高）提示'
Write-Host '== Claude 预加载过重（起步 9 万，带复制按钮）'
CU $F2 '开始'; Start-Sleep 1
CA $F2 h1 claude-fable-5-1 1000 90000 0 500;      Step 'c6' '切到新会话；heavy 提示 + 复制按钮，不自动收起'
Write-Host '== Codex 默认窗口 25.8 万（黄 15 万 / 红 20 万）'
XM $X1 gpt-5.6-terra; Start-Sleep 1
XT $X1 30000 0 500 258400 30500;         Step 'x1' 'Codex 绿灯 约 12%'
XT $X1 155000 150000 600 258400 190000;  Step 'x2' '黄灯'
XT $X1 200000 195000 700 258400 400000;  Step 'x3' '红灯'
XC $X1 1; XT $X1 40000 0 500 258400 440000;      Step 'x4' '压缩 1 次，回绿 + 提示'
XC $X1 2; XT $X1 40000 35000 500 258400 480000;  Step 'x5' '压缩 2 次'
XC $X1 3; XT $X1 40000 35000 500 258400 520000;  Step 'x6' '压缩 3 次 → "已压缩 3 次"提示'
XT $X1 120000 5000 500 258400 640000;    Step 'x7' 'Codex 缓存冷提示'
Write-Host '== Codex 开大窗口 87.2 万，过 27.2 万计费线'
XM $X2 gpt-5.6-terra; Start-Sleep 1
XT $X2 100000 0 500 872000 100500;       Step 'x8' '绿灯，带 27.2 万红线刻度'
XT $X2 280000 270000 500 872000 380500;  Step 'x9' '过计费线：红灯 + 双倍计费提示'
Write-Host '== 持开文件追加（模拟 ChatGPT App 一直不关文件）'
$fs = [IO.File]::Open($X1, 'Append', 'Write', 'ReadWrite'); $sw = New-Object IO.StreamWriter($fs, $utf8)
$sw.WriteLine('{"type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":50000,"cached_input_tokens":45000,"output_tokens":300},"model_context_window":258400,"total_token_usage":{"total_tokens":700000}}}}'); $sw.Flush()
Step 'x10' '文件没关就追加：应立刻切回 Codex 约 19%（若要等 5 秒才变，说明靠的是自愈扫描）'
$sw.Close()
Write-Host '== 闲置隐藏：不再写入，15 分钟后浮窗应自己滑出（可改 config.json 的 hide_after_minutes 缩短）'
Step 'end' '回车开始清理'
Remove-Item -Recurse -Force $CL; Remove-Item -Force $X1, $X2
Write-Host '完成。有异常把日志发我：%USERPROFILE%\.config\nudge-ai\nudge.log'
