#Vagrantfile

CTRL_MEMORY = 4096 #controller memory
CTRL_CPUS = 1 #controller cpus
NODE_MEMORY = 6144 #worker memory
NODE_CPUS = 2 #worker cpus

num_workers = 2

public_key = File.read(File.expand_path(File.join(Dir.home, "vagrant_ssh", "vagrant_id_rsa.pub"))).strip

# Generate inventory.cfg dynamically
hosts = "[ctrl]\n192.168.56.100\n\n[workers]\n"
(1..num_workers).each do |i|
  hosts += "192.168.56.#{100 + i}\n"
end
hosts += "\n[all:children]\nctrl\nworkers\n"

# Write inventory.cfg to file
File.open("provisioning/inventory.cfg", "w") do |file|
  file.write(hosts)
end

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04" #base box

  config.ssh.insert_key = false #disable automatic key insertion

  config.vm.define "ctrl" do |ctrl| #controller vm
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: "192.168.56.100"

    ctrl.vm.provider "virtualbox" do |vb|
      vb.memory = CTRL_MEMORY
      vb.cpus = CTRL_CPUS
    end

    ctrl.vm.provision "shell", privileged: false, inline: <<-SHELL
      mkdir -p /home/vagrant/.ssh
      echo "#{public_key}" >> /home/vagrant/.ssh/authorized_keys
      chmod 700 /home/vagrant/.ssh
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chown -R vagrant:vagrant /home/vagrant/.ssh
    SHELL

    #provisioning ansible
    ctrl.vm.provision "ansible" do |ansible|
      ansible.playbook = "provisioning/general.yml" #playbook
      # ansible.inventory_path = "provisioning/inventory.cfg"
      ansible.extra_vars = {
        ansible_ssh_private_key_file: "~/vagrant_ssh/vagrant_id_rsa", #ssh key to use
        ansible_hosts: hosts,
        num_workers: num_workers
      }
    end

    ctrl.vm.provision "ansible" do |ansible|
      ansible.playbook = "provisioning/ctrl.yml" #playbook
      # ansible.inventory_path = "provisioning/inventory.cfg"
      ansible.extra_vars = {
        ansible_ssh_private_key_file: "~/vagrant_ssh/vagrant_id_rsa" #ssh key to use
      }
    end
  end

  # Define worker nodes
  (1..num_workers).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{100 + i}"

      node.vm.provider "virtualbox" do |vb|
        vb.memory = NODE_MEMORY
        vb.cpus = NODE_CPUS
      end

      node.vm.provision "shell", privileged: false, inline: <<-SHELL
        mkdir -p /home/vagrant/.ssh
        echo "#{public_key}" >> /home/vagrant/.ssh/authorized_keys
        chmod 700 /home/vagrant/.ssh
        chmod 600 /home/vagrant/.ssh/authorized_keys
        chown -R vagrant:vagrant /home/vagrant/.ssh
      SHELL

      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "provisioning/general.yml"
        # ansible.inventory_path = "provisioning/inventory.cfg"
        ansible.extra_vars = {
          ansible_ssh_private_key_file: "~/vagrant_ssh/vagrant_id_rsa", #ssh key to use
          ansible_hosts: hosts,
          num_workers: num_workers
        }
      end
      node.vm.provision "ansible" do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "provisioning/node.yml"
        # ansible.inventory_path = "provisioning/inventory.cfg"
        ansible.extra_vars = {
          ansible_ssh_private_key_file: "~/vagrant_ssh/vagrant_id_rsa" #ssh key to use
        }
      end
    end
  end
end
