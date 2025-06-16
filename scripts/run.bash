#!/usr/bin/env bash

#if ssh key does not exist, generate it
if [ ! -f ./ssh/id_rsa ]; then
    mkdir -p ./ssh
    ssh-keygen -t rsa -b 4096 -f ./ssh/id_rsa -C "remla25-17"
    echo "[+] SSH key generated"
fi


#if .vagrant directory exists, destroy it
if [ -d .vagrant ]; then
    rm -rf .vagrant
fi

echo "[*] Copying SSH keypair into WSL home..."

mkdir -p ~/vagrant_ssh
cp ./ssh/id_rsa ~/vagrant_ssh/vagrant_id_rsa
cp ./ssh/id_rsa.pub ~/vagrant_ssh/vagrant_id_rsa.pub

chmod 600 ~/vagrant_ssh/vagrant_id_rsa
chmod 644 ~/vagrant_ssh/vagrant_id_rsa.pub

echo "[+] SSH key ready in ~/vagrant_ssh/vagrant_id_rsa"

vagrant up
