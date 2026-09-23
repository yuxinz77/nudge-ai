#!/bin/zsh
# Nudge 合成信号测试（Mac）。见 sim.ps1 的说明，逻辑相同。
set -e
CL=~/.claude/projects/nudge-test; CX=~/.codex/sessions/2026/09/23; mkdir -p $CL $CX
F1=$CL/test-claude.jsonl; F2=$CL/test-claude-heavy.jsonl
X1=$CX/rollout-2026-09-23T11-00-00-nudgetest.jsonl; X2=$CX/rollout-2026-09-23T11-30-00-nudgeprice.jsonl
rm -f $F1 $F2 $X1 $X2
step() { sleep 3; echo "[$1] 看浮窗"; }
cu() { echo '{"type":"user","message":{"role":"user","content":"'$2'"}}' >> $1; }
ca() { echo '{"type":"assistant","message":{"id":"'$2'","model":"'$3'","usage":{"input_tokens":'$4',"cache_creation_input_tokens":'$5',"cache_read_input_tokens":'$6',"output_tokens":'$7'}}}' >> $1; }
xm() { echo '{"type":"session_meta","payload":{"cwd":"/tmp/nudge-test","originator":"codex_work_desktop"}}' >> $1; echo '{"type":"turn_context","payload":{"model":"'$2'"}}' >> $1; echo '{"type":"response_item","payload":{"type":"message","role":"user","content":[{"type":"input_text","text":"帮我看看这个"}]}}' >> $1; }
xt() { echo '{"type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":'$2',"cached_input_tokens":'$3',"output_tokens":'$4'},"model_context_window":'$5',"total_token_usage":{"total_tokens":'$6'}}}}' >> $1; }
xc() { echo '{"type":"compacted","payload":{"window_number":'$2'}}' >> $1; }
echo "== Claude 200k"; cu $F1 "帮我看下这个"; sleep 2
ca $F1 m1 claude-sonnet-4-5 1000 20000 0 500; step c1-绿
ca $F1 m2 claude-sonnet-4-5 500 60000 21500 800; step c2-黄
ca $F1 m3 claude-sonnet-4-5 500 42000 82000 900; step c3-红
echo '{"type":"system","subtype":"compact_boundary"}' >> $F1; ca $F1 m4 claude-sonnet-4-5 500 2000 27000 600; step c4-压缩
ca $F1 m5 claude-sonnet-4-5 4000 55000 0 1000; step c5-缓存冷
echo "== heavy"; cu $F2 "开始"; sleep 2; ca $F2 h1 claude-fable-5-1 1000 90000 0 500; step c6-heavy
echo "== Codex"; xm $X1 gpt-5.6-terra; sleep 2
xt $X1 30000 0 500 258400 30500; step x1-绿
xt $X1 155000 150000 600 258400 190000; step x2-黄
xt $X1 200000 195000 700 258400 400000; step x3-红
xc $X1 1; xt $X1 40000 0 500 258400 440000; step x4-压缩1
xc $X1 2; xt $X1 40000 35000 500 258400 480000; step x5-压缩2
xc $X1 3; xt $X1 40000 35000 500 258400 520000; step x6-压缩3
xt $X1 120000 5000 500 258400 640000; step x7-缓存冷
echo "== 计费线"; xm $X2 gpt-5.6-terra; sleep 2; xt $X2 100000 0 500 872000 100500; step x8-绿; xt $X2 280000 270000 500 872000 380500; step x9-过计费线
echo "== 清理"; rm -rf $CL $X1 $X2; rmdir $CX 2>/dev/null; rmdir ~/.codex/sessions/2026/09 2>/dev/null || true
