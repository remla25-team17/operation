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
├── model/                     # Directory for machine learning model
│   └── model.pkl              # Trained sentiment analysis model file
│
├── bag_of_words/              # Directory for bag of words model
│   └── bag_of_words.pkl       # Bag of words vectorizer file
│
├── secrets/                   # Secret files for secure deployment
│   └── example_secret.txt     # Example secret file
│
├── docker-compose.yml         # Main Docker Compose file defining services and networks
│
├── GitVersion.yml             # Configuration for semantic versioning
├── README.md                  # This documentation file
└── LICENSE                    # MIT license file
```

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
