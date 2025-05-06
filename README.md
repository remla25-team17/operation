# Operation

This repository contains an overview of the services and deployment procedures for using the Sentiment Analysis application.

## 📚 Table of Contents

- [Structure](#structure)
- [🚀 Deployment](#-deployment)
  - [🐳 Docker Compose](#-docker-compose)
  - [🔄 Docker Swarm](#-docker-swarm-deployment)
- [🛠 Application](#-application)
- [⚙️ GitHub Actions & CI/CD](#️-github-actions--cicd)
- [Resources](#-resources)

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
├── secrets/                   # Secret files for secure deployment
│   └── example_secret.txt     # Example secret file
│
├── docker-compose.override.yml # Platform-specific settings (linux/arm64, linux/amd64)
├── docker-compose.yml         # Main Docker Compose file defining services and networks
│
├── GitVersion.yml             # Configuration for semantic versioning
├── README.md                  # This documentation file
└── LICENSE                    # MIT license file
```

### Core files

- `docker-compose.yml`: The main Docker Compose file that defines services, networks, volumes, and secrets configuration.
- `docker-compose.override.yml`: Extends the main configuration with platform-specific settings (e.g., `linux/arm64` and `linux/amd64`). Kept separate from `docker-compose.yml` to ensure compatibility with Docker Swarm deployment.

## [🚀 Deployment](#-deployment)

To deploy the application, we use a **Docker Compose setup** that runs both the application and the model service using pre-built images from the **GitHub Container Registry (GHCR)**.

The Docker Compose file defines two main services:

- `app`: The main Sentiment Analysis frontend application.
- `model-service`: The machine learning model API that serves predictions.

These images are pulled directly from GHCR:

- `ghcr.io/remla25-team17/app-service:latest`
- `ghcr.io/remla25-team17/model-service:latest`

### 🐳 **Docker Compose:**

1️⃣ Make sure you have **Docker and Docker Compose** installed.

2️⃣ Save the `docker-compose.yml` and `docker-compose.override.yml` files (found in this repository).

3️⃣ Start the services:

```bash
docker compose up
```

This will:

- Pull the latest images (if not already pulled),
- Run both services together in a single network,
- Expose the following ports by default:
  - **Model service:** [http://localhost:8080](http://localhost:8080)
  - **App:** [http://localhost:5000](http://localhost:5000)

To run in the background (detached mode):

```bash
docker compose up -d
```

To stop the services:

```bash
docker compose down
```

💡 _Note: The Docker Compose file uses a custom bridge network to allow `app` to communicate with `model-service` internally without needing any extra configuration._

### 🔄 **Docker Swarm Deployment**

For production environments or when secure secrets management is required, you can deploy using Docker Swarm mode:

🔧 Step 1: Create a Secret File
Add a secrets file to the `secrets` directory, e.g., db_password.txt.

```bash
echo "supersecretpassword" > secrets/db_password.txt
```

📝 Step 2: Add the Secret to docker-compose.yml
Add this at the bottom of your docker-compose.yml:

```yaml
secrets:
  db_password:
    file: ./secrets/db_password.txt
```

Then, inside the `app` or `model-service` section, add:

```yaml
secrets:
  - db_password
```

⚙️ Step 3: Deploy with Docker Swarm
You must use Swarm mode to use secrets:

**1. Initialize Swarm (only once)**

```bash
docker swarm init
```

**2. Deploy the stack**
Use a different file name for the stack (e.g., `docker-stack.yml`):

```bash
docker stack deploy -c docker-compose.yml mystack
```

🧪 Step 5: Test That It Works
You can exec into the container and check if the secret is mounted:

```bash
docker service ls  # Find container
docker exec -it <container-id> cat /run/secrets/db_password
```

Finding the container ID can be done with:

1. List running containers:

```bash
docker ps
```

2. Look for a container with a name like:

```php-template
mystack_model-service.1.<container-id>
```

You should see: supersecretpassword

🧼 Step 6: Clean Up
To remove the stack:

```bash
docker stack rm mystack
```

To leave Swarm:

```bash
docker swarm leave --force
```

💡 _Note: Docker Swarm provides secure secrets management, service replication, and better orchestration for production environments._

---

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

## [⚙️ GitHub Actions & CI/CD](#️-github-actions--cicd)

We use **GitHub Actions** to automate our entire CI/CD pipeline. Key aspects include:

- **Automated builds:** Every push to `main` and `develop` triggers the CI workflow to build the code.
- **Docker image publishing:** Our workflows build Docker images for both `app` and `model-service` and push them to GHCR under:
  - `ghcr.io/remla25-team17/app-service:<version>`
  - `ghcr.io/remla25-team17/model-service:<version>`
- **Versioning:** We use **GitVersion** to automate semantic versioning based on Git history and branch naming conventions. This ensures:
  - Stable releases for `main`
  - Pre-releases (e.g., `canary` tags) for `develop` and feature branches.
- **Release automation:** New releases are automatically published to GitHub Releases with changelogs and contributor lists, ensuring traceability.
