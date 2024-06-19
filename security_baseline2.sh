#!/bin/bash

# Output file
output_file="configsave.txt"

# List of config files
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
    "/etc/rsyslog.conf"
)

# Function to append a header to the output file
append_header() {
    echo "==============================" >> "$output_file"
    echo "$1" >> "$output_file"
    echo "==============================" >> "$output_file"
}

# Function to append content to the output file
append_content() {
    echo "$1" >> "$output_file"
    echo "" >> "$output_file"
}

# Function to extract .so file extensions and store their nm -D output
extract_and_process_so_files() {
    local file_content="$1"
    local so_files=()
    
    # Extract .so file paths
    while IFS= read -r line; do
        if [[ "$line" =~ \.so ]]; then
            so_file=$(echo "$line" | grep -oP '(\s|\t|^)(\S+\.so\S*)' | tr -d ' ')
            so_files+=("$so_file")
        fi
    done <<< "$file_content"

    # Process each .so file
    for so_file in "${so_files[@]}"; do
        find / -name "$so_file" 2>/dev/null | xargs -I {} sh -c '
            echo "#*#* {}" >> "'"$output_file"'"
            nm -D "{}" >> "'"$output_file"'"
        '
    done
}

# Clear previous output file
> "$output_file"

# 1. Add date and time
append_header "Date and Time"
append_content "$(date)"

# 2. Add system information
append_header "System Information"
append_content "$(uname -a)"

# 3. List A (Config files content)
for config_file in "${config_files[@]}"; do
    if [[ -e "$config_file" ]]; then
        append_header "Contents of $config_file"
        file_content=$(cat "$config_file")
        append_content "$file_content"
        extract_and_process_so_files "$file_content"
    else
        append_header "Contents of $config_file"
        append_content "File not found"
    fi
done

echo "Config extraction completed. Results saved in $output_file"
