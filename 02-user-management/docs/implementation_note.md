# User Management Automation - Implementation Notes

## Project Overview
This script automates the onboarding of new developers in a Linux environment, mimicking real-world IT support tasks.

## Key Features
1. **CSV-based user creation**: Reads from HR-provided CSV files
2. **Secure password generation**: Uses OpenSSL for random passwords
3. **Shared group management**: Creates collaboration groups automatically
4. **Project directory setup**: Configures shared directories with proper permissions
5. **Security best practices**: Forces password change on first login
6. **Comprehensive logging**: Tracks all actions for audit purposes

## Technical Details

### Important Concepts Demonstrated:
1. **SETGID Bit (2775 permissions)**: 
   - Ensures new files in the shared directory inherit the group ownership
   - Critical for collaborative environments

2. **Password Security**:
   - `chage -d 0`: Forces password change on first login
   - Random password generation using OpenSSL

3. **Useradd Options**:
   - `-m`: Create home directory
   - `-c`: Comment field (stores full name)
   - `-s`: Default shell
   - `-G`: Supplementary groups

4. **Error Handling**:
   - Checks for existing users
   - Validates CSV file existence
   - Requires root privileges


