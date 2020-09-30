#!/bin/bash

# Join worker nodes to the Kubernetes cluster
echo "[TASK 1] Join node to Kubernetes Cluster"
yum install -q -y sshpass >/dev/null 2>&1
sshpass -p "kalpana" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.jmlabs.net:/joincluster.sh /joincluster.sh #2>/dev/null
bash /joincluster.sh #>/dev/null 2>&1
