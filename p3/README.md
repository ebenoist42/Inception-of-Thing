# Setup

sudo bash scripts/install.sh

# Usage

# Check namespaces (argocd + dev must be Active)
kubectl get ns

# Check Argo CD pods
kubectl get pods -n argocd

# Check deployed app in dev namespace
kubectl get pods -n dev


# Argo CD installé + accessible navigateur (login/password)
# mot de passe admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
# accès UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
(https://localhost:8080, login admin + le mot de passe affiché)

# Image Docker utilisée dans le repo GitHub
cat ~/iot-gitops/deployment.yaml | grep image

# Test the running version
kubectl port-forward -n dev svc/playground 8888:8888 &
sleep 2
curl http://localhost:8888/
# Expected: {"status":"ok", "message": "v1"}


# Update version (v1 → v2)

cd ~/iot-gitops
sed -i 's/playground:v1/playground:v2/' deployment.yaml
git commit -am "v2"
git push

Wait ~30 seconds for Argo CD to sync, then:


curl http://localhost:8888/
# Expected: {"status":"ok", "message": "v2"}

# To roll back to v1:

sed -i 's/playground:v2/playground:v1/' deployment.yaml
git commit -am "v1"
git push

curl http://localhost:8888/
# Expected: {"status":"ok", "message": "v1"}

# Teardown

# Delete cluster (removes all k3d containers)
k3d cluster delete iot

# check les docker existant

docker ps


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

GitHub repo (watched by Argo CD): https://github.com/ebenoist42/iot-gitops
