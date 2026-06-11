#!/bin/bash
set -e

BIN=/goinfre/$USER/bin
mkdir -p $BIN
export PATH=$BIN:$PATH

# kubectl
curl -sLo $BIN/kubectl "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x $BIN/kubectl

# k3d
curl -sLo $BIN/k3d "https://github.com/k3d-io/k3d/releases/latest/download/k3d-linux-amd64"
chmod +x $BIN/k3d

# Podman compatibility for k3d
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
systemctl --user start podman.socket 2>/dev/null || true

# Cluster + namespaces + Argo CD
k3d cluster create iot
kubectl create namespace argocd
kubectl create namespace dev
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd wait --for=condition=available --timeout=600s deployment/argocd-server
kubectl apply -f confs/application.yaml
