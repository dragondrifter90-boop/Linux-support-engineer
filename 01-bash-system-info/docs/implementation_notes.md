**B. `docs/implementation_notes.md`:**
```markdown
# Implementation Notes

## Design Decisions

### 1. Dual-File Logging Strategy
**Problem:** Need both detailed snapshots and trend analysis.
**Solution:** 
- `REPORT_FILE`: Complete system state (new file per run)
- `LOG_FILE`: Brief entries for long-term trend analysis

### 2. Threshold-Based Monitoring
Implemented warning thresholds (80% disk, 90% memory) to mimic production monitoring systems.

### 3. Cron Integration
Script designed to run autonomously via cron, with proper error handling.

## Code Walkthrough

### Key Sections:
1. **Variable Declaration**: Configurable paths and thresholds
2. **Report Generation**: Comprehensive system checks using standard Linux tools
3. **Threshold Evaluation**: Conditional logic for warning detection
4. **Logging**: Append-only log for historical tracking

### Important Commands Used:
- `df -h`: Disk usage with human-readable format
- `free`: Memory utilization
- `systemctl`: Service status checks
- `tee`: Output to both terminal and file
- `awk`: Text processing for extracting specific values

## Learning Outcomes
- Bash scripting best practices
- System monitoring fundamentals
- Production-ready script design
- Documentation standards
