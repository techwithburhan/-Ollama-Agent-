<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=200&section=header&text=🤖%20Ollama%20Agent&fontSize=50&fontColor=fff&animation=twinkling&fontAlignY=35&desc=Your%20Fully%20Offline%20AI%20Chat%20Assistant&descAlignY=55&descSize=18" width="100%"/>

<br/>

[![React](https://img.shields.io/badge/React-18.2-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://reactjs.org)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.0-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
[![Ollama](https://img.shields.io/badge/Ollama-Local_LLM-FF6B35?style=for-the-badge)](https://ollama.ai)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-KIND-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![JWT](https://img.shields.io/badge/JWT-Auth-000000?style=for-the-badge&logo=jsonwebtokens)](https://jwt.io)
[![GSAP](https://img.shields.io/badge/GSAP-3.12-88CE02?style=for-the-badge)](https://gsap.com)

<br/>

> **A production-ready, full-stack offline AI chat application — no API costs, no data leaks, runs 100% on your machine.**
> Built for DevOps engineers who want to understand real-world containerization, orchestration, and local AI deployment.

<br/>

[🚀 Quick Start](#-quick-start) • [✨ Features](#-features) • [🏗️ Architecture](#️-architecture) • [🐳 Docker](#-docker) • [☸️ Kubernetes](#️-kubernetes-kind) • [🌐 API Docs](#-api-reference) • [☁️ AWS EC2](#️-aws-ec2-deployment) • [🎯 Interview Q&A](#-interview-questions--answers)

---

</div>

## 📖 What Is This Project?

**Ollama Agent** is a production-grade, fully offline AI chat application that runs powerful Large Language Models directly on your own machine — zero internet required, zero API costs, and complete data privacy.

Think of it as your own private ChatGPT — but running entirely on your laptop or server, secured with JWT authentication, with real-time streaming responses via Server-Sent Events (SSE), voice input/output, and document attachment support.

This project is intentionally built to cover the **entire DevOps lifecycle**:

```
Code → Docker → Docker Compose → Kubernetes (KIND) → AWS EC2 → (EKS coming)
```

Whether you are a DevOps engineer, cloud engineer, or developer — this project gives you hands-on experience with every tool used in modern production deployments.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔒 **100% Offline & Private** | Your prompts and data never leave your machine |
| ⚡ **Real-time Streaming** | Token-by-token responses via Server-Sent Events (SSE) |
| 🎤 **Voice Input** | Speak your prompts — Web Speech API (browser native) |
| 🔊 **Text-to-Speech** | AI responses read aloud via SpeechSynthesis API |
| 📎 **Document Attachment** | Attach PDF, TXT, CSV, JSON, code files and ask questions |
| 🤖 **Multi-Model Support** | Switch between tinyllama, llama2, mistral, llama3, codellama, phi |
| 💬 **Chat History** | Conversations persisted to MongoDB per user account |
| 🔐 **JWT Authentication** | Secure signup/login with bcrypt password hashing |
| 🎨 **Glassmorphism UI** | Dark theme with GSAP animations and glowing accents |
| 🗂️ **Chat Management** | Create, load, rename, and delete conversations |
| 📱 **Responsive Design** | Collapsible sidebar with full-height chat layout |
| 🐳 **Fully Containerized** | Docker + Docker Compose for local dev |
| ☸️ **Kubernetes Ready** | KIND cluster with HPA, Ingress, Secrets, PVC |

---

## 🛠️ Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| **Frontend** | React.js 18, React Router v6 | Component-based SPA with protected routes |
| **Animations** | GSAP 3 | Smooth glassmorphism UI transitions |
| **HTTP Client** | Axios | API calls with interceptors for JWT |
| **Backend** | Node.js + Express.js | Non-blocking I/O, perfect for SSE streaming |
| **Database** | MongoDB + Mongoose | Flexible document model for chat history |
| **Auth** | JWT + bcryptjs | Stateless auth — scales horizontally |
| **AI Engine** | Ollama (Local LLM) | Run LLMs locally with REST API |
| **Streaming** | Server-Sent Events (SSE) | One-way real-time stream from server to browser |
| **Voice Input** | Web Speech API | Browser-native, no extra libraries |
| **Voice Output** | SpeechSynthesis API | Browser-native text-to-speech |
| **Container** | Docker + Docker Compose | Isolation, portability, reproducibility |
| **Orchestration** | Kubernetes (KIND) | Auto-scaling, self-healing, rolling updates |

---

## 📁 Project Structure

```
ollama-agent/
│
├── 🎨 frontend/                        # React.js 18 Frontend
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── context/
│   │   │   └── AuthContext.js          # Global auth state + JWT storage
│   │   ├── pages/
│   │   │   ├── Login.js                # Login page with GSAP animations
│   │   │   ├── Signup.js               # Signup page with GSAP animations
│   │   │   └── Chat.js                 # Main chat (streaming + voice + files)
│   │   ├── App.js                      # Router + protected route guards
│   │   ├── index.js                    # React entry point
│   │   └── index.css                   # Glassmorphism CSS variables
│   ├── Dockerfile                      # Multi-stage: Node build → Nginx serve
│   └── package.json
│
├── ⚙️ backend/                         # Node.js + Express.js API
│   ├── models/
│   │   ├── User.js                     # User schema with bcrypt pre-save hook
│   │   └── Chat.js                     # Chat + message schema
│   ├── routes/
│   │   ├── auth.js                     # POST /signup /login  GET /me
│   │   └── chat.js                     # SSE streaming + history CRUD
│   ├── middleware/
│   │   └── auth.js                     # JWT verify middleware (protect routes)
│   ├── server.js                       # Express app + MongoDB connection
│   ├── Dockerfile                      # Node.js production image
│   ├── .env                            # ⚠️ Never commit — in .gitignore
│   └── package.json
│
├── ☸️ k8s/                             # Kubernetes manifests
│   ├── cluster-create/
│   │   └── kind-cluster.yaml           # KIND cluster config with port mappings
│   ├── cluster/
│   │   ├── namespace.yaml              # ollama-agent namespace
│   │   ├── storageclass.yaml           # local-path (KIND built-in)
│   │   └── ingress.yaml                # HTTP routing + SSE support
│   ├── mongodb/
│   │   ├── persistentvolumeclaim.yaml  # 10Gi local storage
│   │   ├── service.yaml                # Headless ClusterIP
│   │   └── statefulset.yaml            # MongoDB with health checks
│   ├── backend/
│   │   ├── secret.yaml                 # JWT + MongoDB URI (base64 encoded)
│   │   ├── configmap.yaml              # Port, Ollama URL, model name
│   │   ├── deployment.yaml             # 1 replica + initContainer (waits for mongo)
│   │   ├── service.yaml                # ClusterIP port 5005
│   │   └── hpa.yaml                    # 2-10 pods auto-scale on CPU
│   ├── frontend/
│   │   ├── configmap.yaml              # Nginx config + API URL
│   │   ├── deployment.yaml             # 2 replicas + initContainer (waits for backend)
│   │   ├── service.yaml                # ClusterIP port 80
│   │   └── hpa.yaml                    # 2-8 pods auto-scale
│   ├── ollama/
│   │   ├── pvc.yaml                    # 30Gi local storage (models persist)
│   │   ├── configmap.yaml              # Ollama settings
│   │   ├── deployment.yaml             # tinyllama auto-pull initContainer
│   │   ├── service.yaml                # ClusterIP port 11434
│   │   └── nodeport.yaml               # NodePort 31434 for debug access
│   ├── apply.sh                        # 🚀 One-command full deployment
│   ├── destroy.sh                      # 💣 One-command full teardown
│   └── port-forward.sh                 # 🔌 All port-forwards in one script
│
├── 🐳 docker-compose.yml               # Local dev: MongoDB + Backend + Frontend
├── mongo-init.js                       # Auto-create collections on first boot
└── README.md
```

---

## ✅ Prerequisites

| Tool | Min Version | Install |
|------|------------|---------|
| Node.js | v18+ | https://nodejs.org |
| MongoDB | v6+ | https://mongodb.com/try/download/community |
| Ollama | Latest | https://ollama.ai |
| Docker | v24+ | https://docker.com |
| kubectl | v1.27+ | https://kubernetes.io/docs/tasks/tools |
| KIND | v0.20+ | https://kind.sigs.k8s.io |
| Git | Any | https://git-scm.com |

---

## 🚀 Quick Start

### Step 1 — Install & Run Ollama

```bash
# macOS / Linux
curl -fsSL https://ollama.ai/install.sh | sh

# Windows → Download from: https://ollama.ai/download/windows

# Pull tinyllama (lightest model — 637MB, works on 4GB RAM)
ollama pull tinyllama

# Pull other models based on your RAM
ollama pull phi           # 1.7 GB  — fastest, lowest RAM
ollama pull llama2        # 3.8 GB  — general purpose ✅ recommended
ollama pull mistral       # 4.1 GB  — fast + efficient
ollama pull llama3        # 4.7 GB  — best quality
ollama pull codellama     # 3.8 GB  — code focused

# Start Ollama server
ollama serve
```

> ✅ Verify: `curl http://localhost:11434/api/version` → should return version JSON

---

### Step 2 — Backend Setup

```bash
cd ollama-agent/backend
npm install

# Generate a secure JWT secret
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

Create `backend/.env`:

```env
PORT=5005
MONGO_URI=mongodb://localhost:27017/ollama-agent
JWT_SECRET=paste_your_64byte_hex_key_here
OLLAMA_API=http://localhost:11434/api
OLLAMA_MODEL=tinyllama
```

```bash
npm run dev
# Expected: ✅ MongoDB Connected  🚀 Server running on http://localhost:5005
```

---

### Step 3 — Frontend Setup

```bash
cd ollama-agent/frontend
npm install

# macOS proxy fix
echo "DANGEROUSLY_DISABLE_HOST_CHECK=true" > .env
echo "WDS_SOCKET_HOST=127.0.0.1" >> .env

npm start
# Browser opens at http://localhost:3000
```

---

### Step 4 — Run All Together (3 terminals)

```bash
# Terminal 1
ollama serve

# Terminal 2
cd backend && npm run dev

# Terminal 3
cd frontend && npm start
```

Open **http://localhost:3000** → Sign up → Start chatting 🎉

---

## 🐳 Docker

### Why Docker?

Without Docker, every developer needs to manually install Node.js, MongoDB, configure ports, and set environment variables — and "it works on my machine" becomes a constant problem.

With Docker, you package the app + its environment into an image that runs identically everywhere — on any developer laptop, CI/CD pipeline, or cloud server.

```
Before Docker                      After Docker
─────────────────────              ─────────────────────
❌ Manual Node.js install          ✅ docker build → done
❌ MongoDB setup + config          ✅ docker run → running
❌ "Works on my machine"           ✅ Same on all machines
❌ Complex deployment              ✅ Push image, pull, run
❌ Dependency conflicts            ✅ Isolated containers
```

---

### 🔐 Login to Docker Hub

```bash
docker login -u burhan503
```

---

### 🎨 Frontend — Build & Push

```bash
cd frontend

# Build multi-stage image (Node.js build → Nginx serve)
docker build -t burhan503/ollama-agent-frontend:latest .

# Run locally
docker run -d -p 3000:80 --name frontend burhan503/ollama-agent-frontend
# Open: http://localhost:3000

# Push to DockerHub
docker push burhan503/ollama-agent-frontend:latest
```

---

### ⚙️ Backend — Build & Push

```bash
cd backend

# Build image
docker build -t burhan503/ollama-agent-backend:latest .

# Run locally
docker run -d -p 5005:5005 --env-file .env --name backend burhan503/ollama-agent-backend
# Open: http://localhost:5005

# Push to DockerHub
docker push burhan503/ollama-agent-backend:latest
```

---

### Verify Images

```bash
docker images | grep burhan503
# burhan503/ollama-agent-backend     latest    ...
# burhan503/ollama-agent-frontend    latest    ...
```

---

### 🛑 Stop & Clean

```bash
# Stop containers
docker stop $(docker ps -q --filter "publish=5005")
docker stop $(docker ps -q --filter "publish=3000")

# Remove images
docker rmi burhan503/ollama-agent-frontend:latest burhan503/ollama-agent-backend:latest

# Force remove
docker rmi -f burhan503/ollama-agent-frontend:latest burhan503/ollama-agent-backend:latest
```

---

## 🐙 Docker Compose

Docker Compose lets you define and run multi-container applications with a single command. Instead of starting MongoDB, backend, and frontend separately — one `docker-compose up` brings everything up in the correct order.

### `docker-compose.yml`

```yaml
version: "3.8"

services:

  # 🟢 MongoDB
  mongodb:
    image: mongo:6.0
    container_name: ollama-mongodb
    restart: always
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: burhan503
      MONGO_INITDB_DATABASE: ollama-agent
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
      - ./mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js:ro
    networks:
      - ollama-network

  # 🔵 Backend
  backend:
    image: burhan503/ollama-agent-backend:latest
    container_name: ollama-backend
    restart: always
    depends_on:
      - mongodb
    environment:
      PORT: 5005
      MONGO_URI: mongodb://admin:burhan503@mongodb:27017/ollama-agent?authSource=admin
      JWT_SECRET: a3f8c2e1b9d4f7a2c5e8b1d4f7a2c5e8b1d4f7a2c5e8b1d4f7a2c5e8b1d4f7a2
      OLLAMA_API: http://host.docker.internal:11434/api
      OLLAMA_MODEL: tinyllama
    ports:
      - "5005:5005"
    networks:
      - ollama-network

  # 🟣 Frontend
  frontend:
    image: burhan503/ollama-agent-frontend:latest
    container_name: ollama-frontend
    restart: always
    depends_on:
      - backend
    ports:
      - "3000:80"
    networks:
      - ollama-network

networks:
  ollama-network:
    driver: bridge

volumes:
  mongo-data:
```

> 💡 `host.docker.internal` is how a Docker container reaches the host machine's localhost — so Ollama running on your laptop is reachable from inside the container.

---

### `mongo-init.js`

```javascript
// Auto-create collections on first boot
db = db.getSiblingDB("ollama-agent");
db.createCollection("users");
db.createCollection("chats");
```

---

### Run Commands

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# Watch live logs
docker-compose logs -f

# Stop all
docker-compose down

# Stop and delete volumes (wipes MongoDB data)
docker-compose down -v
```

---

### Verify MongoDB Inside Container

```bash
# Enter MongoDB shell
docker exec -it ollama-mongodb mongosh -u admin -p burhan503 --authenticationDatabase admin

# Inside mongosh
show dbs
use ollama-agent
show collections
# Expected: users  chats
```

```bash
# One-liner
docker exec -it ollama-mongodb mongosh --eval "use('ollama-agent'); show collections;"
```

---

### Docker Utilities

```bash
# List volumes
docker volume ls

# Inspect volume (see where data is stored)
docker volume inspect mongo-data

# List networks
docker network ls

# Inspect network
docker network inspect ollama-network

# Clean up unused resources
docker volume prune
docker network prune
<<<<<<< HEAD
```
---

## ☸️ Kubernetes — Coming Soon

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🚧  Kubernetes manifests, Helm charts, and                ║
║       EKS/GKE deployment steps will be added here.          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

☸️ Why Kubernetes?Kubernetes (K8s) is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications.
In simple words — Docker runs your containers, Kubernetes manages them at scale.

ollama-agent/
├── frontend/
├── backend/
└── k8s/
├── cluster/
│   ├── namespace.yaml       ✅ ollama-agent namespace
│   ├── storageclass.yaml    ✅ AWS EBS gp3 storage
│   └── ingress.yaml         ✅ HTTP routing + SSE support
├── mongodb/
│   ├── statefulset.yaml     ✅ MongoDB pod + health checks
│   ├── service.yaml         ✅ Headless service
│   └── persistentvolumeclaim.yaml  ✅ 10GB EBS storage
├── backend/
│   ├── secret.yaml          ✅ JWT + MongoDB URI base64
│   ├── configmap.yaml       ✅ Port, Ollama URL, Model
│   ├── deployment.yaml      ✅ 2 replicas + initContainer
│   ├── service.yaml         ✅ ClusterIP
│   └── hpa.yaml             ✅ 2-10 pods auto-scale
└── frontend/
    ├── configmap.yaml       ✅ Nginx config + API URL
    ├── deployment.yaml      ✅ 2 replicas + initContainer
    ├── service.yaml         ✅ LoadBalancer + 443 HTTPS
    └── hpa.yaml             ✅ 2-8 pods auto-scale
ollama/
    ├── pvc.yaml                      ✅ 30GB storage (models persist hongi)
    ├── configmap.yaml                ✅ Ollama settings
    ├── deployment.yaml               ✅ Ollama pod + model auto-pull
    ├── service.yaml                  ✅ ClusterIP (pods se access)
    ├── nodeport.yaml                 ✅ NodePort (bahar se debug)

```
## 🤔 The Problem Without Kubernetes
- Without Kubernetes, running this project in production looks like this:
```code
❌ App gets high traffic → server crashes → manual restart needed
❌ New version deployed → app goes down for users during update
❌ Container crashes → nobody knows until users complain
❌ Need more capacity → manually SSH into server and scale
❌ One server failure → entire app goes down
❌ Different configs for dev, staging, production → human errors
```

## ✅ What Kubernetes Solves
```code
✅ App gets high traffic → auto-scales pods automatically
✅ New version deployed → rolling update with zero downtime
✅ Container crashes → self-heals and restarts automatically
✅ Need more capacity → HPA scales up without human intervention
✅ One server fails → workload moves to healthy nodes
✅ Configs managed → ConfigMaps and Secrets handle all environments
```

## 📋 What Each File Does

| 📄 File                         | 📌 Purpose |
|--------------------------------|----------|
| `deployment.yaml`              | Runs application pods and manages replicas, container image, and resource limits |
| `service.yaml`                 | Exposes pods internally (ClusterIP) or externally (NodePort/LoadBalancer) |
| `hpa.yaml`                     | Automatically scales pods based on CPU or memory usage |
| `configmap.yaml`               | Stores non-sensitive configuration (e.g., API URLs, environment variables) |
| `secret.yaml`                  | Stores sensitive data (e.g., JWT secret, MongoDB URI) securely |
| `statefulset.yaml`             | Deploys MongoDB with stable identity and persistent storage |
| `persistentvolumeclaim.yaml`   | Requests and reserves storage for MongoDB data |
| `ingress.yaml`                 | Acts as a single entry point and routes traffic to services |
| `namespace.yaml`               | Creates an isolated Kubernetes namespace for the application |
| `storageclass.yaml`            | Defines storage provisioning (e.g., AWS EBS volumes) |

## 📋 Why We Used Each Manifest File

### namespace.yaml
Isolates the entire Ollama Agent application in its own Kubernetes namespace — separating it from other applications running on the same cluster.

```yaml
# Everything runs under: ollama-agent namespace
# Instead of polluting the default namespace
=======
docker system prune -f
>>>>>>> new-k8s
```

---

## ☸️ Kubernetes (KIND)

### Why Kubernetes?

Docker runs containers on a single machine. Kubernetes manages containers across many machines, handles failures automatically, and scales based on traffic.

```
Problem Without K8s              Solution With K8s
─────────────────────────        ─────────────────────────
❌ High traffic → crash          ✅ HPA auto-scales pods
❌ Deploy = downtime             ✅ Rolling update (zero downtime)
❌ Pod crash = outage            ✅ Self-healing (auto-restart)
❌ Manual scaling                ✅ HPA scales 2 → 10 pods
❌ One server = single point     ✅ Multi-node redundancy
❌ Config management hell        ✅ ConfigMaps + Secrets
```

---

### 📋 Kubernetes Files Explained

| File | What It Does | Why It Matters |
|------|-------------|----------------|
| `namespace.yaml` | Creates isolated `ollama-agent` namespace | Prevents resource conflicts with other apps |
| `storageclass.yaml` | Defines storage provisioner (local-path for KIND) | Tells K8s how to create persistent volumes |
| `ingress.yaml` | Routes HTTP traffic to frontend/backend | Single entry point, replaces multiple LoadBalancers |
| `secret.yaml` | Stores JWT + MongoDB URI as base64 | Sensitive data separated from code |
| `configmap.yaml` | Stores non-sensitive env vars | Decouples config from container images |
| `deployment.yaml` | Runs pods, manages replicas + rolling updates | Core workload definition |
| `service.yaml` | Stable DNS name for pods | Pods have dynamic IPs — Service gives stable endpoint |
| `hpa.yaml` | Auto-scales pods based on CPU/memory | Handles traffic spikes automatically |
| `statefulset.yaml` | Runs MongoDB with stable identity | Databases need stable hostname + storage |
| `persistentvolumeclaim.yaml` | Requests storage for MongoDB | Data survives pod restarts |

---

### 🔄 How All Components Connect

```
                     ┌─────────────────────────────────────────┐
                     │           KIND Cluster                   │
                     │                                          │
  Internet           │  ┌──────────┐                           │
  ─────────► :80 ────┼─►│ Ingress  │                           │
                     │  └──────────┘                           │
                     │       │                                  │
                     │       ├──── /     ──►  Frontend Svc      │
                     │       │              (ClusterIP :80)     │
                     │       │                    │             │
                     │       │              Frontend Pods       │
                     │       │              [HPA: 2-8 pods]     │
                     │       │                                  │
                     │       └──── /api  ──►  Backend Svc       │
                     │                      (ClusterIP :5005)  │
                     │                            │             │
                     │                      Backend Pods        │
                     │                      [HPA: 2-10 pods]   │
                     │                      [ConfigMap+Secret]  │
                     │                            │             │
                     │              ┌─────────────┴──────────┐  │
                     │              │                        │  │
                     │         MongoDB Svc              Ollama Svc│
                     │       (Headless :27017)          (:11434)│
                     │              │                        │  │
                     │         MongoDB Pod            Ollama Pod │
                     │         StatefulSet            tinyllama  │
                     │              │                        │  │
                     │         10Gi PVC               30Gi PVC  │
                     └─────────────────────────────────────────┘
```

---

### 🚀 Step-by-Step KIND Deployment

#### Step 0 — Create KIND Cluster

```bash
# Check if cluster already exists
kind get clusters

# Create cluster (with port mappings pre-configured)
kind create cluster --name ollama-agent --config cluster-create/kind-cluster.yaml

# Verify
kubectl cluster-info --context kind-ollama-agent
kubectl get nodes

<<<<<<< HEAD
# 🚀 Ollama Agent — Kubernetes Deployment Guide Automated Create Resources but shell Scripts files 

This document covers **installation, deployment, access, and troubleshooting** for the Ollama Agent project on Kubernetes.

---

# 📦 1. Prerequisites

Ensure the following are installed:

* Kubernetes cluster (Docker Desktop / Minikube / EKS)
* kubectl CLI
* Docker (for building images)
* Git

---

# ⚙️ 2. Cluster Setup

### Enable Kubernetes (Docker Desktop)

* Go to Docker Desktop → Settings → Kubernetes → Enable

### Verify cluster:

```
kubectl get nodes
```

Expected:

* Node should be in `Ready` state

---

# 🌐 3. Install Ingress Controller

Ingress requires a controller to route traffic.

### Install NGINX Ingress:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

### Verify:

```
kubectl get pods -n ingress-nginx
```

Wait until:

```
1/1 Running
```

---

# 🚀 4. Deploy Application

Run the deployment script:

```
chmod +x apply-all.sh
./apply-all.sh
```

This will:

* Create namespace
* Deploy MongoDB
* Deploy backend
* Deploy frontend
* Apply ingress

---

# 🌐 5. Access Application

### Port forward ingress:

```
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
```

### Open in browser:

* Frontend → http://localhost:8080
* Backend → http://localhost:8080/api

---

# 🧪 6. Verify Deployment

Check all resources:

```
kubectl get pods -n ollama-agent
kubectl get svc -n ollama-agent
kubectl get ingress -n ollama-agent
```

---

# 🛠️ 7. Troubleshooting Guide

## 🔴 Pod stuck in Pending

### Cause:

* PVC not bound (storage issue)

### Check:

```
kubectl get pvc -n ollama-agent
```

### Fix:

* Use correct StorageClass for environment

  * Local → standard
  * AWS → EBS

---

## 🔴 Ingress not working

### Cause:

* Ingress controller missing OR class not set

### Fix:

* Ensure ingress controller is installed
* Ensure ingress has correct class

---

## 🔴 Port-forward not working

### Cause:

* Pod not ready

### Fix:

```
kubectl get pods -n ingress-nginx
```

Wait until pod shows:

```
1/1 Running
```

---

## 🔴 Backend not connecting to MongoDB

### Cause:

* MongoDB not ready

### Fix:

* Ensure MongoDB pod is running
* Check logs:

```
kubectl logs <pod-name> -n ollama-agent
```

---

## 🔴 Service not accessible

### Check:

```
kubectl get svc -n ollama-agent
```

Ensure:

* Services are created
* Ports are correct

---

# 🗑️ 8. Delete Deployment

### Safe delete (keep data):

```
./delete-all.sh
```

### Full delete (remove data):

```
./delete-all.sh --full
```

---

# 🧠 Notes

* Use different storage for different environments:

  * Local → standard
  * Cloud → EBS
* Always deploy ingress after services
* Use readiness and liveness probes for stability

---

# ✅ Status Check Commands

```
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
kubectl get pvc -A
```

---

# 🎯 Summary

* Deploy using `apply-all.sh`
* Access via ingress (localhost:8080)
* Debug using `kubectl describe` and `logs`
* Delete safely using `delete-all.sh`

---

# 🚀 Ollama Agent — Manual Kubernetes Deployment Guide (Fixed)

This guide explains how to deploy the application **step-by-step manually** with proper verification and troubleshooting.

---

# 📌 Prerequisites

* Kubernetes (Docker Desktop / Minikube / EKS)
* kubectl installed
* Docker installed

---

# 🧱 Step 0: Verify Cluster

```bash
kubectl get nodes
```

✅ Node must be `Ready`

---

# 🌐 Step 1: Install Ingress Controller (IMPORTANT)

👉 Without this, ingress will NOT work

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

### Verify:

```bash
kubectl get pods -n ingress-nginx
```

✅ Wait until:

```
1/1 Running
```

---

# 🧱 Step 2: Cluster Setup

```bash
kubectl apply -f k8s/cluster/namespace.yaml
kubectl apply -f k8s/cluster/storageclass.yaml
```

### Verify:

```bash
kubectl get ns
kubectl get storageclass
```

---

# 🍃 Step 3: MongoDB (FIRST)

```bash
kubectl apply -f k8s/mongodb/
```

---

### Verify:

```bash
kubectl get pods -n ollama-agent
kubectl get pvc -n ollama-agent
```

✅ Expected:

* Pod → Running
* PVC → Bound

---

### Troubleshooting MongoDB

```bash
kubectl describe pod ollama-mongodb-0 -n ollama-agent
kubectl get pvc -n ollama-agent
kubectl logs ollama-mongodb-0 -n ollama-agent
```

---

# ⚙️ Step 4: Backend

### Apply config first:

```bash
kubectl apply -f k8s/backend/secret.yaml
kubectl apply -f k8s/backend/configmap.yaml
```

---

### Deploy backend:

```bash
kubectl apply -f k8s/backend/deployment.yaml
kubectl apply -f k8s/backend/service.yaml
kubectl apply -f k8s/backend/hpa.yaml
```

---

### Verify:

```bash
kubectl get pods -n ollama-agent
kubectl get svc -n ollama-agent
```

---

### Troubleshooting:

```bash
kubectl describe pod <backend-pod> -n ollama-agent
kubectl logs <backend-pod> -n ollama-agent
```

---

# 🎨 Step 5: Frontend

```bash
kubectl apply -f k8s/frontend/
```

---

### Verify:

```bash
kubectl get pods -n ollama-agent
kubectl get svc -n ollama-agent
```

---

### Troubleshooting:

```bash
kubectl logs <frontend-pod> -n ollama-agent
```

---

# 🌐 Step 6: Apply Ingress (FIXED)

```bash
kubectl apply -f k8s/cluster/ingress.yaml
```

---

### Verify:

```bash
kubectl get ingress -n ollama-agent
```

---

### 🔴 IMPORTANT CHECK

Ensure your ingress has:

```
ingressClassName: nginx
```

---

### Troubleshooting Ingress

```bash
kubectl describe ingress -n ollama-agent
kubectl get pods -n ingress-nginx
```

---

# 🌍 Step 7: Access Application

### Port forward ingress:

```bash
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
kubectl port-forward -n ollama-agent service/ollama-backend-service 5005:5005
```

---

### Open:

* Frontend → http://localhost:8080
* Backend → http://localhost:8080/api

---

# 🧠 Master Debug Commands

```bash
kubectl get all -n ollama-agent
kubectl describe pod <pod-name> -n ollama-agent
kubectl logs <pod-name> -n ollama-agent
kubectl get events -n ollama-agent
```

---

# 🎯 Correct Deployment Order

```
1. Ingress Controller
2. Namespace + Storage
3. MongoDB
4. Backend
5. Frontend
6. Ingress
```

---

# ✅ Final Notes

* Always install ingress controller first
* Always deploy database before backend
* Always verify each step before moving ahead
* Always check logs when something fails

---


---

## 🆚 Docker vs Kubernetes

| Feature | Docker | Kubernetes |
|--------|--------|-----------|
| Run containers | ✅ | ✅ |
| Auto-restart | ❌ | ✅ |
| Auto-scale | ❌ | ✅ |
| Zero downtime deploy | ❌ | ✅ |
| Load balancing | ❌ | ✅ |
| Self-healing | ❌ | ✅ |
| Best use | Local | Production |

---

## 💡 One Line Summary

```text
namespace.yaml → Isolated environment
frontend/deployment.yaml → Run frontend pods
frontend/service.yaml → Expose frontend
frontend/hpa.yaml → Auto-scale frontend
frontend/configmap.yaml → Frontend config

backend/deployment.yaml → Run backend pods
backend/service.yaml → Backend internal access
backend/hpa.yaml → Auto-scale backend
backend/configmap.yaml → Backend config
backend/secret.yaml → Secure credentials

mongodb/statefulset.yaml → MongoDB deployment
mongodb/service.yaml → MongoDB access
mongodb/pvc.yaml → Persistent storage

cluster/ingress.yaml → Traffic routing
cluster/storageclass.yaml → AWS storage provisioning
=======
# Expected:
# NAME                         STATUS   ROLES           AGE
# ollama-agent-control-plane   Ready    control-plane   30s
>>>>>>> new-k8s
```

---

<<<<<<< HEAD
## 🏗️ Terraform — Coming Soon

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🚧  Terraform IaC scripts for AWS infrastructure          ║
║       (EC2, VPC, ALB, Route53) will be added here.          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 🎯 Interview Questions — Coming Soon

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🚧  Curated interview Q&A covering Node.js, React,        ║
║       MongoDB, Docker, Kubernetes, and AI/LLM topics        ║
║       will be added here.                                    ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```
# 🎯 DevOps + AI Interview Questions (Project-Based)

This section contains **real-world interview questions** based on this project covering:

* Docker
* Kubernetes
* Terraform
* AWS
* Git
* CI/CD
* AI / LLM / Ollama

---

# 🐳 Docker — 20 Questions

### 🔹 Basic

1. What is Docker and why is it used?
2. What is the difference between Docker Image and Container?
3. What is a Dockerfile?
4. What is Docker Hub?
5. Difference between `docker run` and `docker start`?

### 🔹 Intermediate

6. What is multi-stage build in Docker?
7. Difference between CMD and ENTRYPOINT?
8. What is Docker volume?
9. What is Docker network?
10. Difference between bridge and host network?

### 🔹 Advanced

11. How do you reduce Docker image size?
12. What is layer caching?
13. How do you handle environment variables in Docker?
14. What is docker-compose?

### 🔹 Scenario-Based

15. Your container crashes immediately after start — how will you debug?
16. Docker container is running but app not accessible — what will you check?
17. Image works locally but fails on server — why?
18. How will you run multiple services (frontend + backend + DB)?
19. How do you persist MongoDB data in Docker?
20. How do you deploy Docker containers to production?

---

# ☸️ Kubernetes — 20 Questions

### 🔹 Basic

1. What is Kubernetes?
2. What is a Pod?
3. What is a Deployment?
4. What is a Service?
5. Types of Services in Kubernetes?

### 🔹 Intermediate

6. What is ConfigMap?
7. What is Secret?
8. What is Ingress?
9. What is HPA?
10. Difference between Deployment and StatefulSet?

### 🔹 Advanced

11. What is rolling update?
12. What is readiness vs liveness probe?
13. What is PersistentVolume and PVC?
14. What is StorageClass?

### 🔹 Scenario-Based

15. Pod is in Pending state — how do you debug?
16. Backend cannot connect to MongoDB — what will you check?
17. Ingress is not working — possible reasons?
18. Pod is restarting again and again — how to debug?
19. How do you scale your application automatically?
20. How do you ensure zero downtime deployment?

---

# 🏗️ Terraform — 20 Questions

### 🔹 Basic

1. What is Terraform?
2. What is Infrastructure as Code?
3. What is provider in Terraform?
4. What is state file?
5. Difference between `terraform plan` and `apply`?

### 🔹 Intermediate

6. What is variable in Terraform?
7. What is output?
8. What is module?
9. What is remote backend?
10. What is lifecycle?

### 🔹 Advanced

11. What is state locking?
12. How do you manage secrets in Terraform?
13. What is dependency handling?
14. How do you reuse code?

### 🔹 Scenario-Based

15. Terraform state file is corrupted — what will you do?
16. You want to create EC2 + VPC — how will you structure?
17. How do you manage multiple environments (dev/prod)?
18. How do you destroy specific resource only?
19. How do you integrate Terraform with CI/CD?
20. How do you prevent accidental resource deletion?

---

# ☁️ AWS — 20 Questions

### 🔹 Basic

1. What is AWS?
2. What is EC2?
3. What is S3?
4. What is VPC?
5. What is IAM?

### 🔹 Intermediate

6. What is Load Balancer?
7. What is Auto Scaling?
8. Difference between Security Group and NACL?
9. What is EBS?
10. What is Route53?

### 🔹 Advanced

11. What is EKS?
12. What is CloudWatch?
13. What is CloudFront?
14. What is IAM Role vs User?

### 🔹 Scenario-Based

15. Your EC2 app is not accessible — what will you check?
16. How do you deploy Kubernetes on AWS?
17. How do you secure your infrastructure?
18. Your app is slow — how will you scale?
19. How do you design highly available architecture?
20. How do you reduce AWS cost?

---

# 🔧 Git — 20 Questions

### 🔹 Basic

1. What is Git?
2. What is repository?
3. Difference between git pull and fetch?
4. What is commit?
5. What is branch?

### 🔹 Intermediate

6. What is merge vs rebase?
7. What is conflict in Git?
8. What is .gitignore?
9. What is staging area?
10. What is tag?

### 🔹 Advanced

11. What is cherry-pick?
12. What is stash?
13. What is detached HEAD?
14. What is Git workflow?

### 🔹 Scenario-Based

15. You have merge conflict — how to resolve?
16. Accidentally pushed wrong code — what to do?
17. Need to undo last commit — how?
18. How to collaborate with team?
19. Difference between force push and normal push?
20. How do you manage versioning?

---

# 🔁 CI/CD — 20 Questions

### 🔹 Basic

1. What is CI/CD?
2. Difference between CI and CD?
3. What is pipeline?
4. What is build stage?
5. What is deploy stage?

### 🔹 Intermediate

6. What is GitHub Actions?
7. What is Jenkins?
8. What is artifact?
9. What is rollback?
10. What is environment (dev/staging/prod)?

### 🔹 Advanced

11. What is blue-green deployment?
12. What is canary deployment?
13. What is pipeline as code?
14. How do you secure secrets in CI/CD?

### 🔹 Scenario-Based

15. Pipeline fails — how do you debug?
16. Deployment breaks production — what to do?
17. How do you automate Docker build and push?
18. How do you deploy to Kubernetes via CI/CD?
19. How do you run tests before deployment?
20. How do you ensure zero downtime deployment?

---

# 🤖 AI / LLM / Ollama — 20 Questions

### 🔹 Basic

1. What is LLM?
2. What is Ollama?
3. What is prompt?
4. What is token?
5. What is inference?

### 🔹 Intermediate

6. What is streaming response?
7. What is context window?
8. What is model fine-tuning?
9. Difference between local LLM vs API (OpenAI)?
10. What is embedding?

### 🔹 Advanced

11. What is RAG (Retrieval-Augmented Generation)?
12. What is vector database?
13. What is latency in LLM?
14. What is hallucination?

### 🔹 Scenario-Based

15. LLM response is slow — how to optimize?
16. Model giving wrong answers — what to do?
17. How do you handle large documents?
18. How do you build AI agent?
19. How do you secure local LLM?
20. Why choose Ollama over cloud APIs?

---

# 🎯 Final Tip

👉 Practice these questions with your project examples
👉 Always explain using your real implementation

**Example:**

> “In my project, I used Kubernetes HPA to auto-scale backend pods based on CPU usage…”

---

## 🐞 Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `EADDRINUSE :5000` | Port in use (AirPlay on macOS) | `lsof -ti:5000 \| xargs kill -9` or change PORT in `.env` |
| `allowedHosts` error | Node.js version mismatch | Add `DANGEROUSLY_DISABLE_HOST_CHECK=true` to `frontend/.env` |
| `net::ERR_FAILED` on login | CORS blocked on macOS | Use manual `res.header()` CORS instead of `cors()` package |
| Login fails with correct password | Email case mismatch | Use `email.toLowerCase().trim()` in login route |
| Ollama not responding | Server not running | Run `ollama serve` in a separate terminal |
| MongoDB connection error | Service stopped | `brew services start mongodb-community` (macOS) |
| Model not found | Not pulled yet | `ollama pull llama2:latest` |
| Chat not streaming | Proxy misconfigured | Use full URL `http://localhost:5005` in fetch() calls |

---

## 📦 Production Build
=======
#### Step 1 — Install Nginx Ingress Controller
>>>>>>> new-k8s

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait until ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Verify
kubectl get pods -n ingress-nginx
```

> ⚠️ If you hit a 429 rate limit, use Helm instead:
> ```bash
> helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
> helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace
> ```

---

#### Step 2 — One-Command Deploy (Recommended)

```bash
chmod +x apply.sh
./apply.sh
```

The script handles everything in order: namespace → secret → MongoDB → Ollama (with model pull) → backend → frontend → ingress → port-forwards.

---

#### Manual Deploy (Step by Step)

```bash
# Namespace + Storage
kubectl apply -f cluster/namespace.yaml
kubectl apply -f cluster/storageclass.yaml

# Secret first (MongoDB needs credentials at startup)
kubectl apply -f backend/secret.yaml

# MongoDB
kubectl apply -f mongodb/persistentvolumeclaim.yaml
kubectl apply -f mongodb/service.yaml
kubectl apply -f mongodb/statefulset.yaml
kubectl rollout status statefulset/ollama-mongodb -n ollama-agent --timeout=180s

# Ollama (tinyllama ~600MB — takes 3-10 min on first run)
kubectl apply -f ollama/pvc.yaml
kubectl apply -f ollama/configmap.yaml
kubectl apply -f ollama/service.yaml
kubectl apply -f ollama/nodeport.yaml
kubectl apply -f ollama/deployment.yaml
kubectl rollout status deployment/ollama -n ollama-agent --timeout=600s

# Backend
kubectl apply -f backend/configmap.yaml
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml
kubectl apply -f backend/hpa.yaml
kubectl rollout status deployment/ollama-backend -n ollama-agent --timeout=120s

# Frontend
kubectl apply -f frontend/configmap.yaml
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml
kubectl apply -f frontend/hpa.yaml
kubectl rollout status deployment/ollama-frontend -n ollama-agent --timeout=120s

# Ingress
kubectl apply -f cluster/ingress.yaml
```

---

### 🔌 Port Forwarding

KIND doesn't have a cloud LoadBalancer — use port-forward to access services locally.

```bash
# All at once (background)
./port-forward.sh        # start
./port-forward.sh stop   # stop

# Or individually (separate terminals)
kubectl port-forward svc/ollama-frontend-service 3000:80 -n ollama-agent
kubectl port-forward svc/ollama-backend-service 5005:5005 -n ollama-agent
kubectl port-forward svc/ollama-service 11434:11434 -n ollama-agent
kubectl port-forward svc/ollama-mongodb 27017:27017 -n ollama-agent
```

| Service | URL |
|---------|-----|
| 🖥️ Frontend | http://localhost:3000 |
| ⚙️ Backend | http://localhost:5005 |
| 🤖 Ollama | http://localhost:11434 |
| 🤖 Ollama (NodePort) | http://localhost:31434 |
| 🗄️ MongoDB | localhost:27017 |

---

### 🏥 Health Checks

```bash
# Backend health
curl http://localhost:5005/api/health

# Ollama health
curl http://localhost:11434/api/version

# List downloaded models
curl http://localhost:11434/api/tags

# Test tinyllama directly
curl http://localhost:11434/api/generate -d '{
  "model": "tinyllama",
  "prompt": "Hello!",
  "stream": false
}'
```

---

### 🛠️ Useful Debug Commands

```bash
# See all resources
kubectl get all -n ollama-agent

# Watch pods in real time
kubectl get pods -n ollama-agent -w

# Watch tinyllama downloading
kubectl logs -f -n ollama-agent \
  $(kubectl get pod -n ollama-agent -l app=ollama -o jsonpath='{.items[0].metadata.name}') \
  -c pull-tinyllama

# Pod logs
kubectl logs -f deployment/ollama-backend -n ollama-agent
kubectl logs -f deployment/ollama-frontend -n ollama-agent
kubectl logs -f statefulset/ollama-mongodb -n ollama-agent

# Describe a pod (great for debugging CrashLoopBackOff)
kubectl describe pod <pod-name> -n ollama-agent

# Shell into a running pod
kubectl exec -it deployment/ollama-backend -n ollama-agent -- /bin/sh
kubectl exec -it statefulset/ollama-mongodb -n ollama-agent -- mongosh

# Check events (shows what Kubernetes is doing)
kubectl get events -n ollama-agent --sort-by='.lastTimestamp'

# Check HPA scaling decisions
kubectl get hpa -n ollama-agent

# Check PVC status
kubectl get pvc -n ollama-agent
```

---

### 🗑️ Teardown

```bash
chmod +x destroy.sh
./destroy.sh
# Asks confirmation → yes/no
# Stops port-forwards → deletes K8s resources → deletes KIND cluster → cleans Docker
```

Manual cleanup:
```bash
kubectl delete namespace ollama-agent
kubectl delete namespace ingress-nginx
kind delete cluster --name ollama-agent
```

---

### 🐞 Troubleshooting

**PVC stuck in Pending:**
```bash
kubectl get pvc -n ollama-agent
kubectl describe pvc mongodb-pvc -n ollama-agent
# Fix: ensure storageclass.yaml was applied first
```

**Pod in CrashLoopBackOff:**
```bash
kubectl logs -n ollama-agent <pod-name> --previous
kubectl describe pod -n ollama-agent <pod-name>
# Common causes: wrong secret key name, wrong service DNS, wrong port
```

**initContainer stuck (nc: bad address):**
```bash
# Means the service DNS doesn't match — check service name
kubectl get svc -n ollama-agent
# Match the name exactly in your deployment initContainer
```

**ImagePullBackOff:**
```bash
kubectl describe pod <pod-name> -n ollama-agent | grep -A5 "Events"
# Fix: check image name matches exactly what's on DockerHub
```

**Ingress not routing:**
```bash
kubectl get pods -n ingress-nginx         # controller must be Running
kubectl describe ingress -n ollama-agent  # check rules and backend service names
```

---

## 🌐 API Reference

### Auth Routes (Public)

| Method | Endpoint | Description | Body |
|--------|----------|-------------|------|
| `POST` | `/api/auth/signup` | Create account | `{username, email, password}` |
| `POST` | `/api/auth/login` | Login | `{email, password}` |
| `GET` | `/api/auth/me` | Get current user | `Authorization: Bearer <token>` |

### Chat Routes (Requires JWT)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/chat/message` | Send message (SSE streaming response) |
| `GET` | `/api/chat/history` | Get all chats for logged-in user |
| `GET` | `/api/chat/:chatId` | Load a specific chat |
| `DELETE` | `/api/chat/:chatId` | Delete a chat |
| `GET` | `/api/chat/models/list` | List available Ollama models |

### Test with curl

```bash
# Signup
curl -X POST http://localhost:5005/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"123456"}'

# Login — save the token
TOKEN=$(curl -s -X POST http://localhost:5005/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}' | jq -r '.token')

# Send a chat message
curl -X POST http://localhost:5005/api/chat/message \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello AI!","model":"tinyllama"}'
```

---

## ☁️ AWS EC2 Deployment

### Recommended Instance Types

| Model | RAM Needed | EC2 Instance | vCPUs | Est. Cost/mo |
|-------|-----------|--------------|-------|--------------|
| tinyllama / phi | 4 GB | `t3.medium` | 2 | ~$30 |
| llama2 / mistral | 8 GB | `t3.large` | 2 | ~$60 |
| llama3 / codellama | 16 GB | `t3.xlarge` | 4 | ~$120 |
| Multiple models | 32 GB | `m5.2xlarge` | 8 | ~$280 |

### Security Group Inbound Rules

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | Your IP only | SSH access |
| 80 | TCP | 0.0.0.0/0 | HTTP |
| 443 | TCP | 0.0.0.0/0 | HTTPS |
| 3000 | TCP | 0.0.0.0/0 | Frontend (dev) |
| 5005 | TCP | 0.0.0.0/0 | Backend (dev) |
| 11434 | TCP | 127.0.0.1/32 | Ollama (localhost only — never expose publicly) |

> ⚠️ **Never expose port 11434 to the internet.** Anyone can query your Ollama and use your server's resources.

### EC2 Setup Script (Ubuntu 22.04)

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip

# System update
sudo apt-get update && sudo apt-get upgrade -y

# Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# MongoDB
sudo apt-get install -y mongodb
sudo systemctl start mongodb && sudo systemctl enable mongodb

# Ollama
curl -fsSL https://ollama.ai/install.sh | sh
ollama serve &
ollama pull tinyllama

# App
git clone https://github.com/techwithburhan/ollama-agent.git
cd ollama-agent/backend && npm install
NODE_ENV=production npm start &

cd ../frontend && npm install && npm run build
# Serve build with nginx or serve package
```

---

## 🎯 Interview Questions & Answers

This section covers real interview questions for DevOps, cloud, and backend engineering roles — based exactly on the tech used in this project.

---

### 🐳 Docker Questions

**Q: What is the difference between a Docker image and a Docker container?**
> A Docker image is a read-only blueprint — it contains your app code, dependencies, and OS layers. A container is a running instance of that image. You can run multiple containers from the same image, each isolated from the others.

**Q: What is a multi-stage Docker build and why did you use it here?**
> A multi-stage build uses multiple `FROM` statements in one Dockerfile. For the frontend, Stage 1 uses a Node.js image to `npm run build`, creating the static files. Stage 2 uses a lightweight Nginx image to serve only those static files — the final image has no Node.js, no source code, no dev dependencies. This makes the production image 10x smaller and more secure.

**Q: What is `host.docker.internal` and when do you use it?**
> It's a DNS name that resolves to the host machine's IP from inside a Docker container. We use it in `docker-compose.yml` so the backend container can reach Ollama, which runs on the host (not in Docker). On Linux, you may need to add `--add-host=host.docker.internal:host-gateway`.

**Q: What does `restart: always` do in Docker Compose?**
> It tells Docker to automatically restart the container if it exits for any reason — including crashes, OOM kills, or server reboots. Combined with `depends_on`, it ensures services come back in the right order.

**Q: What is the difference between `COPY` and `ADD` in a Dockerfile?**
> `COPY` simply copies files from the build context into the image. `ADD` does the same but also supports extracting tar archives and fetching URLs. Best practice is to always use `COPY` unless you specifically need the extra functionality of `ADD`.

---

### ☸️ Kubernetes Questions

**Q: What is the difference between a Deployment and a StatefulSet?**
> A Deployment is for stateless apps — pods are interchangeable, can be created/deleted in any order, and don't need stable network identity. A StatefulSet is for stateful apps like databases — each pod gets a stable hostname (e.g., `mongodb-0`, `mongodb-1`), persistent storage, and pods are created/deleted in order. MongoDB uses StatefulSet because it needs stable identity for replication and consistent storage.

**Q: What is a Headless Service and why does MongoDB use one?**
> A regular Service has a ClusterIP that load-balances traffic across pods. A Headless Service (`clusterIP: None`) has no ClusterIP — instead, DNS returns the IPs of individual pods directly. MongoDB's StatefulSet uses a Headless Service so each pod is addressable by its stable DNS name (`mongodb-0.ollama-mongodb`), which is required for database replication.

**Q: What is a PersistentVolumeClaim (PVC) and why is it important?**
> A PVC is a request for storage by a pod. Without a PVC, all data inside a pod is lost when the pod restarts. With a PVC, the storage is provisioned independently — MongoDB data survives pod crashes, reschedules, and cluster restarts. The PVC outlives the pod.

**Q: How does Horizontal Pod Autoscaler (HPA) work?**
> HPA continuously monitors CPU/memory usage of pods and compares it to the target threshold (e.g., 70% CPU). If usage exceeds the threshold, it increases replicas. If usage drops, it scales back down — respecting `minReplicas` and `maxReplicas`. It requires Metrics Server to be running in the cluster.

**Q: What is an initContainer and why did you use one?**
> An initContainer runs to completion before the main container starts. We use `wait-for-mongodb` to loop `nc -z ollama-mongodb 27017` until MongoDB accepts connections. This prevents the backend from starting before its database is ready — avoiding startup crashes.

**Q: What is the difference between ClusterIP, NodePort, and LoadBalancer services?**
> `ClusterIP` exposes the service only inside the cluster — other pods can reach it but external traffic cannot. `NodePort` opens a port on every cluster node so external traffic can reach the service directly. `LoadBalancer` provisions a cloud load balancer (AWS ELB, GCP LB) for external traffic — doesn't work in KIND without MetalLB. In this project we use ClusterIP for internal services and port-forward to access them locally.

**Q: What is an Ingress and how is it different from a Service?**
> A Service exposes one app on one port. An Ingress is an L7 (HTTP/HTTPS) router that can route traffic to multiple services based on path or hostname — `/` goes to frontend, `/api` goes to backend. It requires an Ingress Controller (we use nginx) to process the rules. One Ingress replaces multiple LoadBalancer services, reducing cloud costs.

**Q: What is a ConfigMap vs a Secret?**
> Both inject configuration into pods as environment variables or files. ConfigMap is for non-sensitive data (API URLs, model names, port numbers). Secret is for sensitive data (JWT keys, passwords, connection strings) — values are base64-encoded and can be encrypted at rest. Secrets also don't appear in `kubectl describe pod` output.

**Q: What happens when a pod crashes in Kubernetes?**
> Kubernetes detects the crash via liveness probes, then restarts the pod automatically (following the restart policy). If it keeps crashing (e.g., 5 times in a row), it enters `CrashLoopBackOff` and waits with increasing delays before retrying. The Deployment controller ensures the desired replica count is always maintained.

**Q: What is a Rolling Update and how does zero-downtime deployment work?**
> With `strategy: RollingUpdate`, Kubernetes creates a new pod with the updated image, waits for it to pass readiness probes, then terminates one old pod. This repeats until all pods are updated. At no point are all pods offline simultaneously. `maxUnavailable: 1` means at most 1 old pod can be offline, and `maxSurge: 1` allows 1 extra pod during the update.

---

### 🔐 Auth & Security Questions

**Q: How does JWT authentication work in this project?**
> On login, the backend creates a JWT signed with `JWT_SECRET` containing the user ID and expiry. The frontend stores this token and sends it in the `Authorization: Bearer <token>` header on every API request. The `auth.js` middleware verifies the signature and extracts the user ID — no database lookup needed on every request.

**Q: Why use bcrypt for passwords instead of MD5 or SHA256?**
> bcrypt is a slow hashing algorithm by design — it's computationally expensive to compute, making brute-force attacks impractical. MD5 and SHA256 are fast hash functions designed for speed, not security — they can be cracked with rainbow tables or GPU brute-force in seconds. bcrypt also includes a salt automatically, preventing rainbow table attacks.

**Q: Why is Ollama port 11434 restricted to localhost?**
> If port 11434 is exposed publicly, anyone on the internet can send requests to your Ollama instance, run queries, and consume your server's CPU/RAM — effectively using your server as a free AI API. Always restrict it to `127.0.0.1` or internal cluster traffic only.

---

### ⚡ Streaming & Performance Questions

**Q: What are Server-Sent Events (SSE) and why use them instead of WebSockets?**
> SSE is a one-way HTTP connection where the server pushes data to the client in real time. WebSockets are bidirectional. For AI chat, the server streams tokens as they're generated — the client never needs to send data back during generation. SSE is simpler, works over HTTP/1.1, and handles reconnection automatically. WebSockets require a persistent bidirectional connection which adds complexity.

**Q: Why does Nginx need `proxy_buffering off` for SSE?**
> By default, Nginx buffers the entire response before forwarding it to the client. With SSE, the response is a continuous stream — if Nginx buffers it, the client receives nothing until the entire AI response is complete, breaking the real-time effect. `proxy_buffering off` makes Nginx forward each chunk immediately as it arrives from the backend.

---

## 🗺️ Full Project Roadmap

```
ollama-agent/
│
├── ✅ Full Stack Application
│   ├── ⚛️  Frontend: React.js 18 + GSAP
│   ├── 🖥️  Backend: Node.js + Express
│   └── 🗄️  Database: MongoDB
│
├── ✅ Containerization
│   ├── 🐳 Docker (Multi-stage builds)
│   └── 🐙 Docker Compose (Local dev)
│
├── ✅ Kubernetes Deployment
│   ├── ☸️  KIND (Local K8s)
│   ├── 📦 Deployments + StatefulSet
│   ├── 📈 HPA (Auto Scaling)
│   ├── 🌐 Ingress (nginx)
│   └── 🔐 Secrets + ConfigMaps + PVC
│
├── 🚧 CI/CD Pipeline
│   └── GitHub Actions (Build → Test → Push → Deploy)
│
├── 🚧 Infrastructure as Code
│   └── Terraform (AWS VPC + EC2 + EKS)
│
├── 🚧 Cloud Deployment
│   └── AWS EKS (Managed Kubernetes)
│
└── 🚧 Monitoring & Observability
    ├── Prometheus (Metrics collection)
    └── Grafana (Dashboards + Alerts)
```

---

## ⭐ Support the Project

If this project helped you learn or land a job — please give back:

- ⭐ **Star** this repository
- 👍 **Like** the YouTube video
- 🔔 **Subscribe** to the channel
- 🔗 **Share** with your network

> Every star and subscribe helps create more free DevOps + AI content! 🙏

---

## 📲 Connect with @techwithburhan

<div align="center">

| Platform | Link |
|----------|------|
| 🎬 YouTube — DevOps \| AI \| AWS Cloud | [youtube.com/@TechWithBurhanHQ](https://www.youtube.com/@TechWithBurhanHQ) |
| 🎬 YouTube — CCNA \| CCNP \| Networking | [youtube.com/@codewithburhan1](https://youtube.com/@codewithburhan1) |
| 💼 LinkedIn | [linkedin.com/in/techwithburhan](https://linkedin.com/in/techwithburhan) |
| 📸 Instagram | [instagram.com/techwithburhan](https://instagram.com/techwithburhan) |
| 🌐 Agency | [techdeployers.com](https://techdeployers.com) |
| 🐙 GitHub | [github.com/techwithburhan](https://github.com/techwithburhan) |

</div>

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=100&section=footer" width="100%"/>

**Built with ❤️ by [@techwithburhan](https://github.com/techwithburhan)**

*React • Node.js • MongoDB • Ollama • Docker • Kubernetes*

</div>