#!/bin/bash

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.1.160 saltmaster.jmlabs.net saltmaster
192.168.1.161 saltminion1.jmlabs.net saltminion1
192.168.1.162 saltminion2.jmlabs.net saltminion2
EOF

# Update updates repository
echo "[TASK 2] Update updates repository"
apt update -y

# Install figlet
echo "[TASK 3] Install figlet"
apt install figlet -y

# Add vagrant user to sudoers
echo "[TASK 4] Add vagrant user to sudoers"
cat >>/etc/sudoers<<EOF
vagrant ALL=(ALL) NOPASSWD:ALL
Defaults:vagrant !requiretty
EOF

# Edit message of the day
echo "[TASK 5] Edit message of the day"
cat >>/etc/update-motd.d/00-header<<EOF
figlet $(hostname)
printf '\n'
EOF

# Install common tools
echo "[TASK 6] Install htop vim git tmux wget unzip"
apt install htop vim git tmux wget unzip -y
apt update -y
apt upgrade -y
