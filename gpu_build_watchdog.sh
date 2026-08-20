LOG=/c/Users/mrbla/oss/ov_gpu_build.log
STAT=/c/Users/mrbla/oss/ov_gpu_build_status.txt
WD=/c/Users/mrbla/AppData/Local/Temp/claude/gpu-build-watchdog.log
prev=-1; streak=0; i=0
while [ $i -lt 100 ]; do
  sz=$(stat -c %s "$LOG" 2>/dev/null || echo 0)
  st=$(tr -d '\r\n' < "$STAT" 2>/dev/null)
  if [ "$sz" = "$prev" ]; then streak=$((streak+1)); else streak=0; fi
  flag=""; [ $streak -ge 6 ] && flag=" STALL-SUSPECTED(~12min-static)"
  echo "[$(date '+%H:%M:%S')] +$((i*120))s logsize=$sz prev=$prev streak=$streak status=[$st]$flag" >> "$WD"
  case "$st" in *GPU_BUILD_OK*) echo "[$(date '+%H:%M:%S')] BUILD OK — watchdog exit" >> "$WD"; exit 0;; *GPU_BUILD_FAILED*) echo "[$(date '+%H:%M:%S')] BUILD FAILED — watchdog exit" >> "$WD"; exit 2;; esac
  prev=$sz; i=$((i+1)); sleep 120
done
echo "[$(date '+%H:%M:%S')] watchdog CAP (200min) reached" >> "$WD"
