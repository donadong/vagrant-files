#!/bin/bash

# Setup salt repository
echo "[TASK 1] Setup salt repository"
wget -O - https://repo.saltstack.com/py3/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
cat <<EOF >/etc/apt/sources.list.d/saltstack.list
deb http://repo.saltstack.com/py3/ubuntu/18.04/amd64/latest bionic main
EOF
apt update

# Install salt minion
echo "[TASK 2] Install salt minion"
apt install salt-minion -y
systemctl enable salt-minion
systemctl start salt-minion

# Edit salt master config file
echo "[TASK 3] Edit salt minion config file"
sed -i 's/^#master: salt/master: 192.168.1.160/' /etc/salt/minion

# Restart salt minion service
echo "[TASK 4] Restart salt minion service"
sudo /etc/init.d/salt-minion restart
