#!/bin/bash

# This script sets the KUBECONFIG environment variable
# and verifies that you can access the Kubernetes cluster from your host.

CONFIG_FILE="./admin.conf"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: $CONFIG_FILE not found. Make sure 'ctrl.yml' copied it to your host."
  exit 1
fi

export KUBECONFIG="$CONFIG_FILE"

echo "KUBECONFIG set to $KUBECONFIG"
echo "Verifying access to the Kubernetes cluster..."


kubectl get nodes

echo "Checking if Flannel is working"
kubectl get pods -n kube-flannel

kubectl get nodes
