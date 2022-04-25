#ssh -i ././.ssh/mw-ops-cluster-RG_id_rsa mw-ops-cluster-admin@20.113.83.29 \
#   bash -s -- < ./scripts/disc-config 0 /data

#ssh -i ././.ssh/mw-ops-cluster-RG_id_rsa mw-ops-cluster-admin@20.113.83.29 \
#   bash -s -- < ./scripts/kube-config.sh

#ssh -i ././.ssh/mw-ops-cluster-RG_id_rsa mw-ops-cluster-admin@20.113.83.29 sudo kubeadm init \
#  --apiserver-cert-extra-sans 20.113.83.29 \
#  --pod-network-cidr=192.168.0.0/16"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# scp -i ././.ssh/mw-ops-cluster-RG_id_rsa mw-ops-cluster-admin@20.113.83.29:.kube/config ~/.kube/config