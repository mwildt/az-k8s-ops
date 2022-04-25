#/bin/bash

# ssh -i ./.ssh/mwtest-single-vm_id_rsa mwtestuser@20.113.163.189 /bin/bash -s -- < cluster/kubernetes-join-cluster.sh

token=$(kubeadm token create)
caCertHash=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')

echo "kubeadm join 10.4.0.4:6443 \
--token $token \
--discovery-token-ca-cert-hash sha256:$caCertHash"

# alternativ

# kubeadm token create --print-join-command