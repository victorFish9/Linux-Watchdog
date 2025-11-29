PROCESS_NAME="dummy_service.py"
START_COMMAND="nohup python3 /home/kali/project/dummy_service.py > /dev/null 2>&1 &"

# Thresholds
DISK_THRESHOLD=80 # Percent
MEM_THRESHOLD=500       # MB

LOG_FILE="/var/log/system_health.log"

log_event() { 
        local message="$1" 
        local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

CURRENT_DISK=$(df -P / | tail -n 1 | awk '{ print $5 }' | sed 's/%//')

if [ "$CURRENT_DISK" -gt "$DISK_THRESHOLD" ]; then
        log_event "CRITICAL: Disk usage is high: ${CURRENT_DISK}%"
else
    # Optional: Log heartbeat (comment out to reduce noise) log_event 
    # "INFO: Disk usage normal: ${CURRENT_DISK}%"
        :
fi

FREE_MEM=$(free -m | awk '/Mem:/ { print $7 }')


if [ -z "$FREE_MEM" ]; then
        FREE_MEM=$(free -m | awk '/Mem:/ { print $4 }')
fi

# Safety check: If still empty, default to 0 to avoid crash

if [ -z "$FREE_MEM" ]; then 
FREE_MEM=0 
fi

if [ "$FREE_MEM" -lt "$MEM_THRESHOLD" ]; then
    log_event "WARNING: Low Memory! Free: ${FREE_MEM}MB"
fi

if pgrep -f "$PROCESS_NAME" > /dev/null; then
    # Process is running, everything is fine.
    :
else
        log_event "ALERT: $PROCESS_NAME is NOT running."
        log_event "ATTEMPT: Restarting $PROCESS_NAME..."
    
    # Execute the restart command
        eval "$START_COMMAND"
    
    # Check if it came back up
        sleep 2 
        if pgrep -f "$PROCESS_NAME" > /dev/null; then
                log_event "SUCCESS: $PROCESS_NAME was successfully restarted."
        else 
                log_event "ERROR: Failed to restart $PROCESS_NAME." 
        fi
fi
