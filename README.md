# Operation

This repository contains an overview of the services and deployment procedures for using the Sentiment Analysis application.

## 📚 Table of Contents

- [🚀 Deployment](#-deployment)
- [🛠 Application](#-requirements)
- [⚙️ GitHub Actions & CI/CD](#️-github-actions--cicd)
- [Resources](#-resources)

## [🚀 Deployment](#-deployment)
To deploy the application, we use a **Docker Compose setup** that runs both the application and the model service using pre-built images from the **GitHub Container Registry (GHCR)**.

The Docker Compose file defines two main services:

- `app`: The main Sentiment Analysis frontend application.
- `model-service`: The machine learning model API that serves predictions.

These images are pulled directly from GHCR:

- `ghcr.io/remla25-team17/app-service:latest`
- `ghcr.io/remla25-team17/model-service:latest`

### 🐳 **How to run:**

1️⃣ Make sure you have **Docker and Docker Compose** installed.

2️⃣ Save the `docker-compose.yml` file (found in this repository).

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

💡 *Note: The Docker Compose file uses a custom bridge network to allow `app` to communicate with `model-service` internally without needing any extra configuration.*

---

## [🛠 Application](#-requirements)
Our Sentiment Analysis application is implemented across multiple services and repositories, each focusing on a specific part of the system:

| Repository                                                        | Description                                                                                     |
|-------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
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
    - `ghcr.io/remla25-team17/app:<version>`
    - `ghcr.io/remla25-team17/model-service:<version>`
- **Versioning:** We use **GitVersion** to automate semantic versioning based on Git history and branch naming conventions. This ensures:
    - Stable releases for `main`
    - Pre-releases (e.g., `canary` tags) for `develop` and feature branches.
- **Release automation:** New releases are automatically published to GitHub Releases with changelogs and contributor lists, ensuring traceability.
