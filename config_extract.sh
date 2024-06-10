#!/bin/bash

# Function to append a header to the output file
function append_header {
    echo "==============================" >> configsave.txt
    echo "$1" >> configsave.txt
    echo "==============================" >> configsave.txt
}

# Function to append content to the output file
function append_content {
    echo "$1" >> configsave.txt
    echo "" >> configsave.txt
}

# Function to append file content to the output file
function append_file_content {
    append_header "$1"
    if [ -f "$2" ]; then
        cat "$2" >> configsave.txt
    else
        echo "File $2 not found" >> configsave.txt
    fi
    echo "" >> configsave.txt
}

# Clear previous output file
> configsave.txt

# 1. Add date and time
append_header "Date and Time"
append_content "$(date)"

# 2. Add system information
append_header "System Information"
append_content "$(uname -a)"

# 3. List A
append_file_content "/etc/login.defs" "/etc/login.defs"
append_file_content "/etc/pam.d/system-auth" "/etc/pam.d/system-auth"
append_file_content "/etc/security/pwquality.conf" "/etc/security/pwquality.conf"
append_file_content "/etc/securetty" "/etc/securetty"
append_file_content "/etc/security/faillock.conf" "/etc/security/faillock.conf"
append_file_content "/etc/passwd" "/etc/passwd"
append_file_content "/etc/group" "/etc/group"
append_file_content "/etc/rsyslog.conf" "/etc/rsyslog.conf"
append_file_content "/etc/profile" "/etc/profile"
append_file_content "/var/log/secure" "/var/log/secure"
append_file_content "/etc/syslog.conf" "/etc/syslog.conf"
append_file_content "/var/log/wtmp" "/var/log/wtmp"
append_file_content "/etc/rsyslog.conf" "/etc/rsyslog.conf"

echo "Config extraction completed. Results saved in configsave.txt"
