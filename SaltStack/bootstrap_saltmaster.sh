#!/bin/bash

# Clone Git repository
echo "[TASK 1] Clone Git repository"
# git clone

# Setup salt repository
echo "[TASK 2] Setup salt repository"
wget -O - https://repo.saltstack.com/py3/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
cat <<EOF >/etc/apt/sources.list.d/saltstack.list
deb http://repo.saltstack.com/py3/ubuntu/18.04/amd64/latest bionic main
EOF
apt update

# Setup salt repository
echo "[TASK 3] Install salt master"
apt install salt-master salt-cloud -y
systemctl enable salt-master
systemctl start salt-master

# Create folder stucture
echo "[TASK 4] Create folder stucture"
mkdir -p {keys,pillar,reactor,salt,cloud}
mkdir -p salt/{ssh/files,users/files,common}
mkdir -p cloud/{cloud.providers.d,cloud.profiles.d}
touch keys/.keep reactor/.keep

# Copy salt master config file
echo "[TASK 5] Edit salt master config file"
# set the master interface address
sed -i 's/^#interface: 0.0.0.0/interface: 192.168.1.160/' /etc/salt/master
# set the salt master file file roots
sed -i 's/^#file_roots:/file_roots:/' /etc/salt/master
# set the salt master file file roots
sed -i '0,/#  base:/s//  base:/' /etc/salt/master
# set the salt master file file roots
sed -i '0,/#    - \/srv\/salt/s//    - \/srv\/salt/' /etc/salt/master
# set the salt master to automatically accept minion keys
sed -i 's/^#auto_accept: False/auto_accept: True/' /etc/salt/master

# Restart salt master service
echo "[TASK 6] Restart salt master service"
sudo /etc/init.d/salt-master restart

