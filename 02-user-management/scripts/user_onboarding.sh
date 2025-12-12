#!/bin/bash

# User Onboarding Automation Script
# Reads a CSV file and creates users with proper setup

# Configuration
CSV_FILE="/home/ubuntu/Linux-support-engineer/02-user-management/test-files/new_developers.csv"
SHARED_GROUP="dev-team"
PROJECT_DIR="/opt/awesome_project"
LOG_FILE="/var/log/user_onboarding.log"
SKEL_DIR="/etc/skel"
BACKUP_DIR="/home/ubuntu/Linux-support-engineer/02-user-management/examples"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Check if CSV file exists
if [[ ! -f "$CSV_FILE" ]]; then
    echo -e "${RED}ERROR: CSV file not found at $CSV_FILE${NC}"
    exit 1
fi

log_message "=== Starting user onboarding process ==="

# Create shared group if it doesn't exist
if getent group "$SHARED_GROUP" > /dev/null; then
    log_message "Group '$SHARED_GROUP' already exists"
else
    groupadd "$SHARED_GROUP"
    log_message "Created group: $SHARED_GROUP"
fi

# Create project directory with proper permissions
if [[ ! -d "$PROJECT_DIR" ]]; then
    mkdir -p "$PROJECT_DIR"
    chown :"$SHARED_GROUP" "$PROJECT_DIR"
    chmod 2775 "$PROJECT_DIR" # SETGID bit so new files inherit group
    log_message "Created project directory: $PROJECT_DIR with SETGID bit"
fi

# Process CSV file
log_message "Processing CSV file: $CSV_FILE"
echo -e "\n${YELLOW}=== Creating Users ===${NC}"

# Skip header line and process each user
tail -n +2 "$CSV_FILE" | while IFS=',' read -r username full_name department; do
    # Remove any carriage returns or extra spaces
    username=$(echo "$username" | tr -d '\r' | xargs)
    full_name=$(echo "$full_name" | tr -d '\r' | xargs)

    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo -e "${YELLOW}User '$username' already exists - skipping${NC}"
        log_message "SKIP: User '$username' already exists"
    else
        # Generate a random password
        password=$(openssl rand -base64 12)
        # Create user with comment (full name) and add to shared group
        useradd -m -c "$full_name" -s /bin/bash -G "$SHARED_GROUP" "$username"
        # Set password
        echo "$username:$password" | chpasswd

        # Force password change on first login
        chage -d 0 "$username"
        # Create SSH directory and set permissions
        mkdir -p "/home/$username/.ssh"
        chmod 700 "/home/$username/.ssh"
        chown -R "$username:$username" "/home/$username/.ssh"
        # Copy standard bashrc if needed
        if [[ ! -f "/home/$username/.bashrc" ]]; then
            cp "$SKEL_DIR/.bashrc" "/home/$username/.bashrc"
            chown "$username:$username" "/home/$username/.bashrc"
        fi

        echo -e "${GREEN}Created user: $username${NC}"
        echo -e "  Name: $full_name"
        echo -e "  Temp Password: $password"
        echo -e "  Groups: $(id -nG "$username")"
        log_message "CREATED: User '$username' ($full_name) - Groups: $(id -nG "$username")"
        # Save credentials to a secure file (for demonstration only - in real life, we use a proper secret manager)
        echo "Username: $username, Password: $password, Name: $full_name" >> "$BACKUP_DIR/user_credentials.txt"
    fi
done

# Summary
log_message "=== Onboarding completed ==="
echo -e "\n${GREEN}=== Summary ===${NC}"
echo "Shared group: $SHARED_GROUP"
echo "Project directory: $PROJECT_DIR"
echo -e "Permissions on project directory:"
ls -ld "$PROJECT_DIR"
echo -e "\nGroup members:"
getent group "$SHARED_GROUP"
echo -e "\n${YELLOW}Important: Users must change password on first login${NC}"
echo -e "Credentials backed up to: $BACKUP_DIR/user_credentials.txt"
echo -e "\n${GREEN}Onboarding completed successfully!${NC}"
