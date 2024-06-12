#!/bin/bash

# Define the output file
OUTPUT_FILE="configsave.txt"

# Function to append a section header to the output file
append_header() {
    echo "============================================================" >> $OUTPUT_FILE
    echo "$1" >> $OUTPUT_FILE
    echo "============================================================" >> $OUTPUT_FILE
}

# Function to append the contents of a file to the output file
append_file_contents() {
    local file_path="$1"
    local file_name="$2"

    append_header "Contents of $file_name"
    if [ -f "$file_path" ]; then
        cat "$file_path" >> $OUTPUT_FILE
        echo "" >> $OUTPUT_FILE
    else
        echo "File not found: $file_path" >> $OUTPUT_FILE
    fi
}

# Function to append the output of nm -D for a .so file to the output file
append_nm_output() {
    local file_path="$1"
    local file_name="$2"

    append_header "nm -D output of $file_name"
    if [ -f "$file_path" ]; then
        nm -D "$file_path" >> $OUTPUT_FILE
        echo "" >> $OUTPUT_FILE
    else
        echo "File not found: $file_path" >> $OUTPUT_FILE
    fi
}

# Start the script by recording the current date and time
echo "Script started on: $(date)" > $OUTPUT_FILE

# Append system information
append_header "System Information"
uname -a >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Define the list of configuration files to save
CONFIG_FILES=(
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

# Array to store .so files
sofile=()

# Loop through the list and save the contents of each file
for config_file in "${CONFIG_FILES[@]}"; do
    append_file_contents "$config_file" "$config_file"

    # Check for references to .so files and include their contents as well
    if [ -f "$config_file" ]; then
        so_files=$(grep -oP "/[^ ]*\.so" "$config_file")
        for so_file in $so_files; do
            sofile+=("$so_file")
        done
    fi
done

# Append .so filenames and their contents to the output file
for so_file in "${sofile[@]}"; do
    append_header "Contents of $so_file"
    append_nm_output "$so_file" "$so_file"
done

echo "Script finished. Configuration saved to $OUTPUT_FILE"
