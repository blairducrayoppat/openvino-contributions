LOG=/c/Users/mrbla/oss/ov_gpu_build.log
STAT=/c/Users/mrbla/oss/ov_gpu_build_status.txt
WD=/c/Users/mrbla/AppData/Local/Temp/claude/gpu-build-watchdog.log
prev_cpu=-1; prev_sz=-1; streak=0; i=0
echo "[$(date '+%H:%M:%S')] watchdog2 start (cpu-delta; exits-to-notify on OK/FAIL/stall)" >> "$WD"
while [ $i -lt 120 ]; do
  st=$(tr -d '\r\n' < "$STAT" 2>/dev/null)
  case "$st" in
    *GPU_BUILD_OK*) echo "[$(date '+%H:%M:%S')] BUILD OK -> exit0" >> "$WD"; exit 0;;
    *GPU_BUILD_FAILED*) echo "[$(date '+%H:%M:%S')] BUILD FAILED -> exit2" >> "$WD"; exit 2;;
  esac
  cpu=$(powershell -NoProfile -Command '$p=Get-Process cl,ninja,cmake,link,clang,clang-cl -EA SilentlyContinue; if($p){[math]::Round(($p|Measure-Object CPU -Sum).Sum)}else{0}' 2>/dev/null | tr -d '\r ')
  sz=$(stat -c %s "$LOG" 2>/dev/null || echo 0)
  if [ "$cpu" = "$prev_cpu" ] && [ "$sz" = "$prev_sz" ]; then streak=$((streak+1)); else streak=0; fi
  echo "[$(date '+%H:%M:%S')] +$((i*120))s cpu=${cpu}s prev=${prev_cpu} sz=$sz streak=$streak status=[$st]" >> "$WD"
  if [ "$streak" -ge 5 ]; then echo "[$(date '+%H:%M:%S')] STALL: cpu+log static ~10min -> exit3 (investigate)" >> "$WD"; exit 3; fi
  prev_cpu=$cpu; prev_sz=$sz; i=$((i+1)); sleep 120
done
echo "[$(date '+%H:%M:%S')] watchdog2 CAP (240min) reached -> exit0" >> "$WD"; exit 0
