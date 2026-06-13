SETUP

sh# Tout installer + créer le cluster + namespaces + Argo CD + l'app
bash scripts/install.sh

Le script affiche le mot de passe admin Argo CD à la fin. Note-le.

sh# Vérifier que kubectl pointe bien sur le cluster iot
kubectl config current-context        # attendu : k3d-iot
# si ce n'est pas le cas :
kubectl config use-context k3d-iot


CONFIGURATION 

sh# 1. Infra démarrée : les conteneurs k3d tournent
docker ps                             # k3d-iot-server-0 + k3d-iot-serverlb

# 2. Fichiers de conf présents
ls -R .
cat confs/application.yaml
cat scripts/install.sh

# 3. Les 2 namespaces argocd + dev sont Active
kubectl get ns

# 4. Au moins 1 pod dans dev
kubectl get pods -n dev               # playground-xxxx  Running

# 5. Tous les services Argo CD tournent
kubectl get pods -n argocd            # tous Running

# 6. Argo CD accessible navigateur (login + password)
#    -> dans un AUTRE terminal, laisser tourner :
kubectl port-forward svc/argocd-server -n argocd 8080:443
#    -> mot de passe admin :
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
#    -> navigateur : https://localhost:8080   (login: admin)

# 7. Login dans le nom du repo GitHub
#    -> montrer github.com/ebenoist42/iot-gitops

# 8. Image Docker utilisée dans le repo
cat ~/iot-gitops/deployment.yaml | grep image     # wil42/playground:v1
#    -> montrer hub.docker.com/r/wil42/playground (tags v1 et v2)


USAGE

sh# 1. Naviguer dans l'UI Argo CD et expliquer le fonctionnement

# 2. App v1 accessible via curl
#    -> dans un AUTRE terminal, laisser tourner :
kubectl port-forward -n dev svc/playground 8888:8888
#    -> puis :
curl http://localhost:8888/           # {"status":"ok", "message": "v1"}

# 3. Docker Hub utilisé -> image wil42/playground (montrer le hub)

# 4. Mise à jour v1 -> v2 (commit + push sur GitHub)
cd ~/iot-gitops
sed -i 's/playground:v1/playground:v2/' deployment.yaml
git commit -am "v2"
git push

# 5. Si la synchro auto ne s'est pas faite -> bouton SYNC dans l'UI Argo CD
#    (avec selfHeal+automated, elle se fait seule en ~3 min)

# 6. Vérifier la nouvelle version
curl http://localhost:8888/           # {"status":"ok", "message": "v2"}


ROLLBACK (remettre v1 après la démo)

shcd ~/iot-gitops
sed -i 's/playground:v2/playground:v1/' deployment.yaml
git commit -am "v1"
git push
curl http://localhost:8888/           # {"status":"ok", "message": "v1"}


TEARDOWN

shk3d cluster delete iot
docker ps                             # plus aucun conteneur k3d


À SAVOIR EXPLIQUER (la grille insiste)


Namespace vs Pod : un pod est la plus petite unité exécutable (un ou
plusieurs conteneurs). Un namespace est un cloisonnement logique du cluster
qui regroupe des ressources. argocd isole l'outil, dev isole l'app.
K3s vs K3d : K3s = distribution Kubernetes légère sur la machine.
K3d = K3s lancé dans des conteneurs Docker.
GitOps / Argo CD : Git est la source de vérité. Argo CD surveille le repo
et synchronise le cluster pour qu'il corresponde au contenu du repo. Modifier
le tag dans Git + push -> Argo CD redéploie automatiquement.
Le flux v1->v2 : on change image: wil42/playground:v1 en :v2 dans
deployment.yaml -> push GitHub -> Argo CD détecte le diff -> applique ->
nouveau pod en v2.


