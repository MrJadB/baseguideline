#!/bin/bash

# Output file
outputFile="configsave.txt"

# Function to write section headers
write_section_header() {
    echo "=================================================" >> "$outputFile"
    echo "$1" >> "$outputFile"
    echo "=================================================" >> "$outputFile"
}

# Write current date and time
write_section_header "Current Date and Time"
date >> "$outputFile"

# Write system information
write_section_header "System Information"
uname -a >> "$outputFile"

# List of config files to check
configFiles=(
    "/etc/login.defs"
    "/etc/pam.d/system-auth"
    "/etc/security/pwquality.conf"
    "/etc/securetty"
    "/etc/security/faillock.conf"
    "/etc/passwd"
    "/etc/group"
    "/etc/rsyslog.conf"
    "/etc/profile"
    "/var/log/secure"
    "/etc/syslog.conf"
    "/var/log/wtmp"
    "/etc/ssh/sshd_config"
    "/etc/firewalld/firewalld.conf"
    "/etc/audit/auditd.conf"
)

# Process each config file
for file in "${configFiles[@]}"; do
    if [ -f "$file" ]; then
        write_section_header "Contents of $file"
        cat "$file" >> "$outputFile"
    else
        echo "File $file not found." >> "$outputFile"
    fi
done

# Check the status of firewalld service
write_section_header "Firewalld Service Status"
systemctl status firewalld >> "$outputFile"

# Check the status of sshd service
write_section_header "SSHD Service Status"
systemctl status sshd >> "$outputFile"

# Check for updates and patches
write_section_header "Available Updates and Patches"
yum check-update >> "$outputFile"

# Check for audit logs
write_section_header "Audit Logs"
ausearch --start recent --success yes --interpret >> "$outputFile"

# Array to collect .so files found in the config files
soFiles=()

# Find .so files mentioned in /etc/pam.d/system-auth
if [ -f "/etc/pam.d/system-auth" ]; then
    while IFS= read -r line; do
        if [[ "$line" == *".so"* ]]; then
            soFile=$(echo "$line" | grep -oP '(\s|\t|^)(\S+\.so\S*)' | tr -d ' ')
            if [ -n "$soFile" ]; then
                soFiles+=("$soFile")
            fi
        fi
    done < "/etc/pam.d/system-auth"
fi

# Remove duplicates from soFiles array
soFiles=($(echo "${soFiles[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Process each .so file at the end
write_section_header "Shared Object Files (.so) Contents"
for soFile in "${soFiles[@]}"; do
    if [ -f "$soFile" ]; then
        write_section_header "Strings from $soFile"
        strings "$soFile" | grep '/' >> "$outputFile"
    else
        echo "Shared object file $soFile not found." >> "$outputFile"
    fi
done
