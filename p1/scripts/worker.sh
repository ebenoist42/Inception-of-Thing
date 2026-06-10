#!/bin/bash
IFACE=$(ip -o -4 addr show | awk '/192.168.56.111/ {print $2}')
curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="$(cat /vagrant/token)" INSTALL_K3S_EXEC="--node-ip=192.168.56.111 --flannel-iface=$IFACE" sh -
