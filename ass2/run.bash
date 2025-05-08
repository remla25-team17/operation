
vagrant up

# amount_of_nodes=$(grep -E '^\s*num_of_workers\s*=' Vagrantfile | awk -F= '{print $2}' | tr -d ' \r')
# echo "Number of worker nodes: $amount_of_nodes":contentReference[oaicite:4]{index=4}

# echo "Amount of nodes: $amount_of_nodes"

# #for amount of nodes
# for i in $(seq 0 "$amount_of_nodes"); do
#     ip="192.168.56.$((100 + i))"
#     echo "Copying ssh key to $ip"
#     ssh-copy-id -o StrictHostKeyChecking=no vagrant@"$ip"
# done

echo "Pinging nodes"
ansible ctrl -i inventory.cfg -m ping





