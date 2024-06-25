#!/bin/bash

# วันเวลาที่ทำการบันทึกไฟล์
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# system information
system_info=$(uname -a)

# User Policy
echo "## User Policy" >> passuser.txt
echo "Timestamp: $timestamp" >> passuser.txt
echo "System Information: $system_info" >> passuser.txt
echo "" >> passuser.txt
echo "###  User Account Information" >> passuser.txt

# คัดลอกข้อมูลจาก /etc/passwd 
cat /etc/passwd >> passuser.txt

echo "" >> passuser.txt

# คัดลอกข้อมูลจาก /etc/shadow 
echo "###  User Shadow Information" >> passuser.txt
cat /etc/shadow >> passuser.txt

echo "" >> passuser.txt

# Password Policy 
echo "## Password Policy" >> passuser.txt
echo "" >> passuser.txt

# ตรวจสอบความยาวของรหัสผ่าน
password_min_length=$(grep "PASS_MIN_LEN" /etc/login.defs | awk '{print $2}')
echo "Minimum Password Length: $password_min_length" >> passuser.txt

# ตรวจสอบความซับซ้อนของรหัสผ่าน
password_complexity=$(grep "PASS_COMPLEX" /etc/login.defs | awk '{print $2}')
echo "Password Complexity Requirement: $password_complexity" >> passuser.txt

# ตรวจสอบระยะเวลาหมดอายุของรหัสผ่าน
password_max_age=$(grep "PASS_MAX_AGE" /etc/login.defs | awk '{print $2}')
echo "Maximum Password Age (Days): $password_max_age" >> passuser.txt

# ตรวจสอบระยะเวลาที่ต้องเปลี่ยนรหัสผ่าน
password_warn_age=$(grep "PASS_WARN_AGE" /etc/login.defs | awk '{print $2}')
echo "Password Warning Age (Days): $password_warn_age" >> passuser.txt

# ตรวจสอบจำนวนครั้งที่สามารถพยายามล็อกอินผิดได้
password_inactive_time=$(grep "PASS_INACTIVE_TIME" /etc/login.defs | awk '{print $2}')
echo "Inactive Time (Days): $password_inactive_time" >> passuser.txt

# ตรวจสอบจำนวนครั้งที่สามารถพยายามล็อกอินผิดได้
password_max_tries=$(grep "PASS_MAX_TRIES" /etc/login.defs | awk '{print $2}')
echo "Maximum Login Attempts: $password_max_tries" >> passuser.txt

# ตรวจสอบเวลาที่ล็อกบัญชีหลังจากพยายามล็อกอินผิด
password_lock_time=$(grep "PASS_LOCK_TIME" /etc/login.defs | awk '{print $2}')
echo "Lock Time (Minutes): $password_lock_time" >> passuser.txt

# ตรวจสอบเวลาที่ล็อกบัญชีหลังจากล้มเหลวหลายครั้ง
password_expire_warn=$(grep "PASS_EXPIRE_WARN" /etc/login.defs | awk '{print $2}')
echo "Password Expiration Warning (Days): $password_expire_warn" >> passuser.txt


# บันทึกผลลัพธ์ในไฟล์ passuser.txt
#chmod 644 passuser.txt  # Set permissions for the file

echo "Successfully written to passuser.txt"
