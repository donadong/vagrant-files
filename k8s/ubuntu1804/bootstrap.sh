#!/bin/bash

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.42.42.100 kmaster.example.com kmaster
172.42.42.101 kworker1.example.com kworker1
172.42.42.102 kworker2.example.com kworker2
EOF

# Install docker from Docker-ce repository
echo "[TASK 2] Install docker container engine"
apt update -y
apt install ca-certificates software-properties-common apt-transport-https curl -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"

# Install docker ce (latest supported for K8s 1.13 is Docker 18.06)
apt-get update && apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)

# Setup daemon parameters, like log rotation and cgroups
tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Enable docker service
echo "[TASK 3] Enable and start docker service"
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

# Disable SELinux
echo "[TASK 4] SKIP - Disable SELinux"
# setenforce 0
# sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# Stop and disable firewalld
echo "[TASK 5] Stop and Disable ufw"
ufw disable

# Add sysctl settings
echo "[TASK 6] Add sysctl settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1

# Disable swap
echo "[TASK 7] Disable and turn off SWAP"
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo "vm.swappiness=0" | sudo tee --append /etc/sysctl.conf
sysctl -p
swapoff -a

# Install Kubernetes
echo "[TASK 9] Install Kubernetes (kubeadm, kubelet and kubectl)"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt update 
apt upgrade -y
apt install -y -q kubeadm=1.18.0-00 kubelet=1.18.0-00 kubectl=1.18.0-00 >/dev/null 2>&1
apt-mark hold kubeadm kubectl kubelet

# Start and Enable kubelet service
echo "[TASK 10] Enable and start kubelet service"
systemctl enable kubelet >/dev/null 2>&1
systemctl start kubelet >/dev/null 2>&1

echo "[TASK 11] Add vagrant user to sudoers"
cat >>/etc/sudoers<<EOF
vagrant ALL=(ALL) NOPASSWD:ALL
Defaults:vagrant !requiretty
EOF

# Enable ssh password authentication
echo "[TASK 12] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 13] Set root password"
echo "root:kalpana" | sudo chpasswd >/dev/null 2>&1

# Update vagrant user's bashrc file
echo "export TERM=xterm" >> /etc/bashrc
