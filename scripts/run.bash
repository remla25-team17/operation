#!/bin/bash
echo "[*] Copying SSH keypair into WSL home..."

mkdir -p ~/vagrant_ssh
cp ../ssh/id_rsa ~/vagrant_ssh/vagrant_id_rsa
cp ../ssh/id_rsa.pub ~/vagrant_ssh/vagrant_id_rsa.pub

chmod 600 ~/vagrant_ssh/vagrant_id_rsa
chmod 644 ~/vagrant_ssh/vagrant_id_rsa.pub

echo "[+] SSH key ready in ~/vagrant_ssh/vagrant_id_rsa"

vagrant up