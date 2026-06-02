# 🚀 Containerized Todo Application 
![CI/CD Build Status](https://github.com)


This project demonstrates the containerization, optimization, and local deployment of a Node.js web application. It serves as a foundational piece of my DevOps engineering journey, showcasing clean infrastructure-as-code practices and modern container workflows.

> 💡 **Attribution:** The underlying application source code is based on the official [Docker Getting Started Repository](github.com/docker/getting-started-app). I extracted the core application logic to implement custom containerization, resolve production dependency conflicts, and optimize runtime configurations.

---

## 🏗️ Architecture & Project Overview
This project packages a lightweight Node.js/Express web application into an isolated, production-ready environment using Docker. 

* **Runtime:** Node.js v18 (Alpine Linux backend for security and minimal image size)
* **Local Mapping:** Host Port `3000` ➡️ Container Port `3000`

---

## 🛠️ Key DevOps Implementations & Fixes

### 1. Multi-Stage / Optimized Dockerfile
* Utilized a minimal `node:20-alpine` base image to significantly reduce the final attack surface and storage footprint.
* Implemented optimized layer caching by copying `package*.json` files and executing dependency installs (`npm ci`) *before* copying application code.
* Kept the container slim by designing a comprehensive `.dockerignore` file to exclude `node_modules` and local logs.

### 2. Resolution of Dependency Conflicts (`ERR_REQUIRE_ESM`)
* **Problem:** The original upstream code crashed immediately with an `Exited (1)` status due to a modern ES module conflict within the `uuid` package.
* **Solution:** Debanked and diagnosed the container runtime using `docker logs`, tracing the source to an incompatible `require()` statement. Resolved the issue by explicitly downgrading the dependency to a stable, CommonJS-compliant version (`uuid^9.0.0`) within `package.json`.

---

## 🚀 How to Run the Project Locally

### Prerequisites
Make sure you have the following installed on your machine:
* [Docker Desktop](https://docker.com) (Ensure the Docker daemon is actively running)
* Git

### Step-by-Step Execution

1. **Clone your repository:**
   ```bash
   git clone https://github.com
   cd getting-started-app
   ```

2. **Build the Docker Image:**
   ```bash
   docker build -t todo-app .
   ```

3. **Spin up the Container:**
   ```bash
   docker run -dp 3000:3000 todo-app
   ```

4. **Access the App:**
   Open your browser and navigate to **`http://localhost:3000`**.

---

## 🧭 Useful Commands for Maintenance

* **Check container status:** `docker ps`
* **Inspect real-time logs:** `docker logs <container-id>`
* **Stop the application:** `docker stop <container-id>`

---

### 3. Automated CI/CD Pipeline (GitHub Actions)
* **Continuous Integration:** Configured a custom GitHub Actions workflow (`docker-ci.yml`) that triggers automatically on every code push to the `main` branch.
* **Secure Secret Management:** Integrated encrypted GitHub Repository Secrets (`DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`) to completely eliminate hardcoded cloud credentials.
* **Automated Image Build & Push:** Orchestrated an automated build process utilizing Docker Buildx, tagging each production image with both `latest` and a unique Git commit SHA (`github.sha`) for flawless version tracking and rollback stability.
* **Image Registry Distribution:** Successfully pipelines and deploys newly verified container images directly to my public [Docker Hub Registry](https://docker.com).


## 🔮 Next Steps on the DevOps Roadmap
To mature this repository into an enterprise-grade showcase, I plan to:
- [ ] **Docker Compose:** Introduce a multi-container setup utilizing a persistent MySQL/PostgreSQL database instead of local storage.
- [ ] **CI/CD Pipeline:** Build a GitHub Actions workflow to automate linting, vulnerability scanning, and Docker Hub image pushes on every commit.
- [ ] **Kubernetes Deployment:** Write manifest files to orchestrate and scale the application inside a local Minikube cluster.