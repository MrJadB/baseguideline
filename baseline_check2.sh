#!/bin/bash

OUTPUT_FILE="basecheck.txt"
echo "Baseline Configuration Check - Red Hat Linux 9" > $OUTPUT_FILE
echo "=============================================" >> $OUTPUT_FILE

# Function to add a separator
add_separator() {
    echo "-#--#-" >> $OUTPUT_FILE
}

# Function to check file existence before reading
check_file() {
    if [ -f "$1" ]; then
        cat "$1" >> $OUTPUT_FILE
    else
        echo "$1: No such file or directory" >> $OUTPUT_FILE
    fi
}

# Function to check directory existence before finding
check_directory() {
    if [ -d "$1" ]; then
        find "$1" -type f -exec ls -ld {} \; >> $OUTPUT_FILE
    else
        echo "$1: No such directory" >> $OUTPUT_FILE
    fi
}

# 1. SSH Configuration
echo "1. SSH Configuration" >> $OUTPUT_FILE
check_file /etc/ssh/sshd_config
add_separator

# 2. Verify That There are No accounts with Empty Password Fields
echo "2. Verify That There are No accounts with Empty Password Fields" >> $OUTPUT_FILE
awk -F: '($2 == "" ) {print $1 " has an empty password"}' /etc/shadow >> $OUTPUT_FILE
add_separator

# 3. Find Unauthorized SUID/SGID System Executables
echo "3. Find Unauthorized SUID/SGID System Executables" >> $OUTPUT_FILE
find / -perm /6000 -type f -exec ls -ld {} \; >> $OUTPUT_FILE 2>/dev/null
add_separator

# 4. Verify passwd, shadow, and group File Permissions
echo "4. Verify passwd, shadow, and group File Permissions" >> $OUTPUT_FILE
ls -l /etc/passwd /etc/shadow /etc/group >> $OUTPUT_FILE
add_separator

# 5. Verify No Legacy ‘+’ Entries Exist In passwd, shadow, And group Files
echo "5. Verify No Legacy ‘+’ Entries Exist In passwd, shadow, And group Files" >> $OUTPUT_FILE
grep '^\+:' /etc/passwd /etc/shadow /etc/group >> $OUTPUT_FILE
add_separator

# 6. No ‘.’ Or Group/World-Writable Directory in Root’s $PATH
echo "6. No ‘.’ Or Group/World-Writable Directory in Root’s \$PATH" >> $OUTPUT_FILE
echo $PATH | tr ':' '\n' | while read dir; do [ -d "$dir" ] && ls -ld "$dir"; done | grep -E '^.*( drwxrwx| drwxrwxrwx| drwxr-xrwx)' >> $OUTPUT_FILE
add_separator

# 7. No User Dot-Files Should Be World-Writable
echo "7. No User Dot-Files Should Be World-Writable" >> $OUTPUT_FILE
find /home -type f -name '.*' -perm -o=w >> $OUTPUT_FILE
add_separator

# 8. Remove User .netrc Files
echo "8. Remove User .netrc Files" >> $OUTPUT_FILE
find /home -name .netrc >> $OUTPUT_FILE
add_separator

# 9. Set Default umask For Users
echo "9. Set Default umask For Users" >> $OUTPUT_FILE
grep -i umask /etc/profile /etc/bashrc /etc/login.defs /etc/profile.d/* >> $OUTPUT_FILE
add_separator

# 10. Limit Access To The Root Account From su
echo "10. Limit Access To The Root Account From su" >> $OUTPUT_FILE
grep pam_wheel.so /etc/pam.d/su >> $OUTPUT_FILE
add_separator

# 11. Restrict Permissions On crontab files
echo "11. Restrict Permissions On crontab files" >> $OUTPUT_FILE
ls -l /etc/crontab /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly /etc/cron.d /var/spool/cron >> $OUTPUT_FILE
add_separator

# 12. Restrict at/cron To Authorized Users
echo "12. Restrict at/cron To Authorized Users" >> $OUTPUT_FILE
if [ -f /etc/cron.allow ]; then
    cat /etc/cron.allow >> $OUTPUT_FILE
else
    echo "/etc/cron.allow does not exist" >> $OUTPUT_FILE
fi
add_separator

# 13. Restrict Root Logins to System Console
echo "13. Restrict Root Logins to System Console" >> $OUTPUT_FILE
check_file /etc/securetty
add_separator

# 14. Set LILO/GRUB Password
echo "14. Set LILO/GRUB Password" >> $OUTPUT_FILE
check_file /boot/grub2/grub.cfg
add_separator

# 15. Require Authentication for Single-User Mode
echo "15. Require Authentication for Single-User Mode" >> $OUTPUT_FILE
check_file /etc/sysconfig/init
add_separator

# 16. Add 'nodev' Option To Appropriate Partitions In /etc/fstab
echo "16. Add 'nodev' Option To Appropriate Partitions In /etc/fstab" >> $OUTPUT_FILE
grep nodev /etc/fstab >> $OUTPUT_FILE
add_separator

# 17. Add 'nosuid' and 'nodev' Option For Removable Media In /etc/fstab
echo "17. Add 'nosuid' and 'nodev' Option For Removable Media In /etc/fstab" >> $OUTPUT_FILE
grep nosuid /etc/fstab >> $OUTPUT_FILE
grep nodev /etc/fstab >> $OUTPUT_FILE
add_separator

# 18. World-Writable Directories Should Have Their Sticky Bit Set
echo "18. World-Writable Directories Should Have Their Sticky Bit Set" >> $OUTPUT_FILE
find / -perm -1000 -type d -print >> $OUTPUT_FILE 2>/dev/null
add_separator

# 19. Find All Unowned Files
echo "19. Find All Unowned Files" >> $OUTPUT_FILE
find / -nouser -o -nogroup >> $OUTPUT_FILE 2>/dev/null
add_separator

# 20. World-Writable Directories Should Have Their Sticky Bit Set
echo "20. World-Writable Directories Should Have Their Sticky Bit Set" >> $OUTPUT_FILE
find / -perm -1000 -type d -print >> $OUTPUT_FILE 2>/dev/null
add_separator

# 21. Disable core dumps
echo "21. Disable core dumps" >> $OUTPUT_FILE
check_file /etc/security/limits.d/*
add_separator

# 22. Disable Standard Services
echo "22. Disable Standard Services" >> $OUTPUT_FILE
systemctl list-unit-files | grep enabled >> $OUTPUT_FILE
add_separator

# 23. Configure iptables
echo "23. Configure iptables" >> $OUTPUT_FILE
iptables -L >> $OUTPUT_FILE
add_separator

# 24. Only Enable telnet If Absolutely Necessary
echo "24. Only Enable telnet If Absolutely Necessary" >> $OUTPUT_FILE
systemctl status telnet.socket &>/dev/null && systemctl is-enabled telnet.socket >> $OUTPUT_FILE || echo "telnet.socket does not exist" >> $OUTPUT_FILE
add_separator

# 25. Only Enable ftp If Absolutely Necessary
echo "25. Only Enable ftp If Absolutely Necessary" >> $OUTPUT_FILE
systemctl status vsftpd.service &>/dev/null && systemctl is-enabled vsftpd.service >> $OUTPUT_FILE || echo "vsftpd.service does not exist" >> $OUTPUT_FILE
add_separator

# 26. Only Enable rlogin/rsh/rcp If Absolutely Necessary
echo "26. Only Enable rlogin/rsh/rcp If Absolutely Necessary" >> $OUTPUT_FILE
for service in rsh.socket rlogin.socket rexec.socket; do
    systemctl status $service &>/dev/null && systemctl is-enabled $service >> $OUTPUT_FILE || echo "$service does not exist" >> $OUTPUT_FILE
done
add_separator

# 27. Only Enable TFTP Server if Absolutely Necessary
echo "27. Only Enable TFTP Server if Absolutely Necessary" >> $OUTPUT_FILE
systemctl status tftp.socket &>/dev/null && systemctl is-enabled tftp.socket >> $OUTPUT_FILE || echo "tftp.socket does not exist" >> $OUTPUT_FILE
add_separator

# 28. Only Enable IMAP if Absolutely Necessary
echo "28. Only Enable IMAP if Absolutely Necessary" >> $OUTPUT_FILE
systemctl status dovecot.service &>/dev/null && systemctl is-enabled dovecot.service >> $OUTPUT_FILE || echo "dovecot.service does not exist" >> $OUTPUT_FILE
add_separator

# 29. Only Enable POP if Absolutely Necessary
echo "29. Only Enable POP if Absolutely Necessary" >> $OUTPUT_FILE
systemctl status dovecot.service &>/dev/null && systemctl is-enabled dovecot.service >> $OUTPUT_FILE || echo "dovecot.service does not exist" >> $OUTPUT_FILE
add_separator

# 30. Only Enable SQUID Caching Server if Absolutely Necessary
echo "30. Only Enable SQUID Caching Server if Absolutely Necessary" >> $OUTPUT_FILE
systemctl status squid.service &>/dev/null && systemctl is-enabled squid.service >> $OUTPUT_FILE || echo "squid.service does not exist" >> $OUTPUT_FILE
add_separator

# 31. Only Enable Kudzu Hardware Detection if Absolutely Necessary
echo "31. Only Enable Kudzu Hardware Detection if Absolutely Necessary" >> $OUTPUT_FILE
systemctl status kudzu.service &>/dev/null && systemctl is-enabled kudzu.service >> $OUTPUT_FILE || echo "kudzu.service does not exist" >> $OUTPUT_FILE
add_separator

# 32. Create ftpusers Files
echo "32. Create ftpusers Files" >> $OUTPUT_FILE
check_file /etc/ftpusers
add_separator

# 33. Remove .rhosts Support In PAM Configuration Files
echo "33. Remove .rhosts Support In PAM Configuration Files" >> $OUTPUT_FILE
grep -r "pam_rhosts_auth" /etc/pam.d/ >> $OUTPUT_FILE
add_separator

# 34. User Home Directories Should Be Mode 750 or More Restrictive
echo "34. User Home Directories Should Be Mode 750 or More Restrictive" >> $OUTPUT_FILE
find /home -maxdepth 1 -type d ! -perm 750 >> $OUTPUT_FILE
add_separator

# 35. Disable xinetd, If Possible
echo "35. Disable xinetd, If Possible" >> $OUTPUT_FILE
systemctl is-enabled xinetd &>/dev/null || echo "xinetd is not enabled" >> $OUTPUT_FILE
add_separator

# 36. Disable sendmail Server, If Possible
echo "36. Disable sendmail Server, If Possible" >> $OUTPUT_FILE
systemctl is-enabled sendmail &>/dev/null || echo "sendmail is not enabled" >> $OUTPUT_FILE
add_separator

# 37. Disable GUI Login
echo "37. Disable GUI Login" >> $OUTPUT_FILE
systemctl get-default >> $OUTPUT_FILE
add_separator

# 38. Disable X Font Server
echo "38. Disable X Font Server" >> $OUTPUT_FILE
systemctl is-enabled xfs &>/dev/null || echo "xfs is not enabled" >> $OUTPUT_FILE
add_separator

# 39. Disable Standard Boot Services
echo "39. Disable Standard Boot Services" >> $OUTPUT_FILE
systemctl list-unit-files --type=service | grep enabled >> $OUTPUT_FILE
add_separator

# 40. Network Parameter Modifications
echo "40. Network Parameter Modifications" >> $OUTPUT_FILE
sysctl -a | grep net.ipv4 >> $OUTPUT_FILE
add_separator

# 41. Additional Network Parameter Modifications
echo "41. Additional Network Parameter Modifications" >> $OUTPUT_FILE
sysctl -a | grep net.ipv6 >> $OUTPUT_FILE
add_separator

# 42. Disable User-Mounted Removable File Systems
echo "42. Disable User-Mounted Removable File Systems" >> $OUTPUT_FILE
grep nodev /etc/fstab | grep noexec | grep nosuid >> $OUTPUT_FILE
add_separator

# 43. Only Enable NFS Server Processes If Absolutely Necessary
echo "43. Only Enable NFS Server Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled nfs-server &>/dev/null || echo "nfs-server is not enabled" >> $OUTPUT_FILE
add_separator

# 44. Only Enable NFS Client Processes If Absolutely Necessary
echo "44. Only Enable NFS Client Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled nfs-client.target &>/dev/null || echo "nfs-client is not enabled" >> $OUTPUT_FILE
add_separator

# 45. Only Enable NIS Client Processes If Absolutely Necessary
echo "45. Only Enable NIS Client Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled ypbind &>/dev/null || echo "ypbind is not enabled" >> $OUTPUT_FILE
add_separator

# 46. Only Enable NIS Server Processes If Absolutely Necessary
echo "46. Only Enable NIS Server Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled ypserv &>/dev/null || echo "ypserv is not enabled" >> $OUTPUT_FILE
add_separator

# 47. Only Enable RPC Portmap Processes If Absolutely Necessary
echo "47. Only Enable RPC Portmap Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled rpcbind &>/dev/null || echo "rpcbind is not enabled" >> $OUTPUT_FILE
add_separator

# 48. Only Enable netfs Script If Absolutely Necessary
echo "48. Only Enable netfs Script If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled netfs &>/dev/null || echo "netfs is not enabled" >> $OUTPUT_FILE
add_separator

# 49. Only Enable Printer Daemon Processes If Absolutely Necessary
echo "49. Only Enable Printer Daemon Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled cups &>/dev/null || echo "cups is not enabled" >> $OUTPUT_FILE
add_separator

# 50. Only Enable Web Server Processes If Absolutely Necessary
echo "50. Only Enable Web Server Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled httpd &>/dev/null || echo "httpd is not enabled" >> $OUTPUT_FILE
add_separator

# 51. Only Enable SNMP Processes If Absolutely Necessary
echo "51. Only Enable SNMP Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled snmpd &>/dev/null || echo "snmpd is not enabled" >> $OUTPUT_FILE
add_separator

# 52. Only Enable DNS Processes If Absolutely Necessary
echo "52. Only Enable DNS Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled named &>/dev/null || echo "named is not enabled" >> $OUTPUT_FILE
add_separator

# 53. Only Enable SQL Server Processes If Absolutely Necessary
echo "53. Only Enable SQL Server Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled mysqld &>/dev/null || echo "mysqld is not enabled" >> $OUTPUT_FILE
add_separator

# 54. Only Enable Webmin Processes If Absolutely Necessary
echo "54. Only Enable Webmin Processes If Absolutely Necessary" >> $OUTPUT_FILE
systemctl is-enabled webmin &>/dev/null || echo "webmin is not enabled" >> $OUTPUT_FILE
add_separator

# 55. Restrict NFS Client Requests to Privileged Ports
echo "55. Restrict NFS Client Requests to Privileged Ports" >> $OUTPUT_FILE
check_file /etc/sysconfig/nfs
add_separator

# 56. Only enable syslog to Accept Messages If Absolutely Necessary
echo "56. Only enable syslog to Accept Messages If Absolutely Necessary" >> $OUTPUT_FILE
grep -i "^\*\.\*" /etc/rsyslog.conf >> $OUTPUT_FILE
add_separator

# 57. Set Account Expiration Parameters On Active Accounts
echo "57. Set Account Expiration Parameters On Active Accounts" >> $OUTPUT_FILE
chage -l root >> $OUTPUT_FILE
add_separator

# 58. Prevent X Server From Listening on Port 6000/tcp
echo "58. Prevent X Server From Listening on Port 6000/tcp" >> $OUTPUT_FILE
check_file /etc/X11/xinit/xserverrc
add_separator

# 59. Apply latest OS Patches
echo "59. Apply latest OS Patches" >> $OUTPUT_FILE
yum check-update >> $OUTPUT_FILE
add_separator

# 60. Install Zabbix
echo "60. Install Zabbix" >> $OUTPUT_FILE
rpm -qa | grep zabbix >> $OUTPUT_FILE
add_separator

# 61. Install and Run Bastille
echo "61. Install and Run Bastille" >> $OUTPUT_FILE
rpm -qa | grep bastille >> $OUTPUT_FILE
add_separator

# 62. Capture Messages Sent To Syslog AUTHPRIV Facility
echo "62. Capture Messages Sent To Syslog AUTHPRIV Facility" >> $OUTPUT_FILE
grep authpriv /etc/rsyslog.conf >> $OUTPUT_FILE
add_separator

# 63. Turn On Additional Logging For FTP Daemon
echo "63. Turn On Additional Logging For FTP Daemon" >> $OUTPUT_FILE
check_file /etc/vsftpd/vsftpd.conf
add_separator

# 64. Confirm Permissions On System Log Files
echo "64. Confirm Permissions On System Log Files" >> $OUTPUT_FILE
ls -l /var/log >> $OUTPUT_FILE
add_separator

# 65. Install Splunk
echo "65. Install Splunk" >> $OUTPUT_FILE
rpm -qa | grep splunk >> $OUTPUT_FILE
add_separator

echo "Baseline Configuration Check Completed" >> $OUTPUT_FILE
