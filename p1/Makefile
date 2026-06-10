.PHONY: up down clean status nodes ssh-server ssh-worker

up:
	vagrant up

down:
	vagrant halt

clean:
	vagrant destroy -f
	rm -f token

status:
	vagrant status

nodes:
	vagrant ssh ebenoistS -c "kubectl get nodes -o wide"

ssh-server:
	vagrant ssh ebenoistS

ssh-worker:
	vagrant ssh ebenoistSW
