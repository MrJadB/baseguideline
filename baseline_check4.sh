#!/bin/bash

# Set the output file for configuration data
output_file="configsave.txt"

# Capture the current date and time
current_date_time=$(date +"%Y-%m-%d %H:%M:%S")

# Capture system information
system_info=$(uname -a)

# Start the configuration data extraction process
echo "===============================================================================" >> $output_file
echo "Configuration Data Extraction Script" >> $output_file
echo "Date and Time: $current_date_time" >> $output_file
echo "System Information: $system_info" >> $output_file
echo "===============================================================================" >> $output_file

# Extract and save data from each file in list A
for file in "/etc/login.defs" "/etc/pam.d/system-auth" "/etc/security/pwquality.conf" "/etc/securetty" "/etc/security/faillock.conf" "/etc/passwd" "/etc/group" /etc/rsyslog.conf /etc/profile /var/log/secure /etc/syslog.conf /var/log/wtmp /etc/rsyslog.conf; do
    # Start a new section for each file
    echo "===============================================================================" >> $output_file
    echo "File: $file" >> $output_file
    echo "===============================================================================" >> $output_file

    # Extract and save file content
    cat $file >> $output_file

    # Check for pam files with .so extension
    if [ -f "$file" ]; then
        # Extract pam file names and file extensions
        pam_files=$(grep -oP 'pam_\K[^\s]+"' $file)

        # Process each pam file
        for pam_file in $pam_files; do
            # Check if the pam file has a .so extension
            if [[ $pam_file =~ .*\.so$ ]]; then
                # Extract the pam file name without extension
                pam_file_name=${pam_file%%.so}

                # Check if the pam file exists
                if [ -f "$pam_file_name.so" ]; then
                    # Extract and save pam file content
                    echo "===============================================================================" >> $output_file
                    echo "PAM File: $pam_file_name.so" >> $output_file
                    echo "===============================================================================" >> $output_file

                    nm -D $pam_file_name.so >> $output_file
                fi
            fi
        done
    fi
done

echo "===============================================================================" >> $output_file
echo "Configuration Data Extraction Completed" >> $output_file
echo "===============================================================================" >> $output_file
