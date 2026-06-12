
# verifier si deux vm tourne bien / voir les ip / les deux noeuds sont dans le meme cluster :

vagrant ssh ebenoistS -c "sudo kubectl get nodes -o wide"


# teste des ssh (pas de mdp requis):

vagrant ssh ebenoistS

ou 

vagrant ssh ebenoistSW

exit

# Check utilisation K3s sur les machine :

vagrant ssh ebenoistS -c "k3s --version"
vagrant ssh ebenoistS -c "sudo systemctl is-active k3s"          # active (mode server)
vagrant ssh ebenoistSW -c "sudo systemctl is-active k3s-agent"   # active (mode agent)

# down les deux vm : 

vagrant halt
vagrant destroy -f

# Tue les processus VirtualBox bloqués
pkill -f VBoxSVC 2>/dev/null
sleep 3

# Nettoie les VM inaccessibles
for uuid in $(VBoxManage list vms | grep inaccessible | grep -oE '\{[a-f0-9-]+\}' | tr -d '{}'); do
  VBoxManage unregistervm "$uuid" 2>/dev/null
done
VBoxManage list vms

# supprimer les log des box
find ~ -maxdepth 4 -name "*VBoxHeadless*" -delete 2>/dev/null
find ~ -maxdepth 4 -name "*VirtualBoxVM*" -delete 2>/dev/null


# 