#!/bin/bash
set -e

# Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Namespace
kubectl create namespace gitlab

# GitLab Helm repo
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# Install GitLab (minimal: monitoring/registry/ingress trimmed for a single node)
helm install gitlab gitlab/gitlab -n gitlab \
  -f confs/values.yaml \
  --timeout 600s

echo "GitLab installing. Wait for all pods to be Running:"
echo "  kubectl get pods -n gitlab -w"
