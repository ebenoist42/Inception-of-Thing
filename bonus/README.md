# Inception of Things — Bonus (GitLab)

Adds a local GitLab to the Part 3 lab. Argo CD deploys from this local GitLab
instead of GitHub.

> **Heavy.** GitLab needs ~6-8 GB RAM. Bump your VM before running.

---

## 1. Install GitLab

```sh
cd bonus
bash scripts/install.sh
```

Watch the pods come up (takes 5-10 min, many pods):

```sh
kubectl get pods -n gitlab -w
```

Wait until webservice, gitaly, postgresql, redis, sidekiq are all Running.

---

## 2. Get the root password

```sh
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab \
  -ojsonpath='{.data.password}' | base64 -d; echo
```

---

## 3. Access GitLab UI

```sh
kubectl port-forward -n gitlab svc/gitlab-webservice-default 8181:8181 &
# Open http://localhost:8181  (user: root)
```

---

## 4. Create the repo in GitLab and push your config

In the GitLab UI, create a public project named `iot-gitops` under `root`.
Then push the same deployment.yaml used in Part 3:

```sh
cd ~/iot-gitops
git remote add gitlab http://root:<PASSWORD>@localhost:8181/root/iot-gitops.git
git push gitlab main
```

---

## 5. Point Argo CD to local GitLab

```sh
# Remove the GitHub-based Application from Part 3
kubectl delete -f ../p3/confs/application.yaml

# Apply the GitLab-based Application
kubectl apply -f confs/application.yaml
```

---

## 6. Verify everything from Part 3 still works

```sh
kubectl get ns                       # argocd, dev, gitlab all Active
kubectl get pods -n dev              # playground pod Running
kubectl port-forward -n dev svc/playground 8888:8888 &
curl http://localhost:8888/          # {"message": "v1"}
```

Then change v1 -> v2 in the GitLab repo, push, and confirm Argo CD redeploys:

```sh
sed -i 's/playground:v1/playground:v2/' deployment.yaml
git commit -am "v2"
git push gitlab main
# wait for sync
curl http://localhost:8888/          # {"message": "v2"}
```

---

## Layout

```
bonus/
|-- scripts/
|   `-- install.sh        # Helm + GitLab install + namespace gitlab
`-- confs/
    |-- values.yaml       # trimmed GitLab config for single-node
    `-- application.yaml  # Argo CD Application pointing to local GitLab
```
