#Vagrantfile

CTRL_MEMORY = 4096 #controller memory
CTRL_CPUS = 2 #controller cpus
NODE_MEMORY = 6144 #worker memory
NODE_CPUS = 2 #worker cpus

num_workers = 2

public_key = File.read(File.expand_path(File.join(Dir.home, "vagrant_ssh", "vagrant_id_rsa.pub"))).strip

INVENTORY_PATH = "provisioning/templates/inventory.cfg"

private_key_path = "#{ENV['HOME']}/vagrant_ssh/vagrant_id_rsa"
user = "vagrant"

# Generate inventory.cfg dynamically
inventory = "[controller]\nctrl ansible_host=192.168.56.100 ansible_ssh_user=#{user} ansible_ssh_private_key_file=#{private_key_path} num_workers=#{num_workers}\n\n[workers]\n"
(1..num_workers).each do |i|
  inventory += "node-#{ i } ansible_host=192.168.56.#{100 + i} ansible_ssh_user=#{user} ansible_ssh_private_key_file=#{private_key_path} num_workers=#{num_workers}\n"
end
inventory += "\n[all:children]\ncontroller\nworkers\n"

# Write inventory.cfg to file
File.open(INVENTORY_PATH, "w") do |file|
  file.write(inventory)
end

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04" #base box

  config.ssh.insert_key = false #disable automatic key insertion
  config.vm.synced_folder "./shared-folder", "/mnt/shared", type: "virtualbox"

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
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "provisioning/general.yml" #playbook
      #ansible.ssh_private_key_file = private_key_path
      ansible.extra_vars = {
        ansible_ssh_private_key_file: private_key_path,
        num_workers: num_workers
      }
      ansible.inventory_path = INVENTORY_PATH #inventory file
      #ansible.raw_arguments     = ["--private-key=#{private_key_path}"]
    end

    ctrl.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "provisioning/ctrl.yml" #playbook
      ansible.extra_vars = {
        ansible_ssh_private_key_file: private_key_path
      }
      ansible.inventory_path = INVENTORY_PATH #inventory file
      #ansible.raw_arguments     = ["--private-key=#{private_key_path}"]
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
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "provisioning/general.yml"
        ansible.extra_vars = {
          ansible_ssh_private_key_file: private_key_path,
          num_workers: num_workers
        }
        ansible.inventory_path = INVENTORY_PATH #inventory file
        #ansible.raw_arguments     = ["--private-key=#{private_key_path}"]
      end

      node.vm.provision "ansible" do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "provisioning/node.yml"
        ansible.extra_vars = {
          ansible_ssh_private_key_file: private_key_path
        }
        ansible.inventory_path = INVENTORY_PATH #inventory file
        #ansible.raw_arguments     = ["--private-key=#{private_key_path}"]
      end
    end
  end
end
