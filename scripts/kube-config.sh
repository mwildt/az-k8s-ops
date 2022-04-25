#!/bin/bash
echo "[INFO] prepare" 
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# install containerd.io

echo "[INFO] prepare containerd" 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

echo "[INFO] sudo apt-get install -y containerd.io" 
sudo apt-get install -y containerd.io

# Configure containerd and start service 
# https://computingforgeeks.com/deploy-kubernetes-cluster-on-ubuntu-with-kubeadm/
sudo su -
mkdir -p /etc/containerd
containerd config default>/etc/containerd/config.toml

# restart containerd
echo "[INFO] restart & enable containerd" 
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status containerd

# wait for containerd to be startetd
until pids=$(pidof containerd)
do   
    sleep 1
done

# install kubernetes tooling
echo "[INFO] prepare kubernetes" 
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

echo "[INFO] sudo apt-get install -y kubelet kubeadm kubectl" 
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# den hostnamen konfigurieren
echo "[INFO] set hostname" 
sudo hostnamectl set-hostname kubemaster
## und den namen auch in die ip-tabelle eintragen
IP_ADR=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo "$IP_ADR kubemaster" | sudo tee -a /etc/hosts > /dev/null

## disable swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
echo "[RUN] sudo sysctl --system" 
sudo sysctl --system

#echo "[RUN] sudo kubeadm init, see ./var/logs/logs/kubeadm-init.logs" 
#sudo kubeadm init --apiserver-cert-extra-sans 20.113.178.234 | sudo tee -a /var/logs/kubeadm-init.logs



