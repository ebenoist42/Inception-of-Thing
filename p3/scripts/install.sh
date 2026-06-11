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
set -e

echo "Updating..."
sudo apt update

echo "Installing dependencies..."
sudo apt install -y curl wget git

echo "Installing k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "Installing ArgoCD CLI..."
curl -sSL -o argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

chmod +x argocd
sudo mv argocd /usr/local/bin/

echo "Versions:"
docker --version
k3d version
kubectl version --client
argocd version --client

echo "Done."
