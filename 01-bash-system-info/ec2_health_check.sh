#!/bin/bash

# Enhanced version with better logging
LOG_FILE="/var/log/ec2_health.log"
REPORT_DIR="/home/ubuntu/Linux-support-engineer/01-bash-system-info"
REPORT_FILE="$REPORT_DIR/health_report_$(date +%Y-%m-%d_%H%M%S).txt"


# Thresholds for warnings
DISK_WARNING=80
MEMORY_WARNING=90

{
echo "=== EC2 System Health Report ==="
echo "Generated on: $(date)"
echo "================================="

# ... (all the previous checks)

# Add threshold checks
DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
MEMORY_USAGE=$(free | awk '/Mem/{printf("%.0f"), $3/$2*100}')

echo -e "\n8. THRESHOLD CHECKS:"
echo "Root Disk Usage: ${DISK_USAGE}% $( [ $DISK_USAGE -ge $DISK_WARNING ] && echo '[WARNING]' || echo '[OK]' )"
echo "Memory Usage: ${MEMORY_USAGE}% $( [ $MEMORY_USAGE -ge $MEMORY_WARNING ] && echo '[WARNING]' || echo '[OK]' )"

} | tee "$REPORT_FILE"

# Enhanced log entry - includes status
if [ $DISK_USAGE -ge $DISK_WARNING ] || [ $MEMORY_USAGE -ge $MEMORY_WARNING ]; then
    STATUS="WARNING"
else
    STATUS="OK"
fi

echo "$(date): Health check completed - Disk:${DISK_USAGE}% Mem:${MEMORY_USAGE}% Status:${STATUS}" >> "$LOG_FILE"

echo "Health report saved to: $REPORT_FILE"
echo "Log entry added to: $LOG_FILE"
