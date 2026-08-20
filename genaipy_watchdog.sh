LOG=/c/Users/mrbla/oss/ov_genaipy_build.log
STAT=/c/Users/mrbla/oss/ov_genaipy_build_status.txt
WD=/c/Users/mrbla/AppData/Local/Temp/claude/genaipy-watchdog.log
prev_cpu=-1; prev_sz=-1; streak=0; i=0
while [ $i -lt 45 ]; do
  st=$(tr -d '\r\n' < "$STAT" 2>/dev/null)
  case "$st" in
    *GENAIPY_BUILD_OK*) echo "[$(date '+%H:%M:%S')] OK -> exit0" >> "$WD"; exit 0;;
    *FAILED*) echo "[$(date '+%H:%M:%S')] $st -> exit2" >> "$WD"; exit 2;;
  esac
  cpu=$(powershell -NoProfile -Command '$p=Get-Process cl,ninja,cmake,link,clang,clang-cl,python -EA SilentlyContinue; if($p){[math]::Round(($p|Measure-Object CPU -Sum).Sum)}else{0}' 2>/dev/null | tr -d '\r ')
  sz=$(stat -c %s "$LOG" 2>/dev/null || echo 0)
  if [ "$cpu" = "$prev_cpu" ] && [ "$sz" = "$prev_sz" ]; then streak=$((streak+1)); else streak=0; fi
  echo "[$(date '+%H:%M:%S')] +$((i*120))s cpu=${cpu}s sz=$sz streak=$streak status=[$st]" >> "$WD"
  [ "$streak" -ge 5 ] && { echo "[$(date '+%H:%M:%S')] STALL -> exit3" >> "$WD"; exit 3; }
  prev_cpu=$cpu; prev_sz=$sz; i=$((i+1)); sleep 120
done
echo "[$(date '+%H:%M:%S')] CAP -> exit0" >> "$WD"; exit 0
