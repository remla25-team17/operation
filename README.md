# Operation

This repository contains an overview of the services and deployment procedures for using the Sentiment Analysis application.

## 📚 Table of Contents

- [Structure](#structure)
- [🛠 Application](#-application)
- [🚀 Deployment](#-deployment)
  - [🐳 Docker Compose](#-docker-compose)
  - [🔄 Docker Swarm](#-docker-swarm-deployment)
  - [☸️ Kubernetes via Vagrant](#️-kubernetes-via-vagrant)
- [🧪 Testing Kubernetes Configuration](#-testing-kubernetes-configuration)
- [⚙️ GitHub Actions & CI/CD](#️-github-actions--cicd)
- [Use of Gen AI](#-gen-ai)

## [Structure](#structure)

This repository is organized according to the following structure:

```
operation/
├── .github/
│   └── workflows/             # CI/CD workflow definitions
│       └── release.yml        # Release automation workflow
│
├── environments/              # Environment variable files
│   ├── app.env                # App service environment variables
│   └── model-service.env      # Model service environment variables
│
├── model/                     # Directory for machine learning model
│   └── model.pkl              # Trained sentiment analysis model file
│
├── bag_of_words/              # Directory for bag of words model
│   └── bag_of_words.pkl       # Bag of words vectorizer file
│
├── provisioning/              # Ansible playbooks for K8s configuration
│   ├── ansible.cfg            # Ansible configuration
│   ├── ctrl.yml               # Controller node configuration
│   ├── general.yml            # General node configuration
│   ├── inventory.cfg          # Node inventory file
│   └── node.yml               # Worker node configuration
│
├── public-keys/               # SSH public keys for VM access
│
├── secrets/                   # Secret files for secure deployment
│   └── example_secret.txt     # Example secret file
│
├── docker-compose.yml         # Main Docker Compose file defining services and networks
├── Vagrantfile                # VM provisioning for Kubernetes cluster
├── run.bash                   # Script to set up SSH keys and start VMs
├── generate_key.bash          # Script to generate SSH keys
├── destroy.bash               # Script to tear down VMs
├── config_k8s.sh              # Script to setup local K8s connection
│
├── GitVersion.yml             # Configuration for semantic versioning
├── README.md                  # This documentation file
└── LICENSE                    # MIT license file
```

## [🛠 Application](#-application)

Our Sentiment Analysis application is implemented across multiple services and repositories, each focusing on a specific part of the system:

| Repository                                                         | Description                                                                                      |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| [model-training](https://github.com/remla25-team17/model-training) | Handles training and evaluation of the sentiment analysis model.                                 |
| [model-service](https://github.com/remla25-team17/model-service)   | Flask API that serves the trained model for real-time predictions.                               |
| [lib-ml](https://github.com/remla25-team17/lib-ml)                 | Shared machine learning utilities and preprocessing code used by both training and service apps. |
| [app](https://github.com/remla25-team17/app)                       | The main application that connects to the `model-service` and exposes user-facing endpoints.     |
| [lib-version](https://github.com/remla25-team17/lib-version)       | Provides versioning utilities to keep services aligned and trackable.                            |

Each of these components works together to deliver an end-to-end sentiment analysis pipeline, from training to real-time predictions.

---

## [🚀 Deployment](#-deployment)

To deploy the application, we use a **Docker Compose setup** that runs both the application and the model service using pre-built images from the **GitHub Container Registry (GHCR)**.

The Docker Compose file defines two main services:

- `app`: The main Sentiment Analysis frontend application.
- `model-service`: The machine learning model API that serves predictions.

The Docker Compose file uses environment variables to specify the images:

- `${APP_IMAGE_NAME}:${APP_IMAGE_TAG}` for the app service
- `${MODEL_IMAGE_NAME}:${MODEL_IMAGE_TAG}` for the model service

### 🐳 **Docker Compose:**

1️⃣ Make sure you have **Docker and Docker Compose** installed.

2️⃣ Set the required environment variables before running docker compose:

```bash
export APP_IMAGE_NAME=ghcr.io/remla25-team17/app-service
export APP_IMAGE_TAG=latest
export MODEL_IMAGE_NAME=ghcr.io/remla25-team17/model-service
export MODEL_IMAGE_TAG=latest
```

3️⃣ Start the services:

```bash
docker compose up
```

This will:

- Pull the latest images (if not already pulled),
- Run both services together in a single network,
- Mount the model and bag_of_words directories into the model-service container
- Expose the following ports by default:
  - **Model service:** internally available through the model-service hostname
  - **App:** [http://localhost:5000](http://localhost:5000)

To run in the background (detached mode):

```bash
docker compose up -d
```

To stop the services:

```bash
docker compose down
```

💡 _Note: The Docker Compose file connects the app and model-service containers, allowing them to communicate internally without needing any extra configuration._

### 🔄 **Docker Swarm Deployment**

For production environments or when high availability and better orchestration is required, you can deploy using Docker Swarm mode:

⚙️ Deploy with Docker Swarm:

**1. Initialize Swarm (only once)**

```bash
docker swarm init
```

**2. Deploy the stack**

```bash
docker stack deploy -c docker-compose.yml mystack
```

**3. Clean Up**

To remove the stack:

```bash
docker stack rm mystack
```

To leave Swarm:

```bash
docker swarm leave --force
```

💡 _Note: Docker Swarm provides service replication and better orchestration for production environments._

### ☸️ **Kubernetes via Vagrant**

For advanced deployment with Kubernetes, we've set up an automated provisioning system using Vagrant and Ansible:

**1. Generate SSH Key**

First, generate the SSH key pair needed for the VM setup:

```bash
./generate_key.bash
```

If you encounter a "permission denied" error, make the script executable:
```bash
chmod +x generate_key.bash
```

**2. Deploy the Kubernetes Cluster**
> Note: Make sure that you have a VM provider (e.g. VirtualBox) installed as well as Ansible.

Run the deployment script to set up the VMs and provision them:

```bash
./run.bash
```

This script will:
- Copy your SSH key to the appropriate location
- Set correct permissions
- Start up a 3-node cluster (1 control plane + 2 worker nodes) using Vagrant

If you need to make the script executable:
```bash
chmod +x run.bash
```

**3. Updating Configurations**

After changing Ansible playbooks, you can apply the changes without recreating VMs:

```bash
vagrant provision
```

**4. Tear Down the Cluster**

To destroy the VMs when done:

```bash
./destroy.bash
```

💡 _Note: The Kubernetes cluster consists of one control node (192.168.56.100) and two worker nodes (192.168.56.101, 192.168.56.102), all provisioned with the necessary Kubernetes components and configured with SSH access._


## [🧪 Testing Kubernetes Configuration](#-testing-kubernetes-configuration)

To start Vagrant run:

```bash
vagrant up 
```

This will create the virtual machines: ctrl, node-1 and node-2.

### Verify the nodes are accessible 

1. Through the private network:
```bash
vagrant ssh ctrl
ping 192.168.56.100
```

2. Through the public network:
```bash
vagrant ssh ctrl
ping google.com
```

### Swap Disabled (Step 5)

Kubernetes requires swap to be disabled. Verify with:

```bash
vagrant ssh ctrl
swapon --show
```

This should return empty output, indicating no swap is enabled.

### Kernel Modules (Step 6)

Verify that required kernel modules are loaded:

```bash
vagrant ssh ctrl
cat /etc/modules-load.d/k8s.conf
```

Both modules should appear in the output.

### IP Forwarding (Step 7)

Confirm IP forwarding is enabled:

```bash
vagrant ssh ctrl
sysctl net.ipv4.ip_forward
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
```

Output should be 
```bash
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
```

### Host Entries (Step 8)

Check that the hosts file contains all node entries:

```bash
vagrant ssh ctrl
cat /etc/hosts
```

You should see entries for the control node and worker nodes.

### APT repository and key (Step 9)

Check the repository is under:
```bash
/etc/apt/sources.list.d/
```

And the key is shown with:
```bash
apt-key list | grep -i kubernetes
```

### Kubernetes Packages (Step 10)

Verify Kubernetes components are properly installed:

```bash
vagrant ssh ctrl
containerd --version
runc --version
kubelet --version
kubeadm version
kubectl version --client
```

It should show containerd is version 1.7.24, runc version 1.1.12 and kubelet, kubeadm and kubectl version 1.32.4.

### Containerd Configuration (Step 11)

Verify containerd is running with the correct configuration:

```bash
vagrant ssh ctrl
systemctl status containerd
```

Status should be "active (running)".

To verify specific containerd settings:

```bash
vagrant ssh ctrl
sudo cat /etc/containerd/config.toml | grep -E 'SystemdCgroup|disable_apparmor|sandbox_image'
```

Output should show `disable_apparmor = true`, `sandbox_image = "registry.k8s.io/pause:3.10"` and `SystemdCgroup = true`.

### Kubelet Status (Step 12)

Check that kubelet service is running:

```bash
vagrant ssh ctrl
systemctl status kubelet
```

Status should be "active (running)" if you're on the control node. On worker nodes, it might show "activating" until the node joins the cluster.

💡 _Replace `ctrl` with `node-1` or `node-2` to test different nodes in your cluster._

To leave the node perform `ctrl+d` and destroy Vagrant using `vagrant destroy -f`


### Initialize the Kubernetes Cluster (Step 13)

We initialized the Kubernetes control plane using `kubeadm`, configuring it to advertise the controller's IP address and setting the appropriate Pod network CIDR (Classless Inter-Domain Routing).

### Configure kubectl Access (Step 14)
We made the cluster configuration available to the `vagrant` user on the controller VM, enabling direct use of `kubectl`. Additionally, we copied the configuration file to the host machine so that `kubectl` can be used from outside the VM. Example script: `sh ./cnfig_k8s.sh`.



### Deploy Flannel Network Plugin (Step 15)

We installed the Flannel networking plugin to enable Pod-to-Pod communication across the cluster. The Flannel configuration was patched to use the correct network interface (`eth1`) that matches our Vagrant host-only setup.

### Install Helm (Step 16-17)

We installed Helm, the Kubernetes package manager, by adding its official APT repository and installing it via the system package manager. This allows us to manage and deploy applications on the cluster more easily.

Also, we installed the `helm-diff` plugin to improve visibility into Helm changes and make Ansible's provisioning more reliable by avoiding unnecessary re-installs during re-provisioning.

### Generate Join Command (Step 18)

We generated the command to join the Kubernetes cluster in the controller by delegating it using the `delegate_to` parameter. The command is stored in a variable.

### Run Join Command (Step 19)

We run the command generated in Step 19 in order to join the worker to the Kubernetes cluster.

### Install MetalLB (Step 20)

We installed MetalLB, adding an IPAdressPool and configuring an L2Advertisement.

### Install the Nginx Ingress Controller (Step 21)

We deployed the Nginx Ingress Controller using Helm to expose services within the cluster. The controller was configured to work with MetalLB by assigning a specific IP from the MetalLB pool using the `controller.service.loadBalancerIP` setting.

### Install Kubernetes Dashboard (Step 22)

We set up the Kubernetes Dashboard, adding a `ServiceAccount` and `ClusterRoleBinding` for an admin user. An Ingress resource was created to enable HTTPS access using a self-signed certificate managed by cert-manager.

### Install Istio (Step 23)

We integrated Istio into the cluster by configuring its ingress gateway as a LoadBalancer service. 

## [⚙️ GitHub Actions & CI/CD](#️-github-actions--cicd)

We use **GitHub Actions** to automate our entire CI/CD pipeline. Key aspects include:

- **Automated builds:** Every push to `main` and `develop` triggers the CI workflow to build the code.
- **Versioning:** We use **GitVersion** to automate semantic versioning based on Git history and branch naming conventions. This ensures:
  - Stable releases for `main`
  - Pre-releases (e.g., `canary` tags) for `develop` and feature branches.
- **Release automation:** New releases are automatically published to GitHub Releases with changelogs and contributor lists, ensuring traceability.


## [Use of Gen AI](#-gen-ai)
Across this project, we have used GenAI solutions (e.g. ChatGPT, GitHub Copilot) for the following:
- Generating templates and suggesting content for the READMEs across all the repositories. 
- The AI was especially helpful in debugging various issues. One place that we used this was for creating the `GitVersion.yml` file across all the repositories. The problem was that the documentation for GitVersion was scattered and outdated in some places and ChatGPT helped in retrieving up-to-date information easily. 
- Another place that we used AI was in the `release.yml` files. Specifically, there was the issue where we did not understand why the pre-release included the changelog from the main branch but not from the `develop/` one. Hence, ChatGPT suggested to make a deep fetch request and enforce the current commit-sha.
- Also, we used AI to write the schema specifications for the Flask API in `model-service` and validate this.
- Lastly, we use AI for understanding various concepts that we have been working on, especially helping us understand the root cause of some issues.