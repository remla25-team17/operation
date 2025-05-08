hello :)

this assignment is using vagrant and ansible.
in the vagrantfile we define the number of worker nodes. 
there is also one controller node.

to initially create the vms and provision them with ansible we create a ssh key pair and copy the public key to the authorized_keys file of the vagrant user.

to generate the key:

```bash
./generate_key.bash
```

in case of "permission denied" error, run:

```bash
chmod +x generate_key.bash
```

once we have this key pair, we can copy it to a linux filesystem (this is needed for people that use wsl on windows but does not affect linux users). from there we can use posix file permissions to the private key. This is needed because ansible refuses to use the key pair if the permissions are not set correctly. once that is set, we can run vagrant up. This starts the vms in order and provisions them once created. provisioning is done by ansible playbooks which are defined in the ctrl.yml, the general.yml and the node.yml files. In these files we define tasks to be done in the nodes. These are things like copying ssh keys, installing software, etc. 

to do all of this, you can run the run.bash script after you have generated the key pair with the previous command.


```bash
./run.bash
```

again, in case of "permission denied" error, run:

```bash
chmod +x run.bash
```

After changing ansible playbooks, you can run "vagrant provision" to apply the changes to the vms.
If you however change the vagrantfile and you change something else than the something.vm.provision, then you have to destroy the vms and run the run.bash script or run "vagrant up" again.

Since for destroying we need to confirm destroying each vm, we have a destroy.bash that forces the destruction of all the VMs without confirmation.

```bash
./destroy.bash
```
