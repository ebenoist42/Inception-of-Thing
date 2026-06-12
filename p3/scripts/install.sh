#!/bin/bash
set -e

# Docker
command -v docker >/dev/null || curl -fsSL https://get.docker.com | sh

# kubectl
command -v kubectl >/dev/null || {
  curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl
}

# k3d
command -v k3d >/dev/null || curl -sL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Cluster + namespaces + Argo CD
k3d cluster create iot
kubectl create namespace argocd
kubectl create namespace dev
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd wait --for=condition=available --timeout=600s deployment/argocd-server
kubectl apply -f confs/application.yaml
echo "Done."
