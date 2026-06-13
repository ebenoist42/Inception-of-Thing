#!/bin/bash
set -e

if ! command -v docker >/dev/null 2>&1; then
  echo "[+] Installing Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER" || true
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "[+] Installing kubectl..."
  curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
fi

if ! command -v k3d >/dev/null 2>&1; then
  echo "[+] Installing k3d..."
  curl -sL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

if ! k3d cluster list 2>/dev/null | grep -q "^iot"; then
  echo "[+] Creating k3d cluster 'iot'..."
  k3d cluster create iot
fi

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev    --dry-run=client -o yaml | kubectl apply -f -

echo "[+] Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[+] Waiting for Argo CD server..."
kubectl -n argocd wait --for=condition=available --timeout=600s deployment/argocd-server

kubectl apply -f confs/application.yaml

echo ""
echo "[OK] Done."
echo "Argo CD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
