# Inception of Things — Part 3

K3d + Argo CD GitOps pipeline. No Vagrant. Requires Docker.

---

## Setup

```sh
sudo bash scripts/install.sh
```

This installs kubectl, k3d, creates the cluster, namespaces, Argo CD, and applies the Application.

If Docker is already installed and the cluster already exists, skip to **Usage**.

---

## Manual setup (step by step)

```sh
# Install kubectl
sudo curl -sLo /usr/local/bin/kubectl \
  "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x /usr/local/bin/kubectl

# Install k3d
sudo curl -sLo /usr/local/bin/k3d \
  "https://github.com/k3d-io/k3d/releases/latest/download/k3d-linux-amd64"
sudo chmod +x /usr/local/bin/k3d

# Create cluster
k3d cluster create iot

# Create namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Install Argo CD
kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
kubectl -n argocd wait --for=condition=available --timeout=600s deployment/argocd-server

# Apply the Application (points to GitHub repo)
kubectl apply -f confs/application.yaml
```

---

## Usage

```sh
# Check namespaces (argocd + dev must be Active)
kubectl get ns

# Check Argo CD pods
kubectl get pods -n argocd

# Check deployed app in dev namespace
kubectl get pods -n dev

# Test the running version
kubectl port-forward -n dev svc/playground 8888:8888 &
sleep 2
curl http://localhost:8888/
# Expected: {"status":"ok", "message": "v1"}
```

---

## Update version (v1 → v2)

```sh
cd ~/iot-gitops
sed -i 's/playground:v1/playground:v2/' deployment.yaml
git commit -am "v2"
git push
```

Wait ~30 seconds for Argo CD to sync, then:

```sh
curl http://localhost:8888/
# Expected: {"status":"ok", "message": "v2"}
```

To roll back to v1:

```sh
sed -i 's/playground:v2/playground:v1/' deployment.yaml
git commit -am "v1"
git push
```

---

## Argo CD UI (optional)

```sh
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo

# Forward UI to localhost:8080
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
# Open https://localhost:8080 in browser (login: admin)
```

---

## Teardown

```sh
# Delete cluster (removes all k3d containers)
k3d cluster delete iot

# List remaining docker containers
docker ps
```

---

## Layout

```
p3/
|-- scripts/
|   `-- install.sh       # installs everything and sets up the cluster
`-- confs/
    `-- application.yaml # Argo CD Application pointing to GitHub repo
```

GitHub repo (watched by Argo CD): https://github.com/ebenoist42/iot-gitops
