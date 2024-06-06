#!/bin/bash

# Function to append a header to the output file
function append_header {
    echo "==============================" >> passuser.txt
    echo "$1" >> passuser.txt
    echo "==============================" >> passuser.txt
}

# Function to append content to the output file
function append_content {
    echo "$1" >> passuser.txt
    echo "" >> passuser.txt
}

# Clear previous output file
> passuser.txt

# 1. Add date and time
append_header "Date and Time"
append_content "$(date)"

# 2. Add system information
append_header "System Information"
append_content "$(uname -a)"

# 3. User Policy
append_header "User Policy"

# 3.1 List all users
append_content "List of all users:"
append_content "$(cat /etc/passwd)"

# 3.2 Check for root accounts
append_content "Check for root accounts:"
append_content "$(awk -F: '($3 == 0) {print}' /etc/passwd)"

# 3.3 Check for empty password fields
append_content "Check for empty password fields:"
append_content "$(awk -F: '($2 == "") {print}' /etc/shadow)"

# 4. Password Policy
append_header "Password Policy"

# 4.1 Check password minimum length
append_content "Password minimum length:"
append_content "$(grep -E '^PASS_MIN_LEN' /etc/login.defs)"

# 4.2 Check password complexity requirements
append_content "Password complexity requirements:"
append_content "$(grep -E 'pam_pwquality' /etc/pam.d/system-auth)"

# 4.3 Check password expiration policy
append_content "Password expiration policy:"
append_content "$(grep -E '^PASS_MAX_DAYS|^PASS_MIN_DAYS' /etc/login.defs)"

# 4.4 Check password history
append_content "Password history settings:"
append_content "$(grep -E 'remember' /etc/pam.d/system-auth)"

echo "Security baseline check completed. Results saved in passuser.txt"
