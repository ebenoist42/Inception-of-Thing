#!/bin/bash
IFACE=$(ip -o -4 addr show | awk '/192.168.56.110/ {print $2}')
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --flannel-iface=$IFACE --write-kubeconfig-mode=644" sh -
cp /var/lib/rancher/k3s/server/node-token /vagrant/token
