#!/bin/bash

output_file="configsave.txt"

# Function to log the current date and time
log_date() {
    echo "============================================================" >> "$output_file"
    echo "==== Date and Time ====" >> "$output_file"
    date >> "$output_file"
    echo "" >> "$output_file"
}

# Function to log system information
log_system_info() {
    echo "============================================================" >> "$output_file"
    echo "==== System Information ====" >> "$output_file"
    uname -a >> "$output_file"
    echo "" >> "$output_file"
}

# Function to log the contents of a file
log_file_contents() {
    local file_path="$1"
    echo "============================================================" >> "$output_file"
    echo "==== Contents of $file_path ====" >> "$output_file"
    cat "$file_path" | tr -d '\000' >> "$output_file"
    echo "" >> "$output_file"
}

# Function to log the status of firewalld
log_firewalld_status() {
    echo "============================================================" >> "$output_file"
    echo "==== Status of firewalld ====" >> "$output_file"
    systemctl status firewalld >> "$output_file"
    echo "" >> "$output_file"
}

# Function to extract .so files from a file content
extract_so_files() {
    local file_content="$1"
    local so_files=()

    # Extract .so file paths
    while IFS= read -r line; do
        if [[ "$line" =~ \.so ]]; then
            so_file=$(echo "$line" | grep -oP '(\s|\t|^)(\S+\.so\S*)' | tr -d ' ')
            so_files+=("$so_file")
        fi
    done <<< "$file_content"

    echo "${so_files[@]}"
}

# Function to process .so files and log their objdump output
process_and_log_so_files() {
    local so_files=("$@")

    for so_file in "${so_files[@]}"; do
        find / -name "$so_file" 2>/dev/null | while read -r found_file; do
            echo "#*#* $found_file" >> "$output_file"
            strings "$found_file" | grep '/' >> "$output_file"
            echo "" >> "$output_file"
        done
    done
}

# Main script
log_date
log_system_info

config_files=(
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
    "/etc/ssh/sshd_config"  # Added sshd_config to the list
    "/etc/audit/auditd.conf"
)

# Array to collect .so files
collected_so_files=()

for config_file in "${config_files[@]}"; do
    if [[ -f "$config_file" ]]; then
        log_file_contents "$config_file"
        file_content=$(cat "$config_file" | tr -d '\000')  # Remove null bytes from file content
        so_files=($(extract_so_files "$file_content"))
        collected_so_files+=("${so_files[@]}")
    else
        echo "============================================================" >> "$output_file"
        echo "File $config_file does not exist." >> "$output_file"
    fi
done

log_firewalld_status  # Log the status of firewalld at the end

# Process and log .so files at the end
process_and_log_so_files "${collected_so_files[@]}"

echo "Configuration extraction completed. Output saved to $output_file."
