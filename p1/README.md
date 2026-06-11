À la fin de cette session (quand P1 marche), sauvegarde le cache Vagrant :

sh# Sauvegarde sur ton disque dur externe
cp -r /goinfre/$USER/.vagrant.d /run/media/ebenoist/Samsung_T5/vagrant_cache



Au début de la prochaine session :

sh# Restore
mkdir -p /goinfre/$USER
cp -r /run/media/ebenoist/Samsung_T5/vagrant_cache /goinfre/$USER/.vagrant.d
export VAGRANT_HOME=/goinfre/$USER/.vagrant.d
VBoxManage setproperty machinefolder /goinfre/$USER/VirtualBox



verifier si deux vm tourne bien :

vagrant ssh ebenoistS -c "sudo kubectl get nodes -o wide"

Pour down les deux vm : 

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