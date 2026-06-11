Vagrant up


# Affiche tous les objets Kubernetes du namespace
vagrant ssh ebenoistS -c "kubectl get all"

# Affiche les règles de routage HTTP. L'Ingress c'est l'objet Kubernetes qui dit "tel host → tel service". Sans Ingress, tes services existent mais ne sont accessibles que depuis l'intérieur du cluster.
vagrant ssh ebenoistS -c "kubectl get ingress"

# Ce sont les tests fonctionnels qui valident que le routage marche réellement.
vagrant ssh ebenoistS -c "curl -s -H 'Host: app1.com' 192.168.56.110 | grep -i message"
vagrant ssh ebenoistS -c "curl -s -H 'Host: app2.com' 192.168.56.110 | grep -i message"
vagrant ssh ebenoistS -c "curl -s 192.168.56.110 | grep -i message"

# La VM tourne
vagrant status

#  SSH sans mot de passe
vagrant ssh ebenoistS -c "hostname"

#  IP sur l'interface (commande exacte de la grille de correction)
vagrant ssh ebenoistS -c "ip a show \$(ip route | grep default | awk '{print \$5}')"
vagrant ssh ebenoistS -c "ip a | grep 192.168.56.110"

# K3s actif
vagrant ssh ebenoistS -c "sudo systemctl is-active k3s"

# Nœud Kubernetes
vagrant ssh ebenoistS -c "kubectl get nodes -o wide"

# Les 3 apps + Ingress
vagrant ssh ebenoistS -c "kubectl get all"
vagrant ssh ebenoistS -c "kubectl get ingress"

# Tests fonctionnels message par Host
vagrant ssh ebenoistS -c "curl -s -H 'Host: app1.com' 192.168.56.110 | grep -A1 'id=\"message\"' | tail -1"
vagrant ssh ebenoistS -c "curl -s -H 'Host: app2.com' 192.168.56.110 | grep -A1 'id=\"message\"' | tail -1"
vagrant ssh ebenoistS -c "curl -s 192.168.56.110 | grep -A1 'id=\"message\"' | tail -1"



# Pour fermer le projet proprement :
vagrant halt
vagrant destroy -f


#2 Tue les processus VirtualBox bloqués
pkill -f VBoxSVC 2>/dev/null
sleep 3

#3. Nettoie les VM inaccessibles
for uuid in $(VBoxManage list vms | grep inaccessible | grep -oE '\{[a-f0-9-]+\}' | tr -d '{}'); do
  VBoxManage unregistervm "$uuid" 2>/dev/null
done
VBoxManage list vms

#4 supprimer les log des box
find ~ -maxdepth 4 -name "*VBoxHeadless*" -delete 2>/dev/null
find ~ -maxdepth 4 -name "*VirtualBoxVM*" -delete 2>/dev/null