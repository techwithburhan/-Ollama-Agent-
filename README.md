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
> Built for DevOps engineers who want real-world hands-on experience with containerization, orchestration, and local AI.

<br/>

[🚀 Quick Install](#-quick-install) • [✨ Features](#-features) • [📁 Structure](#-project-structure) • [🐳 Docker](#-docker) • [☸️ Kubernetes](#️-kubernetes-kind) • [🌐 API Docs](#-api-reference) • [☁️ AWS EC2](#️-aws-ec2-deployment) • [🎯 Interview Q&A](#-interview-questions--answers)

---

</div>

<img width="1470" height="835" alt="Ollama Agent Chat UI" src="https://github.com/user-attachments/assets/b4b6cbdc-95c3-48d8-9220-f457da84a3ff" />
<br/>
<img width="1470" height="835" alt="Ollama Agent Login" src="https://github.com/user-attachments/assets/a4cc83d7-7c2b-42ef-a4d9-fe204d732c6d" />

---

## 📖 What Is This Project?

**Ollama Agent** is a production-grade, fully offline AI chat application that runs powerful Large Language Models directly on your own machine — zero internet required, zero API costs, complete data privacy.

Think of it as your own private ChatGPT — running entirely on your laptop or server, secured with JWT authentication, real-time streaming via SSE, voice input/output, and document attachment support.

This project covers the **entire DevOps lifecycle**:

```
Code → Docker → Docker Compose → Kubernetes (KIND) → AWS EC2 → EKS (coming)
```

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔒 **100% Offline & Private** | Prompts and data never leave your machine |
| ⚡ **Real-time Streaming** | Token-by-token responses via Server-Sent Events (SSE) |
| 🎤 **Voice Input** | Speak your prompts — Web Speech API (browser native) |
| 🔊 **Text-to-Speech** | AI responses read aloud via SpeechSynthesis API |
| 📎 **Document Attachment** | Attach PDF, TXT, CSV, JSON, code files |
| 🤖 **Multi-Model Support** | Switch between tinyllama, llama2, mistral, llama3, codellama, phi |
| 💬 **Chat History** | Conversations persisted to MongoDB per user |
| 🔐 **JWT Authentication** | Secure signup/login with bcrypt password hashing |
| 🎨 **Glassmorphism UI** | Dark theme with GSAP animations |
| 🗂️ **Chat Management** | Create, load, rename, and delete conversations |
| 📱 **Responsive Design** | Collapsible sidebar with full-height chat layout |
| 🐳 **Fully Containerized** | Docker + Docker Compose ready |
| ☸️ **Kubernetes Ready** | KIND cluster with HPA, Ingress, Secrets, PVC |

---

## 🛠️ Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| **Frontend** | React.js 18 + React Router v6 | Component-based SPA with protected routes |
| **Animations** | GSAP 3 | Smooth glassmorphism UI transitions |
| **HTTP Client** | Axios | API calls with JWT interceptors |
| **Backend** | Node.js + Express.js | Non-blocking I/O — perfect for SSE streaming |
| **Database** | MongoDB + Mongoose | Flexible document model for chat history |
| **Auth** | JWT + bcryptjs | Stateless auth — scales horizontally |
| **AI Engine** | Ollama (Local LLM) | Run LLMs locally with a REST API |
| **Streaming** | Server-Sent Events (SSE) | One-way real-time stream from server to browser |
| **Voice Input** | Web Speech API | Browser-native, no libraries needed |
| **Voice Output** | SpeechSynthesis API | Browser-native text-to-speech |
| **Container** | Docker + Docker Compose | Isolation, portability, reproducibility |
| **Orchestration** | Kubernetes (KIND) | Auto-scaling, self-healing, rolling updates |

---

## 📁 Project Structure

```
ollama-agent/
│
├── 🎨 frontend/
│   ├── public/index.html
│   ├── src/
│   │   ├── context/AuthContext.js        # Global auth state + JWT storage
│   │   ├── pages/
│   │   │   ├── Login.js                  # Login page with GSAP animations
│   │   │   ├── Signup.js                 # Signup page with GSAP animations
│   │   │   └── Chat.js                   # Main chat (streaming + voice + files)
│   │   ├── App.js                        # Router + protected route guards
│   │   ├── index.js                      # React entry point
│   │   └── index.css                     # Glassmorphism CSS variables
│   ├── Dockerfile                        # Multi-stage: Node build → Nginx serve
│   └── package.json
│
├── ⚙️ backend/
│   ├── models/
│   │   ├── User.js                       # User schema with bcrypt pre-save hook
│   │   └── Chat.js                       # Chat + message schema
│   ├── routes/
│   │   ├── auth.js                       # POST /signup /login  GET /me
│   │   └── chat.js                       # SSE streaming + history CRUD
│   ├── middleware/auth.js                # JWT verify middleware
│   ├── server.js                         # Express app + MongoDB connection
│   ├── Dockerfile                        # Node.js production image
│   ├── .env                              # ⚠️ Never commit — in .gitignore
│   └── package.json
│
├── ☸️ k8s/
│   ├── cluster-create/
│   │   └── kind-cluster.yaml             # KIND cluster config with port mappings
│   ├── cluster/
│   │   ├── namespace.yaml                # ollama-agent namespace
│   │   ├── storageclass.yaml             # local-path (KIND built-in)
│   │   └── ingress.yaml                  # HTTP routing + SSE support
│   ├── mongodb/
│   │   ├── persistentvolumeclaim.yaml    # 10Gi local storage
│   │   ├── service.yaml                  # Headless ClusterIP
│   │   └── statefulset.yaml              # MongoDB with health checks
│   ├── backend/
│   │   ├── secret.yaml                   # JWT + MongoDB URI (base64)
│   │   ├── configmap.yaml                # Port, Ollama URL, model name
│   │   ├── deployment.yaml               # 1 replica + initContainer
│   │   ├── service.yaml                  # ClusterIP :5005
│   │   └── hpa.yaml                      # 2–10 pods auto-scale
│   ├── frontend/
│   │   ├── configmap.yaml                # Nginx config + API URL
│   │   ├── deployment.yaml               # 2 replicas + initContainer
│   │   ├── service.yaml                  # ClusterIP :80
│   │   └── hpa.yaml                      # 2–8 pods auto-scale
│   ├── ollama/
│   │   ├── pvc.yaml                      # 30Gi local storage (models persist)
│   │   ├── configmap.yaml                # Ollama settings
│   │   ├── deployment.yaml               # tinyllama auto-pull initContainer
│   │   ├── service.yaml                  # ClusterIP :11434
│   │   └── nodeport.yaml                 # NodePort 31434 for debug
│   ├── apply.sh                          # 🚀 One-command full deploy
│   ├── destroy.sh                        # 💣 One-command full teardown
│   └── port-forward.sh                   # 🔌 All port-forwards in one shot
│
├── 🐳 docker-compose.yml
├── mongo-init.js                         # Auto-create collections on first boot
└── README.md
```

---

## ✅ Prerequisites

### Local Development

| Tool | Min Version | Install |
|------|------------|---------|
| Node.js | v18+ | https://nodejs.org |
| MongoDB | v6+ | https://mongodb.com/try/download/community |
| Ollama | Latest | https://ollama.ai |
| Git | Any | https://git-scm.com |

### Docker & Kubernetes

| Tool | Min Version | Install |
|------|------------|---------|
| Docker | v24+ | https://docker.com |
| Docker Compose | v2+ | Included with Docker Desktop |
| kubectl | v1.27+ | https://kubernetes.io/docs/tasks/tools |
| KIND | v0.20+ | https://kind.sigs.k8s.io |

### AWS EC2 — Recommended Specs

| Resource | Recommendation |
|----------|---------------|
| Instance | **`t2.large`** (2 vCPU, 8 GB RAM) ✅ |
| Storage | 30 GB gp3 EBS |
| OS | Ubuntu 22.04 LTS |
| Open Ports | 22, 80, 443, 3000, 5005 |
| Restricted | 11434 → localhost only |

> 💡 `t2.medium` works only for tinyllama/phi. Use **`t2.large`** for llama2, mistral, or llama3.

---

## 🚀 Quick Install

### Step 1 — Install Docker, KIND & kubectl (Linux / EC2)

```bash
chmod +x install.sh
./install.sh

# Activate Docker group after script finishes
newgrp docker
```

### Step 2 — Deploy Everything

```bash
chmod +x apply.sh
./apply.sh
```

Open **http://localhost:3000** → Sign up → Start chatting 🎉

---

## 🚀 Local Quick Start (No Docker/K8s)

### Step 1 — Install & Run Ollama

```bash
# macOS / Linux
curl -fsSL https://ollama.ai/install.sh | sh

# Windows → https://ollama.ai/download/windows

# Pull a model (choose based on your RAM)
ollama pull tinyllama   # 637 MB  — 4 GB RAM ✅ fastest
ollama pull phi         # 1.7 GB  — lowest RAM
ollama pull llama2      # 3.8 GB  — general purpose ✅ recommended
ollama pull mistral     # 4.1 GB  — fast + efficient
ollama pull llama3      # 4.7 GB  — best quality
ollama pull codellama   # 3.8 GB  — code focused

# Start server
ollama serve
```

> ✅ Verify: `curl http://localhost:11434/api/version`

---

### Step 2 — Backend Setup

```bash
cd ollama-agent/backend
npm install

# Generate secure JWT secret
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
# ✅ MongoDB Connected
# 🚀 Server running on http://localhost:5005
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
# Opens at http://localhost:3000
```

---

### Step 4 — Run All Together

```bash
# Terminal 1 — AI Engine
ollama serve

# Terminal 2 — Backend API
cd backend && npm run dev

# Terminal 3 — Frontend
cd frontend && npm start
```

---

## 🐳 Docker

### Why Docker?

```
Before Docker                      After Docker
─────────────────────              ─────────────────────
❌ Manual Node.js install          ✅ docker build → done
❌ MongoDB setup + config          ✅ docker run → running
❌ "Works on my machine"           ✅ Same on all machines
❌ Complex deployment              ✅ Push image, pull, run
❌ Dependency conflicts            ✅ Isolated containers
```

### Login to DockerHub

```bash
docker login -u burhan503
```

### 🎨 Frontend — Build & Push

```bash
cd frontend
docker build -t burhan503/ollama-agent-frontend:latest .
docker run -d -p 3000:80 --name frontend burhan503/ollama-agent-frontend
docker push burhan503/ollama-agent-frontend:latest
```

### ⚙️ Backend — Build & Push

```bash
cd backend
docker build -t burhan503/ollama-agent-backend:latest .
docker run -d -p 5005:5005 --env-file .env --name backend burhan503/ollama-agent-backend
docker push burhan503/ollama-agent-backend:latest
```

### Verify Images

```bash
docker images | grep burhan503
# burhan503/ollama-agent-backend     latest   ...
# burhan503/ollama-agent-frontend    latest   ...
```

### Stop & Clean

```bash
docker stop $(docker ps -q --filter "publish=5005")
docker stop $(docker ps -q --filter "publish=3000")
docker rmi -f burhan503/ollama-agent-frontend:latest burhan503/ollama-agent-backend:latest
```

---

## 🐙 Docker Compose

### `docker-compose.yml`

```yaml
version: "3.8"

services:

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

> 💡 `host.docker.internal` lets containers reach Ollama on the host machine. On Linux add `--add-host=host.docker.internal:host-gateway`.

### `mongo-init.js`

```javascript
db = db.getSiblingDB("ollama-agent");
db.createCollection("users");
db.createCollection("chats");
```

### Run Commands

```bash
docker-compose up -d          # Start all
docker-compose ps             # Status
docker-compose logs -f        # Live logs
docker-compose down           # Stop
docker-compose down -v        # Stop + wipe MongoDB data
```

### Verify MongoDB

```bash
docker exec -it ollama-mongodb mongosh -u admin -p burhan503 --authenticationDatabase admin
show dbs
use ollama-agent
show collections
# Expected: users  chats
```

### Docker Utilities

```bash
docker volume ls
docker volume inspect mongo-data
docker network ls
docker network inspect ollama-network
docker system prune -f
```

---

## 🆚 Docker vs Kubernetes

| Feature | Docker | Kubernetes |
|---------|--------|-----------|
| Run containers | ✅ | ✅ |
| Auto-restart on crash | ❌ | ✅ |
| Auto-scale on traffic | ❌ | ✅ |
| Zero downtime deploy | ❌ | ✅ |
| Load balancing | ❌ | ✅ |
| Self-healing | ❌ | ✅ |
| Multi-node support | ❌ | ✅ |
| Best use | Local dev | Production |

---

## ☸️ Kubernetes (KIND)

### Why Kubernetes?

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

### 📋 What Each Manifest Does

| File | What It Does | Why It Matters |
|------|-------------|----------------|
| `namespace.yaml` | Creates isolated `ollama-agent` namespace | Prevents conflicts with other apps |
| `storageclass.yaml` | Defines storage provisioner (local-path for KIND) | Tells K8s how to create volumes |
| `ingress.yaml` | Routes HTTP traffic to frontend/backend | Single entry point |
| `secret.yaml` | Stores JWT + MongoDB URI as base64 | Sensitive data separated from code |
| `configmap.yaml` | Stores non-sensitive env vars | Decouples config from images |
| `deployment.yaml` | Runs pods, manages replicas + rolling updates | Core workload definition |
| `service.yaml` | Stable DNS name for pods | Pods have dynamic IPs — Service fixes that |
| `hpa.yaml` | Auto-scales pods on CPU/memory | Handles traffic spikes |
| `statefulset.yaml` | Runs MongoDB with stable identity | Databases need stable hostname + storage |
| `persistentvolumeclaim.yaml` | Requests storage for MongoDB | Data survives pod restarts |

### 🔄 Architecture

```
                ┌────────────────────────────────────────────┐
                │              KIND Cluster                  │
                │                                            │
 Internet       │   ┌──────────┐                            │
 ──── :80 ──────┼──►│  Ingress │                            │
                │   └──────────┘                            │
                │        │                                   │
                │        ├── /      ──► Frontend Svc :80    │
                │        │               │                   │
                │        │           Frontend Pods           │
                │        │           [HPA: 2–8 pods]         │
                │        │                                   │
                │        └── /api   ──► Backend Svc :5005   │
                │                        │                   │
                │                    Backend Pods            │
                │                    [HPA: 2–10 pods]        │
                │                    [ConfigMap + Secret]    │
                │                        │                   │
                │            ┌───────────┴──────────┐        │
                │            │                      │        │
                │       MongoDB Svc            Ollama Svc    │
                │     Headless :27017          :11434        │
                │            │                      │        │
                │       MongoDB Pod          Ollama Pod      │
                │       StatefulSet          tinyllama       │
                │            │                      │        │
                │        10Gi PVC              30Gi PVC      │
                └────────────────────────────────────────────┘
```

### 🚀 Step-by-Step KIND Deployment

#### Step 0 — Verify Prerequisites

```bash
docker --version          # Docker 24+
kind --version            # kind v0.20+
kubectl version --client  # v1.27+

# Not installed? Run:
chmod +x install.sh && ./install.sh && newgrp docker
```

#### Step 1 — Create KIND Cluster

```bash
# Check existing clusters
kind get clusters

# Create with pre-configured port mappings
kind create cluster --name ollama-agent --config cluster-create/kind-cluster.yaml

# Verify
kubectl cluster-info --context kind-ollama-agent
kubectl get nodes
# Expected:
# NAME                         STATUS   ROLES           AGE
# ollama-agent-control-plane   Ready    control-plane   30s
```

#### Step 2 — Install Nginx Ingress Controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

kubectl get pods -n ingress-nginx
# Expected: 1/1 Running
```

> ⚠️ Hit 429 rate limit? Use Helm:
> ```bash
> helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
> helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace
> ```

#### Step 3 — Deploy Everything (One Command)

```bash
chmod +x apply.sh && ./apply.sh
```

#### Manual Step-by-Step Deploy

```bash
# 1. Namespace + Storage
kubectl apply -f cluster/namespace.yaml
kubectl apply -f cluster/storageclass.yaml
kubectl get namespace ollama-agent && kubectl get storageclass

# 2. Secret FIRST (MongoDB reads credentials at startup)
kubectl apply -f backend/secret.yaml
kubectl get secret -n ollama-agent

# 3. MongoDB
kubectl apply -f mongodb/persistentvolumeclaim.yaml
kubectl apply -f mongodb/service.yaml
kubectl apply -f mongodb/statefulset.yaml
kubectl rollout status statefulset/ollama-mongodb -n ollama-agent --timeout=180s
# Verify: pod Running + PVC Bound
kubectl get pods -n ollama-agent | grep mongodb
kubectl get pvc -n ollama-agent

# 4. Ollama (tinyllama ~600MB — first run: 3–10 min)
kubectl apply -f ollama/pvc.yaml
kubectl apply -f ollama/configmap.yaml
kubectl apply -f ollama/service.yaml
kubectl apply -f ollama/nodeport.yaml
kubectl apply -f ollama/deployment.yaml
kubectl rollout status deployment/ollama -n ollama-agent --timeout=600s

# Watch model downloading in real time
kubectl logs -f -n ollama-agent \
  $(kubectl get pod -n ollama-agent -l app=ollama -o jsonpath='{.items[0].metadata.name}') \
  -c pull-tinyllama

# 5. Backend
kubectl apply -f backend/configmap.yaml
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml
kubectl apply -f backend/hpa.yaml
kubectl rollout status deployment/ollama-backend -n ollama-agent --timeout=120s

# 6. Frontend
kubectl apply -f frontend/configmap.yaml
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml
kubectl apply -f frontend/hpa.yaml
kubectl rollout status deployment/ollama-frontend -n ollama-agent --timeout=120s

# 7. Ingress (ALWAYS LAST — all services must exist first)
kubectl apply -f cluster/ingress.yaml
kubectl get ingress -n ollama-agent
```

### 🔌 Port Forwarding

```bash
./port-forward.sh          # start all (background)
./port-forward.sh stop     # stop all

# Or individually
kubectl port-forward svc/ollama-frontend-service 3000:80 -n ollama-agent --address 0.0.0.0
kubectl port-forward svc/ollama-backend-service 5005:5005 -n ollama-agent --address 0.0.0.0
kubectl port-forward svc/ollama-service 11434:11434 -n ollama-agent
kubectl port-forward svc/ollama-mongodb 27017:27017 -n ollama-agent

# Or via Ingress
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
```

| Service | URL |
|---------|-----|
| 🖥️ Frontend | http://localhost:3000 |
| ⚙️ Backend | http://localhost:5005 |
| 🤖 Ollama | http://localhost:11434 |
| 🤖 Ollama NodePort | http://localhost:31434 |
| 🗄️ MongoDB | localhost:27017 |
| 🌐 Via Ingress | http://localhost:8080 |

### 🏥 Health Checks

```bash
curl http://localhost:5005/api/health
curl http://localhost:11434/api/version
curl http://localhost:11434/api/tags
curl http://localhost:11434/api/generate -d '{"model":"tinyllama","prompt":"Hello!","stream":false}'
```

### 🛠️ Debug Commands

```bash
kubectl get all -n ollama-agent
kubectl get pods -n ollama-agent -w
kubectl logs -f deployment/ollama-backend -n ollama-agent
kubectl logs -f deployment/ollama-frontend -n ollama-agent
kubectl logs -f statefulset/ollama-mongodb -n ollama-agent
kubectl describe pod <pod-name> -n ollama-agent
kubectl exec -it deployment/ollama-backend -n ollama-agent -- /bin/sh
kubectl exec -it statefulset/ollama-mongodb -n ollama-agent -- mongosh
kubectl get events -n ollama-agent --sort-by='.lastTimestamp'
kubectl get hpa -n ollama-agent
kubectl get pvc -n ollama-agent
kubectl get pods -A && kubectl get svc -A && kubectl get ingress -A
```

### 🗑️ Teardown

```bash
chmod +x destroy.sh && ./destroy.sh
# Confirmation prompt → kills port-forwards → deletes K8s → deletes KIND → cleans Docker

# Manual
kubectl delete namespace ollama-agent
kubectl delete namespace ingress-nginx
kind delete cluster --name ollama-agent
```

### 🐞 Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `connection refused` on apply | KIND cluster not running | `kind create cluster` first |
| `ImagePullBackOff` | Wrong image name | `kubectl describe pod` → check DockerHub name |
| `nc: bad address 'ollama-mongodb-headless'` | Service name mismatch | `kubectl get svc -n ollama-agent` → match name in initContainer |
| PVC stuck in `Pending` | StorageClass missing | `kubectl apply -f cluster/storageclass.yaml` |
| `CrashLoopBackOff` | App crash on start | `kubectl logs <pod> --previous` |
| Ingress not routing | Controller not ready | `kubectl get pods -n ingress-nginx` — wait `1/1 Running` |
| `selector is immutable` | Labels changed on existing Deployment | Delete deployment first, then reapply |
| Backend can't reach MongoDB | Mongo pod not fully ready | Check `kubectl get pods` — must be `1/1 Running` |

---

## 🌐 API Reference

### Auth Routes (Public)

| Method | Endpoint | Body | Description |
|--------|----------|------|-------------|
| `POST` | `/api/auth/signup` | `{username, email, password}` | Create account |
| `POST` | `/api/auth/login` | `{email, password}` | Login, returns JWT |
| `GET` | `/api/auth/me` | Bearer token | Get current user |

### Chat Routes (JWT Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/chat/message` | Send message — returns SSE stream |
| `GET` | `/api/chat/history` | All chats for logged-in user |
| `GET` | `/api/chat/:chatId` | Load a specific chat |
| `DELETE` | `/api/chat/:chatId` | Delete a chat |
| `GET` | `/api/chat/models/list` | List available Ollama models |

### Test with curl

```bash
# Signup
curl -X POST http://localhost:5005/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@test.com","password":"123456"}'

# Login + save token
TOKEN=$(curl -s -X POST http://localhost:5005/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}' | jq -r '.token')

# Send message
curl -X POST http://localhost:5005/api/chat/message \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello AI!","model":"tinyllama"}'
```

---

## ☁️ AWS EC2 Deployment

### Recommended Instance Types

| Model | RAM | EC2 Instance | vCPUs | Cost/mo |
|-------|-----|--------------|-------|---------|
| tinyllama / phi | 4 GB | `t2.medium` | 2 | ~$20 |
| llama2 / mistral | 8 GB | **`t2.large`** ✅ | 2 | ~$60 |
| llama3 / codellama | 16 GB | `t2.xlarge` | 4 | ~$120 |
| Multiple models | 32 GB | `m5.2xlarge` | 8 | ~$280 |

> ✅ **Recommended: `t2.large`** — enough for llama2/mistral with room for OS + Docker + MongoDB.

### Security Group Rules

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | Your IP only | SSH |
| 80 | TCP | 0.0.0.0/0 | HTTP |
| 443 | TCP | 0.0.0.0/0 | HTTPS |
| 3000 | TCP | 0.0.0.0/0 | Frontend |
| 5005 | TCP | 0.0.0.0/0 | Backend |
| 11434 | TCP | 127.0.0.1/32 | Ollama — **localhost only, never expose** |

### EC2 Setup (Ubuntu 22.04)

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip

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

# Clone and run
git clone https://github.com/techwithburhan/ollama-agent.git
cd ollama-agent/backend && npm install && NODE_ENV=production npm start &
cd ../frontend && npm install && npm run build
```

---
# 🚀 Terraform Remote Backend on AWS — Complete Guide

> **Production-ready Terraform setup with S3 remote state storage, DynamoDB state locking, and multi-EC2 provisioning using `for_each` and `locals`.**

---

## 📁 Project Structure

```
terraform-remote-backend/
│
├── terraform-backend/          # Phase 1 — Create the backend infrastructure
│   ├── backend-infra.tf        # S3 bucket + DynamoDB table
│   ├── variables.tf            # Backend-specific variables
│   └── terraform.tf            # AWS provider config (local backend here)
│
└── terraform/                  # Phase 2 — Main infra using remote backend
    ├── terraform.tf            # Provider + S3 backend config
    ├── main.tf                 # EC2, Security Group, Key Pair, EIP
    ├── variables.tf            # All input variables
    ├── output.tf               # Outputs (IPs, SSH commands, instance IDs)
    └── terraform.pub           # Your SSH public key
```

---

## 🧠 What This Project Does

This project demonstrates a **two-phase Terraform workflow**:

### Phase 1 — Backend Infrastructure
Creates the AWS resources needed to store Terraform state remotely:
- **S3 Bucket** — stores the `terraform.tfstate` file (versioned & encrypted)
- **DynamoDB Table** — handles state locking using a `LockID` partition key

### Phase 2 — Main Infrastructure
Provisions real AWS compute resources using the remote backend:
- **EC2 Instances** — two Ubuntu 22.04 instances using `for_each`
- **Security Group** — allows SSH (22), HTTP (80), and port 3000
- **SSH Key Pair** — using your local public key
- **Elastic IPs** — static public IPs attached to each instance

---

## 🔑 Key Concepts Explained

### 1. 🗂️ Terraform State Management

Terraform uses a **state file** (`terraform.tfstate`) to track what real-world resources it manages. Think of it as Terraform's memory.

**Problems with local state:**
- If you lose the file, Terraform loses track of your infra
- Two people running `terraform apply` at the same time = conflicts
- No backup, no history

**Solution → Remote Backend (S3)**

```hcl
# terraform.tf
backend "s3" {
  bucket         = "agent-pilot-terraform-state"
  key            = "terraform.tfstate"
  region         = "eu-west-1"
  dynamodb_table = "terraform-DynamoDB"
}
```

Now the state file lives in S3 — shared, versioned, and encrypted.

---

### 2. 🔐 State Locking with DynamoDB

**What is State Locking?**

When you run `terraform apply`, Terraform writes a **lock record** into DynamoDB before doing anything. This prevents another person or CI/CD pipeline from running apply at the same time.

**How it works (6 steps):**

```
Step 1 → You run: terraform apply
Step 2 → Terraform ACQUIRES LOCK in DynamoDB (writes LockID entry)
Step 3 → Terraform READS state file from S3
Step 4 → Terraform PROVISIONS/UPDATES resources in AWS
Step 5 → Terraform UPDATES state file back to S3
Step 6 → Terraform RELEASES the lock from DynamoDB
```

If someone else runs apply while the lock exists → they get an error:
```
Error: Error acquiring the state lock
```

**DynamoDB Table config from your project:**

```hcl
# backend-infra.tf
resource "aws_dynamodb_table" "my_dynamodb_table" {
  name         = var.aws_dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"          # ← This is the magic key

  attribute {
    name = "LockID"
    type = "S"                      # S = String type
  }
}
```

> **Key insight:** The `LockID` attribute is what Terraform looks for. It must be exactly `"LockID"` — this is a Terraform convention.

---

### 3. 📦 locals Block

`locals` are **local variables** inside your Terraform config — they cannot be passed from outside. Use them to define values you reuse or compute internally.

**From your `main.tf`:**

```hcl
locals {
  instances = {
    instance1 = { name = "instance1", instance_type = var.instance_type }
    instance2 = { name = "instance2", instance_type = var.instance_type }
  }
}
```

**Why use locals here?**
- One place to control how many EC2s are created
- Want 3 instances? Just add `instance3 = { ... }` — done!
- Want a different type for one instance? Override just that entry:

```hcl
instance3 = { name = "instance3", instance_type = "t2.small" }
```

**Accessing locals:**
```hcl
for_each = local.instances     # ← access with local. prefix
```

---

### 4. 🔁 for_each

`for_each` creates **one resource per item** in a map or set. Much more powerful than `count` for named resources.

**From your `main.tf`:**

```hcl
resource "aws_instance" "advanced_ec2" {
  for_each = local.instances        # loops over the map

  ami           = data.aws_ami.ubuntu.id
  instance_type = each.value.instance_type   # access map value
  tags = {
    Name = each.value.name          # each.key = "instance1", each.value = { name=..., type=... }
  }
}
```

**Result:** Terraform creates:
- `aws_instance.advanced_ec2["instance1"]`
- `aws_instance.advanced_ec2["instance2"]`

**Referencing for_each resources:**

```hcl
resource "aws_eip" "ec2_eip" {
  for_each = local.instances
  instance = aws_instance.advanced_ec2[each.key].id   # ← reference by key
}
```

**Key variables inside for_each:**

| Variable | Meaning |
|----------|---------|
| `each.key` | The map key → `"instance1"` |
| `each.value` | The map value → `{ name = "instance1", instance_type = "t2.micro" }` |
| `each.value.name` | Nested field access |

---

### 5. 🔢 count (vs for_each)

`count` creates **N identical copies** of a resource using an index number.

**Example (not in your project but good to know):**

```hcl
resource "aws_instance" "server" {
  count         = 3
  ami           = "ami-12345"
  instance_type = "t2.micro"

  tags = {
    Name = "server-${count.index}"   # server-0, server-1, server-2
  }
}
```

**Referencing count resources:**
```hcl
aws_instance.server[0].id
aws_instance.server[1].id
```

**count vs for_each — When to use which:**

| | `count` | `for_each` |
|---|---------|------------|
| **Use when** | All resources identical, just need N copies | Each resource has different config |
| **Addressed by** | Index number [0], [1]... | String key ["instance1"]... |
| **Remove middle item** | ⚠️ Renumbers everything! | ✅ Only removes that item |
| **Your project** | ❌ Not used | ✅ Used for EC2 + EIP |

> **Best practice:** Prefer `for_each` over `count` for most real-world use cases.

---

### 6. 📤 Outputs with for expressions

Your `output.tf` uses **for expressions** to build maps from `for_each` resources:

```hcl
output "elastic_ips" {
  value = { for k, v in aws_eip.ec2_eip : k => v.public_ip }
}
# Result: { "instance1" = "3.248.105.11", "instance2" = "54.220.226.108" }

output "ssh_commands" {
  value = { for k, v in aws_eip.ec2_eip : k => "ssh -i ~/.ssh/id_rsa ubuntu@${v.public_ip}" }
}
# Result: { "instance1" = "ssh -i ~/.ssh/id_rsa ubuntu@3.248.105.11", ... }
```

---

### 7. 📋 variables.tf

Variables make your config reusable and parameterizable.

```hcl
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-west-1"     # Used unless overridden
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "terraform-key"
}
```

**Override at runtime:**
```bash
terraform apply -var="instance_type=t3.small"
```

---

## ⚙️ Prerequisites

Before you start, make sure you have:

- [ ] **AWS Account** with IAM user credentials configured
- [ ] **AWS CLI** installed and configured (`aws configure`)
- [ ] **Terraform** v1.0+ installed
- [ ] **SSH key pair** generated (instructions below)

**Check your setup:**
```bash
aws --version
terraform --version
aws sts get-caller-identity    # Confirms your credentials work
```

---

## 🔧 Step-by-Step Setup Instructions

### Step 1 — Clone the Repository

```bash
git clone <YOUR_GITHUB_URL>
cd terraform-remote-backend
```

---

### Step 2 — Generate SSH Key Pair

```bash
ssh-keygen -t rsa -b 4096 -f terraform
# This creates two files:
#   terraform     → private key (keep secret, never commit!)
#   terraform.pub → public key (used by Terraform)
```

Copy `terraform.pub` into the `terraform/` folder:
```bash
cp terraform.pub terraform/
```

---

### Step 3 — Phase 1: Create the Backend Infrastructure

Navigate to the backend folder and deploy S3 + DynamoDB:

```bash
cd terraform-backend

# Initialize Terraform (downloads AWS provider)
terraform init

# Preview what will be created
terraform plan

# Create S3 bucket and DynamoDB table
terraform apply -auto-approve
```

**Expected output:**
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

> Note the S3 bucket name and DynamoDB table name from the output — you'll need them in the next step.

---

### Step 4 — Update Backend Config in terraform/terraform.tf

Open `terraform/terraform.tf` and update with your actual bucket name:

```hcl
backend "s3" {
  bucket         = "agent-pilot-terraform-state"   # ← your S3 bucket name
  key            = "terraform.tfstate"
  region         = "eu-west-1"
  dynamodb_table = "terraform-DynamoDB"            # ← your DynamoDB table name
}
```

---

### Step 5 — Phase 2: Initialize Main Terraform with Remote Backend

```bash
cd ../terraform

terraform init
```

Terraform will ask:
```
Do you want to copy existing state to the new backend?
Enter a value: yes
```

Type `yes` and press Enter.

**Success looks like:**
```
Successfully configured the backend "s3"!
Terraform has been successfully initialized!
```

---

### Step 6 — Plan and Apply Main Infrastructure

```bash
# See what Terraform will create
terraform plan

# Create all resources (2 EC2s, Security Group, Key Pair, 2 EIPs)
terraform apply -auto-approve
```

**Expected output:**
```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:
elastic_ips = {
  "instance1" = "3.248.105.11"
  "instance2" = "54.220.226.108"
}
ssh_commands = {
  "instance1" = "ssh -i ~/.ssh/id_rsa ubuntu@3.248.105.11"
  "instance2" = "ssh -i ~/.ssh/id_rsa ubuntu@54.220.226.108"
}
```

---

### Step 7 — SSH into Your Instances

```bash
# SSH into instance1
ssh -i terraform ubuntu@<elastic_ip_instance1>

# SSH into instance2
ssh -i terraform ubuntu@<elastic_ip_instance2>
```

---

### Step 8 — Verify State is in S3

Go to AWS Console → S3 → your bucket → you should see `terraform.tfstate`

Or via CLI:
```bash
aws s3 ls s3://agent-pilot-terraform-state/
```

---

### Step 9 — Verify State Lock in DynamoDB

Go to AWS Console → DynamoDB → terraform-DynamoDB → Explore items

While `terraform apply` is running, you'll see a `LockID` entry appear. It disappears after apply completes.

---

### Step 10 — Clean Up (Destroy Everything)

```bash
# Destroy main infrastructure first
cd terraform/
terraform destroy -auto-approve

# Then destroy backend infrastructure
cd ../terraform-backend/
terraform destroy -auto-approve
```

> ⚠️ Always destroy main infra BEFORE backend infra, otherwise you'll lose the state file!

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                   Developer / CI-CD                  │
└─────────────────────┬───────────────────────────────┘
                      │ terraform apply
                      ▼
              ┌───────────────┐
              │   Terraform   │
              └──┬────────────┘
                 │
       ┌─────────┼─────────────┐
       │         │             │
       ▼         ▼             ▼
  ┌─────────┐ ┌──────────┐ ┌──────────────┐
  │   S3    │ │ DynamoDB │ │     AWS      │
  │ State   │ │  Lock    │ │  Resources   │
  │  File   │ │  Table   │ │  (EC2, EIP)  │
  └─────────┘ └──────────┘ └──────────────┘
  Versioned    LockID key    instance1
  Encrypted    prevents      instance2
               conflicts
```

---

## 📌 Common Commands Reference

```bash
# Initialize terraform (run first or after backend changes)
terraform init

# Preview changes (dry run)
terraform plan

# Apply changes
terraform apply

# Apply without confirmation prompt
terraform apply -auto-approve

# Destroy all resources
terraform destroy

# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource in state
terraform state show aws_instance.advanced_ec2[\"instance1\"]

# Force unlock if state is stuck
terraform force-unlock <LOCK_ID>

# Refresh state (sync with real AWS)
terraform refresh

# Format all .tf files
terraform fmt

# Validate configuration
terraform validate

# View outputs
terraform output
terraform output elastic_ips
```

---

## 🛠️ Customization

### Add More EC2 Instances

In `terraform/main.tf`, add entries to the `locals` block:

```hcl
locals {
  instances = {
    instance1 = { name = "instance1", instance_type = var.instance_type }
    instance2 = { name = "instance2", instance_type = var.instance_type }
    instance3 = { name = "instance3", instance_type = "t2.small" }   # ← Add this
    instance4 = { name = "instance4", instance_type = "t3.micro" }   # ← Or this
  }
}
```

Then run:
```bash
terraform plan    # Will show 2 new resources being added
terraform apply
```

### Change Region

```bash
terraform apply -var="aws_region=ap-south-1"    # Mumbai
terraform apply -var="aws_region=us-east-1"     # Virginia
```

### Change Instance Type

```bash
terraform apply -var="instance_type=t3.small"
```

---

## ⚠️ Security Notes

- `cidr_blocks = ["0.0.0.0/0"]` on SSH port is open to the world — **restrict to your IP in production**
- Never commit `terraform` (private key) to Git — add it to `.gitignore`
- Enable S3 bucket versioning and encryption for production state buckets
- Add IAM policies to restrict who can read/write the state bucket

**.gitignore recommendations:**
```
terraform           # private SSH key
*.tfstate           # never commit state files
*.tfstate.backup
.terraform/         # provider downloads
.terraform.lock.hcl
terraform.tfvars    # if contains secrets
```

---

## 🙏 Credits

Special thanks to **@ShubhamLonde** for guidance and mentorship on this project.

---

## 📜 License

MIT License — free to use, modify, and distribute.

---
## 🎯 Interview Questions & Answers

### 🐳 Docker

**Q: Image vs Container?**
> Image = read-only blueprint (code + deps + OS). Container = running instance of that image. Multiple containers can run from one image, each isolated.

**Q: What is a multi-stage Docker build?**
> Multiple `FROM` in one Dockerfile. Stage 1: Node.js builds the React app. Stage 2: Nginx serves only the static output — no source code, no dev deps. Result: 10× smaller, more secure image.

**Q: What is `host.docker.internal`?**
> DNS name resolving to the host machine's IP from inside a container. Used so the backend container reaches Ollama running on the host. On Linux: `--add-host=host.docker.internal:host-gateway`.

**Q: COPY vs ADD?**
> `COPY` copies files from build context. `ADD` also extracts tars and fetches URLs. Always use `COPY` unless you need `ADD`'s extras.

**Q: `restart: always`?**
> Auto-restarts the container on any exit — crashes, OOM, reboots.

**Q: How to reduce image size?**
> Multi-stage builds, Alpine/slim base images, combine `RUN` commands, `.dockerignore` to exclude `node_modules`, `.git`, logs.

---

### ☸️ Kubernetes

**Q: Deployment vs StatefulSet?**
> Deployment = stateless, pods interchangeable, any order. StatefulSet = stateful (MongoDB) — stable hostname per pod (`mongodb-0`), ordered startup, own storage per pod.

**Q: What is a Headless Service?**
> `clusterIP: None` — no load balancing. DNS returns individual pod IPs. MongoDB uses it so each pod has stable DNS (`mongodb-0.ollama-mongodb`) for replication.

**Q: What is a PVC?**
> Request for storage. Without PVC, data is lost on restart. With PVC, storage is independent — MongoDB data survives pod crashes and rescheduling.

**Q: How does HPA work?**
> Monitors CPU/memory vs target (70%). Exceeds → add replicas. Drops → remove replicas. Respects `minReplicas`/`maxReplicas`. Needs Metrics Server.

**Q: What is an initContainer?**
> Runs to completion before main container starts. Used here to loop `nc -z ollama-mongodb 27017` until MongoDB is ready — prevents backend crash on startup.

**Q: ClusterIP vs NodePort vs LoadBalancer?**
> ClusterIP = internal only. NodePort = opens port on every node for external access. LoadBalancer = cloud LB (AWS ELB). KIND has no LB support — use ClusterIP + port-forward.

**Q: Ingress vs Service?**
> Service = one app, one port. Ingress = L7 HTTP router — `/` to frontend, `/api` to backend. Requires Ingress Controller (nginx). One Ingress replaces multiple LoadBalancers.

**Q: ConfigMap vs Secret?**
> ConfigMap = non-sensitive (URLs, ports). Secret = sensitive (JWT, passwords) — base64 encoded, encrypted at rest, hidden from `describe pod`.

**Q: What is CrashLoopBackOff?**
> Pod keeps crashing — K8s restarts with increasing delays. Debug: `kubectl logs <pod> --previous` + `kubectl describe pod`.

**Q: How does Rolling Update achieve zero downtime?**
> Creates new pod → waits for readiness probe → terminates old pod → repeats. `maxUnavailable: 1` = 1 pod offline max. `maxSurge: 1` = 1 extra pod allowed. Traffic only goes to ready pods.

**Q: Liveness vs Readiness probe?**
> Liveness = "Is pod alive?" → fails → restart. Readiness = "Is pod ready for traffic?" → fails → remove from load balancer (no restart).

---

### 🔐 Security

**Q: How does JWT work here?**
> Login → backend signs JWT with `JWT_SECRET` (user ID + expiry). Frontend sends `Authorization: Bearer <token>`. Middleware verifies signature, extracts user ID — no DB lookup per request.

**Q: Why bcrypt over MD5/SHA256?**
> bcrypt is slow by design — makes brute-force impractical. MD5/SHA256 are fast — crackable with GPU in seconds. bcrypt auto-includes salt, preventing rainbow table attacks.

**Q: Why restrict Ollama to localhost?**
> Public port 11434 = anyone can query your LLM and use your server's resources for free. Always keep it on `127.0.0.1` or internal cluster traffic only.

---

### ⚡ Streaming & Performance

**Q: SSE vs WebSockets for AI chat?**
> SSE = one-way server → client over HTTP/1.1 — perfect for streaming tokens. WebSockets = bidirectional — overkill here. SSE auto-reconnects, simpler to implement, works over standard HTTP.

**Q: Why `proxy_buffering off` for SSE?**
> Nginx buffers full response before forwarding. With SSE, the stream never ends during generation — buffering means the user sees nothing until complete. `proxy_buffering off` forwards each token chunk immediately.

---

## 🗺️ Project Roadmap

```
ollama-agent/
│
├── ✅ Full Stack App        React + Node.js + MongoDB
├── ✅ Docker               Multi-stage builds + DockerHub
├── ✅ Docker Compose        Local dev environment
├── ✅ Kubernetes (KIND)     HPA + Ingress + StatefulSet + PVC
├── 🚧 CI/CD                GitHub Actions (Build → Test → Push → Deploy)
├── 🚧 Terraform            AWS VPC + EC2 + EKS
├── 🚧 AWS EKS              Managed Kubernetes
└── 🚧 Monitoring           Prometheus + Grafana
```

---

## ⭐ Support the Project

- ⭐ **Star** this repo
- 👍 **Like** the YouTube video
- 🔔 **Subscribe** to the channel
- 🔗 **Share** with your network

---

## 📲 Connect with @techwithburhan

<div align="center">

| Platform | Link |
|----------|------|
| 🎬 YouTube — DevOps \| AI \| AWS | [youtube.com/@TechWithBurhanHQ](https://www.youtube.com/@TechWithBurhanHQ) |
| 🎬 YouTube — CCNA \| Networking | [youtube.com/@codewithburhan1](https://youtube.com/@codewithburhan1) |
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
